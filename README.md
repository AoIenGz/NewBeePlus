# 产品能效标签与缺陷检测系统

基于 OpenHarmony 6.0.2 开发的产品能效标签与缺陷检测系统，包含前端和后端服务。

## 系统功能

### 1. 产品能效检测系统
- **标签识别与校验**：通过工业相机采集产品能效数据，准确识别能效标签上的信息，并与预设的产品型号信息进行比对。

### 2. 产品质量检测
- **缺陷检测**：检测标签是否存在破损、污渍、褶皱等缺陷。
- **位置检测**：判断能效标签是否粘贴在规定位置。
- **实时反馈**：检测结果实时显示，便于生产环节的即时调整。

### 3. 系统可扩展性
- 系统可以灵活接入家电产品在工业生产中的其他场景功能。

### 4. 机器学习集成
- 支持导入机器学习检测结果
- 实时展示检测数据
- 与后端服务无缝集成

## 项目结构

```
/workspace/
├── AppScope/              # 应用全局配置
├── entry/                 # 主模块
│   ├── src/main/ets/      # ETS 代码
│   │   ├── common/        # 公共文件和接口定义
│   │   ├── entryability/  # 应用入口
│   │   ├── pages/         # 页面
│   │   │   ├── Index.ets  # 主页面（实时检测）
│   │   │   ├── Settings.ets  # 设置页面
│   │   │   └── History.ets  # 历史记录页面
│   │   └── resources/     # 资源文件
├── backend/               # 后端服务
│   ├── src/               # 后端代码
│   │   ├── api/           # API路由
│   │   ├── services/      # 业务逻辑服务
│   │   └── server.js      # 服务器入口
│   └── package.json       # 后端依赖
├── .trae/documents/       # 产品需求文档和技术架构文档
└── build-profile.json5    # 构建配置
```

## 页面说明

### 1. 主页面（Index.ets）
- **相机监控**：显示工业相机实时画面，支持开始/停止检测。
- **检测结果**：实时显示能效标签识别结果，包括产品型号、能效等级、功耗和数据匹配状态。
- **缺陷检测**：显示标签是否存在破损、污渍、褶皱等缺陷。
- **位置检测**：判断能效标签是否粘贴在规定位置，显示位置坐标和偏差值。
- **机器学习集成**：支持导入机器学习检测结果，实时更新检测数据。
- **系统状态**：显示相机连接状态、检测速度和系统运行时间。

### 2. 设置页面（Settings.ets）
- **参数配置**：配置相机参数（分辨率、帧率、曝光时间）和检测参数（精度、速度、阈值）。
- **产品管理**：添加、编辑、删除产品型号信息，包括产品型号、能效等级和功耗。

### 3. 历史记录页面（History.ets）
- **检测记录**：查看历史检测结果，支持按产品型号、日期和状态进行搜索和过滤。
- **统计分析**：显示总检测数、通过数、失败数、通过率、缺陷统计和位置偏差统计。
- **报告导出**：导出检测报告为 Excel 或 PDF 格式，支持选择时间范围。

## 技术实现

### 前端
- **框架**：OpenHarmony 6.0.2 + ETS (ArkTS)
- **页面导航**：使用 @ohos.router 实现页面跳转
- **状态管理**：使用 @State 装饰器管理组件状态
- **UI 组件**：使用 OpenHarmony 内置组件，如 Flex、Row、Column、Text、Button、TextInput、Slider 等
- **API 调用**：使用 fetch API 与后端服务通信

### 后端
- **框架**：Node.js + Express.js
- **API 风格**：RESTful API
- **数据处理**：内置服务层处理业务逻辑
- **跨域支持**：使用 CORS 中间件
- **文件上传**：支持通过 API 导入机器学习结果

## 运行环境

### 前端
- **开发工具**：DevEco Studio
- **OpenHarmony 版本**：6.0.2
- **目标设备**：工业平板或显示器

### 后端
- **运行环境**：Node.js 14.0 或更高版本
- **依赖管理**：npm
- **网络要求**：与前端应用在同一网络环境

## 如何运行

### 1. 启动后端服务

```bash
# 进入后端目录
cd backend

# 安装依赖
npm install

# 启动服务
npm start
```

后端服务将在 `http://localhost:3000` 运行。

### 2. 运行前端项目

1. 在 DevEco Studio 中打开项目
2. 配置 OpenHarmony 开发环境
3. 编译并运行项目到目标设备

## 系统特点

- **实时性**：实时显示检测结果，便于生产环节的即时调整。
- **准确性**：准确识别能效标签上的数据信息，并与预设的产品型号信息进行比对。
- **可扩展性**：系统可以灵活接入家电产品在工业生产中的其他场景功能。
- **用户友好**：直观的用户界面，便于操作和管理。
- **机器学习集成**：支持导入机器学习检测结果，提升检测精度和效率。

## 机器学习结果格式

导入机器学习结果时，需要使用以下JSON格式：

```json
{
  "productModel": "产品型号",
  "energyEfficiency": "能效等级",
  "powerConsumption": "功耗",
  "isDataMatch": true,
  "defects": {
    "isDamaged": false,
    "isStained": false,
    "isWrinkled": false
  },
  "position": {
    "isCorrect": true,
    "x": 120,
    "y": 80,
    "deviation": 0.5
  },
  "isPass": true
}
```

## 后端API接口

### 检测相关
- `GET /api/detection/result` - 获取实时检测结果
- `POST /api/detection/start` - 开始检测
- `POST /api/detection/stop` - 停止检测
- `POST /api/detection/import-ml-result` - 导入机器学习结果

### 产品相关
- `GET /api/products` - 获取所有产品
- `GET /api/products/:id` - 获取单个产品
- `POST /api/products` - 添加产品
- `PUT /api/products/:id` - 更新产品
- `DELETE /api/products/:id` - 删除产品

### 历史记录相关
- `GET /api/history` - 获取检测记录
- `GET /api/history/:id` - 获取单个检测记录
- `GET /api/history/export/csv` - 导出检测记录为CSV
