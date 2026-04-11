// 检测服务
class DetectionService {
  constructor() {
    // 模拟检测结果
    this.detectionResult = {
      productModel: 'HB-2024-001',
      energyEfficiency: 'A+',
      powerConsumption: '120W',
      isDataMatch: true,
      defects: {
        isDamaged: false,
        isStained: false,
        isWrinkled: false,
      },
      position: {
        isCorrect: true,
        x: 120,
        y: 80,
        deviation: 0.5,
      },
      isPass: true,
    };
    this.isDetecting = false;
  }

  // 获取检测结果
  getDetectionResult() {
    return this.detectionResult;
  }

  // 开始检测
  startDetection() {
    this.isDetecting = true;
    console.log('检测已开始');
  }

  // 停止检测
  stopDetection() {
    this.isDetecting = false;
    console.log('检测已停止');
  }

  // 导入机器学习结果
  importMLResult(result) {
    this.detectionResult = result;
    console.log('机器学习结果导入成功');
  }
}

module.exports = new DetectionService();