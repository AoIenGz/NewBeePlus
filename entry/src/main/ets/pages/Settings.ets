import router from '@ohos.router';
import { DetectionParams } from '../common/Interfaces';

const INTERVAL_OPTIONS = [5, 10, 30, 60];

@Entry
@Component
struct Settings {
  @State detectionParams: DetectionParams = {
    precision: 0.85,
    speed: 0.7,
    threshold: 0.6,
  };
  @State serverUrl: string = 'http://10.0.2.2:3000';
  @State captureInterval: number = AppStorage.get<number>('industrialCaptureInterval') || 10;
  @State webcamServerUrl: string = AppStorage.get<string>('webcamServerUrl') || 'http://10.0.2.2:5000';

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button('返回')
          .fontSize(12).fontColor('#ffffff').height(28).padding({ left: 12, right: 12 })
          .backgroundColor('rgba(255, 255, 255, 0.2)').borderRadius(14)
          .onClick(() => { router.back(); });
        Text('设置')
          .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#ffffff')
          .layoutWeight(1).textAlign(TextAlign.Center);
        Row().width(56);
      }
      .width('100%').padding({ left: 12, right: 12, top: 10, bottom: 10 })
      .linearGradient({ direction: GradientDirection.Right, colors: [['#2B6CB0', 0], ['#4299E1', 1]] });

      Scroll() {
        Column() {
          // 检测参数
          Column() {
            Text('检测参数')
              .fontSize(14).fontWeight(FontWeight.Medium).fontColor('#1a365d').margin({ bottom: 12 });
            Column() {
              Text('检测精度: ' + (this.detectionParams.precision * 100).toFixed(0) + '%')
                .fontSize(13).fontColor('#4a5568').margin({ bottom: 6 });
              Slider({ value: this.detectionParams.precision, min: 0.5, max: 0.95, step: 0.05, style: SliderStyle.OutSet })
                .width('100%')
                .onChange((value: number) => { this.detectionParams.precision = value; });
            }.width('100%').alignItems(HorizontalAlign.Start).margin({ bottom: 12 });
            Column() {
              Text('检测速度: ' + (this.detectionParams.speed * 100).toFixed(0) + '%')
                .fontSize(13).fontColor('#4a5568').margin({ bottom: 6 });
              Slider({ value: this.detectionParams.speed, min: 0.3, max: 0.9, step: 0.1, style: SliderStyle.OutSet })
                .width('100%')
                .onChange((value: number) => { this.detectionParams.speed = value; });
            }.width('100%').alignItems(HorizontalAlign.Start).margin({ bottom: 12 });
            Column() {
              Text('阈值: ' + (this.detectionParams.threshold * 100).toFixed(0) + '%')
                .fontSize(13).fontColor('#4a5568').margin({ bottom: 6 });
              Slider({ value: this.detectionParams.threshold, min: 0.3, max: 0.9, step: 0.05, style: SliderStyle.OutSet })
                .width('100%')
                .onChange((value: number) => { this.detectionParams.threshold = value; });
            }.width('100%').alignItems(HorizontalAlign.Start);
          }.width('100%').padding(12).backgroundColor('#ffffff').borderRadius(10);

          // 服务器配置
          Column() {
            Text('服务器配置')
              .fontSize(14).fontWeight(FontWeight.Medium).fontColor('#1a365d').margin({ bottom: 12 });
            Column() {
              Text('后端地址').fontSize(12).fontColor('#718096').margin({ bottom: 6 });
              TextInput({ text: this.serverUrl, placeholder: 'http://IP:PORT' })
                .width('100%').height(38).padding({ left: 10, right: 10 })
                .backgroundColor('#f7fafc').borderRadius(8)
                .onChange((value: string) => { this.serverUrl = value; });
            }.width('100%').alignItems(HorizontalAlign.Start);
          }.width('100%').padding(12).backgroundColor('#ffffff').borderRadius(10).margin({ top: 10 });

          // 工业相机配置
          Column() {
            Text('工业相机配置')
              .fontSize(14).fontWeight(FontWeight.Medium).fontColor('#1a365d').margin({ bottom: 12 });
            Column() {
              Text('网络摄像头地址').fontSize(12).fontColor('#718096').margin({ bottom: 6 });
              TextInput({ text: this.webcamServerUrl, placeholder: 'http://IP:PORT' })
                .width('100%').height(38).padding({ left: 10, right: 10 })
                .backgroundColor('#f7fafc').borderRadius(8)
                .onChange((value: string) => {
                  this.webcamServerUrl = value;
                  AppStorage.setOrCreate<string>('webcamServerUrl', value);
                });
            }.width('100%').alignItems(HorizontalAlign.Start).margin({ bottom: 12 });
            Column() {
              Text('默认拍照间隔').fontSize(12).fontColor('#718096').margin({ bottom: 8 });
              Row() {
                ForEach(INTERVAL_OPTIONS, (interval: number) => {
                  Text(`${interval}秒`)
                    .fontSize(13)
                    .fontColor(this.captureInterval === interval ? '#ffffff' : '#4a5568')
                    .fontWeight(this.captureInterval === interval ? FontWeight.Bold : FontWeight.Normal)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.captureInterval === interval ? '#3182ce' : '#edf2f7')
                    .borderRadius(8)
                    .margin({ right: 8 })
                    .onClick(() => {
                      this.captureInterval = interval;
                      AppStorage.setOrCreate<number>('industrialCaptureInterval', interval);
                    });
                }, (interval: number) => `${interval}`)
              }
            }.width('100%').alignItems(HorizontalAlign.Start);
          }.width('100%').padding(12).backgroundColor('#ffffff').borderRadius(10).margin({ top: 10 });

          // 关于
          Column() {
            Text('关于')
              .fontSize(14).fontWeight(FontWeight.Medium).fontColor('#1a365d').margin({ bottom: 12 });
            Row() {
              Text('应用名称').fontSize(13).fontColor('#718096').layoutWeight(1);
              Text('能效标签检测系统').fontSize(13).fontColor('#1a365d');
            }.width('100%').margin({ bottom: 8 });
            Row() {
              Text('版本').fontSize(13).fontColor('#718096').layoutWeight(1);
              Text('1.0.0').fontSize(13).fontColor('#1a365d');
            }.width('100%').margin({ bottom: 8 });
            Row() {
              Text('模型').fontSize(13).fontColor('#718096').layoutWeight(1);
              Text('YOLOv8n').fontSize(13).fontColor('#1a365d');
            }.width('100%');
          }.width('100%').padding(12).backgroundColor('#ffffff').borderRadius(10).margin({ top: 10 });
        }.width('100%').padding(12);
      }.layoutWeight(1);
    }
    .height('100%').width('100%').backgroundColor('#f0f4f8');
  }
}
