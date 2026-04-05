import router from '@ohos.router';
import { DetectionRecord, SearchParams } from '../common/Interfaces';

@Entry
@Component
struct History {
  @State selectedTab: string = 'records';
  @State detectionRecords: Array<DetectionRecord> = [
    {
      id: '1',
      timestamp: '2026-04-05 10:30:45',
      productModel: 'HB-2024-001',
      energyEfficiency: 'A+',
      isDataMatch: true,
      defects: {
        isDamaged: false,
        isStained: false,
        isWrinkled: false,
      },
      position: {
        isCorrect: true,
        deviation: 0.5,
      },
      isPass: true,
    },
    {
      id: '2',
      timestamp: '2026-04-05 10:31:20',
      productModel: 'HB-2024-002',
      energyEfficiency: 'A',
      isDataMatch: true,
      defects: {
        isDamaged: false,
        isStained: true,
        isWrinkled: false,
      },
      position: {
        isCorrect: true,
        deviation: 0.8,
      },
      isPass: false,
    },
    {
      id: '3',
      timestamp: '2026-04-05 10:32:15',
      productModel: 'HB-2024-001',
      energyEfficiency: 'A+',
      isDataMatch: true,
      defects: {
        isDamaged: false,
        isStained: false,
        isWrinkled: false,
      },
      position: {
        isCorrect: false,
        deviation: 2.5,
      },
      isPass: false,
    },
    {
      id: '4',
      timestamp: '2026-04-05 10:33:00',
      productModel: 'HB-2024-003',
      energyEfficiency: 'B',
      isDataMatch: true,
      defects: {
        isDamaged: false,
        isStained: false,
        isWrinkled: false,
      },
      position: {
        isCorrect: true,
        deviation: 0.3,
      },
      isPass: true,
    },
    {
      id: '5',
      timestamp: '2026-04-05 10:34:10',
      productModel: 'HB-2024-002',
      energyEfficiency: 'A',
      isDataMatch: true,
      defects: {
        isDamaged: true,
        isStained: false,
        isWrinkled: false,
      },
      position: {
        isCorrect: true,
        deviation: 0.6,
      },
      isPass: false,
    },
  ];
  @State searchParams: SearchParams = {
    productModel: '',
    startDate: '2026-04-05',
    endDate: '2026-04-05',
    status: 'all',
  };
  @State showExportDialog: boolean = false;
  @State exportFormat: string = 'excel';
  @State exportDateRange: string = 'today';

