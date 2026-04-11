import router from '@ohos.router';
import { DetectionResult, SystemStatus } from '../common/Interfaces';

// API服务
class ApiService {
  private baseUrl: string = 'http://localhost:3000/api';

  async fetchDetectionResult(): Promise<DetectionResult> {
    try {
      const response = await fetch(`${this.baseUrl}/detection/result`);
      return await response.json();
    } catch (error) {
      console.error('获取检测结果失败:', error);
      // 返回默认值
      return {
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
    }
  }

  async startDetection(): Promise<void> {
    try {
      await fetch(`${this.baseUrl}/detection/start`, {
        method: 'POST',
      });
    } catch (error) {
      console.error('开始检测失败:', error);
    }
  }

  async stopDetection(): Promise<void> {
    try {
      await fetch(`${this.baseUrl}/detection/stop`, {
        method: 'POST',
      });
    } catch (error) {
      console.error('停止检测失败:', error);
    }
  }

  async importMLResult(result: DetectionResult): Promise<void> {
    try {
      await fetch(`${this.baseUrl}/detection/import-ml-result`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ result }),
      });
    } catch (error) {
      console.error('导入机器学习结果失败:', error);
    }
  }
}

const apiService = new ApiService();

@Entry
@Component
struct Index {
  @State isCameraConnected: boolean = true;
  @State detectionResult: DetectionResult = {
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
  @State systemStatus: SystemStatus = {
    cameraStatus: '已连接',
    detectionSpeed: '120ms/帧',
    uptime: '00:30:45',
  };

  // 组件生命周期
  async aboutToAppear() {
    await this.updateDetectionResult();
  }

  // 更新检测结果
  async updateDetectionResult() {
    const result = await apiService.fetchDetectionResult();
    this.detectionResult = result;
  }

  // 开始检测
  async handleStartDetection() {
    await apiService.startDetection();
    // 模拟实时更新
    setInterval(async () => {
      await this.updateDetectionResult();
    }, 1000);
  }

  // 停止检测
  async handleStopDetection() {
    await apiService.stopDetection();
  }

  // 导入机器学习结果
  async handleImportMLResult() {
    // 模拟机器学习结果
    const mlResult: DetectionResult = {
      productModel: 'HB-2024-004',
      energyEfficiency: 'A++',
      powerConsumption: '90W',
      isDataMatch: true,
      defects: {
        isDamaged: false,
        isStained: false,
        isWrinkled: false,
      },
      position: {
        isCorrect: true,
        x: 122,
        y: 81,
        deviation: 0.3,
      },
      isPass: true,
    };
    await apiService.importMLResult(mlResult);
    await this.updateDetectionResult();
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('产品能效标签与缺陷检测系统')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1a365d');
        Row() {
          Button('设置')
            .fontSize(14)
            .width(60)
            .height(32)
            .backgroundColor('#3182ce')
            .borderRadius(8)
            .shadow({
              radius: 4,
              color: '#00000020',
              offsetX: 0,
              offsetY: 2,
            })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/Settings'
              });
            });
          Button('历史记录')
            .fontSize(14)
            .width(80)
            .height(32)
            .backgroundColor('#3182ce')
            .borderRadius(8)
            .shadow({
              radius: 4,
              color: '#00000020',
              offsetX: 0,
              offsetY: 2,
            })
            .margin({ left: 12 })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/History'
              });
            });
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(16)
      .backgroundColor('#ffffff')
      .shadow({
        radius: 4,
        color: '#00000010',
        offsetX: 0,
        offsetY: 2,
      });

      // 主内容区域
      Row() {
        // 左侧相机监控区域
        Column() {
          Text('相机监控')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1a365d')
            .margin({ bottom: 12 });
          Stack() {
            Image($r('app.media.background'))
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)
              .borderRadius(12);
            if (this.detectionResult.isPass) {
              Text('检测通过')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#38a169')
                .backgroundColor('rgba(255, 255, 255, 0.9)')
                .padding(12)
                .borderRadius(8)
                .alignSelf(ItemAlign.Center)
                .margin({ top: 20 })
                .shadow({
                  radius: 4,
                  color: '#00000020',
                  offsetX: 0,
                  offsetY: 2,
                });
            } else {
              Text('检测失败')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#e53e3e')
                .backgroundColor('rgba(255, 255, 255, 0.9)')
                .padding(12)
                .borderRadius(8)
                .alignSelf(ItemAlign.Center)
                .margin({ top: 20 })
                .shadow({
                  radius: 4,
                  color: '#00000020',
                  offsetX: 0,
                  offsetY: 2,
                });
            }
          }
          .width('100%')
          .height('100%')
          .borderRadius(12)
          .backgroundColor('#e2e8f0')
          .shadow({
            radius: 6,
            color: '#00000015',
            offsetX: 0,
            offsetY: 4,
          });
          // 控制按钮
          Row() {
            Button('开始检测')
              .fontSize(14)
              .width(100)
              .height(36)
              .backgroundColor('#38a169')
              .borderRadius(8)
              .shadow({
                radius: 4,
                color: '#00000020',
                offsetX: 0,
                offsetY: 2,
              })
              .onClick(() => this.handleStartDetection());
            Button('停止检测')
              .fontSize(14)
              .width(100)
              .height(36)
              .backgroundColor('#e53e3e')
              .borderRadius(8)
              .shadow({
                radius: 4,
                color: '#00000020',
                offsetX: 0,
                offsetY: 2,
              })
              .onClick(() => this.handleStopDetection());
            Button('导入ML结果')
              .fontSize(14)
              .width(100)
              .height(36)
              .backgroundColor('#805ad5')
              .borderRadius(8)
              .shadow({
                radius: 4,
                color: '#00000020',
                offsetX: 0,
                offsetY: 2,
              })
              .onClick(() => this.handleImportMLResult());
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)
          .margin({ top: 16 })
        }
        .width('60%')
        .padding(16)

        // 右侧检测结果区域
        Column() {
          this.ResultCard();
          this.DefectCard();
          this.PositionCard();
        }
        .width('40%')
        .padding(16)
      }
      .width('100%')
      .layoutWeight(1)

      // 底部状态栏
      Row() {
        Row() {
          Image($r('app.media.foreground'))
            .width(16)
            .height(16)
            .margin({ right: 8 });
          Text(`相机状态: ${this.systemStatus.cameraStatus}`)
            .fontSize(14)
            .fontColor('#1a365d');
        }
        Row() {
          Image($r('app.media.foreground'))
            .width(16)
            .height(16)
            .margin({ right: 8 });
          Text(`检测速度: ${this.systemStatus.detectionSpeed}`)
            .fontSize(14)
            .fontColor('#1a365d');
        }
        Row() {
          Image($r('app.media.foreground'))
            .width(16)
            .height(16)
            .margin({ right: 8 });
          Text(`运行时间: ${this.systemStatus.uptime}`)
            .fontSize(14)
            .fontColor('#1a365d');
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(16)
      .backgroundColor('#ffffff')
      .border({ width: { top: 1 }, color: '#e2e8f0' })
      .shadow({
        radius: 4,
        color: '#00000010',
        offsetX: 0,
        offsetY: -2,
      });
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#f7fafc');
  }

  @Builder ResultCard() {
    Column() {
      Row() {
        Text('检测结果')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1a365d');
        if (this.detectionResult.isPass) {
          Text('通过')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor('#38a169')
            .backgroundColor('#c6f6d5')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(12);
        } else {
          Text('失败')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor('#e53e3e')
            .backgroundColor('#fed7d7')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(12);
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 12 });
      Column() {
        Row() {
          Text('产品型号:')
            .fontSize(14)
            .fontColor('#4a5568');
          Text(this.detectionResult.productModel)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1a365d');
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 10 });
        Row() {
          Text('能效等级:')
            .fontSize(14)
            .fontColor('#4a5568');
          Text(this.detectionResult.energyEfficiency)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1a365d');
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 10 });
        Row() {
          Text('功耗:')
            .fontSize(14)
            .fontColor('#4a5568');
          Text(this.detectionResult.powerConsumption)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1a365d');
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 10 });
        Row() {
          Text('数据匹配:')
            .fontSize(14)
            .fontColor('#4a5568');
          Text(this.detectionResult.isDataMatch ? '匹配' : '不匹配')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.detectionResult.isDataMatch ? '#38a169' : '#e53e3e');
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding(20)
      .backgroundColor('#ffffff')
      .borderRadius(12)
      .shadow({
        radius: 6,
        color: '#00000015',
        offsetX: 0,
        offsetY: 4,
      });
    }
    .width('100%')
    .margin({ bottom: 20 });
  }

  @Builder DefectCard() {
    Column() {
      Text('缺陷检测')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1a365d')
        .margin({ bottom: 12 });
      Column() {
        Row() {
          Text('破损:')
            .fontSize(14)
            .fontColor('#4a5568');
          Text(this.detectionResult.defects.isDamaged ? '存在' : '不存在')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.detectionResult.defects.isDamaged ? '#e53e3e' : '#38a169');
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 10 });
        Row() {
          Text('污渍:')
            .fontSize(14)
            .fontColor('#4a5568');
          Text(this.detectionResult.defects.isStained ? '存在' : '不存在')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.detectionResult.defects.isStained ? '#e53e3e' : '#38a169');
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 10 });
        Row() {
          Text('褶皱:')
            .fontSize(14)
            .fontColor('#4a5568');
          Text(this.detectionResult.defects.isWrinkled ? '存在' : '不存在')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.detectionResult.defects.isWrinkled ? '#e53e3e' : '#38a169');
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding(20)
      .backgroundColor('#ffffff')
      .borderRadius(12)
      .shadow({
        radius: 6,
        color: '#00000015',
        offsetX: 0,
        offsetY: 4,
      });
    }
    .width('100%')
    .margin({ bottom: 20 });
  }

  @Builder PositionCard() {
    Column() {
      Text('位置检测')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1a365d')
        .margin({ bottom: 12 });
      Column() {
        Row() {
          Text('位置是否正确:')
            .fontSize(14)
            .fontColor('#4a5568');
          Text(this.detectionResult.position.isCorrect ? '正确' : '不正确')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.detectionResult.position.isCorrect ? '#38a169' : '#e53e3e');
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 10 });
        Row() {
          Text('X坐标:')
            .fontSize(14)
            .fontColor('#4a5568');
          Text(`${this.detectionResult.position.x}px`)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1a365d');
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 10 });
        Row() {
          Text('Y坐标:')
            .fontSize(14)
            .fontColor('#4a5568');
          Text(`${this.detectionResult.position.y}px`)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1a365d');
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 10 });
        Row() {
          Text('偏差值:')
            .fontSize(14)
            .fontColor('#4a5568');
          Text(`${this.detectionResult.position.deviation}mm`)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1a365d');
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding(20)
      .backgroundColor('#ffffff')
      .borderRadius(12)
      .shadow({
        radius: 6,
        color: '#00000015',
        offsetX: 0,
        offsetY: 4,
      });
    }
    .width('100%')
  }
}
