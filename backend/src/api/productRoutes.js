const express = require('express');
const router = express.Router();
const productService = require('../services/productService');

// 获取所有产品
router.get('/', (req, res) => {
  try {
    const products = productService.getProducts();
    res.status(200).json(products);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 获取单个产品
router.get('/:id', (req, res) => {
  try {
    const { id } = req.params;
    const product = productService.getProductById(id);
    res.status(200).json(product);
  } catch (error) {
    res.status(404).json({ error: '产品未找到' });
  }
});

// 添加产品
router.post('/', (req, res) => {
  try {
    const productData = req.body;
    const newProduct = productService.addProduct(productData);
    res.status(201).json(newProduct);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// 更新产品
router.put('/:id', (req, res) => {
  try {
    const { id } = req.params;
    const productData = req.body;
    const updatedProduct = productService.updateProduct(id, productData);
    res.status(200).json(updatedProduct);
  } catch (error) {
    res.status(404).json({ error: '产品未找到' });
  }
});

// 删除产品
router.delete('/:id', (req, res) => {
  try {
    const { id } = req.params;
    productService.deleteProduct(id);
    res.status(200).json({ message: '产品已删除' });
  } catch (error) {
    res.status(404).json({ error: '产品未找到' });
  }
});

module.exports = router;