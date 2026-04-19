"""
常驻检测 HTTP 服务 - 模型只加载一次，后续请求直接推理
替代 detect_api.py 的每次 spawn 新进程方式

API:
  POST /detect  body: {"image_path": "xxx.jpg"}  → 返回检测结果 JSON
  GET  /health  → 健康检查

用法: python detect_server.py [--port 5001]
"""

import sys
import os
import json
import argparse
import time

if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    sys.stderr.reconfigure(encoding='utf-8', errors='replace')

from http.server import HTTPServer, BaseHTTPRequestHandler

# 延迟导入重量级模块
import cv2
import numpy as np

# 模型路径
_MODEL_CANDIDATES = [
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "best.pt"),
    r"D:\yolo_test\train\weights\best.pt",
]
MODEL_PATH = next((p for p in _MODEL_CANDIDATES if os.path.exists(p)), _MODEL_CANDIDATES[-1])

# 全局模型（只加载一次）
model = None


def load_model_once():
    global model
    if model is None:
        from ultralytics import YOLO
        print(f"[模型] 正在加载 {MODEL_PATH} ...")
        t0 = time.time()
        model = YOLO(MODEL_PATH)
        print(f"[模型] 加载完成，耗时 {time.time() - t0:.1f}s")
    return model


# ===== 以下检测逻辑直接从 detect_api.py 复用 =====

def hue_to_grade(hue):
    if hue > 168 or hue < 12:
        return 5
    elif 12 <= hue < 24:
        return 4
    elif 24 <= hue < 36:
        return 3
    elif 36 <= hue < 65:
        return 2
    elif 65 <= hue <= 105:
        return 1
    return None


def _analyze_roi(hsv, roi_h, roi_w, sat_thr):
    right_edges = np.zeros(roi_h)
    for y in range(roi_h):
        row = hsv[y]
        mask = (row[:, 1] > sat_thr) & (row[:, 2] > 60)
        colored = np.where(mask)[0]
        if len(colored) >= 3:
            right_edges[y] = colored[-1]

    grade_start = 0
    in_header = False
    for y in range(roi_h):
        if right_edges[y] > roi_w * 0.3:
            in_header = True
        elif in_header and right_edges[y] < roi_w * 0.15:
            for y2 in range(y, roi_h):
                if right_edges[y2] > roi_w * 0.15:
                    grade_start = y2
                    break
            break

    search_end = min(roi_h, grade_start + 80)
    grade_edges = right_edges[grade_start:search_end]
    grade_h = len(grade_edges)

    if grade_h < 10:
        return None, {"grade_start": int(grade_start), "error": "short"}

    nonzero = grade_edges[grade_edges > 0]
    if len(nonzero) < 5:
        return None, {"error": "no_color"}

    median_edge = float(np.median(nonzero))
    arrow_threshold = median_edge * 1.3

    arrow_mask = grade_edges > arrow_threshold
    arrow_indices = np.where(arrow_mask)[0]

    debug = {
        "grade_start": int(grade_start),
        "median_edge": round(median_edge, 1),
        "arrow_threshold": round(arrow_threshold, 1),
        "arrow_count": len(arrow_indices),
    }

    if len(arrow_indices) < 3:
        return None, {**debug, "error": "no_arrow"}

    all_hues = []
    hue_sample_thr = max(sat_thr, 50)
    for idx in arrow_indices:
        actual_y = grade_start + idx
        row = hsv[actual_y]
        hi_mask = (row[:, 1] > hue_sample_thr) & (row[:, 2] > 50)
        hi_pixels = np.where(hi_mask)[0]
        if len(hi_pixels) >= 3:
            hues = row[hi_pixels, 0]
            all_hues.extend(hues.tolist())

    if len(all_hues) < 10:
        return None, {**debug, "error": "few_hues"}

    hue_array = np.array(all_hues)

    bins = [0, 0, 0, 0, 0]
    for hue_val in hue_array:
        h = float(hue_val)
        if h > 168 or h < 12:
            bins[4] += 1
        elif 12 <= h < 24:
            bins[3] += 1
        elif 24 <= h < 36:
            bins[2] += 1
        elif 36 <= h < 65:
            bins[1] += 1
        elif 65 <= h <= 105:
            bins[0] += 1

    total_pixels = sum(bins)
    debug["hue_bins"] = {f"G{i+1}": b for i, b in enumerate(bins)}
    debug["hue_median"] = round(float(np.median(hue_array)), 1)

    best_bin = bins.index(max(bins))
    grade = best_bin + 1
    debug["grade"] = int(grade)
    debug["confidence"] = round(max(bins) / total_pixels, 2) if total_pixels > 0 else 0

    return grade, debug


