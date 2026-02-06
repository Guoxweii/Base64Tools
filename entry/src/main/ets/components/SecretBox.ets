import { curves } from '@kit.ArkUI';

@Component
export struct SecretBox {
  @Link @Watch('onContentChange') content: string;
  @State isBlurred: boolean = true;
  @State viewCount: number = 0;
  @State isLocked: boolean = false;
  @State timeLeft: number = 0;
  
  private timerId: number = -1;
  private intervalId: number = -1;
  private maxViews: number = 3;
  private revealDuration: number = 3000;

  @Prop title: string;
  @Prop isInput: boolean = false; 
  @Prop placeholder: string = '在此输入...';

  // 回调
  onCameraClick?: () => void;
  onScanClick?: () => void;
  onClearClick?: () => void;

  onContentChange() {
    this.viewCount = 0;
    this.isLocked = false;
    if (!this.isInput) {
      this.isBlurred = true;
      this.clearTimers();
      this.timeLeft = 0;
    }
  }

  aboutToAppear() {
    this.isBlurred = true;
  }

  aboutToDisappear() {
    this.clearTimers();
  }

  clearTimers() {
    if (this.timerId !== -1) {
      clearTimeout(this.timerId);
      this.timerId = -1;
    }
    if (this.intervalId !== -1) {
      clearInterval(this.intervalId);
      this.intervalId = -1;
    }
  }

  startReveal() {
    if (this.isLocked) return;
    if (!this.isBlurred) {
      this.hideContent();
      return;
    }
    if (this.viewCount >= this.maxViews) {
      this.isLocked = true;
      return;
    }

    this.isBlurred = false; 
    this.viewCount++;
    this.timeLeft = 100; 

    this.clearTimers();
    let step = 100 / (this.revealDuration / 30); 
    this.intervalId = setInterval(() => {
      this.timeLeft -= step;
      if (this.timeLeft <= 0) {
        this.timeLeft = 0;
        clearInterval(this.intervalId);
      }
    }, 30);

    this.timerId = setTimeout(() => {
      this.hideContent();
    }, this.revealDuration);
  }

  hideContent() {
    this.clearTimers();
    animateTo({ duration: 300, curve: Curve.FastOutSlowIn }, () => {
      this.isBlurred = true; 
      this.timeLeft = 0;
    });
    if (this.viewCount >= this.maxViews) {
      this.isLocked = true;
    }
  }

  // === 极简几何图标 ===
  
  // 1. 查看图标 (Eye)
  @Builder IconReveal(color: ResourceColor) {
    Image($r('app.media.ic_eye_open'))
      .width(24)
      .height(24)
      .fillColor(color)
  }

  // 2. 隐藏图标 (Eye Off)
  @Builder IconHide(color: ResourceColor) {
    Image($r('app.media.ic_eye_close'))
      .width(24)
      .height(24)
      .fillColor(color)
  }

  // 3. 锁定图标 (Lock)
  @Builder IconLock(color: ResourceColor) {
    Stack({ alignContent: Alignment.Bottom }) {
      Circle()
        .width(14)
        .height(14)
        .fillOpacity(0)
        .stroke(color)
        .strokeWidth(2)
        .margin({ bottom: 10 })
      
      Rect()
        .width(16)
        .height(11)
        .fill(color)
        .radius(2)
    }
    .width(24)
    .height(24)
    .alignContent(Alignment.Bottom)
  }

  // 4. 扫描图标 (Scan) - SVG 资源版
  @Builder IconScan(color: ResourceColor) {
    Image($r('app.media.ic_scan'))
      .width(24)
      .height(24)
      .fillColor(color) // 使用 fillColor 对 SVG 进行着色
      .objectFit(ImageFit.Contain)
  }

