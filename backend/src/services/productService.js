// 产品服务
class ProductService {
  constructor() {
    // 模拟产品数据
    this.products = [
      {
        id: '1',
        model: 'HB-2024-001',
        energyEfficiency: 'A+',
        powerConsumption: 120,
      },
      {
        id: '2',
        model: 'HB-2024-002',
        energyEfficiency: 'A',
        powerConsumption: 150,
      },
      {
        id: '3',
        model: 'HB-2024-003',
        energyEfficiency: 'B',
        powerConsumption: 200,
      },
    ];
  }

  // 获取所有产品
  getProducts() {
    return this.products;
  }

  // 根据ID获取产品
  getProductById(id) {
    const product = this.products.find(p => p.id === id);
    if (!product) {
      throw new Error('产品未找到');
    }
    return product;
  }

  // 添加产品
  addProduct(productData) {
    const newProduct = {
      id: (this.products.length + 1).toString(),
      ...productData,
    };
    this.products.push(newProduct);
    return newProduct;
  }

  // 更新产品
  updateProduct(id, productData) {
    const index = this.products.findIndex(p => p.id === id);
    if (index === -1) {
      throw new Error('产品未找到');
    }
    this.products[index] = {
      ...this.products[index],
      ...productData,
    };
    return this.products[index];
  }

  // 删除产品
  deleteProduct(id) {
    const index = this.products.findIndex(p => p.id === id);
    if (index === -1) {
      throw new Error('产品未找到');
    }
    this.products.splice(index, 1);
  }
}

module.exports = new ProductService();