import router from '@ohos.router';
import http from '@ohos.net.http';
import { DetectionRecord, SearchParams } from '../common/Interfaces';

const BASE_URL = 'http://10.0.2.2:3000/api';

interface StatsData {
  total: number;
  passCount: number;
  failCount: number;
  passRate: number;
  damaged: number;
  stained: number;
  wrinkled: number;
  avgDev: string;
  maxDev: string;
  minDev: string;
}

@Entry
@Component
struct History {
  @State selectedTab: string = 'records';
  @State detectionRecords: DetectionRecord[] = [];
  @State stats: StatsData = {
    total: 0, passCount: 0, failCount: 0, passRate: 0,
    damaged: 0, stained: 0, wrinkled: 0,
    avgDev: '0', maxDev: '0', minDev: '0',
  };
  @State searchParams: SearchParams = {
    productModel: '',
    startDate: '',
    endDate: '',
    status: 'all',
  };
  @State showExportDialog: boolean = false;

  aboutToAppear() {
    this.loadRecords();
    this.loadStats();
  }

  async loadRecords() {
    try {
      const httpRequest = http.createHttp();
      let url = `${BASE_URL}/history?`;
      if (this.searchParams.productModel) url += `productModel=${this.searchParams.productModel}&`;
      if (this.searchParams.startDate) url += `startDate=${this.searchParams.startDate}&`;
      if (this.searchParams.endDate) url += `endDate=${this.searchParams.endDate}&`;
      if (this.searchParams.status !== 'all') url += `status=${this.searchParams.status}&`;

      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: { 'Content-Type': 'application/json' },
      });
      if (response.responseCode === 200) {
        this.detectionRecords = JSON.parse(response.result as string) as DetectionRecord[];
      }
    } catch (err) {
      console.error('加载记录失败:', err);
    }
  }

  async loadStats() {
    try {
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(`${BASE_URL}/history/stats`, {
        method: http.RequestMethod.GET,
        header: { 'Content-Type': 'application/json' },
      });
      if (response.responseCode === 200) {
        this.stats = JSON.parse(response.result as string) as StatsData;
      }
    } catch (err) {
      console.error('加载统计失败:', err);
    }
  }

  handleSearch() {
    this.loadRecords();
    this.loadStats();
  }

  async deleteRecord(id: string) {
    try {
      const httpRequest = http.createHttp();
      await httpRequest.request(`${BASE_URL}/history/${id}`, {
        method: http.RequestMethod.DELETE,
        header: { 'Content-Type': 'application/json' },
      });
      httpRequest.destroy();
      this.loadRecords();
      this.loadStats();
    } catch (err) {
      console.error('删除记录失败:', err);
    }
  }

  async deleteAllRecords() {
    try {
      const httpRequest = http.createHttp();
      await httpRequest.request(`${BASE_URL}/history`, {
        method: http.RequestMethod.DELETE,
        header: { 'Content-Type': 'application/json' },
      });
      httpRequest.destroy();
      this.detectionRecords = [];
      this.loadStats();
    } catch (err) {
      console.error('清空记录失败:', err);
    }
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航栏
        Row() {
          Button('返回')
            .fontSize(12).fontColor('#ffffff').height(28).padding({ left: 12, right: 12 })
            .backgroundColor('rgba(255, 255, 255, 0.2)').borderRadius(14)
            .onClick(() => { router.back(); });
          Text('历史记录')
            .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#ffffff')
            .layoutWeight(1).textAlign(TextAlign.Center);
          Row().width(56);
        }
        .width('100%').padding({ left: 12, right: 12, top: 10, bottom: 10 })
        .linearGradient({ direction: GradientDirection.Right, colors: [['#2B6CB0', 0], ['#4299E1', 1]] });

        // 标签切换
        Row() {
          Button('检测记录')
            .fontSize(13).layoutWeight(1).height(34)
            .backgroundColor(this.selectedTab === 'records' ? '#3182ce' : '#e2e8f0')
            .fontColor(this.selectedTab === 'records' ? '#ffffff' : '#4a5568').borderRadius(8)
            .onClick(() => { this.selectedTab = 'records'; });
          Button('统计分析')
            .fontSize(13).layoutWeight(1).height(34)
            .backgroundColor(this.selectedTab === 'analytics' ? '#3182ce' : '#e2e8f0')
            .fontColor(this.selectedTab === 'analytics' ? '#ffffff' : '#4a5568').borderRadius(8)
            .margin({ left: 8 })
            .onClick(() => { this.selectedTab = 'analytics'; });
        }
        .width('100%').padding(12).backgroundColor('#ffffff');

        if (this.selectedTab === 'records') {
          this.RecordsView();
        } else {
          this.AnalyticsView();
        }

        Row() {
          Button('导出报告')
            .fontSize(14).fontColor('#ffffff').width('100%').height(38)
            .backgroundColor('#38a169').borderRadius(8)
            .onClick(() => { this.showExportDialog = true; });
        }
        .width('100%').padding({ left: 16, right: 16, top: 10, bottom: 10 })
        .backgroundColor('#ffffff').border({ width: { top: 1 }, color: '#e2e8f0' });
      }
      .height('100%').width('100%').backgroundColor('#f0f4f8');

      if (this.showExportDialog) {
        this.ExportDialog();
      }
    }
    .height('100%').width('100%');
  }

  @Builder RecordsView() {
    Column() {
      // 搜索区
      Column() {
        Text('搜索和过滤').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#1a365d').margin({ bottom: 10 });
        Column() {
          Text('产品型号').fontSize(12).fontColor('#718096').margin({ bottom: 6 });
          TextInput({ text: this.searchParams.productModel, placeholder: '请输入产品型号' })
            .width('100%').height(36).padding({ left: 10, right: 10 })
            .backgroundColor('#f7fafc').borderRadius(8)
            .onChange((value: string) => { this.searchParams.productModel = value; });
        }.width('100%').alignItems(HorizontalAlign.Start).margin({ bottom: 10 });

        Row() {
          Column() {
            Text('开始日期').fontSize(12).fontColor('#718096').margin({ bottom: 6 });
            TextInput({ text: this.searchParams.startDate, placeholder: 'YYYY-MM-DD' })
              .width('100%').height(36).padding({ left: 10, right: 10 })
              .backgroundColor('#f7fafc').borderRadius(8)
              .onChange((value: string) => { this.searchParams.startDate = value; });
          }.layoutWeight(1).alignItems(HorizontalAlign.Start);
          Column() {
            Text('结束日期').fontSize(12).fontColor('#718096').margin({ bottom: 6 });
            TextInput({ text: this.searchParams.endDate, placeholder: 'YYYY-MM-DD' })
              .width('100%').height(36).padding({ left: 10, right: 10 })
              .backgroundColor('#f7fafc').borderRadius(8)
              .onChange((value: string) => { this.searchParams.endDate = value; });
          }.layoutWeight(1).alignItems(HorizontalAlign.Start).margin({ left: 8 });
        }.width('100%').margin({ bottom: 10 });

        Column() {
          Text('状态').fontSize(12).fontColor('#718096').margin({ bottom: 6 });
          Row() {
            Button('全部').fontSize(12).layoutWeight(1).height(32)
              .backgroundColor(this.searchParams.status === 'all' ? '#3182ce' : '#e2e8f0')
              .fontColor(this.searchParams.status === 'all' ? '#ffffff' : '#4a5568').borderRadius(6)
              .onClick(() => { this.searchParams.status = 'all'; });
            Button('通过').fontSize(12).layoutWeight(1).height(32)
              .backgroundColor(this.searchParams.status === 'pass' ? '#3182ce' : '#e2e8f0')
              .fontColor(this.searchParams.status === 'pass' ? '#ffffff' : '#4a5568').borderRadius(6).margin({ left: 8 })
              .onClick(() => { this.searchParams.status = 'pass'; });
            Button('失败').fontSize(12).layoutWeight(1).height(32)
              .backgroundColor(this.searchParams.status === 'fail' ? '#3182ce' : '#e2e8f0')
              .fontColor(this.searchParams.status === 'fail' ? '#ffffff' : '#4a5568').borderRadius(6).margin({ left: 8 })
              .onClick(() => { this.searchParams.status = 'fail'; });
          }.width('100%');
        }.width('100%').alignItems(HorizontalAlign.Start).margin({ bottom: 10 });

        Button('搜索').fontSize(14).fontColor('#ffffff').width('100%').height(36)
          .backgroundColor('#3182ce').borderRadius(8)
          .onClick(() => { this.handleSearch(); });

        Button('清空所有记录').fontSize(12).fontColor('#e53e3e').width('100%').height(32)
          .backgroundColor('#fff5f5').borderRadius(8).margin({ top: 8 })
          .onClick(() => { this.deleteAllRecords(); });
      }.width('100%').padding(12).backgroundColor('#ffffff').borderRadius(10).margin({ bottom: 10 });

      // 记录列表
      Scroll() {
        Column() {
          if (this.detectionRecords.length === 0) {
            Text('暂无检测记录').fontSize(13).fontColor('#a0aec0').margin({ top: 20 });
          }
          ForEach(this.detectionRecords, (record: DetectionRecord) => {
            Column() {
              Row() {
                Text(record.productModel).fontSize(14).fontWeight(FontWeight.Medium).fontColor('#1a365d').layoutWeight(1);
                Text(record.isPass ? '通过' : '失败')
                  .fontSize(11).fontWeight(FontWeight.Bold)
                  .fontColor(record.isPass ? '#38a169' : '#e53e3e')
                  .backgroundColor(record.isPass ? '#c6f6d5' : '#fed7d7')
                  .padding({ left: 8, right: 8, top: 3, bottom: 3 }).borderRadius(10);
              }.width('100%').margin({ bottom: 6 });

              Text(record.timestamp).fontSize(12).fontColor('#718096').width('100%').margin({ bottom: 6 });

              Row() {
                Text(`等级: ${record.grade}级`).fontSize(12).fontColor('#4a5568');
                Text(' | ').fontSize(12).fontColor('#cbd5e0');
                Text(record.isDataMatch ? '数据匹配' : '数据不匹配')
                  .fontSize(12).fontColor(record.isDataMatch ? '#38a169' : '#e53e3e');
              }.width('100%').margin({ bottom: 6 });

              Row() {
                if (record.defects.isDamaged) {
                  Text('破损').fontSize(11).fontColor('#e53e3e')
                    .backgroundColor('#fed7d7').padding({ left: 6, right: 6, top: 2, bottom: 2 }).borderRadius(4)
                    .margin({ right: 4 });
                }
                if (record.defects.isStained) {
                  Text('污渍').fontSize(11).fontColor('#e53e3e')
                    .backgroundColor('#fed7d7').padding({ left: 6, right: 6, top: 2, bottom: 2 }).borderRadius(4)
                    .margin({ right: 4 });
                }
                if (record.defects.isWrinkled) {
                  Text('褶皱').fontSize(11).fontColor('#e53e3e')
                    .backgroundColor('#fed7d7').padding({ left: 6, right: 6, top: 2, bottom: 2 }).borderRadius(4);
                }
                Blank().layoutWeight(1);
                Text('删除').fontSize(11).fontColor('#e53e3e')
                  .onClick(() => { this.deleteRecord(record.id); });
              }.width('100%');
            }.width('100%').padding(12).backgroundColor('#ffffff').borderRadius(10).margin({ bottom: 8 });
          }, (record: DetectionRecord) => record.id);
        }.width('100%');
      }.layoutWeight(1);
    }.width('100%').padding(12).layoutWeight(1);
  }

  @Builder AnalyticsView() {
    Scroll() {
      Column() {
        Text('统计分析').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#1a365d').margin({ bottom: 10 });

        Row() {
          Column() {
            Text('总检测数').fontSize(12).fontColor('#718096').margin({ bottom: 4 });
            Text(`${this.stats.total}`).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#1a365d');
          }.layoutWeight(1).padding(14).backgroundColor('#ffffff').borderRadius(10).alignItems(HorizontalAlign.Center);
          Column() {
            Text('通过数').fontSize(12).fontColor('#718096').margin({ bottom: 4 });
            Text(`${this.stats.passCount}`).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#38a169');
          }.layoutWeight(1).padding(14).backgroundColor('#ffffff').borderRadius(10).alignItems(HorizontalAlign.Center).margin({ left: 8 });
        }.width('100%').margin({ bottom: 8 });

        Row() {
          Column() {
            Text('失败数').fontSize(12).fontColor('#718096').margin({ bottom: 4 });
            Text(`${this.stats.failCount}`).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#e53e3e');
          }.layoutWeight(1).padding(14).backgroundColor('#ffffff').borderRadius(10).alignItems(HorizontalAlign.Center);
          Column() {
            Text('通过率').fontSize(12).fontColor('#718096').margin({ bottom: 4 });
            Text(`${this.stats.passRate}%`).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#3182ce');
          }.layoutWeight(1).padding(14).backgroundColor('#ffffff').borderRadius(10).alignItems(HorizontalAlign.Center).margin({ left: 8 });
        }.width('100%').margin({ bottom: 12 });

        // 缺陷统计
        Column() {
          Text('缺陷统计').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#1a365d').margin({ bottom: 10 });
          Row() {
            Column() {
              Text('破损').fontSize(11).fontColor('#718096').margin({ bottom: 4 });
              Text(`${this.stats.damaged}`).fontSize(18).fontWeight(FontWeight.Bold)
                .fontColor(this.stats.damaged > 0 ? '#e53e3e' : '#38a169');
            }.layoutWeight(1).padding(10).backgroundColor('#f7fafc').borderRadius(8).alignItems(HorizontalAlign.Center);
            Column() {
              Text('污渍').fontSize(11).fontColor('#718096').margin({ bottom: 4 });
              Text(`${this.stats.stained}`).fontSize(18).fontWeight(FontWeight.Bold)
                .fontColor(this.stats.stained > 0 ? '#e53e3e' : '#38a169');
            }.layoutWeight(1).padding(10).backgroundColor('#f7fafc').borderRadius(8).alignItems(HorizontalAlign.Center).margin({ left: 8 });
            Column() {
              Text('褶皱').fontSize(11).fontColor('#718096').margin({ bottom: 4 });
              Text(`${this.stats.wrinkled}`).fontSize(18).fontWeight(FontWeight.Bold)
                .fontColor(this.stats.wrinkled > 0 ? '#e53e3e' : '#38a169');
            }.layoutWeight(1).padding(10).backgroundColor('#f7fafc').borderRadius(8).alignItems(HorizontalAlign.Center).margin({ left: 8 });
          }.width('100%');
        }.width('100%').padding(12).backgroundColor('#ffffff').borderRadius(10).margin({ bottom: 12 });

        // 位置偏差
        Column() {
          Text('位置偏差统计').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#1a365d').margin({ bottom: 10 });
          Column() {
            Row() {
              Text('平均偏差').fontSize(13).fontColor('#718096');
              Text(`${this.stats.avgDev}%`).fontSize(13).fontWeight(FontWeight.Medium).fontColor('#1a365d');
            }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 8 });
            Row() {
              Text('最大偏差').fontSize(13).fontColor('#718096');
              Text(`${this.stats.maxDev}%`).fontSize(13).fontWeight(FontWeight.Medium).fontColor('#e53e3e');
            }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 8 });
            Row() {
              Text('最小偏差').fontSize(13).fontColor('#718096');
              Text(`${this.stats.minDev}%`).fontSize(13).fontWeight(FontWeight.Medium).fontColor('#38a169');
            }.width('100%').justifyContent(FlexAlign.SpaceBetween);
          }.width('100%').padding(10).backgroundColor('#f7fafc').borderRadius(8);
        }.width('100%').padding(12).backgroundColor('#ffffff').borderRadius(10);
      }.width('100%').padding(12);
    }.layoutWeight(1);
  }

  @Builder ExportDialog() {
    Column() {
      Column() {
        Text('导出报告').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1a365d').margin({ bottom: 16 });
        Text('将导出所有检测记录为CSV文件')
          .fontSize(13).fontColor('#718096').margin({ bottom: 20 });
        Row() {
          Button('取消').fontSize(14).fontColor('#4a5568').layoutWeight(1).height(36)
            .backgroundColor('#e2e8f0').borderRadius(8)
            .onClick(() => { this.showExportDialog = false; });
          Button('导出CSV').fontSize(14).fontColor('#ffffff').layoutWeight(1).height(36)
            .backgroundColor('#38a169').borderRadius(8).margin({ left: 8 })
            .onClick(() => {
              this.showExportDialog = false;
            });
        }.width('100%');
      }.padding(20).backgroundColor('#ffffff').borderRadius(12).width('85%');
    }.width('100%').height('100%').backgroundColor('rgba(0, 0, 0, 0.5)').justifyContent(FlexAlign.Center);
  }
}
