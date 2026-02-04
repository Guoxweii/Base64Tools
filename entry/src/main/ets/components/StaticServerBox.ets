@Component
export struct StaticServerBox {
  @State isRunning: boolean = false;
  @State serverIp: string = '192.168.1.5'; // 模拟 IP
  @State serverPort: string = '8080';

  build() {
    Column() {
      // Header
      Row() {
        // 使用生成的 Icon
        Image($r('app.media.mi_icon'))
          .width(48)
          .height(48)
          .margin({ right: 16 })
          .borderRadius(12) // Icon 自带圆角，这里可以不切，或者切一点
        
        Column() {
          Text('静态服务')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
          
          Text(this.isRunning ? '正在运行' : '已停止')
            .fontSize(14)
            .fontColor(this.isRunning ? '#34C759' : '#8E8E93') // iOS Green or Grey
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Toggle({ type: ToggleType.Switch, isOn: this.isRunning })
          .onChange((isOn: boolean) => {
            animateTo({ duration: 300, curve: Curve.FastOutSlowIn }, () => {
              this.isRunning = isOn;
            });
          })
          .selectedColor('#007AFF')
          .switchPointColor('#FFFFFF')
      }
      .width('100%')
      .padding(20)
      .alignItems(VerticalAlign.Center)

      // Details Area
      if (this.isRunning) {
        Divider()
          .color('#F5F5F5')
          .width('100%')
          .strokeWidth(1)
        
        Column({ space: 12 }) {
          Row() {
             Text('服务地址')
               .fontSize(14)
               .fontColor('#8E8E93')
             Blank()
             Text(`http://${this.serverIp}:${this.serverPort}`)
               .fontSize(16)
               .fontColor('#007AFF')
               .fontWeight(FontWeight.Medium)
               .copyOption(CopyOptions.LocalDevice)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          
          Row() {
             Text('状态')
               .fontSize(14)
               .fontColor('#8E8E93')
             Blank()
             Text('在线')
               .fontSize(14)
               .fontColor('#34C759')
          }
          .width('100%')
          
          Text('保持应用前台运行以维持服务稳定性')
            .fontSize(12)
            .fontColor('#C7C7CC')
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: 8 })
        }
        .padding(20)
        .backgroundColor('#FAFAFA')
        .borderRadius({ bottomLeft: 16, bottomRight: 16 })
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 10, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
    .animation({ duration: 300, curve: Curve.FastOutSlowIn })
  }
}
