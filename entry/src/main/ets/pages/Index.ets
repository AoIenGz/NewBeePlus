import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State isCameraConnected: boolean = true;
  @State detectionResult: {
    productModel: string;
    energyEfficiency: string;
    powerConsumption: string;
    isDataMatch: boolean;
    defects: {
      isDamaged: boolean;
      isStained: boolean;
      isWrinkled: boolean;
    };
    position: {
      isCorrect: boolean;
      x: number;
      y: number;
      deviation: number;
    };
    isPass: boolean;
  } = {
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
  @State systemStatus: {
    cameraStatus: string;
    detectionSpeed: string;
    uptime: string;
  } = {
    cameraStatus: '已连接',
    detectionSpeed: '120ms/帧',
    uptime: '00:30:45',
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
        Text('产品能效标签与缺陷检测系统')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .textColor('#1a365d');
        Row() {
          Button('设置')
            .fontSize(14)
            .width(60)
            .height(32)
            .backgroundColor('#3182ce')
            .borderRadius(8)
            .onClick(() => {
              router.push({
                uri: 'pages/Settings'
              });
            });
          Button('历史记录')
            .fontSize(14)
            .width(80)
            .height(32)
            .backgroundColor('#3182ce')
            .borderRadius(8)
            .marginLeft(12)
            .onClick(() => {
              router.push({
                uri: 'pages/History'
              });
            });
        }
      }
      .padding(16)
      .backgroundColor('#f7fafc');

      // 主内容区域
      Flex({
        direction: FlexDirection.Row,
        alignItems: ItemAlign.Stretch,
        justifyContent: FlexAlign.Start,
        flexGrow: 1
      }) {
        // 左侧相机监控
        Column({
          alignItems: ItemAlign.Stretch,
          justifyContent: FlexAlign.Start
        }) {
          Text('相机监控')
            .fontSize(16)
            .fontWeight(FontWeight.SemiBold)
            .textColor('#1a365d')
            .marginBottom(12);
          // 相机画面（模拟）
          Stack() {
            Image($r('app.media.background'))
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)
              .borderRadius(8);
            // 检测标记（模拟）
            if (this.detectionResult.isPass) {
              Text('检测通过')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .textColor('#38a169')
                .backgroundColor('rgba(255, 255, 255, 0.8)')
                .padding(8)
                .borderRadius(4)
                .alignSelf(ItemAlign.Center)
                .marginTop(20);
            } else {
              Text('检测失败')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .textColor('#e53e3e')
                .backgroundColor('rgba(255, 255, 255, 0.8)')
                .padding(8)
                .borderRadius(4)
                .alignSelf(ItemAlign.Center)
                .marginTop(20);
            }
          }
          .width('100%')
          .height('100%')
          .borderRadius(8)
          .backgroundColor('#e2e8f0');
          // 相机控制按钮
          Row({
            alignItems: ItemAlign.Center,
            justifyContent: FlexAlign.SpaceEvenly
          }) {
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
          .marginTop(12)
        }
        .width('60%')
        .padding(16)

        // 右侧检测结果
        Column({
          alignItems: ItemAlign.Stretch,
          justifyContent: FlexAlign.Start
        }) {
          // 检测结果卡片
          this.ResultCard();
          // 缺陷检测卡片
          this.DefectCard();
          // 位置检测卡片
          this.PositionCard();
        }
        .width('40%')
        .padding(16)
      }

      // 底部状态栏
      Row({
        alignItems: ItemAlign.Center,
        justifyContent: FlexAlign.SpaceBetween
      }) {
        Text(`相机状态: ${this.systemStatus.cameraStatus}`)
          .fontSize(14)
          .textColor('#1a365d');
        Text(`检测速度: ${this.systemStatus.detectionSpeed}`)
          .fontSize(14)
          .textColor('#1a365d');
        Text(`运行时间: ${this.systemStatus.uptime}`)
          .fontSize(14)
          .textColor('#1a365d');
      }
      .padding(12)
      .backgroundColor('#f7fafc')
      .borderTopWidth(1)
      .borderTopColor('#e2e8f0');
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#edf2f7');
  }

  // 检测结果卡片
  @Builder ResultCard() {
    Column({
      alignItems: ItemAlign.Stretch,
      justifyContent: FlexAlign.Start
    }) {
      Text('检测结果')
        .fontSize(16)
        .fontWeight(FontWeight.SemiBold)
        .textColor('#1a365d')
        .marginBottom(12);
      Column({
        alignItems: ItemAlign.Start,
        justifyContent: FlexAlign.Start
      }) {
        Row({
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.SpaceBetween
        }) {
          Text('产品型号:')
            .fontSize(14)
            .textColor('#4a5568');
          Text(this.detectionResult.productModel)
            .fontSize(14)
            .fontWeight(FontWeight.SemiBold)
            .textColor('#1a365d');
        }
        .marginBottom(8);
        Row({
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.SpaceBetween
        }) {
          Text('能效等级:')
            .fontSize(14)
            .textColor('#4a5568');
          Text(this.detectionResult.energyEfficiency)
            .fontSize(14)
            .fontWeight(FontWeight.SemiBold)
            .textColor('#1a365d');
        }
        .marginBottom(8);
        Row({
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.SpaceBetween
        }) {
          Text('功耗:')
            .fontSize(14)
            .textColor('#4a5568');
          Text(this.detectionResult.powerConsumption)
            .fontSize(14)
            .fontWeight(FontWeight.SemiBold)
            .textColor('#1a365d');
        }
        .marginBottom(8);
        Row({
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.SpaceBetween
        }) {
          Text('数据匹配:')
            .fontSize(14)
            .textColor('#4a5568');
          Text(this.detectionResult.isDataMatch ? '匹配' : '不匹配')
            .fontSize(14)
            .fontWeight(FontWeight.SemiBold)
            .textColor(this.detectionResult.isDataMatch ? '#38a169' : '#e53e3e');
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
    .marginBottom(16);
  }

  // 缺陷检测卡片
  @Builder DefectCard() {
    Column({
      alignItems: ItemAlign.Stretch,
      justifyContent: FlexAlign.Start
    }) {
      Text('缺陷检测')
        .fontSize(16)
        .fontWeight(FontWeight.SemiBold)
        .textColor('#1a365d')
        .marginBottom(12);
      Column({
        alignItems: ItemAlign.Start,
        justifyContent: FlexAlign.Start
      }) {
        Row({
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.SpaceBetween
        }) {
          Text('破损:')
            .fontSize(14)
            .textColor('#4a5568');
          Text(this.detectionResult.defects.isDamaged ? '存在' : '不存在')
            .fontSize(14)
            .fontWeight(FontWeight.SemiBold)
            .textColor(this.detectionResult.defects.isDamaged ? '#e53e3e' : '#38a169');
        }
        .marginBottom(8);
        Row({
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.SpaceBetween
        }) {
          Text('污渍:')
            .fontSize(14)
            .textColor('#4a5568');
          Text(this.detectionResult.defects.isStained ? '存在' : '不存在')
            .fontSize(14)
            .fontWeight(FontWeight.SemiBold)
            .textColor(this.detectionResult.defects.isStained ? '#e53e3e' : '#38a169');
        }
        .marginBottom(8);
        Row({
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.SpaceBetween
        }) {
          Text('褶皱:')
            .fontSize(14)
            .textColor('#4a5568');
          Text(this.detectionResult.defects.isWrinkled ? '存在' : '不存在')
            .fontSize(14)
            .fontWeight(FontWeight.SemiBold)
            .textColor(this.detectionResult.defects.isWrinkled ? '#e53e3e' : '#38a169');
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
    .marginBottom(16);
  }

  // 位置检测卡片
  @Builder PositionCard() {
    Column({
      alignItems: ItemAlign.Stretch,
      justifyContent: FlexAlign.Start
    }) {
      Text('位置检测')
        .fontSize(16)
        .fontWeight(FontWeight.SemiBold)
        .textColor('#1a365d')
        .marginBottom(12);
      Column({
        alignItems: ItemAlign.Start,
        justifyContent: FlexAlign.Start
      }) {
        Row({
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.SpaceBetween
        }) {
          Text('位置是否正确:')
            .fontSize(14)
            .textColor('#4a5568');
          Text(this.detectionResult.position.isCorrect ? '正确' : '不正确')
            .fontSize(14)
            .fontWeight(FontWeight.SemiBold)
            .textColor(this.detectionResult.position.isCorrect ? '#38a169' : '#e53e3e');
        }
        .marginBottom(8);
        Row({
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.SpaceBetween
        }) {
          Text('X坐标:')
            .fontSize(14)
            .textColor('#4a5568');
          Text(`${this.detectionResult.position.x}px`)
            .fontSize(14)
            .fontWeight(FontWeight.SemiBold)
            .textColor('#1a365d');
        }
        .marginBottom(8);
        Row({
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.SpaceBetween
        }) {
          Text('Y坐标:')
            .fontSize(14)
            .textColor('#4a5568');
          Text(`${this.detectionResult.position.y}px`)
            .fontSize(14)
            .fontWeight(FontWeight.SemiBold)
            .textColor('#1a365d');
        }
        .marginBottom(8);
        Row({
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.SpaceBetween
        }) {
          Text('偏差值:')
            .fontSize(14)
            .textColor('#4a5568');
          Text(`${this.detectionResult.position.deviation}mm`)
            .fontSize(14)
            .fontWeight(FontWeight.SemiBold)
            .textColor('#1a365d');
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
  }
}