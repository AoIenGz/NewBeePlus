import router from '@ohos.router';
import { DetectionResult, SystemStatus } from '../common/Interfaces';

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

  build() {
    Column() {
      Row() {
        Text('产品能效标签与缺陷检测系统')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1a365d');
        Row() {
          Button('设置')
            .fontSize(14)
            .width(60)
            .height(32)
            .backgroundColor('#3182ce')
            .borderRadius(8)
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
      .backgroundColor('#f7fafc');

      Row() {
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
              .borderRadius(8);
            if (this.detectionResult.isPass) {
              Text('检测通过')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#38a169')
                .backgroundColor('rgba(255, 255, 255, 0.8)')
                .padding(8)
                .borderRadius(4)
                .alignSelf(ItemAlign.Center)
                .margin({ top: 20 });
            } else {
              Text('检测失败')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#e53e3e')
                .backgroundColor('rgba(255, 255, 255, 0.8)')
                .padding(8)
                .borderRadius(4)
                .alignSelf(ItemAlign.Center)
                .margin({ top: 20 });
            }
          }
          .width('100%')
          .height('100%')
          .borderRadius(8)
          .backgroundColor('#e2e8f0');
          Row() {
            Button('开始检测')
              .fontSize(14)
              .width(100)
              .height(36)
              .backgroundColor('#38a169')
              .borderRadius(8);
            Button('停止检测')
              .fontSize(14)
              .width(100)
              .height(36)
              .backgroundColor('#e53e3e')
              .borderRadius(8);
            Button('调整相机')
              .fontSize(14)
              .width(100)
              .height(36)
              .backgroundColor('#3182ce')
              .borderRadius(8);
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)
          .margin({ top: 12 })
        }
        .width('60%')
        .padding(16)

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

      Row() {
        Text(`相机状态: ${this.systemStatus.cameraStatus}`)
          .fontSize(14)
          .fontColor('#1a365d');
        Text(`检测速度: ${this.systemStatus.detectionSpeed}`)
          .fontSize(14)
          .fontColor('#1a365d');
        Text(`运行时间: ${this.systemStatus.uptime}`)
          .fontSize(14)
          .fontColor('#1a365d');
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(12)
      .backgroundColor('#f7fafc')
      .border({ width: { top: 1 }, color: '#e2e8f0' });
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#edf2f7');
  }

  @Builder ResultCard() {
    Column() {
      Text('检测结果')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1a365d')
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
        .margin({ bottom: 8 });
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
        .margin({ bottom: 8 });
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
        .margin({ bottom: 8 });
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
    .margin({ bottom: 16 });
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
        .margin({ bottom: 8 });
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
        .margin({ bottom: 8 });
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
    .margin({ bottom: 16 });
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
        .margin({ bottom: 8 });
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
        .margin({ bottom: 8 });
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
        .margin({ bottom: 8 });
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
  }
}
