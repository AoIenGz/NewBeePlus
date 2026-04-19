const express = require('express');
const router = express.Router();
const historyService = require('../services/historyService');

// 获取检测记录（支持过滤）
router.get('/', (req, res) => {
  try {
    const { productModel, startDate, endDate, status } = req.query;
    const records = historyService.getDetectionRecords({ productModel, startDate, endDate, status });
    res.status(200).json(records);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 获取统计信息
router.get('/stats', (req, res) => {
  try {
    const stats = historyService.getStats();
    res.status(200).json(stats);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 获取单个检测记录
router.get('/:id', (req, res) => {
  try {
    const record = historyService.getDetectionRecordById(req.params.id);
    res.status(200).json(record);
  } catch (error) {
    res.status(404).json({ error: '记录未找到' });
  }
});

// 导出CSV
router.get('/export/csv', (req, res) => {
  try {
    const { productModel, startDate, endDate, status } = req.query;
    const csvData = historyService.exportDetectionRecords({ productModel, startDate, endDate, status });
    res.setHeader('Content-Type', 'text/csv; charset=utf-8');
    res.setHeader('Content-Disposition', 'attachment; filename=detection-records.csv');
    res.status(200).send(csvData);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 删除单条记录
router.delete('/:id', (req, res) => {
  try {
    historyService.deleteRecord(req.params.id);
    res.status(200).json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 清空所有记录
router.delete('/', (req, res) => {
  try {
    historyService.deleteAllRecords();
    res.status(200).json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
