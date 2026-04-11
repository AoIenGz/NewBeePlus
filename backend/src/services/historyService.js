// 历史记录服务
class HistoryService {
  constructor() {
    // 模拟检测记录数据
    this.detectionRecords = [
      {
        id: '1',
        timestamp: '2024-01-01T10:00:00',
        productModel: 'HB-2024-001',
        energyEfficiency: 'A+',
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
      },
      {
        id: '2',
        timestamp: '2024-01-01T10:05:00',
        productModel: 'HB-2024-002',
        energyEfficiency: 'A',
        isDataMatch: true,
        defects: {
          isDamaged: false,
          isStained: true,
          isWrinkled: false,
        },
        position: {
          isCorrect: true,
          x: 118,
          y: 82,
          deviation: 0.8,
        },
        isPass: false,
      },
      {
        id: '3',
        timestamp: '2024-01-01T10:10:00',
        productModel: 'HB-2024-003',
        energyEfficiency: 'B',
        isDataMatch: true,
        defects: {
          isDamaged: false,
          isStained: false,
          isWrinkled: false,
        },
        position: {
          isCorrect: false,
          x: 100,
          y: 70,
          deviation: 2.5,
        },
        isPass: false,
      },
    ];
  }

  // 获取检测记录
  getDetectionRecords(filters) {
    let records = [...this.detectionRecords];
    
    // 应用过滤条件
    if (filters.productModel) {
      records = records.filter(record => record.productModel === filters.productModel);
    }
    
    if (filters.startDate) {
      records = records.filter(record => new Date(record.timestamp) >= new Date(filters.startDate));
    }
    
    if (filters.endDate) {
      records = records.filter(record => new Date(record.timestamp) <= new Date(filters.endDate));
    }
    
    if (filters.status) {
      const isPass = filters.status === 'pass';
      records = records.filter(record => record.isPass === isPass);
    }
    
    return records;
  }

  // 根据ID获取检测记录
  getDetectionRecordById(id) {
    const record = this.detectionRecords.find(r => r.id === id);
    if (!record) {
      throw new Error('记录未找到');
    }
    return record;
  }

  // 导出检测记录为CSV
  exportDetectionRecords(filters) {
    const records = this.getDetectionRecords(filters);
    
    // CSV头部
    let csv = 'ID,时间戳,产品型号,能效等级,数据匹配,破损,污渍,褶皱,位置是否正确,X坐标,Y坐标,偏差值,检测结果\n';
    
    // 转换数据为CSV行
    records.forEach(record => {
      const row = [
        record.id,
        record.timestamp,
        record.productModel,
        record.energyEfficiency,
        record.isDataMatch ? '是' : '否',
        record.defects.isDamaged ? '是' : '否',
        record.defects.isStained ? '是' : '否',
        record.defects.isWrinkled ? '是' : '否',
        record.position.isCorrect ? '是' : '否',
        record.position.x,
        record.position.y,
        record.position.deviation,
        record.isPass ? '通过' : '失败'
      ];
      csv += row.join(',') + '\n';
    });
    
    return csv;
  }
}

module.exports = new HistoryService();