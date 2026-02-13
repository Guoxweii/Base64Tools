import { Base64Util } from '../utils/Base64Util';
import { SecretBox } from '../components/SecretBox';
import pasteboard from '@ohos.pasteboard';
import promptAction from '@ohos.promptAction';
import { scanBarcode, scanCore } from '@kit.ScanKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, common } from '@kit.AbilityKit';

@Entry
@Component
struct Index {
  @State inputText: string = '';
  @State outputText: string = '';
  @State outputKey: number = 0;
  @State inputKey: number = 0;
  @State currentMode: 'encode' | 'decode' = 'encode';

  hideKeyboard(): void {
    focusControl.requestFocus('titleFocus');
  }

  executeTransform(): void {
    this.hideKeyboard();
    if (!this.inputText) {
      return;
    }

    animateTo({ duration: 240, curve: Curve.FastOutSlowIn }, () => {
      this.outputText = this.currentMode === 'encode' ? Base64Util.encode(this.inputText) : Base64Util.decode(this.inputText);
      this.outputKey = Date.now();
    });
  }

  handleClear(): void {
    this.hideKeyboard();
    animateTo({ duration: 180, curve: Curve.EaseOut }, () => {
      this.inputText = '';
      this.outputText = '';
      this.inputKey = Date.now();
      this.outputKey = Date.now() + 1;
    });
  }

  handleCopyAndBurn(): void {
    this.hideKeyboard();
    if (!this.outputText) {
      return;
    }

    try {
      const systemPasteboard = pasteboard.getSystemPasteboard();
      const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.outputText);

      systemPasteboard.setData(pasteData).then(() => {
        promptAction.showToast({
          message: '已复制并销毁记录',
          duration: 1800,
          bottom: 180
        });
        this.handleClear();
      }).catch((err: Error) => {
        console.error('Copy failed:', err);
      });
    } catch (e) {
      console.error('Pasteboard error:', e);
    }
  }

  async requestCameraPermission(): Promise<boolean> {
    let atManager = abilityAccessCtrl.createAtManager();
    let context = getContext(this) as common.UIAbilityContext;
    try {
      let result = await atManager.requestPermissionsFromUser(context, ['ohos.permission.CAMERA']);
      return result.authResults.length > 0 && result.authResults[0] === 0;
    } catch (err) {
      return false;
    }
  }

  async handleScan(): Promise<void> {
    this.hideKeyboard();
    const hasPermission = await this.requestCameraPermission();
    if (!hasPermission) {
      return;
    }

    let options: scanBarcode.ScanOptions = {
      scanTypes: [scanCore.ScanType.ALL],
      enableMultiMode: true,
      enableAlbum: true
    };

    try {
      scanBarcode.startScanForResult(getContext(this), options)
        .then((result: scanBarcode.ScanResult) => {
          if (result.originalValue) {
            this.inputText = result.originalValue;
          }
        })
        .catch((error: BusinessError) => {
          console.error('Scan failed:', error);
        });
    } catch (error) {
      console.error('Scan launch failed:', error);
    }
  }

  @Builder
  ModeButton(label: string, mode: 'encode' | 'decode') {
    Button(label, { type: ButtonType.Normal, stateEffect: true })
      .layoutWeight(1)
      .height(42)
      .borderRadius(999)
      .backgroundColor(this.currentMode === mode ? $r('app.color.card_background') : Color.Transparent)
      .fontColor(this.currentMode === mode ? $r('app.color.brand_primary') : $r('app.color.text_secondary'))
      .fontWeight(this.currentMode === mode ? FontWeight.Medium : FontWeight.Regular)
      .onClick(() => {
        this.currentMode = mode;
      })
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.page_background'))
        .onClick(() => {
          this.hideKeyboard();
        })

      Column() {
        Column() {
          Text('Base64加密助手')
            .id('titleFocus')
            .focusable(true)
            .defaultFocus(true)
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Text('本地转换，不上传服务器')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 4 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ top: 53, bottom: 14 })

        SecretBox({
          content: $inputText,
          title: '输入内容',
          isInput: true,
          placeholder: '粘贴文本或扫码读取内容',
          contentHeight: 112,
          onScanClick: () => {
            this.handleScan();
          },
          onClearClick: () => {
            this.handleClear();
          }
        })
        .key(`input_${this.inputKey}`)

        Row() {
          Row({ space: 8 }) {
            this.ModeButton('Base64 编码', 'encode');
            this.ModeButton('Base64 解码', 'decode');
          }
          .width('100%')
          .padding(4)
          .backgroundColor($r('app.color.sub_button_background'))
          .borderRadius(999)
        }
        .width('100%')
        .margin({ top: 10 })

        Button(this.currentMode === 'encode' ? '执行编码转换' : '执行解码转换', { type: ButtonType.Capsule, stateEffect: true })
          .width('100%')
          .height(48)
          .margin({ top: 10 })
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_white'))
          .linearGradient({
            angle: 135,
            colors: [[$r('app.color.brand_primary'), 0.0], [$r('app.color.brand_primary_dark'), 1.0]]
          })
          .shadow({ radius: 16, color: $r('app.color.shadow_primary'), offsetY: 6 })
          .enabled(!!this.inputText)
          .opacity(this.inputText ? 1 : 0.52)
          .onClick(() => {
            this.executeTransform();
          })

        SecretBox({
          content: $outputText,
          title: '输出结果',
          isInput: false,
          contentHeight: this.outputText ? 96 : 80
        })
        .key(`output_${this.outputKey}`)
        .margin({ top: 12 })

        Row({ space: 10 }) {
          Button('清空', { type: ButtonType.Capsule, stateEffect: true })
            .layoutWeight(1)
            .height(44)
            .backgroundColor($r('app.color.card_background'))
            .fontColor($r('app.color.text_secondary'))
            .fontWeight(FontWeight.Medium)
            .shadow({ radius: 8, color: $r('app.color.shadow_normal'), offsetY: 2 })
            .onClick(() => {
              this.handleClear();
            })

          Button('复制并销毁', { type: ButtonType.Capsule, stateEffect: true })
            .layoutWeight(1)
            .height(44)
            .backgroundColor($r('app.color.danger_light_background'))
            .fontColor($r('app.color.brand_danger_dark'))
            .fontWeight(FontWeight.Bold)
            .enabled(!!this.outputText)
            .opacity(this.outputText ? 1 : 0.5)
            .onClick(() => {
              this.handleCopyAndBurn();
            })
        }
        .width('100%')
        .margin({ top: 10, bottom: 20 })
      }
      .width('100%')
      .height('100%')
      .padding({ left: 20, right: 20, top: 0, bottom: 12 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
