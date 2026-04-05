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

interface DetectionResult {
  productModel: string;
  energyEfficiency: string;
  powerConsumption: string;
  isDataMatch: boolean;
  defects: Defects;
  position: Position;
  isPass: boolean;
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
  energyEfficiency: string;
  powerConsumption: number;
}

interface NewProduct {
  model: string;
  energyEfficiency: string;
  powerConsumption: number;
}

interface DetectionRecord {
  id: string;
  timestamp: string;
  productModel: string;
  energyEfficiency: string;
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

export {
  Defects,
  Position,
  DetectionResult,
  SystemStatus,
  CameraParams,
  DetectionParams,
  Product,
  NewProduct,
  DetectionRecord,
  SearchParams
}
