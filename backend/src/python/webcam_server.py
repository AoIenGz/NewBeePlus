"""
电脑摄像头 HTTP 服务器
供模拟器上的 App 通过网络获取摄像头实时画面

API:
  GET /cameras          - 列出可用摄像头
  POST /camera/select   - 选择摄像头 { "index": 0 }
  GET /frame.jpg        - 获取当前帧 JPEG 图片
  GET /status           - 当前摄像头状态

用法: python webcam_server.py [--port 5000]
"""

import sys
import os
import json
import argparse
import threading
import time

# 修复 Windows 控制台编码
if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    sys.stderr.reconfigure(encoding='utf-8', errors='replace')

import cv2
import numpy as np
from http.server import HTTPServer, BaseHTTPRequestHandler


class WebcamManager:
    """摄像头管理器，支持多摄像头切换"""

    def __init__(self):
        self.current_index = -1
        self.cap = None
        self.lock = threading.Lock()
        self.latest_frame = None
        self.frame_lock = threading.Lock()
        self.cameras_info = []
        self._scan_cameras()

    def _scan_cameras(self, max_check=5):
        """扫描可用摄像头"""
        self.cameras_info = []
        for i in range(max_check):
            cap = cv2.VideoCapture(i, cv2.CAP_DSHOW)
            if cap.isOpened():
                w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
                h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
                fps = int(cap.get(cv2.CAP_PROP_FPS))
                backend = cap.getBackendName()
                name = f"Camera {i}"
                # 尝试获取摄像头名称
                try:
                    name_prop = cap.get(cv2.CAP_PROP_BACKEND)
                except:
                    pass
                self.cameras_info.append({
                    "index": i,
                    "name": name,
                    "resolution": f"{w}x{h}",
                    "fps": fps,
                    "backend": backend,
                })
                cap.release()
        if self.cameras_info:
            print(f"[摄像头] 发现 {len(self.cameras_info)} 个摄像头:")
            for cam in self.cameras_info:
                print(f"  [{cam['index']}] {cam['name']} - {cam['resolution']} @ {cam['fps']}fps ({cam['backend']})")
        else:
            print("[摄像头] 未检测到任何摄像头")

    def select_camera(self, index):
        """切换摄像头"""
        with self.lock:
            if index < 0 or index >= len(self.cameras_info):
                return False, f"无效的摄像头索引: {index}"
            old_cap = self.cap
            self.cap = None
            self.current_index = index
            if old_cap is not None:
                try:
                    old_cap.release()
                except:
                    pass
            time.sleep(0.1)
            try:
                new_cap = cv2.VideoCapture(index, cv2.CAP_DSHOW)
                if not new_cap.isOpened():
                    return False, f"无法打开摄像头 {index}"
                # 尝试设置高分辨率
                new_cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
                new_cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
                ret, _ = new_cap.read()
                if not ret:
                    new_cap.release()
                    return False, f"摄像头 {index} 无法读取画面"
                self.cap = new_cap
                w = int(self.cap.get(cv2.CAP_PROP_FRAME_WIDTH))
                h = int(self.cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
                print(f"[摄像头] 已切换到 Camera {index} ({w}x{h})")
                return True, f"已切换到 Camera {index} ({w}x{h})"
            except Exception as e:
                print(f"[摄像头] 切换失败: {e}")
                return False, f"切换失败: {e}"

    def get_frame(self):
        """获取当前帧 JPEG 数据"""
        with self.lock:
            if self.cap is None or not self.cap.isOpened():
                return None
            try:
                ret, frame = self.cap.read()
                if not ret or frame is None:
                    return None
                _, buf = cv2.imencode('.jpg', frame, [cv2.IMWRITE_JPEG_QUALITY, 85])
                return buf.tobytes()
            except Exception:
                return None

    def get_status(self):
        """获取当前状态"""
        cam = None
        if 0 <= self.current_index < len(self.cameras_info):
            cam = self.cameras_info[self.current_index]
        return {
            "active": self.cap is not None and self.cap.isOpened(),
            "camera": cam,
            "available_cameras": self.cameras_info,
        }

    def release(self):
        if self.cap:
            self.cap.release()


# 全局管理器
manager = WebcamManager()


class WebcamHTTPHandler(BaseHTTPRequestHandler):
    """HTTP 请求处理"""

    def do_GET(self):
        if self.path == '/cameras':
            self._json_response(manager.cameras_info)
        elif self.path == '/frame.jpg':
            frame_data = manager.get_frame()
            if frame_data is None:
                self._json_response({"error": "摄像头未就绪或未选择"}, code=503)
                return
            self.send_response(200)
            self.send_header('Content-Type', 'image/jpeg')
            self.send_header('Cache-Control', 'no-cache, no-store')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(frame_data)
        elif self.path.startswith('/frame_b64'):
            frame_data = manager.get_frame()
            if frame_data is None:
                self._json_response({"error": "摄像头未就绪或未选择"}, code=503)
                return
            import base64
            b64_str = base64.b64encode(frame_data).decode('ascii')
            self._json_response({"data": b64_str})
        elif self.path == '/status':
            self._json_response(manager.get_status())
        else:
            self._json_response({
                "endpoints": {
                    "GET /cameras": "列出可用摄像头",
                    "POST /camera/select": "选择摄像头 (body: {\"index\": 0})",
                    "GET /frame.jpg": "获取当前帧 JPEG",
                    "GET /status": "当前状态",
                }
            })

    def do_POST(self):
        if self.path == '/camera/select':
            length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(length)
            try:
                data = json.loads(body)
                index = data.get('index', 0)
            except:
                self._json_response({"error": "无效的请求体"}, code=400)
                return
            ok, msg = manager.select_camera(index)
            self._json_response({"success": ok, "message": msg})
        elif self.path == '/camera/rescan':
            manager._scan_cameras()
            self._json_response({"cameras": manager.cameras_info})
        else:
            self._json_response({"error": "未知接口"}, code=404)

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
        # 简化日志
        if '/frame.jpg' not in (args[0] if args else ''):
            print(f"[HTTP] {args[0] if args else ''}")


def main():
    parser = argparse.ArgumentParser(description='摄像头 HTTP 服务器')
    parser.add_argument('--port', type=int, default=5000, help='服务端口 (默认 5000)')
    parser.add_argument('--camera', type=int, default=-1, help='自动选择摄像头索引')
    args = parser.parse_args()

    print("=" * 50)
    print("  摄像头 HTTP 服务器")
    print(f"  地址: http://localhost:{args.port}")
    print("=" * 50)

    if args.camera >= 0:
        manager.select_camera(args.camera)
    elif manager.cameras_info:
        # 默认选择第一个摄像头
        manager.select_camera(0)

    server = HTTPServer(('0.0.0.0', args.port), WebcamHTTPHandler)
    try:
        print(f"\n[服务] 已启动，端口 {args.port}")
        print("[服务] App 中访问地址: http://10.0.2.2:5000")
        print("[服务] 按 Ctrl+C 停止\n")
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n[服务] 正在停止...")
        manager.release()
        server.server_close()
        print("[服务] 已停止")


if __name__ == '__main__':
    main()