def _detect_with_roi(crop, ry1, ry2, rx2):
    h, w = crop.shape[:2]
    roi = crop[int(h * ry1):int(h * ry2), 0:int(w * rx2)]
    roi_h, roi_w = roi.shape[:2]

    if roi_h < 20 or roi_w < 20:
        return None, {"error": "roi_small"}

    hsv = cv2.cvtColor(roi, cv2.COLOR_BGR2HSV)

    for sat_thr in [40, 25, 15]:
        result = _analyze_roi(hsv, roi_h, roi_w, sat_thr)
        if result[0] is not None:
            result[1]["sat_thr"] = sat_thr
            return result

    return None, {"error": "sat_adaptive_failed"}


def detect_grade(crop):
    """颜色检测能效等级 1-5，带回退机制"""
    grade, debug = _detect_with_roi(crop, 0.08, 0.58, 0.58)
    if grade is not None:
        return grade, debug

    grade2, debug2 = _detect_with_roi(crop, 0.05, 0.65, 0.60)
    if grade2 is not None:
        debug2["fallback"] = "wide_roi"
        return grade2, debug2

    grade3, debug3 = _detect_with_roi(crop, 0.10, 0.55, 0.55)
    if grade3 is not None:
        debug3["fallback"] = "original_roi"
        return grade3, debug3

    ch, cw = crop.shape[:2]
    big_crop = cv2.resize(crop, (cw * 4, ch * 4), interpolation=cv2.INTER_CUBIC)
    grade4, debug4 = _detect_with_roi(big_crop, 0.08, 0.58, 0.58)
    if grade4 is not None:
        debug4["fallback"] = "upscaled_4x"
        return grade4, debug4

    grade5, debug5 = _detect_with_roi(crop, 0.05, 0.75, 0.70)
    if grade5 is not None:
        debug5["fallback"] = "wide_search"
        return grade5, debug5

    return None, {**debug, "error": "all_failed"}


def extract_ocr(crop):
    try:
        from paddleocr import PaddleOCR
        import re
        ocr = PaddleOCR(use_angle_cls=True, lang='ch', show_log=False)
        h, w = crop.shape[:2]

        # 尝试多个放大倍数
        best_grade = None
        best_grade_conf = 0
        best_grade_method = ''
        all_texts = []
        energy_param = None
        standby_power = None

        for scale in [4, 3, 5]:
            big_crop = cv2.resize(crop, (w * scale, h * scale), interpolation=cv2.INTER_CUBIC)
            result = ocr.ocr(big_crop, cls=True)

            if not result or not result[0]:
                continue

            texts = []
            for line in result[0]:
                text = line[1][0]
                confidence = round(line[1][1], 3)
                texts.append({'text': text, 'confidence': confidence})
                all_texts.append({'text': text, 'confidence': confidence, 'scale': scale})

            for item in texts:
                t = item['text'].strip()
                c = item['confidence']

                # 提取能效参数
                decimal_matches = re.findall(r'\d+\.\d+', t)
                for dm in decimal_matches:
                    val = float(dm)
                    if val >= 0.01 and val <= 999:
                        if energy_param is None:
                            energy_param = val
                        elif standby_power is None:
                            standby_power = val

                # 方法1: 匹配 "X级" 模式（最可靠）
                grade_match = re.search(r'([1-5])\s*级', t)
                if grade_match:
                    g = int(grade_match.group(1))
                    if c > best_grade_conf:
                        best_grade = g
                        best_grade_conf = c
                        best_grade_method = 'ocr_x级'

                # 方法2: 匹配纯数字 1-5（高置信度）
                if c > 0.85 and len(t) == 1 and t in '12345':
                    g = int(t)
                    if best_grade_method != 'ocr_x级' and c > best_grade_conf:
                        best_grade = g
                        best_grade_conf = c
                        best_grade_method = 'ocr_digit'

                # 方法3: 匹配 "能效X" 或 "等级X"
                grade_match2 = re.search(r'(?:能效|等级)\s*([1-5])', t)
                if grade_match2:
                    g = int(grade_match2.group(1))
                    if best_grade_method != 'ocr_x级' and c > best_grade_conf:
                        best_grade = g
                        best_grade_conf = c
                        best_grade_method = 'ocr_keyword'

            # 如果已经用 x级 模式找到了，不需要继续放大
            if best_grade_method == 'ocr_x级':
                break

        return {
            'texts': all_texts,
            'energy_param': energy_param,
            'standby_power': standby_power,
            'grade_from_ocr': best_grade,
            'grade_ocr_confidence': best_grade_conf,
            'grade_ocr_method': best_grade_method,
        }
    except ImportError:
        return {'error': 'PaddleOCR 未安装', 'texts': [], 'energy_param': None,
                'standby_power': None, 'grade_from_ocr': None}
    except Exception as e:
        return {'error': str(e), 'texts': [], 'energy_param': None,
                'standby_power': None, 'grade_from_ocr': None}