  // 5. 垃圾桶图标 (Trash) - SVG 资源版
  @Builder IconTrash(color: ResourceColor) {
    Image($r('app.media.ic_trash'))
      .width(24)
      .height(24)
      .fillColor(color) // 使用 fillColor 对 SVG 进行着色
      .objectFit(ImageFit.Contain)
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        if (this.isInput) {
            TextInput({ 
               text: this.content, 
               placeholder: this.placeholder 
            })
              .type(this.isBlurred ? InputType.Password : InputType.Normal)
              .showPasswordIcon(false) 
              .cancelButton({ style: CancelButtonStyle.INPUT }) // 添加自带的清除按钮
              .fontSize(16)
              .fontColor($r('app.color.text_content'))
              .placeholderColor($r('app.color.text_placeholder'))
              .caretColor($r('app.color.brand_primary'))
              .backgroundColor(Color.Transparent)
              .width('100%')
              .height('100%') 
              .padding({ left: 16, right: 16 })
              .onChange((value: string) => {
                this.content = value;
              })
        } else {
          Scroll() {
            Text(this.content)
              .fontSize(16)
              .fontColor($r('app.color.text_content'))
              .lineHeight(24)
              .width('100%')
              .padding(16)
              .visibility(this.isBlurred ? Visibility.Hidden : Visibility.Visible)
          }
          .width('100%')
          .height('100%') 
          .align(Alignment.TopStart)
        }

        if (this.isBlurred && !this.isInput) {
          Stack() {
            Rect()
              .width('100%')
              .height('100%')
              .fill($r('app.color.blur_background')) 
              .backdropBlur(0) 
            
            Column({ space: 12 }) {
              if (this.isLocked) {
                 this.IconLock($r('app.color.brand_danger'))
              } else {
                 this.IconLock($r('app.color.brand_primary')) 
              }
              
              if (this.isLocked) {
                 Text('内容已销毁')
                  .fontSize(14)
                  .fontColor($r('app.color.brand_danger'))
                  .fontWeight(FontWeight.Medium)
              } else {
                 Text('点击查看隐藏内容')
                  .fontSize(14)
                  .fontColor($r('app.color.text_secondary'))
              }
            }
          }
          .width('100%')
          .height('100%') 
          .onClick(() => {
            this.startReveal();
          })
        }
      }
      .width('100%')
      .height(140) 
      .animation({ duration: 300, curve: Curve.FastOutSlowIn })

      // === 进度条 ===
      if (this.timeLeft > 0 && !this.isBlurred) {
        Progress({ value: this.timeLeft, total: 100, type: ProgressType.Linear })
          .width('100%')
          .height(2)
          .color($r('app.color.brand_primary')) 
          .backgroundColor($r('app.color.divider_color'))
      } else {
        Divider()
          .color($r('app.color.divider_color'))
          .width('100%')
          .strokeWidth(1)
      }

      // === 底部工具栏 ===
      Row() {
        if (this.isLocked) {
           Text('无法访问')
             .fontSize(12)
             .fontColor($r('app.color.brand_danger'))
        } else {
           Row({ space: 6 }) { 
             ForEach([1, 2, 3], (index: number) => {
               Circle()
                 .width(6)
                 .height(6)
                 // 优化：未激活状态颜色加深到 #C7C7CC
                 .fill(index > this.viewCount ? $r('app.color.brand_primary') : $r('app.color.text_tertiary')) 
             })
           }
        }

        Blank()

        Row({ space: 0 }) {
          if (this.isInput && !this.isLocked && this.onScanClick) {
             Button({ type: ButtonType.Normal }) {
               this.IconScan($r('app.color.text_secondary'))
             }
             .width(44).height(44).backgroundColor('transparent').borderRadius(8)
             .onClick(() => { if(this.onScanClick) this.onScanClick() })
          }
          
          // 移除垃圾桶图标
          
          Button({ type: ButtonType.Normal }) {
            if (this.isBlurred) {
              this.IconReveal($r('app.color.brand_primary'))
            } else {
              this.IconHide($r('app.color.text_secondary'))
            }
          }
          .width(44)
          .height(44)
          .backgroundColor('transparent')
          .borderRadius(8)
          .onClick(() => {
             this.startReveal();
          })
        }
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 8 })
      .backgroundColor($r('app.color.tool_bar_background')) 
      .borderRadius({ bottomLeft: 16, bottomRight: 16 }) 
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background')) 
    .borderRadius(16)
    .shadow({ radius: 10, color: $r('app.color.shadow_normal'), offsetY: 2 })
    .clip(true) 
  }
}
