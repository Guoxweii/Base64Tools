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
            .fontColor($r('app.color.text_primary'))
          
          Text(this.isRunning ? '正在运行' : '已停止')
            .fontSize(14)
            .fontColor(this.isRunning ? $r('app.color.brand_success') : $r('app.color.text_secondary')) // iOS Green or Grey
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
          .selectedColor($r('app.color.brand_primary'))
          .switchPointColor($r('app.color.text_white'))
      }
      .width('100%')
      .padding(20)
      .alignItems(VerticalAlign.Center)

      // Details Area
      if (this.isRunning) {
        Divider()
          .color($r('app.color.divider_color'))
          .width('100%')
          .strokeWidth(1)
        
        Column({ space: 12 }) {
          Row() {
             Text('服务地址')
               .fontSize(14)
               .fontColor($r('app.color.text_secondary'))
             Blank()
             Text(`http://${this.serverIp}:${this.serverPort}`)
               .fontSize(16)
               .fontColor($r('app.color.brand_primary'))
               .fontWeight(FontWeight.Medium)
               .copyOption(CopyOptions.LocalDevice)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          
          Row() {
             Text('状态')
               .fontSize(14)
               .fontColor($r('app.color.text_secondary'))
             Blank()
             Text('在线')
               .fontSize(14)
               .fontColor($r('app.color.brand_success'))
          }
          .width('100%')
          
          Text('保持应用前台运行以维持服务稳定性')
            .fontSize(12)
            .fontColor($r('app.color.text_tertiary'))
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: 8 })
        }
        .padding(20)
        .backgroundColor($r('app.color.tool_bar_background'))
        .borderRadius({ bottomLeft: 16, bottomRight: 16 })
      }
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
    .shadow({ radius: 10, color: $r('app.color.shadow_normal'), offsetY: 2 })
    .animation({ duration: 300, curve: Curve.FastOutSlowIn })
  }
}
