import router from '@ohos.router';

@Entry
@Component
struct History {
  @State selectedTab: string = 'records';
  @State detectionRecords: Array<{
    id: string;
    timestamp: string;
    productModel: string;
    energyEfficiency: string;
    isDataMatch: boolean;
    defects: {
      isDamaged: boolean;
      isStained: boolean;
      isWrinkled: boolean;
    };
    position: {
      isCorrect: boolean;
      deviation: number;
    };
    isPass: boolean;
  }> = [
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
  @State searchParams: {
    productModel: string;
    startDate: string;
    endDate: string;
    status: string;
  } = {
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
          Text('历史记录')
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
          Button('检测记录')
            .fontSize(14)
            .width(100)
            .height(36)
            .backgroundColor(this.selectedTab === 'records' ? '#3182ce' : '#e2e8f0')
            .textColor(this.selectedTab === 'records' ? '#ffffff' : '#4a5568')
            .borderRadius(8)
            .onClick(() => {
              this.selectedTab = 'records';
            });
          Button('统计分析')
            .fontSize(14)
            .width(100)
            .height(36)
            .backgroundColor(this.selectedTab === 'analytics' ? '#3182ce' : '#e2e8f0')
            .textColor(this.selectedTab === 'analytics' ? '#ffffff' : '#4a5568')
            .borderRadius(8)
            .marginLeft(12)
            .onClick(() => {
              this.selectedTab = 'analytics';
            });
        }
        .padding(16)
        .backgroundColor('#ffffff');

        // 内容区域
        if (this.selectedTab === 'records') {
          this.RecordsView();
        } else if (this.selectedTab === 'analytics') {
          this.AnalyticsView();
        }

        // 底部按钮
        Row({
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.End
        }) {
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
        .padding(16)
        .backgroundColor('#f7fafc');
      }
      .height('100%')
      .width('100%')
      .backgroundColor('#edf2f7');

      // 导出报告对话框
      if (this.showExportDialog) {
        this.ExportDialog();
      }
    }
    .height('100%')
    .width('100%');
  }

  // 检测记录页面
  @Builder RecordsView() {
    Column({
      alignItems: ItemAlign.Stretch,
      justifyContent: FlexAlign.Start
    }) {
      // 搜索和过滤
      Column({
        alignItems: ItemAlign.Stretch,
        justifyContent: FlexAlign.Start
      }) {
        Text('搜索和过滤')
          .fontSize(16)
          .fontWeight(FontWeight.SemiBold)
          .textColor('#1a365d')
          .marginBottom(16);

        Row({
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.SpaceBetween
        }) {
          Column({
            alignItems: ItemAlign.Start,
            justifyContent: FlexAlign.Start
          }) {
            Text('产品型号')
              .fontSize(14)
              .textColor('#4a5568')
              .marginBottom(8);
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
          Column({
            alignItems: ItemAlign.Start,
            justifyContent: FlexAlign.Start
          }) {
            Text('开始日期')
              .fontSize(14)
              .textColor('#4a5568')
              .marginBottom(8);
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
          Column({
            alignItems: ItemAlign.Start,
            justifyContent: FlexAlign.Start
          }) {
            Text('结束日期')
              .fontSize(14)
              .textColor('#4a5568')
              .marginBottom(8);
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
          Column({
            alignItems: ItemAlign.Start,
            justifyContent: FlexAlign.Start
          }) {
            Text('状态')
              .fontSize(14)
              .textColor('#4a5568')
              .marginBottom(8);
            Row() {
              Button('全部')
                .fontSize(12)
                .width(60)
                .height(32)
                .backgroundColor(this.searchParams.status === 'all' ? '#3182ce' : '#e2e8f0')
                .textColor(this.searchParams.status === 'all' ? '#ffffff' : '#4a5568')
                .borderRadius(6)
                .onClick(() => {
                  this.searchParams.status = 'all';
                });
              Button('通过')
                .fontSize(12)
                .width(60)
                .height(32)
                .backgroundColor(this.searchParams.status === 'pass' ? '#3182ce' : '#e2e8f0')
                .textColor(this.searchParams.status === 'pass' ? '#ffffff' : '#4a5568')
                .borderRadius(6)
                .marginLeft(8)
                .onClick(() => {
                  this.searchParams.status = 'pass';
                });
              Button('失败')
                .fontSize(12)
                .width(60)
                .height(32)
                .backgroundColor(this.searchParams.status === 'fail' ? '#3182ce' : '#e2e8f0')
                .textColor(this.searchParams.status === 'fail' ? '#ffffff' : '#4a5568')
                .borderRadius(6)
                .marginLeft(8)
                .onClick(() => {
                  this.searchParams.status = 'fail';
                });
            }
          }
        }
        .marginBottom(16);

        Button('搜索')
          .fontSize(14)
          .width(100)
          .height(36)
          .backgroundColor('#3182ce')
          .borderRadius(8)
          .alignSelf(ItemAlign.End);
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

      // 记录列表
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
            Text('时间')
              .fontSize(14)
              .fontWeight(FontWeight.SemiBold)
              .textColor('#1a365d')
              .width('25%');
            Text('产品型号')
              .fontSize(14)
              .fontWeight(FontWeight.SemiBold)
              .textColor('#1a365d')
              .width('20%');
            Text('能效等级')
              .fontSize(14)
              .fontWeight(FontWeight.SemiBold)
              .textColor('#1a365d')
              .width('15%');
            Text('数据匹配')
              .fontSize(14)
              .fontWeight(FontWeight.SemiBold)
              .textColor('#1a365d')
              .width('15%');
            Text('状态')
              .fontSize(14)
              .fontWeight(FontWeight.SemiBold)
              .textColor('#1a365d')
              .width('15%');
            Text('操作')
              .fontSize(14)
              .fontWeight(FontWeight.SemiBold)
              .textColor('#1a365d')
              .width('10%');
          }
          .padding(12)
          .backgroundColor('#f7fafc')
          .borderRadius(8);

          // 记录列表
          ForEach(this.detectionRecords, (record) => {
            Row({
              alignItems: ItemAlign.Center,
              justifyContent: FlexAlign.SpaceBetween
            }) {
              Text(record.timestamp)
                .fontSize(14)
                .textColor('#4a5568')
                .width('25%');
              Text(record.productModel)
                .fontSize(14)
                .textColor('#4a5568')
                .width('20%');
              Text(record.energyEfficiency)
                .fontSize(14)
                .textColor('#4a5568')
                .width('15%');
              Text(record.isDataMatch ? '匹配' : '不匹配')
                .fontSize(14)
                .textColor(record.isDataMatch ? '#38a169' : '#e53e3e')
                .width('15%');
              Text(record.isPass ? '通过' : '失败')
                .fontSize(14)
                .fontWeight(FontWeight.SemiBold)
                .textColor(record.isPass ? '#38a169' : '#e53e3e')
                .width('15%');
              Button('查看')
                .fontSize(12)
                .width(50)
                .height(28)
                .backgroundColor('#3182ce')
                .borderRadius(6);
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

  // 统计分析页面
  @Builder AnalyticsView() {
    Column({
      alignItems: ItemAlign.Stretch,
      justifyContent: FlexAlign.Start
    }) {
      Text('统计分析')
        .fontSize(16)
        .fontWeight(FontWeight.SemiBold)
        .textColor('#1a365d')
        .marginBottom(16);

      // 统计卡片
      Row({
        alignItems: ItemAlign.Center,
        justifyContent: FlexAlign.SpaceBetween
      }) {
        Column({
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.Center
        }) {
          Text('总检测数')
            .fontSize(14)
            .textColor('#4a5568')
            .marginBottom(8);
          Text('5')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .textColor('#1a365d');
        }
        .padding(24)
        .backgroundColor('#ffffff')
        .borderRadius(8)
        .shadow({
          color: '#000000',
          radius: 4,
          offsetX: 0,
          offsetY: 2,
          blurRadius: 8
        })
        .width('23%');

        Column({
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.Center
        }) {
          Text('通过数')
            .fontSize(14)
            .textColor('#4a5568')
            .marginBottom(8);
          Text('2')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .textColor('#38a169');
        }
        .padding(24)
        .backgroundColor('#ffffff')
        .borderRadius(8)
        .shadow({
          color: '#000000',
          radius: 4,
          offsetX: 0,
          offsetY: 2,
          blurRadius: 8
        })
        .width('23%');

        Column({
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.Center
        }) {
          Text('失败数')
            .fontSize(14)
            .textColor('#4a5568')
            .marginBottom(8);
          Text('3')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .textColor('#e53e3e');
        }
        .padding(24)
        .backgroundColor('#ffffff')
        .borderRadius(8)
        .shadow({
          color: '#000000',
          radius: 4,
          offsetX: 0,
          offsetY: 2,
          blurRadius: 8
        })
        .width('23%');

        Column({
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.Center
        }) {
          Text('通过率')
            .fontSize(14)
            .textColor('#4a5568')
            .marginBottom(8);
          Text('40%')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .textColor('#3182ce');
        }
        .padding(24)
        .backgroundColor('#ffffff')
        .borderRadius(8)
        .shadow({
          color: '#000000',
          radius: 4,
          offsetX: 0,
          offsetY: 2,
          blurRadius: 8
        })
        .width('23%');
      }
      .marginBottom(16);

      // 缺陷统计
      Column({
        alignItems: ItemAlign.Stretch,
        justifyContent: FlexAlign.Start
      }) {
        Text('缺陷统计')
          .fontSize(16)
          .fontWeight(FontWeight.SemiBold)
          .textColor('#1a365d')
          .marginBottom(16);

        Row({
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.SpaceBetween
        }) {
          Column({
            alignItems: ItemAlign.Center,
            justifyContent: FlexAlign.Center
          }) {
            Text('破损')
              .fontSize(14)
              .textColor('#4a5568')
              .marginBottom(8);
            Text('1')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .textColor('#e53e3e');
          }
          .padding(20)
          .backgroundColor('#ffffff')
          .borderRadius(8)
          .shadow({
            color: '#000000',
            radius: 4,
            offsetX: 0,
            offsetY: 2,
            blurRadius: 8
          })
          .width('31%');

          Column({
            alignItems: ItemAlign.Center,
            justifyContent: FlexAlign.Center
          }) {
            Text('污渍')
              .fontSize(14)
              .textColor('#4a5568')
              .marginBottom(8);
            Text('1')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .textColor('#e53e3e');
          }
          .padding(20)
          .backgroundColor('#ffffff')
          .borderRadius(8)
          .shadow({
            color: '#000000',
            radius: 4,
            offsetX: 0,
            offsetY: 2,
            blurRadius: 8
          })
          .width('31%');

          Column({
            alignItems: ItemAlign.Center,
            justifyContent: FlexAlign.Center
          }) {
            Text('褶皱')
              .fontSize(14)
              .textColor('#4a5568')
              .marginBottom(8);
            Text('0')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .textColor('#38a169');
          }
          .padding(20)
          .backgroundColor('#ffffff')
          .borderRadius(8)
          .shadow({
            color: '#000000',
            radius: 4,
            offsetX: 0,
            offsetY: 2,
            blurRadius: 8
          })
          .width('31%');
        }
      }
      .marginBottom(16);

      // 位置偏差统计
      Column({
        alignItems: ItemAlign.Stretch,
        justifyContent: FlexAlign.Start
      }) {
        Text('位置偏差统计')
          .fontSize(16)
          .fontWeight(FontWeight.SemiBold)
          .textColor('#1a365d')
          .marginBottom(16);

        Column({
          alignItems: ItemAlign.Start,
          justifyContent: FlexAlign.Start
        }) {
          Row({
            alignItems: ItemAlign.Center,
            justifyContent: FlexAlign.SpaceBetween
          }) {
            Text('平均偏差')
              .fontSize(14)
              .textColor('#4a5568');
            Text('1.14 mm')
              .fontSize(14)
              .fontWeight(FontWeight.SemiBold)
              .textColor('#1a365d');
          }
          .marginBottom(8);
          Row({
            alignItems: ItemAlign.Center,
            justifyContent: FlexAlign.SpaceBetween
          }) {
            Text('最大偏差')
              .fontSize(14)
              .textColor('#4a5568');
            Text('2.5 mm')
              .fontSize(14)
              .fontWeight(FontWeight.SemiBold)
              .textColor('#e53e3e');
          }
          .marginBottom(8);
          Row({
            alignItems: ItemAlign.Center,
            justifyContent: FlexAlign.SpaceBetween
          }) {
            Text('最小偏差')
              .fontSize(14)
              .textColor('#4a5568');
            Text('0.3 mm')
              .fontSize(14)
              .fontWeight(FontWeight.SemiBold)
              .textColor('#38a169');
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
    .padding(16);
  }

  // 导出报告对话框
  @Builder ExportDialog() {
    Column({
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.Center
    }) {
      Column({
        alignItems: ItemAlign.Stretch,
        justifyContent: FlexAlign.Start
      }) {
        Text('导出报告')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .textColor('#1a365d')
          .marginBottom(16);

        // 导出格式
        Column({
          alignItems: ItemAlign.Start,
          justifyContent: FlexAlign.Start
        }) {
          Text('导出格式')
            .fontSize(14)
            .textColor('#4a5568')
            .marginBottom(8);
          Row() {
            Button('Excel')
              .fontSize(14)
              .width(80)
              .height(32)
              .backgroundColor(this.exportFormat === 'excel' ? '#3182ce' : '#e2e8f0')
              .textColor(this.exportFormat === 'excel' ? '#ffffff' : '#4a5568')
              .borderRadius(8)
              .onClick(() => {
                this.exportFormat = 'excel';
              });
            Button('PDF')
              .fontSize(14)
              .width(80)
              .height(32)
              .backgroundColor(this.exportFormat === 'pdf' ? '#3182ce' : '#e2e8f0')
              .textColor(this.exportFormat === 'pdf' ? '#ffffff' : '#4a5568')
              .borderRadius(8)
              .marginLeft(12)
              .onClick(() => {
                this.exportFormat = 'pdf';
              });
          }
        }
        .marginBottom(16);

        // 时间范围
        Column({
          alignItems: ItemAlign.Start,
          justifyContent: FlexAlign.Start
        }) {
          Text('时间范围')
            .fontSize(14)
            .textColor('#4a5568')
            .marginBottom(8);
          Row() {
            Button('今日')
              .fontSize(14)
              .width(80)
              .height(32)
              .backgroundColor(this.exportDateRange === 'today' ? '#3182ce' : '#e2e8f0')
              .textColor(this.exportDateRange === 'today' ? '#ffffff' : '#4a5568')
              .borderRadius(8)
              .onClick(() => {
                this.exportDateRange = 'today';
              });
            Button('本周')
              .fontSize(14)
              .width(80)
              .height(32)
              .backgroundColor(this.exportDateRange === 'week' ? '#3182ce' : '#e2e8f0')
              .textColor(this.exportDateRange === 'week' ? '#ffffff' : '#4a5568')
              .borderRadius(8)
              .marginLeft(12)
              .onClick(() => {
                this.exportDateRange = 'week';
              });
            Button('本月')
              .fontSize(14)
              .width(80)
              .height(32)
              .backgroundColor(this.exportDateRange === 'month' ? '#3182ce' : '#e2e8f0')
              .textColor(this.exportDateRange === 'month' ? '#ffffff' : '#4a5568')
              .borderRadius(8)
              .marginLeft(12)
              .onClick(() => {
                this.exportDateRange = 'month';
              });
          }
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
              this.showExportDialog = false;
            });
          Button('导出')
            .fontSize(14)
            .width(80)
            .height(36)
            .backgroundColor('#38a169')
            .borderRadius(8)
            .marginLeft(12)
            .onClick(() => {
              // 执行导出操作
              this.showExportDialog = false;
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