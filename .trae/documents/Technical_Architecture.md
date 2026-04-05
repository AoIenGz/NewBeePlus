## 1. 架构设计
```mermaid
diagram TD
    A[OpenHarmony 应用] --> B[ETS 前端]
    B --> C[相机管理模块]
    B --> D[图像处理模块]
    B --> E[数据比对模块]
    B --> F[结果显示模块]
    B --> G[设置管理模块]
    B --> H[历史记录模块]
    C --> I[工业相机]
    D --> J[图像处理算法]
    E --> K[预设产品数据]
    H --> L[本地存储]
```

## 2. 技术描述
- 前端：OpenHarmony 6.0.2 + ETS (ArkTS)
- 开发工具：DevEco Studio
- 相机接口：使用 OpenHarmony 相机 API
- 图像处理：使用 OpenHarmony 图像处理 API
- 数据存储：使用 OpenHarmony 本地存储 API
- 图表库：使用 OpenHarmony 内置图表组件

## 3. 页面路由
| 页面名称 | 路由路径 | 功能描述 |
|-----------|-------------|---------------------|
| 主页面 | pages/Index | 实时检测界面，显示相机画面和检测结果 |
| 设置页面 | pages/Settings | 配置检测参数和管理产品信息 |
| 历史记录页面 | pages/History | 查看历史检测结果和导出报告 |

## 4. 核心模块设计
### 4.1 相机管理模块
- 功能：连接和控制工业相机，获取实时图像流
- API：使用 OpenHarmony 相机 API
- 实现：使用 CameraKit 和 SurfaceProvider 组件

### 4.2 图像处理模块
- 功能：对相机获取的图像进行处理，识别能效标签
- 实现：使用 OpenHarmony 图像处理 API，结合 OCR 技术

### 4.3 数据比对模块
- 功能：将识别的能效标签数据与预设的产品型号信息进行比对
- 实现：使用本地存储的产品数据进行比对

### 4.4 缺陷检测模块
- 功能：检测标签是否存在破损、污渍、褶皱等缺陷
- 实现：使用图像处理算法进行缺陷识别

### 4.5 位置检测模块
- 功能：判断能效标签是否粘贴在规定位置
- 实现：使用图像处理算法进行位置检测

### 4.6 结果显示模块
- 功能：实时显示检测结果，包括数据信息、缺陷检测结果和位置检测结果
- 实现：使用 OpenHarmony 界面组件

### 4.7 设置管理模块
- 功能：配置检测参数，管理产品型号信息
- 实现：使用 OpenHarmony 界面组件和本地存储 API

### 4.8 历史记录模块
- 功能：记录和查询历史检测结果，导出报告
- 实现：使用 OpenHarmony 本地存储 API

## 5. 数据模型
### 5.1 产品型号数据
```typescript
interface Product {
  id: string;
  model: string; // 产品型号
  energyEfficiency: string; // 能效等级
  powerConsumption: number; // 功耗
  otherParams: Record<string, string>; // 其他参数
}
```

### 5.2 检测结果数据
```typescript
interface DetectionResult {
  id: string;
  timestamp: number; // 检测时间
  productModel: string; // 产品型号
  energyLabelData: Record<string, string>; // 能效标签数据
  isDataMatch: boolean; // 数据是否匹配
  defects: {
    isDamaged: boolean; // 是否破损
    isStained: boolean; // 是否有污渍
    isWrinkled: boolean; // 是否有褶皱
  };
  position: {
    isCorrect: boolean; // 位置是否正确
    x: number; // x坐标
    y: number; // y坐标
    deviation: number; // 偏差值
  };
  isPass: boolean; // 是否通过检测
}
```

### 5.3 系统配置数据
```typescript
interface SystemConfig {
  cameraParams: {
    resolution: string; // 分辨率
    frameRate: number; // 帧率
    exposure: number; // 曝光时间
  };
  detectionParams: {
    precision: number; // 检测精度
    speed: number; // 检测速度
    threshold: number; // 阈值
  };
  uiParams: {
    theme: string; // 主题
    language: string; // 语言
  };
}
```

## 6. 实现计划
1. 搭建 OpenHarmony 项目基础结构
2. 实现主页面的布局和基本功能
3. 实现相机管理模块，连接工业相机
4. 实现图像处理和识别功能
5. 实现数据比对和缺陷检测功能
6. 实现位置检测功能
7. 实现设置页面和产品管理功能
8. 实现历史记录页面和报告导出功能
9. 测试和优化系统性能
10. 完成系统部署和用户培训
