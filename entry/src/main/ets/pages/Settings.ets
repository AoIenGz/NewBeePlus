import router from '@ohos.router';
import { CameraParams, DetectionParams, Product, NewProduct } from '../common/Interfaces';

@Entry
@Component
struct Settings {
  @State selectedTab: string = 'params';
  @State cameraParams: CameraParams = {
    resolution: '1920x1080',
    frameRate: 30,
    exposure: 100,
  };
  @State detectionParams: DetectionParams = {
    precision: 0.85,
    speed: 0.7,
    threshold: 0.6,
  };
  @State products: Array<Product> = [
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
  @State newProduct: NewProduct = {
    model: '',
    energyEfficiency: '',
    powerConsumption: 0,
  };

  build() {
    Stack() {
      Column() {
        Row() {
          Text('设置')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1a365d');
          Button('返回')
            .fontSize(14)
            .width(60)
            .height(32)
            .backgroundColor('#3182ce')
            .borderRadius(8)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/Index'
              });
            });
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding(16)
        .backgroundColor('#f7fafc');

        Row() {
          Button('参数配置')
            .fontSize(14)
            .width(100)
            .height(36)
            .backgroundColor(this.selectedTab === 'params' ? '#3182ce' : '#e2e8f0')
            .fontColor(this.selectedTab === 'params' ? '#ffffff' : '#4a5568')
            .borderRadius(8)
            .onClick(() => {
              this.selectedTab = 'params';
            });
          Button('产品管理')
            .fontSize(14)
            .width(100)
            .height(36)
            .backgroundColor(this.selectedTab === 'products' ? '#3182ce' : '#e2e8f0')
            .fontColor(this.selectedTab === 'products' ? '#ffffff' : '#4a5568')
            .borderRadius(8)
            .margin({ left: 12 })
            .onClick(() => {
              this.selectedTab = 'products';
            });
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .padding(16)
        .backgroundColor('#ffffff');

        if (this.selectedTab === 'params') {
          this.ParamsConfig();
        } else if (this.selectedTab === 'products') {
          this.ProductManagement();
        }

        Row() {
          Button('保存设置')
            .fontSize(14)
            .width(100)
            .height(36)
            .backgroundColor('#38a169')
            .borderRadius(8);
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .padding(16)
        .backgroundColor('#f7fafc');
      }
      .height('100%')
      .width('100%')
      .backgroundColor('#edf2f7');

      if (this.showAddProductDialog) {
        this.AddProductDialog();
      }
    }
    .height('100%')
    .width('100%');
  }

