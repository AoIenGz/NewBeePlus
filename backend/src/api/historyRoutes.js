const express = require('express');
const router = express.Router();
const historyService = require('../services/historyService');

// 获取所有检测记录
router.get('/', (req, res) => {
  try {
    const { productModel, startDate, endDate, status } = req.query;
    const records = historyService.getDetectionRecords({ productModel, startDate, endDate, status });
    res.status(200).json(records);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 获取单个检测记录
router.get('/:id', (req, res) => {
  try {
    const { id } = req.params;
    const record = historyService.getDetectionRecordById(id);
    res.status(200).json(record);
  } catch (error) {
    res.status(404).json({ error: '记录未找到' });
  }
});

// 导出检测记录
router.get('/export/csv', (req, res) => {
  try {
    const { productModel, startDate, endDate, status } = req.query;
    const csvData = historyService.exportDetectionRecords({ productModel, startDate, endDate, status });
    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename=detection-records.csv');
    res.status(200).send(csvData);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;