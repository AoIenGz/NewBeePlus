import router from '@ohos.router';

@Entry
@Component
struct Settings {
  @State selectedTab: string = 'params';
  @State cameraParams: {
    resolution: string;
    frameRate: number;
    exposure: number;
  } = {
    resolution: '1920x1080',
    frameRate: 30,
    exposure: 100,
  };
  @State detectionParams: {
    precision: number;
    speed: number;
    threshold: number;
  } = {
    precision: 0.85,
    speed: 0.7,
    threshold: 0.6,
  };
  @State products: Array<{
    id: string;
    model: string;
    energyEfficiency: string;
    powerConsumption: number;
  }> = [
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
      powerConsumption: 180,
    },
  ];
  @State showAddProductDialog: boolean = false;
  @State newProduct: {
    model: string;
    energyEfficiency: string;
    powerConsumption: number;
  } = {
    model: '',
    energyEfficiency: '',
    powerConsumption: 0,
  };

  build() {
    Flex({
      direction: FlexDirection.Column,
      alignItems: ItemAlign.Stretch,
      justifyContent: FlexAlign.Start
    }) {
      // 顶部导航栏
      Row({
        alignItems: ItemAlign.Center,
        justifyContent: FlexAlign.SpaceBetween
      }) {
        Text('设置')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .textColor('#1a365d');
        Button('返回')
          .fontSize(14)
          .width(60)
          .height(32)
          .backgroundColor('#3182ce')
          .borderRadius(8)
          .onClick(() => {
            router.push({
              uri: 'pages/Index'
            });
          });
      }
      .padding(16)
      .backgroundColor('#f7fafc');

      // 标签页切换
      Row({
        alignItems: ItemAlign.Center,
        justifyContent: FlexAlign.Start
      }) {
        Button('参数配置')
          .fontSize(14)
          .width(100)
          .height(36)
          .backgroundColor(this.selectedTab === 'params' ? '#3182ce' : '#e2e8f0')
          .textColor(this.selectedTab === 'params' ? '#ffffff' : '#4a5568')
          .borderRadius(8)
          .onClick(() => {
            this.selectedTab = 'params';
          });
        Button('产品管理')
          .fontSize(14)
          .width(100)
          .height(36)
          .backgroundColor(this.selectedTab === 'products' ? '#3182ce' : '#e2e8f0')
          .textColor(this.selectedTab === 'products' ? '#ffffff' : '#4a5568')
          .borderRadius(8)
          .marginLeft(12)
          .onClick(() => {
            this.selectedTab = 'products';
          });
      }
      .padding(16)
      .backgroundColor('#ffffff');

      // 内容区域
      if (this.selectedTab === 'params') {
        this.ParamsConfig();
      } else if (this.selectedTab === 'products') {
        this.ProductManagement();
      }

      // 底部按钮
      Row({
        alignItems: ItemAlign.Center,
        justifyContent: FlexAlign.End
      }) {
        Button('保存设置')
          .fontSize(14)
          .width(100)
          .height(36)
          .backgroundColor('#38a169')
          .borderRadius(8);
      }
      .padding(16)
      .backgroundColor('#f7fafc');
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#edf2f7');

    // 添加产品对话框
    if (this.showAddProductDialog) {
      this.AddProductDialog();
    }
  }

  // 参数配置页面
  @Builder ParamsConfig() {
    Scroll() {
      Column({
        alignItems: ItemAlign.Stretch,
        justifyContent: FlexAlign.Start
      }) {
        // 相机参数
        Column({
          alignItems: ItemAlign.Stretch,
          justifyContent: FlexAlign.Start
        }) {
          Text('相机参数')
            .fontSize(16)
            .fontWeight(FontWeight.SemiBold)
            .textColor('#1a365d')
            .marginBottom(16);

          // 分辨率
          Column({
            alignItems: ItemAlign.Start,
            justifyContent: FlexAlign.Start
          }) {
            Text('分辨率')
              .fontSize(14)
              .textColor('#4a5568')
              .marginBottom(8);
            Row({
              alignItems: ItemAlign.Center,
              justifyContent: FlexAlign.SpaceBetween
            }) {
              Button('1280x720')
                .fontSize(14)
                .width(100)
                .height(32)
                .backgroundColor(this.cameraParams.resolution === '1280x720' ? '#3182ce' : '#e2e8f0')
                .textColor(this.cameraParams.resolution === '1280x720' ? '#ffffff' : '#4a5568')
                .borderRadius(8)
                .onClick(() => {
                  this.cameraParams.resolution = '1280x720';
                });
              Button('1920x1080')
                .fontSize(14)
                .width(100)
                .height(32)
                .backgroundColor(this.cameraParams.resolution === '1920x1080' ? '#3182ce' : '#e2e8f0')
                .textColor(this.cameraParams.resolution === '1920x1080' ? '#ffffff' : '#4a5568')
                .borderRadius(8)
                .onClick(() => {
                  this.cameraParams.resolution = '1920x1080';
                });
              Button('2560x1440')
                .fontSize(14)
                .width(100)
                .height(32)
                .backgroundColor(this.cameraParams.resolution === '2560x1440' ? '#3182ce' : '#e2e8f0')
                .textColor(this.cameraParams.resolution === '2560x1440' ? '#ffffff' : '#4a5568')
                .borderRadius(8)
                .onClick(() => {
                  this.cameraParams.resolution = '2560x1440';
                });
            }
          }
          .marginBottom(16);

          // 帧率
          Column({
            alignItems: ItemAlign.Start,
            justifyContent: FlexAlign.Start
          }) {
            Row({
              alignItems: ItemAlign.Center,
              justifyContent: FlexAlign.SpaceBetween
            }) {
              Text('帧率: ' + this.cameraParams.frameRate + ' fps')
                .fontSize(14)
                .textColor('#4a5568');
            }
            .marginBottom(8);
            Slider({
              value: this.cameraParams.frameRate,
              min: 10,
              max: 60,
              step: 1,
              style: SliderStyle.OutSet
            })
              .width('100%')
              .onChange((value: number) => {
                this.cameraParams.frameRate = value;
              });
          }
          .marginBottom(16);

          // 曝光时间
          Column({
            alignItems: ItemAlign.Start,
            justifyContent: FlexAlign.Start
          }) {
            Row({
              alignItems: ItemAlign.Center,
              justifyContent: FlexAlign.SpaceBetween
            }) {
              Text('曝光时间: ' + this.cameraParams.exposure + ' ms')
                .fontSize(14)
                .textColor('#4a5568');
            }
            .marginBottom(8);
            Slider({
              value: this.cameraParams.exposure,
              min: 10,
              max: 500,
              step: 10,
              style: SliderStyle.OutSet
            })
              .width('100%')
              .onChange((value: number) => {
                this.cameraParams.exposure = value;
              });
          }
        }
        .padding(16)
        .backgroundColor('#ffffff')
        .borderRadius(8)
        .shadow({
          color: '#000000',
          radius: 4,
          offsetX: 0,
          offsetY: 2,
          blurRadius: 8
        })
        .marginBottom(16);

        // 检测参数
        Column({
          alignItems: ItemAlign.Stretch,
          justifyContent: FlexAlign.Start
        }) {
          Text('检测参数')
            .fontSize(16)
            .fontWeight(FontWeight.SemiBold)
            .textColor('#1a365d')
            .marginBottom(16);

          // 检测精度
          Column({
            alignItems: ItemAlign.Start,
            justifyContent: FlexAlign.Start
          }) {
            Row({
              alignItems: ItemAlign.Center,
              justifyContent: FlexAlign.SpaceBetween
            }) {
              Text('检测精度: ' + (this.detectionParams.precision * 100).toFixed(0) + '%')
                .fontSize(14)
                .textColor('#4a5568');
            }
            .marginBottom(8);
            Slider({
              value: this.detectionParams.precision,
              min: 0.5,
              max: 0.95,
              step: 0.05,
              style: SliderStyle.OutSet
            })
              .width('100%')
              .onChange((value: number) => {
                this.detectionParams.precision = value;
              });
          }
          .marginBottom(16);

          // 检测速度
          Column({
            alignItems: ItemAlign.Start,
            justifyContent: FlexAlign.Start
          }) {
            Row({
              alignItems: ItemAlign.Center,
              justifyContent: FlexAlign.SpaceBetween
            }) {
              Text('检测速度: ' + (this.detectionParams.speed * 100).toFixed(0) + '%')
                .fontSize(14)
                .textColor('#4a5568');
            }
            .marginBottom(8);
            Slider({
              value: this.detectionParams.speed,
              min: 0.3,
              max: 0.9,
              step: 0.1,
              style: SliderStyle.OutSet
            })
              .width('100%')
              .onChange((value: number) => {
                this.detectionParams.speed = value;
              });
          }
          .marginBottom(16);

          // 阈值
          Column({
            alignItems: ItemAlign.Start,
            justifyContent: FlexAlign.Start
          }) {
            Row({
              alignItems: ItemAlign.Center,
              justifyContent: FlexAlign.SpaceBetween
            }) {
              Text('阈值: ' + (this.detectionParams.threshold * 100).toFixed(0) + '%')
                .fontSize(14)
                .textColor('#4a5568');
            }
            .marginBottom(8);
            Slider({
              value: this.detectionParams.threshold,
              min: 0.3,
              max: 0.9,
              step: 0.05,
              style: SliderStyle.OutSet
            })
              .width('100%')
              .onChange((value: number) => {
                this.detectionParams.threshold = value;
              });
          }
        }
        .padding(16)
        .backgroundColor('#ffffff')
        .borderRadius(8)
        .shadow({
          color: '#000000',
          radius: 4,
          offsetX: 0,
          offsetY: 2,
          blurRadius: 8
        });
      }
      .padding(16);
    }
    .flexGrow(1);
  }

  // 产品管理页面
  @Builder ProductManagement() {
    Column({
      alignItems: ItemAlign.Stretch,
      justifyContent: FlexAlign.Start
    }) {
      Row({
        alignItems: ItemAlign.Center,
        justifyContent: FlexAlign.SpaceBetween
      }) {
        Text('产品列表')
          .fontSize(16)
          .fontWeight(FontWeight.SemiBold)
          .textColor('#1a365d');
        Button('添加产品')
          .fontSize(14)
          .width(100)
          .height(36)
          .backgroundColor('#38a169')
          .borderRadius(8)
          .onClick(() => {
            this.showAddProductDialog = true;
          });
      }
      .marginBottom(16);

      // 产品表格
      Scroll() {
        Column({
          alignItems: ItemAlign.Stretch,
          justifyContent: FlexAlign.Start
        }) {
          // 表头
          Row({
            alignItems: ItemAlign.Center,
            justifyContent: FlexAlign.SpaceBetween
          }) {
            Text('产品型号')
              .fontSize(14)
              .fontWeight(FontWeight.SemiBold)
              .textColor('#1a365d')
              .width('33%');
            Text('能效等级')
              .fontSize(14)
              .fontWeight(FontWeight.SemiBold)
              .textColor('#1a365d')
              .width('33%');
            Text('功耗 (W)')
              .fontSize(14)
              .fontWeight(FontWeight.SemiBold)
              .textColor('#1a365d')
              .width('34%');
          }
          .padding(12)
          .backgroundColor('#f7fafc')
          .borderRadius(8);

          // 产品列表
          ForEach(this.products, (product) => {
            Row({
              alignItems: ItemAlign.Center,
              justifyContent: FlexAlign.SpaceBetween
            }) {
              Text(product.model)
                .fontSize(14)
                .textColor('#4a5568')
                .width('33%');
              Text(product.energyEfficiency)
                .fontSize(14)
                .textColor('#4a5568')
                .width('33%');
              Row({
                alignItems: ItemAlign.Center,
                justifyContent: FlexAlign.SpaceBetween
              }) {
                Text(product.powerConsumption.toString())
                  .fontSize(14)
                  .textColor('#4a5568');
                Row() {
                  Button('编辑')
                    .fontSize(12)
                    .width(50)
                    .height(28)
                    .backgroundColor('#3182ce')
                    .borderRadius(6);
                  Button('删除')
                    .fontSize(12)
                    .width(50)
                    .height(28)
                    .backgroundColor('#e53e3e')
                    .borderRadius(6)
                    .marginLeft(8);
                }
              }
              .width('34%');
            }
            .padding(12)
            .backgroundColor('#ffffff')
            .borderRadius(8)
            .marginTop(8)
            .shadow({
              color: '#000000',
              radius: 2,
              offsetX: 0,
              offsetY: 1,
              blurRadius: 4
            });
          });
        }
      }
      .flexGrow(1);
    }
    .padding(16);
  }

  // 添加产品对话框
  @Builder AddProductDialog() {
    Column({
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.Center
    }) {
      Column({
        alignItems: ItemAlign.Stretch,
        justifyContent: FlexAlign.Start
      }) {
        Text('添加产品')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .textColor('#1a365d')
          .marginBottom(16);

        // 产品型号
        Column({
          alignItems: ItemAlign.Start,
          justifyContent: FlexAlign.Start
        }) {
          Text('产品型号')
            .fontSize(14)
            .textColor('#4a5568')
            .marginBottom(8);
          TextInput({
            text: this.newProduct.model,
            placeholder: '请输入产品型号'
          })
            .width('100%')
            .height(40)
            .padding(8)
            .backgroundColor('#f7fafc')
            .borderRadius(8)
            .onChange((value: string) => {
              this.newProduct.model = value;
            });
        }
        .marginBottom(16);

        // 能效等级
        Column({
          alignItems: ItemAlign.Start,
          justifyContent: FlexAlign.Start
        }) {
          Text('能效等级')
            .fontSize(14)
            .textColor('#4a5568')
            .marginBottom(8);
          TextInput({
            text: this.newProduct.energyEfficiency,
            placeholder: '请输入能效等级 (如 A+)'
          })
            .width('100%')
            .height(40)
            .padding(8)
            .backgroundColor('#f7fafc')
            .borderRadius(8)
            .onChange((value: string) => {
              this.newProduct.energyEfficiency = value;
            });
        }
        .marginBottom(16);

        // 功耗
        Column({
          alignItems: ItemAlign.Start,
          justifyContent: FlexAlign.Start
        }) {
          Text('功耗 (W)')
            .fontSize(14)
            .textColor('#4a5568')
            .marginBottom(8);
          TextInput({
            text: this.newProduct.powerConsumption.toString(),
            placeholder: '请输入功耗'
          })
            .width('100%')
            .height(40)
            .padding(8)
            .backgroundColor('#f7fafc')
            .borderRadius(8)
            .onChange((value: string) => {
              this.newProduct.powerConsumption = parseInt(value) || 0;
            });
        }
        .marginBottom(24);

        // 按钮
        Row({
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.End
        }) {
          Button('取消')
            .fontSize(14)
            .width(80)
            .height(36)
            .backgroundColor('#e2e8f0')
            .borderRadius(8)
            .onClick(() => {
              this.showAddProductDialog = false;
            });
          Button('保存')
            .fontSize(14)
            .width(80)
            .height(36)
            .backgroundColor('#38a169')
            .borderRadius(8)
            .marginLeft(12)
            .onClick(() => {
              // 保存产品
              this.products.push({
                id: (this.products.length + 1).toString(),
                model: this.newProduct.model,
                energyEfficiency: this.newProduct.energyEfficiency,
                powerConsumption: this.newProduct.powerConsumption,
              });
              this.showAddProductDialog = false;
              // 重置表单
              this.newProduct = {
                model: '',
                energyEfficiency: '',
                powerConsumption: 0,
              };
            });
        }
      }
      .padding(24)
      .backgroundColor('#ffffff')
      .borderRadius(12)
      .shadow({
        color: '#000000',
        radius: 8,
        offsetX: 0,
        offsetY: 4,
        blurRadius: 16
      })
      .width('80%')
      .maxWidth(400);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0, 0, 0, 0.5)');
  }
}