  build() {
    Stack() {
      Column() {
        Row() {
          Text('历史记录')
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
          Button('检测记录')
            .fontSize(14)
            .width(100)
            .height(36)
            .backgroundColor(this.selectedTab === 'records' ? '#3182ce' : '#e2e8f0')
            .fontColor(this.selectedTab === 'records' ? '#ffffff' : '#4a5568')
            .borderRadius(8)
            .onClick(() => {
              this.selectedTab = 'records';
            });
          Button('统计分析')
            .fontSize(14)
            .width(100)
            .height(36)
            .backgroundColor(this.selectedTab === 'analytics' ? '#3182ce' : '#e2e8f0')
            .fontColor(this.selectedTab === 'analytics' ? '#ffffff' : '#4a5568')
            .borderRadius(8)
            .margin({ left: 12 })
            .onClick(() => {
              this.selectedTab = 'analytics';
            });
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .padding(16)
        .backgroundColor('#ffffff');

        if (this.selectedTab === 'records') {
          this.RecordsView();
        } else if (this.selectedTab === 'analytics') {
          this.AnalyticsView();
        }

        Row() {
          Button('导出报告')
            .fontSize(14)
            .width(100)
            .height(36)
            .backgroundColor('#38a169')
            .borderRadius(8)
            .onClick(() => {
              this.showExportDialog = true;
            });
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .padding(16)
        .backgroundColor('#f7fafc');
      }
      .height('100%')
      .width('100%')
      .backgroundColor('#edf2f7');

      if (this.showExportDialog) {
        this.ExportDialog();
      }
    }
    .height('100%')
    .width('100%');
  }

  @Builder RecordsView() {
    Column() {
      Column() {
        Text('搜索和过滤')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1a365d')
          .margin({ bottom: 16 });

        Row() {
          Column() {
            Text('产品型号')
              .fontSize(14)
              .fontColor('#4a5568')
              .margin({ bottom: 8 });
            TextInput({
              text: this.searchParams.productModel,
              placeholder: '请输入产品型号'
            })
              .width(180)
              .height(40)
              .padding(8)
              .backgroundColor('#f7fafc')
              .borderRadius(8)
              .onChange((value: string) => {
                this.searchParams.productModel = value;
              });
          }
          .alignItems(HorizontalAlign.Start);
          Column() {
            Text('开始日期')
              .fontSize(14)
              .fontColor('#4a5568')
              .margin({ bottom: 8 });
            TextInput({
              text: this.searchParams.startDate,
              placeholder: 'YYYY-MM-DD'
            })
              .width(120)
              .height(40)
              .padding(8)
              .backgroundColor('#f7fafc')
              .borderRadius(8)
              .onChange((value: string) => {
                this.searchParams.startDate = value;
              });
          }
          .alignItems(HorizontalAlign.Start);
          Column() {
            Text('结束日期')
              .fontSize(14)
              .fontColor('#4a5568')
              .margin({ bottom: 8 });
            TextInput({
              text: this.searchParams.endDate,
              placeholder: 'YYYY-MM-DD'
            })
              .width(120)
              .height(40)
              .padding(8)
              .backgroundColor('#f7fafc')
              .borderRadius(8)
              .onChange((value: string) => {
                this.searchParams.endDate = value;
              });
          }
          .alignItems(HorizontalAlign.Start);
          Column() {
            Text('状态')
              .fontSize(14)
              .fontColor('#4a5568')
              .margin({ bottom: 8 });
            Row() {
              Button('全部')
                .fontSize(12)
                .width(60)
                .height(32)
                .backgroundColor(this.searchParams.status === 'all' ? '#3182ce' : '#e2e8f0')
                .fontColor(this.searchParams.status === 'all' ? '#ffffff' : '#4a5568')
                .borderRadius(6)
                .onClick(() => {
                  this.searchParams.status = 'all';
                });
              Button('通过')
                .fontSize(12)
                .width(60)
                .height(32)
                .backgroundColor(this.searchParams.status === 'pass' ? '#3182ce' : '#e2e8f0')
                .fontColor(this.searchParams.status === 'pass' ? '#ffffff' : '#4a5568')
                .borderRadius(6)
                .margin({ left: 8 })
                .onClick(() => {
                  this.searchParams.status = 'pass';
                });
              Button('失败')
                .fontSize(12)
                .width(60)
                .height(32)
                .backgroundColor(this.searchParams.status === 'fail' ? '#3182ce' : '#e2e8f0')
                .fontColor(this.searchParams.status === 'fail' ? '#ffffff' : '#4a5568')
                .borderRadius(6)
                .margin({ left: 8 })
                .onClick(() => {
                  this.searchParams.status = 'fail';
                });
            }
          }
          .alignItems(HorizontalAlign.Start);
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 16 });

        Button('搜索')
          .fontSize(14)
          .width(100)
          .height(36)
          .backgroundColor('#3182ce')
          .borderRadius(8)
          .alignSelf(ItemAlign.End);
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

      Scroll() {
        Column() {
          Row() {
            Text('时间')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1a365d')
              .width('25%');
            Text('产品型号')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1a365d')
              .width('20%');
            Text('能效等级')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1a365d')
              .width('15%');
            Text('数据匹配')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1a365d')
              .width('15%');
            Text('状态')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1a365d')
              .width('15%');
            Text('操作')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1a365d')
              .width('10%');
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding(12)
          .backgroundColor('#f7fafc')
          .borderRadius(8);

          ForEach(this.detectionRecords, (record: DetectionRecord) => {
            Row() {
              Text(record.timestamp)
                .fontSize(14)
                .fontColor('#4a5568')
                .width('25%');
              Text(record.productModel)
                .fontSize(14)
                .fontColor('#4a5568')
                .width('20%');
              Text(record.energyEfficiency)
                .fontSize(14)
                .fontColor('#4a5568')
                .width('15%');
              Text(record.isDataMatch ? '匹配' : '不匹配')
                .fontSize(14)
                .fontColor(record.isDataMatch ? '#38a169' : '#e53e3e')
                .width('15%');
              Text(record.isPass ? '通过' : '失败')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(record.isPass ? '#38a169' : '#e53e3e')
                .width('15%');
              Button('查看')
                .fontSize(12)
                .width(50)
                .height(28)
                .backgroundColor('#3182ce')
                .borderRadius(6);
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

  @Builder AnalyticsView() {
    Column() {
      Text('统计分析')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1a365d')
        .margin({ bottom: 16 });

      Row() {
        Column() {
          Text('总检测数')
            .fontSize(14)
            .fontColor('#4a5568')
            .margin({ bottom: 8 });
          Text('5')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1a365d');
        }
        .padding(24)
        .backgroundColor('#ffffff')
        .borderRadius(8)
        .shadow({
          radius: 4,
          color: '#000000',
          offsetX: 0,
          offsetY: 2,
        })
        .width('23%');

        Column() {
          Text('通过数')
            .fontSize(14)
            .fontColor('#4a5568')
            .margin({ bottom: 8 });
          Text('2')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#38a169');
        }
        .padding(24)
        .backgroundColor('#ffffff')
        .borderRadius(8)
        .shadow({
          radius: 4,
          color: '#000000',
          offsetX: 0,
          offsetY: 2,
        })
        .width('23%');

        Column() {
          Text('失败数')
            .fontSize(14)
            .fontColor('#4a5568')
            .margin({ bottom: 8 });
          Text('3')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#e53e3e');
        }
        .padding(24)
        .backgroundColor('#ffffff')
        .borderRadius(8)
        .shadow({
          radius: 4,
          color: '#000000',
          offsetX: 0,
          offsetY: 2,
        })
        .width('23%');

        Column() {
          Text('通过率')
            .fontSize(14)
            .fontColor('#4a5568')
            .margin({ bottom: 8 });
          Text('40%')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#3182ce');
        }
        .padding(24)
        .backgroundColor('#ffffff')
        .borderRadius(8)
        .shadow({
          radius: 4,
          color: '#000000',
          offsetX: 0,
          offsetY: 2,
        })
        .width('23%');
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 16 });

      Column() {
        Text('缺陷统计')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1a365d')
          .margin({ bottom: 16 });

        Row() {
          Column() {
            Text('破损')
              .fontSize(14)
              .fontColor('#4a5568')
              .margin({ bottom: 8 });
            Text('1')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#e53e3e');
          }
          .padding(20)
          .backgroundColor('#ffffff')
          .borderRadius(8)
          .shadow({
            radius: 4,
            color: '#000000',
            offsetX: 0,
            offsetY: 2,
          })
          .width('31%');

          Column() {
            Text('污渍')
              .fontSize(14)
              .fontColor('#4a5568')
              .margin({ bottom: 8 });
            Text('1')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#e53e3e');
          }
          .padding(20)
          .backgroundColor('#ffffff')
          .borderRadius(8)
          .shadow({
            radius: 4,
            color: '#000000',
            offsetX: 0,
            offsetY: 2,
          })
          .width('31%');

          Column() {
            Text('褶皱')
              .fontSize(14)
              .fontColor('#4a5568')
              .margin({ bottom: 8 });
            Text('0')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#38a169');
          }
          .padding(20)
          .backgroundColor('#ffffff')
          .borderRadius(8)
          .shadow({
            radius: 4,
            color: '#000000',
            offsetX: 0,
            offsetY: 2,
          })
          .width('31%');
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween);
      }
      .width('100%')
      .margin({ bottom: 16 });

      Column() {
        Text('位置偏差统计')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1a365d')
          .margin({ bottom: 16 });

        Column() {
          Row() {
            Text('平均偏差')
              .fontSize(14)
              .fontColor('#4a5568');
            Text('1.14 mm')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1a365d');
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: 8 });
          Row() {
            Text('最大偏差')
              .fontSize(14)
              .fontColor('#4a5568');
            Text('2.5 mm')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#e53e3e');
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: 8 });
          Row() {
            Text('最小偏差')
              .fontSize(14)
              .fontColor('#4a5568');
            Text('0.3 mm')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#38a169');
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween);
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
      .width('100%');
    }
    .width('100%')
    .padding(16);
  }

  @Builder ExportDialog() {
    Column() {
      Column() {
        Text('导出报告')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1a365d')
          .margin({ bottom: 16 });

        Column() {
          Text('导出格式')
            .fontSize(14)
            .fontColor('#4a5568')
            .margin({ bottom: 8 });
          Row() {
            Button('Excel')
              .fontSize(14)
              .width(80)
              .height(32)
              .backgroundColor(this.exportFormat === 'excel' ? '#3182ce' : '#e2e8f0')
              .fontColor(this.exportFormat === 'excel' ? '#ffffff' : '#4a5568')
              .borderRadius(8)
              .onClick(() => {
                this.exportFormat = 'excel';
              });
            Button('PDF')
              .fontSize(14)
              .width(80)
              .height(32)
              .backgroundColor(this.exportFormat === 'pdf' ? '#3182ce' : '#e2e8f0')
              .fontColor(this.exportFormat === 'pdf' ? '#ffffff' : '#4a5568')
              .borderRadius(8)
              .margin({ left: 12 })
              .onClick(() => {
                this.exportFormat = 'pdf';
              });
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 16 });

        Column() {
          Text('时间范围')
            .fontSize(14)
            .fontColor('#4a5568')
            .margin({ bottom: 8 });
          Row() {
            Button('今日')
              .fontSize(14)
              .width(80)
              .height(32)
              .backgroundColor(this.exportDateRange === 'today' ? '#3182ce' : '#e2e8f0')
              .fontColor(this.exportDateRange === 'today' ? '#ffffff' : '#4a5568')
              .borderRadius(8)
              .onClick(() => {
                this.exportDateRange = 'today';
              });
            Button('本周')
              .fontSize(14)
              .width(80)
              .height(32)
              .backgroundColor(this.exportDateRange === 'week' ? '#3182ce' : '#e2e8f0')
              .fontColor(this.exportDateRange === 'week' ? '#ffffff' : '#4a5568')
              .borderRadius(8)
              .margin({ left: 12 })
              .onClick(() => {
                this.exportDateRange = 'week';
              });
            Button('本月')
              .fontSize(14)
              .width(80)
              .height(32)
              .backgroundColor(this.exportDateRange === 'month' ? '#3182ce' : '#e2e8f0')
              .fontColor(this.exportDateRange === 'month' ? '#ffffff' : '#4a5568')
              .borderRadius(8)
              .margin({ left: 12 })
              .onClick(() => {
                this.exportDateRange = 'month';
              });
          }
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
              this.showExportDialog = false;
            });
          Button('导出')
            .fontSize(14)
            .width(80)
            .height(36)
            .backgroundColor('#38a169')
            .borderRadius(8)
            .margin({ left: 12 })
            .onClick(() => {
              this.showExportDialog = false;
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