def is_label_upside_down(crop):
    """分析标签裁剪图中的白底区域，判断是否颠倒。
    能效标签有两块大白底：上部（产品信息区）和下部（参数区）。
    正常方向：上部白底高度 >= 下部白底高度
    颠倒方向：上部白底高度 <  下部白底高度 → 需要旋转180°
    """
    gray = cv2.cvtColor(crop, cv2.COLOR_BGR2GRAY)
    h, w = gray.shape

    # 二值化提取白色区域（亮度 > 200）
    _, binary = cv2.threshold(gray, 200, 255, cv2.THRESH_BINARY)

    # 形态学操作去除噪点
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (max(w // 30, 3), max(h // 30, 3)))
    binary = cv2.morphologyEx(binary, cv2.MORPH_CLOSE, kernel)
    binary = cv2.morphologyEx(binary, cv2.MORPH_OPEN, kernel)

    # 找轮廓
    contours, _ = cv2.findContours(binary, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    # 过滤出较大的白色区域（面积 > 标签面积的 3%）
    min_area = h * w * 0.03
    white_regions = []
    for cnt in contours:
        area = cv2.contourArea(cnt)
        if area > min_area:
            rx, ry, rw, rh = cv2.boundingRect(cnt)
            white_regions.append({
                'area': area,
                'y': ry,
                'h': rh,
                'cy': ry + rh / 2,  # 中心y
            })

    if len(white_regions) < 2:
        return False  # 不足两个白底区域，无法判断

    # 按面积排序，取最大的两个白底区域
    white_regions.sort(key=lambda r: r['area'], reverse=True)
    r1, r2 = white_regions[0], white_regions[1]

    # 按 y 坐标区分上下
    if r1['cy'] < r2['cy']:
        top_h, bottom_h = r1['h'], r2['h']
        top_area, bottom_area = r1['area'], r2['area']
    else:
        top_h, bottom_h = r2['h'], r1['h']
        bottom_area, top_area = r1['area'], r2['area']

    debug_info = {
        'top_h': top_h, 'bottom_h': bottom_h,
        'top_area': int(top_area), 'bottom_area': int(bottom_area),
        'region_count': len(white_regions),
    }
    print(f"[旋转检测] 上部白底高度={top_h}, 下部白底高度={bottom_h}, 区域数={len(white_regions)}")

    # 上部白底高度 < 下部白底高度 → 颠倒了
    if top_h < bottom_h * 0.85:
        print(f"[旋转] 判定为颠倒，将旋转180°")
        return True

    return False


def auto_rotate_exif(image_path):
    """根据 EXIF 信息自动旋转图片"""
    try:
        from PIL import Image
        from PIL.ExifTags import TAGS
        img = Image.open(image_path)
        exif = img._getexif()
        if not exif:
            return
        orientation = None
        for tag_id, value in exif.items():
            tag_name = TAGS.get(tag_id, tag_id)
            if tag_name == 'Orientation':
                orientation = value
                break
        if orientation == 3:
            img = img.rotate(180, expand=True)
        elif orientation == 6:
            img = img.rotate(270, expand=True)
        elif orientation == 8:
            img = img.rotate(90, expand=True)
        else:
            return
        img.save(image_path)
        print(f"[旋转] EXIF Orientation={orientation}，已自动旋转")
    except Exception:
        pass


def analyze_image(image_path):
    # 第一步：EXIF 旋转
    auto_rotate_exif(image_path)

    img = cv2.imread(image_path)
    if img is None:
        return {'success': False, 'error': '无法读取图片'}

    m = load_model_once()
    results = m(image_path, verbose=False, conf=0.15)

    detections = []
    best_label = None
    best_label_conf = 0
    best_label_bbox = None
    defects = {'isDamaged': False, 'isStained': False, 'isWrinkled': False}
    position = {'isCorrect': True, 'x': 0, 'y': 0, 'deviation': 0}
    has_label = False

    for result in results:
        for box in result.boxes:
            cls_name = result.names[int(box.cls[0])]
            conf = float(box.conf[0])
            bx1, by1, bx2, by2 = map(int, box.xyxy[0])

            detections.append({
                'class': cls_name,
                'confidence': round(conf, 3),
                'bbox': [bx1, by1, bx2, by2]
            })

            cls_lower = cls_name.lower()

            if cls_lower in ['label', 'nor'] and conf > best_label_conf:
                best_label_conf = conf
                best_label = img[by1:by2, bx1:bx2]
                best_label_bbox = [bx1, by1, bx2, by2]
                has_label = True
                img_h, img_w = img.shape[:2]
                position['x'] = (bx1 + bx2) // 2
                position['y'] = (by1 + by2) // 2
                position['deviation'] = round(
                    abs((bx1 + bx2) / 2 - img_w / 2) / img_w * 100, 1)
                position['isCorrect'] = position['deviation'] <= 10

            if cls_lower == 'break':
                defects['isDamaged'] = True
            elif cls_lower == 'stain':
                defects['isStained'] = True
            elif cls_lower == 'wrinkle':
                defects['isWrinkled'] = True

    # 检测到标签后，判断是否颠倒
    rotated = False
    if has_label and best_label is not None and best_label.size > 0:
        if is_label_upside_down(best_label):
            # 旋转原图180°并重新检测
            img_rotated = cv2.rotate(img, cv2.ROTATE_180)
            cv2.imwrite(image_path, img_rotated)
            rotated = True
            print("[旋转] 已旋转图片180°，重新检测")

            # 重置状态重新检测
            results2 = m(image_path, verbose=False, conf=0.15)
            detections = []
            best_label = None
            best_label_conf = 0
            best_label_bbox = None
            defects = {'isDamaged': False, 'isStained': False, 'isWrinkled': False}
            position = {'isCorrect': True, 'x': 0, 'y': 0, 'deviation': 0}
            has_label = False

            for result in results2:
                for box in result.boxes:
                    cls_name = result.names[int(box.cls[0])]
                    conf = float(box.conf[0])
                    bx1, by1, bx2, by2 = map(int, box.xyxy[0])

                    detections.append({
                        'class': cls_name,
                        'confidence': round(conf, 3),
                        'bbox': [bx1, by1, bx2, by2]
                    })

                    cls_lower = cls_name.lower()

                    if cls_lower in ['label', 'nor'] and conf > best_label_conf:
                        best_label_conf = conf
                        best_label = img_rotated[by1:by2, bx1:bx2]
                        best_label_bbox = [bx1, by1, bx2, by2]
                        has_label = True
                        img_h, img_w = img_rotated.shape[:2]
                        position['x'] = (bx1 + bx2) // 2
                        position['y'] = (by1 + by2) // 2
                        position['deviation'] = round(
                            abs((bx1 + bx2) / 2 - img_w / 2) / img_w * 100, 1)
                        position['isCorrect'] = position['deviation'] <= 10

                    if cls_lower == 'break':
                        defects['isDamaged'] = True
                    elif cls_lower == 'stain':
                        defects['isStained'] = True
                    elif cls_lower == 'wrinkle':
                        defects['isWrinkled'] = True

    if not has_label:
        return {
            'success': True, 'grade': None, 'gradeMethod': None, 'gradeConfidence': None,
            'energyParam': None, 'standbyPower': None,
            'defects': defects, 'position': position,
            'isPass': False, 'detections': detections,
            'labelFound': False, 'hasDefect': any(defects.values()),
            'message': '未检测到能效标签'
        }

    has_defect = defects['isDamaged'] or defects['isStained'] or defects['isWrinkled']

    if has_defect:
        return {
            'success': True, 'grade': None, 'gradeMethod': None, 'gradeConfidence': None,
            'energyParam': None, 'standbyPower': None,
            'defects': defects, 'position': position,
            'isPass': False, 'detections': detections,
            'labelFound': True, 'hasDefect': True,
            'labelConfidence': round(best_label_conf, 3),
            'labelBbox': best_label_bbox,
            'message': '检测到标签缺陷，跳过等级检测'
        }

    # 同时运行颜色和 OCR 检测，优先 OCR
    grade = None
    grade_debug = None
    ocr_result = None

    if best_label is not None and best_label.size > 0:
        # OCR 优先 - "X级" 模式识别
        ocr_result = extract_ocr(best_label)

        # 颜色分析作为备用
        grade, grade_debug = detect_grade(best_label)

    # 等级判定优先级：OCR "X级" > OCR 纯数字 > 颜色分析
    final_grade = None
    grade_method = None
    grade_confidence = None

    if ocr_result and ocr_result.get('grade_from_ocr'):
        ocr_method = ocr_result.get('grade_ocr_method', '')
        ocr_conf = ocr_result.get('grade_ocr_confidence', 0)
        # OCR "X级" 模式最可靠，直接采用
        if ocr_method == 'ocr_x级':
            final_grade = ocr_result['grade_from_ocr']
            grade_method = 'ocr_级字'
            grade_confidence = ocr_conf
        elif grade is None:
            # 颜色失败时，用 OCR 结果
            final_grade = ocr_result['grade_from_ocr']
            grade_method = 'ocr'
            grade_confidence = ocr_conf
        else:
            # 颜色和 OCR 都有结果，一致则用颜色，不一致优先 OCR
            if grade == ocr_result['grade_from_ocr']:
                final_grade = grade
                grade_method = 'color+ocr'
                grade_confidence = grade_debug.get('confidence') if grade_debug else None
            else:
                final_grade = ocr_result['grade_from_ocr']
                grade_method = 'ocr(颜色不一致)'
                grade_confidence = ocr_conf
    elif grade is not None:
        final_grade = grade
        grade_method = 'color'
        grade_confidence = grade_debug.get('confidence') if grade_debug else None

    energy_param = None
    standby_power = None
    if ocr_result:
        energy_param = ocr_result.get('energy_param')
        standby_power = ocr_result.get('standby_power')

    is_pass = final_grade is not None and position['isCorrect']

    return {
        'success': True,
        'grade': final_grade,
        'gradeMethod': grade_method,
        'gradeConfidence': grade_confidence,
        'energyParam': energy_param,
        'standbyPower': standby_power,
        'defects': defects,
        'position': position,
        'isPass': is_pass,
        'detections': detections,
        'labelFound': True,
        'hasDefect': False,
        'labelConfidence': round(best_label_conf, 3),
        'labelBbox': best_label_bbox,
        'labelCropSize': f"{best_label.shape[1]}x{best_label.shape[0]}" if best_label is not None else None,
        'rotated': rotated,
    }


# ===== HTTP 服务 =====

class DetectHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/health':
            self._json_response({'status': 'ok', 'model_loaded': model is not None})
        else:
            self._json_response({'endpoints': {'POST /detect': '检测图片', 'GET /health': '健康检查'}})

    def do_POST(self):
        if self.path == '/detect':
            length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(length)
            try:
                data = json.loads(body)
                image_path = data.get('image_path', '')
            except Exception:
                self._json_response({'success': False, 'error': '无效请求'}, 400)
                return

            if not image_path or not os.path.exists(image_path):
                self._json_response({'success': False, 'error': f'图片不存在: {image_path}'}, 400)
                return

            t0 = time.time()
            try:
                result = analyze_image(image_path)
                result['detectionTime'] = round(time.time() - t0, 2)
                self._json_response(result)
            except Exception as e:
                self._json_response({'success': False, 'error': str(e)}, 500)
        else:
            self._json_response({'error': '未知接口'}, 404)

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def _json_response(self, data, code=200):
        self.send_response(code)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(json.dumps(data, ensure_ascii=False).encode('utf-8'))

    def log_message(self, format, *args):
        msg = args[0] if args else ''
        print(f"[检测] {msg}")


def main():
    parser = argparse.ArgumentParser(description='常驻检测服务')
    parser.add_argument('--port', type=int, default=5001, help='服务端口 (默认 5001)')
    args = parser.parse_args()

    print("=" * 50)
    print("  常驻检测服务 (模型只加载一次)")
    print(f"  地址: http://localhost:{args.port}")
    print("=" * 50)

    # 预加载模型
    load_model_once()

    server = HTTPServer(('0.0.0.0', args.port), DetectHandler)
    try:
        print(f"\n[服务] 已启动，端口 {args.port}")
        print("[服务] 按 Ctrl+C 停止\n")
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n[服务] 正在停止...")
        server.server_close()


if __name__ == '__main__':
    main()
