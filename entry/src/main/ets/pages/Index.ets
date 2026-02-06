import { Base64Util } from '../utils/Base64Util';
import { SecretBox } from '../components/SecretBox';
import pasteboard from '@ohos.pasteboard';
import promptAction from '@ohos.promptAction';
import { scanBarcode, scanCore } from '@kit.ScanKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';

@Entry
@Component
struct Index {
  @State inputText: string = '';
  @State outputText: string = '';
  @State outputKey: number = 0; 
  @State inputKey: number = 0;

  hideKeyboard(): void {
    focusControl.requestFocus('titleFocus');
  }

  handleEncrypt(): void {
    this.hideKeyboard();
    if (!this.inputText) return;
    
    animateTo({ duration: 300, curve: Curve.FastOutSlowIn }, () => {
      this.outputText = Base64Util.encode(this.inputText);
      this.outputKey = Date.now(); 
    });
  }

  handleDecrypt(): void {
    this.hideKeyboard();
    if (!this.inputText) return;

    animateTo({ duration: 300, curve: Curve.FastOutSlowIn }, () => {
      this.outputText = Base64Util.decode(this.inputText);
      this.outputKey = Date.now(); 
    });
  }

  handleClear(): void {
    this.hideKeyboard();
    animateTo({ duration: 200, curve: Curve.EaseOut }, () => {
      this.inputText = '';
      this.outputText = '';
      this.inputKey = Date.now(); 
      this.outputKey = Date.now() + 1; 
    });
  }

  handleCopyAndBurn(): void {
    this.hideKeyboard();
    if (!this.outputText) return;
    
    try {
      const systemPasteboard = pasteboard.getSystemPasteboard();
      const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.outputText);
      
      systemPasteboard.setData(pasteData).then(() => {
        promptAction.showToast({
          message: '📋 已复制并销毁记录',
          duration: 2000,
          bottom: 200
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
      if (result.authResults.length > 0 && result.authResults[0] === 0) {
        return true;
      }
      return false;
    } catch (err) {
      return false;
    }
  }

  async handleScan(): Promise<void> {
    this.hideKeyboard();
    const hasPermission = await this.requestCameraPermission();
    if (!hasPermission) return;

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
        .catch((error: BusinessError) => {});
    } catch (error) {}
  }

  build() {
    Stack() {
      // 1. 全局背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.page_background')) // iOS 系统灰
        .onClick(() => { this.hideKeyboard(); })

      // 2. 可滚动的内容区域
      Scroll() {
        Column() {
          // 2.1 标题区
          Row() {
            Column() {
              Text('Base64 隐私助手')
                .id('titleFocus') 
                .focusable(true) 
                .defaultFocus(true) 
                .fontSize(24) // 稍微调小一点，更精致
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary'))
                .margin({ bottom: 4 })
              
              Text('阅后即焚的安全转换工具')
                .fontSize(14)
                .fontColor($r('app.color.text_secondary'))
            }
            .alignItems(HorizontalAlign.Start)
            
            Blank()
            
            // 可以放个小的 logo 或者版本号
            Text('v1.0beta')
              .fontSize(10)
              .fontColor($r('app.color.text_secondary'))
              .backgroundColor($r('app.color.sub_button_background'))
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(10)
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .margin({ top: 48, bottom: 32 }) // 增加底部间距
          .padding({ left: 4 })

          // 2.2 输入卡片 (集成工具栏)
          SecretBox({
            content: $inputText,
            title: 'INPUT', 
            isInput: true,
            placeholder: '在此输入内容...',
            onScanClick: () => { this.handleScan() },
            onClearClick: () => { this.handleClear() } // 绑定清空逻辑
          })
          .key(`input_${this.inputKey}`)
          .margin({ bottom: 24 })

          // 2.3 转换操作区
          Row() {
             // 加密按钮 (蓝色胶囊)
             Button('加密 (Base64)', { type: ButtonType.Normal, stateEffect: true })
              .onClick(() => { this.handleEncrypt() })
              .borderRadius(24)
              .linearGradient({
                  angle: 135,
                  colors: [[$r('app.color.brand_primary'), 0.0], [$r('app.color.brand_primary_dark'), 1.0]]
              })
              .fontColor($r('app.color.text_white'))
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
              .height(48)
              .margin({ right: 16 })
              .shadow({ radius: 8, color: $r('app.color.shadow_primary'), offsetY: 4 })

             // 解密按钮 (白色胶囊)
             Button('解密还原', { type: ButtonType.Normal, stateEffect: true })
              .onClick(() => { this.handleDecrypt() })
              .borderRadius(24)
              .backgroundColor($r('app.color.card_background')) 
              .fontColor($r('app.color.brand_primary')) 
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
              .height(48)
              .shadow({ radius: 8, color: $r('app.color.shadow_normal'), offsetY: 2 })
          }
          .width('100%')
          .margin({ bottom: 24 })

          // 2.4 结果卡片
          if (this.outputText) {
            Column() {
              SecretBox({
                content: $outputText,
                title: 'RESULT',
                isInput: false,
                // 结果框也有清空和复制
                 onClearClick: () => { this.handleClear() }
              })
              .key(`output_${this.outputKey}`)
              
              // 底部按钮组
              Row({ space: 16 }) {
                // 清空按钮
                Button({ type: ButtonType.Capsule, stateEffect: true }) {
                  Text('清空')
                    .fontSize(16)
                    .fontColor($r('app.color.text_secondary'))
                    .fontWeight(FontWeight.Medium)
                }
                .onClick(() => { this.handleClear() })
                .backgroundColor($r('app.color.card_background'))
                .shadow({ radius: 8, color: $r('app.color.shadow_normal'), offsetY: 2 }) // Capsule 时 border radius 需要很大以匹配
                .layoutWeight(1)
                .height(48)
                  
                // 复制销毁按钮
                Button('复制结果并销毁', { type: ButtonType.Capsule, stateEffect: true }) // 改为 Capsule
                  .onClick(() => { this.handleCopyAndBurn() })
                  .backgroundColor($r('app.color.danger_light_background')) 
                  .fontColor($r('app.color.brand_danger_dark')) 
                  .fontWeight(FontWeight.Bold)
                  .layoutWeight(1)
                  .height(48)
              }
              .width('100%')
              .margin({ top: 16 })
            }
          }
        }
        .width('100%')
        .padding(20)
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]) // 开启沉浸式，延伸至状态栏和导航条
  }
}