  @Builder ParamsConfig() {
    Scroll() {
      Column() {
        Column() {
          Text('相机参数')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1a365d')
            .margin({ bottom: 16 });

          Column() {
            Text('分辨率')
              .fontSize(14)
              .fontColor('#4a5568')
              .margin({ bottom: 8 });
            Row() {
              Button('1280x720')
                .fontSize(14)
                .width(100)
                .height(32)
                .backgroundColor(this.cameraParams.resolution === '1280x720' ? '#3182ce' : '#e2e8f0')
                .fontColor(this.cameraParams.resolution === '1280x720' ? '#ffffff' : '#4a5568')
                .borderRadius(8)
                .onClick(() => {
                  this.cameraParams.resolution = '1280x720';
                });
              Button('1920x1080')
                .fontSize(14)
                .width(100)
                .height(32)
                .backgroundColor(this.cameraParams.resolution === '1920x1080' ? '#3182ce' : '#e2e8f0')
                .fontColor(this.cameraParams.resolution === '1920x1080' ? '#ffffff' : '#4a5568')
                .borderRadius(8)
                .onClick(() => {
                  this.cameraParams.resolution = '1920x1080';
                });
              Button('2560x1440')
                .fontSize(14)
                .width(100)
                .height(32)
                .backgroundColor(this.cameraParams.resolution === '2560x1440' ? '#3182ce' : '#e2e8f0')
                .fontColor(this.cameraParams.resolution === '2560x1440' ? '#ffffff' : '#4a5568')
                .borderRadius(8)
                .onClick(() => {
                  this.cameraParams.resolution = '2560x1440';
                });
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ bottom: 16 });

          Column() {
            Row() {
              Text('帧率: ' + this.cameraParams.frameRate + ' fps')
                .fontSize(14)
                .fontColor('#4a5568');
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 8 });
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
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ bottom: 16 });

          Column() {
            Row() {
              Text('曝光时间: ' + this.cameraParams.exposure + ' ms')
                .fontSize(14)
                .fontColor('#4a5568');
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 8 });
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
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#ffffff')
        .borderRadius(8)
        .shadow({
          radius: 4,
          color: '#000000',
          offsetX: 0,
          offsetY: 2,
        })
        .margin({ bottom: 16 });

        Column() {
          Text('检测参数')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1a365d')
            .margin({ bottom: 16 });

          Column() {
            Row() {
              Text('检测精度: ' + (this.detectionParams.precision * 100).toFixed(0) + '%')
                .fontSize(14)
                .fontColor('#4a5568');
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 8 });
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
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ bottom: 16 });

          Column() {
            Row() {
              Text('检测速度: ' + (this.detectionParams.speed * 100).toFixed(0) + '%')
                .fontSize(14)
                .fontColor('#4a5568');
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 8 });
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
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ bottom: 16 });

          Column() {
            Row() {
              Text('阈值: ' + (this.detectionParams.threshold * 100).toFixed(0) + '%')
                .fontSize(14)
                .fontColor('#4a5568');
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 8 });
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
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#ffffff')
        .borderRadius(8)
        .shadow({
          radius: 4,
          color: '#000000',
          offsetX: 0,
          offsetY: 2,
        });
      }
      .width('100%')
      .padding(16);
    }
    .layoutWeight(1);
  }

  @Builder ProductManagement() {
    Column() {
      Row() {
        Text('产品列表')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1a365d');
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
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 16 });

      Scroll() {
        Column() {
          Row() {
            Text('产品型号')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1a365d')
              .width('33%');
            Text('能效等级')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1a365d')
              .width('33%');
            Text('功耗 (W)')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1a365d')
              .width('34%');
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding(12)
          .backgroundColor('#f7fafc')
          .borderRadius(8);

          ForEach(this.products, (product: Product) => {
            Row() {
              Text(product.model)
                .fontSize(14)
                .fontColor('#4a5568')
                .width('33%');
              Text(product.energyEfficiency)
                .fontSize(14)
                .fontColor('#4a5568')
                .width('33%');
              Row() {
                Text(product.powerConsumption.toString())
                  .fontSize(14)
                  .fontColor('#4a5568');
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
                    .margin({ left: 8 });
                }
              }
              .width('34%')
              .justifyContent(FlexAlign.SpaceBetween);
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding(12)
            .backgroundColor('#ffffff')
            .borderRadius(8)
            .margin({ top: 8 })
            .shadow({
              radius: 2,
              color: '#000000',
              offsetX: 0,
              offsetY: 1,
            });
          });
        }
        .width('100%')
      }
      .layoutWeight(1);
    }
    .width('100%')
    .padding(16);
  }

  @Builder AddProductDialog() {
    Column() {
      Column() {
        Text('添加产品')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1a365d')
          .margin({ bottom: 16 });

        Column() {
          Text('产品型号')
            .fontSize(14)
            .fontColor('#4a5568')
            .margin({ bottom: 8 });
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
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 16 });

        Column() {
          Text('能效等级')
            .fontSize(14)
            .fontColor('#4a5568')
            .margin({ bottom: 8 });
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
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 16 });

        Column() {
          Text('功耗 (W)')
            .fontSize(14)
            .fontColor('#4a5568')
            .margin({ bottom: 8 });
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
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 24 });

        Row() {
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
            .margin({ left: 12 })
            .onClick(() => {
              const newProductItem: Product = {
                id: (this.products.length + 1).toString(),
                model: this.newProduct.model,
                energyEfficiency: this.newProduct.energyEfficiency,
                powerConsumption: this.newProduct.powerConsumption,
              };
              this.products.push(newProductItem);
              this.showAddProductDialog = false;
              this.newProduct = {
                model: '',
                energyEfficiency: '',
                powerConsumption: 0,
              };
            });
        }
        .width('100%')
        .justifyContent(FlexAlign.End);
      }
      .padding(24)
      .backgroundColor('#ffffff')
      .borderRadius(12)
      .shadow({
        radius: 8,
        color: '#000000',
        offsetX: 0,
        offsetY: 4,
      })
      .width('80%')
      .maxWidth(400);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0, 0, 0, 0.5)');
  }
}
