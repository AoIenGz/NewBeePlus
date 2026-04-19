interface Defects {
  isDamaged: boolean;
  isStained: boolean;
  isWrinkled: boolean;
}

interface Position {
  isCorrect: boolean;
  x?: number;
  y?: number;
  deviation: number;
}

// 后端 Python 检测返回的原始结果
interface AnalyzeResult {
  success: boolean;
  error?: string;
  grade: number | null;
  gradeMethod: string | null;
  gradeConfidence: number | null;
  energyParam: number | null;
  standbyPower: number | null;
  defects: Defects;
  position: Position;
  isPass: boolean;
  detections: Array<DetectionItem>;
  labelFound: boolean;
  hasDefect?: boolean;
  labelConfidence?: number;
  labelBbox?: number[];
  message?: string;
}

interface DetectionItem {
  class: string;
  confidence: number;
  bbox: number[];
}

// 前端展示用的检测结果
interface DetectionResult {
  grade: number;
  gradeMethod: string;
  gradeConfidence: number;
  energyParam: string;
  standbyPower: string;
  isDataMatch: boolean;
  defects: Defects;
  position: Position;
  isPass: boolean;
  labelFound: boolean;
  hasDefect: boolean;
  detections: DetectionItem[];
}

interface SystemStatus {
  cameraStatus: string;
  detectionSpeed: string;
  uptime: string;
}

interface CameraParams {
  resolution: string;
  frameRate: number;
  exposure: number;
}

interface DetectionParams {
  precision: number;
  speed: number;
  threshold: number;
}

interface Product {
  id: string;
  model: string;
  energyGrade: number;
  powerConsumption: number;
}

interface NewProduct {
  model: string;
  energyGrade: number;
  powerConsumption: number;
}

interface DetectionRecord {
  id: string;
  timestamp: string;
  productModel: string;
  grade: number;
  energyParam: string;
  isDataMatch: boolean;
  defects: Defects;
  position: Position;
  isPass: boolean;
}

interface SearchParams {
  productModel: string;
  startDate: string;
  endDate: string;
  status: string;
}

// 检测模式
type DetectionMode = 'manual' | 'industrial';

// 工业相机配置
interface IndustrialCameraConfig {
  captureInterval: number;  // 捕获间隔(秒)
}

// 产线模式会话统计
interface DetectionSessionStats {
  totalCaptures: number;
  passCount: number;
  failCount: number;
  passRate: number;
  averageTime: number;
  sessionStart: number;
  defectDamaged: number;
  defectStained: number;
  defectWrinkled: number;
}

// 产线模式单条检测记录
interface AutoDetectionRecord {
  id: number;
  timestamp: string;
  imageUri: string;
  thumbnail: string;
  result: DetectionResult | null;
  status: 'captured' | 'analyzing' | 'completed' | 'failed';
  errorMessage: string;
}

// 网络摄像头信息
interface WebcamCameraInfo {
  index: number;
  name: string;
  resolution: string;
  fps: number;
  backend: string;
}

export {
  Defects,
  Position,
  AnalyzeResult,
  DetectionItem,
  DetectionResult,
  SystemStatus,
  CameraParams,
  DetectionParams,
  Product,
  NewProduct,
  DetectionRecord,
  SearchParams,
  DetectionMode,
  IndustrialCameraConfig,
  DetectionSessionStats,
  AutoDetectionRecord,
  WebcamCameraInfo
}
