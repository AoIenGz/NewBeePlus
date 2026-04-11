const express = require('express');
const cors = require('cors');
const detectionRoutes = require('./api/detectionRoutes');
const productRoutes = require('./api/productRoutes');
const historyRoutes = require('./api/historyRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// 中间件
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 路由
app.use('/api/detection', detectionRoutes);
app.use('/api/products', productRoutes);
app.use('/api/history', historyRoutes);

// 健康检查
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

// 启动服务器
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = app;