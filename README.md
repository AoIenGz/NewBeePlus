# 产品能效标签与缺陷检测系统

基于 OpenHarmony（API 20）开发的产品能效标签与缺陷检测系统，集成 YOLOv8 深度学习模型，支持手动检测与工业产线自动检测两种模式。

## 系统功能

### 双模式检测

#### 手动模式（图片选择）
通过三种方式选择图片进行检测：
- **选择图片**：从相册选择图片进行分析
- **拍照检测**：调用设备相机实时拍摄标签
- **测试图片**：加载内置测试图片验证检测效果

#### 产线模式（工业相机）
接入工业相机或网络摄像头实现流水线自动检测：
- **自动拍照**：按设定时间间隔（5s/10s/30s/60s）自动捕获标签图像
- **网络摄像头**：支持通过 HTTP 接入网络摄像头实时预览和拍照
- **自动分析**：每次拍照后自动调用后端进行检测分析
- **实时统计**：显示检测总数、通过率、缺陷统计、平均耗时、运行时长
- **开始/暂停/结束**：灵活控制检测流程

### 检测能力
- **能效等级识别**：通过颜色分析和 OCR 识别 1~5 级能效标签
- **缺陷检测**：检测标签是否存在破损、污渍、褶皱等缺陷
- **位置检测**：判断能效标签是否粘贴在规定位置，显示坐标和偏差值
- **参数提取**：识别能效参数和待机功率

## 项目结构

```
MyGo/
├── AppScope/                  # 应用全局配置
├── entry/                     # 主模块
│   ├── src/main/ets/
│   │   ├── common/
│   │   │   └── Interfaces.ets # 类型定义
│   │   ├── entryability/      # 应用入口
│   │   └── pages/
│   │       ├── Index.ets      # 主页面（双模式检测）
│   │       ├── CameraPage.ets # 相机拍照页面
│   │       ├── Settings.ets   # 设置页面
│   │       └── History.ets    # 历史记录页面
│   └── src/main/resources/
│       └── rawfile/test_images/ # 测试图片
├── backend/
│   ├── src/
│   │   ├── api/               # API 路由
│   │   ├── db/                # 数据库模块（sql.js SQLite）
│   │   ├── services/          # 业务逻辑
│   │   ├── python/            # Python ML 检测引擎
│   │   │   ├── detect_api.py  # YOLO + 颜色分析 + OCR（回退模式）
│   │   │   ├── detect_server.py # 常驻检测服务（模型预加载，推荐）
│   │   │   ├── webcam_server.py # 网络摄像头流服务
│   │   │   └── best.pt        # YOLO 模型权重
│   │   └── server.js          # 服务器入口
│   ├── data/                  # 数据库文件目录
│   └── package.json
└── build-profile.json5
```

## 检测引擎

后端 Python 检测引擎集成多阶段分析：

1. **YOLO 目标检测**：检测标签位置和缺陷类型（破损/污渍/褶皱）
2. **颜色分析**：基于 HSV 色彩空间识别能效等级（87% 准确率）
3. **OCR 识别**：PaddleOCR 提取能效参数和待机功率，辅助等级判定

检测服务支持两种运行模式：
- **常驻服务模式（推荐）**：通过 `detect_server.py` 启动 HTTP 服务（端口 5001），模型预加载，响应更快
- **Spawn 回退模式**：每次检测启动新 Python 进程，无需额外部署，但较慢

## 测试图片

内置 13 张测试图片，位于 `entry/src/main/resources/rawfile/test_images/`：

| 类型 | 数量 | 示例文件 |
|------|------|---------|
| 能效等级标签（正常） | 5 张 | `test_L1~L5_nor.jpg` |
| 破损缺陷 (DAM) | 2 张 | `A02_L2_T01_DAM_003.jpg` |
| 污渍缺陷 (STA) | 2 张 | `A02_L2_T04_STA_023.jpg` |
| 褶皱缺陷 (WRI) | 2 张 | `A02_L2_T06_WRI_015.jpg` |
| 位置偏移 | 2 张 | `A02_L2_T06_NOR_022.jpg` |

## 页面说明

### 主页面（Index.ets）
顶部模式切换按钮在手动模式和产线模式之间切换：

**手动模式**：
- 图片预览区 → 操作按钮（选择图片/拍照/测试图片/分析）→ 检测结果卡片

**产线模式**：
- 相机预览 + 实时统计面板 → 控制栏（开始/暂停/结束 + 间隔选择）→ 检测记录列表

### 设置页面（Settings.ets）
- 检测参数配置（精度、速度、阈值）
- 服务器地址配置
- 网络摄像头地址配置
- 工业相机默认拍照间隔配置

### 历史记录页面（History.ets）
- 检测记录查询（按型号、日期、状态过滤）
- 统计分析（通过率、缺陷统计、位置偏差）
- 记录管理（单条删除、一键清空）
- CSV 报告导出

## 技术栈

### 前端
- **框架**：OpenHarmony（API 20）+ ArkTS
- **相机**：`@ohos.multimedia.camera` + XComponent
- **网络**：`@ohos.net.http` RESTful API
- **导航**：`@ohos.router`

### 后端
- **服务**：Node.js + Express.js
- **存储**：sql.js（SQLite WebAssembly 本地存储）
- **检测**：Python + Ultralytics YOLO + PaddleOCR + OpenCV
- **通信**：Node.js 子进程调用 Python 脚本

## 运行

### 1. 启动后端

```bash
cd backend
npm install
npm start
```

后端运行在 `http://localhost:3000`，需要 Python 环境及 YOLO 模型文件。数据库文件自动生成在 `backend/data/detection.db`。

可选启动常驻检测服务（推荐，检测更快）：
```bash
cd backend/src/python
python detect_server.py
```

可选启动网络摄像头服务：
```bash
python webcam_server.py
```

### 2. 运行前端

1. 在 DevEco Studio 中打开项目
2. 配置 OpenHarmony SDK（API 20）
3. 编译并部署到目标设备

## 后端 API

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/detection/analyze` | 分析图片（base64） |
| GET | `/api/detection/result` | 获取最新检测结果 |
| GET | `/api/history` | 获取检测记录 |
| GET | `/api/history/stats` | 获取统计数据 |
| DELETE | `/api/history/:id` | 删除单条记录 |
| DELETE | `/api/history` | 清空所有记录 |
| GET | `/api/history/export/csv` | 导出 CSV |
| GET | `/api/products` | 产品管理 |
| GET | `/health` | 健康检查 |
