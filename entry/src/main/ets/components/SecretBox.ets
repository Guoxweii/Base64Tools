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
  private revealDuration: number = 2000;

  @Prop title: string;
  @Prop isInput: boolean = false;
  @Prop placeholder: string = '在此输入...';
  @Prop contentHeight: number = 156;

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
    if (this.isInput) {
      if (!this.isBlurred) {
        this.clearTimers();
        this.isBlurred = true;
        this.timeLeft = 0;
        return;
      }
      this.clearTimers();
      this.isBlurred = false;
      this.timeLeft = 100;
      let step = 100 / (this.revealDuration / 30);
      this.intervalId = setInterval(() => {
        this.timeLeft -= step;
        if (this.timeLeft <= 0) {
          this.timeLeft = 0;
          clearInterval(this.intervalId);
          this.intervalId = -1;
        }
      }, 30);
      this.timerId = setTimeout(() => {
        this.isBlurred = true;
        this.timeLeft = 0;
        this.timerId = -1;
      }, this.revealDuration);
      return;
    }
    if (!this.content || this.isLocked) {
      return;
    }
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
    animateTo({ duration: 220, curve: Curve.FastOutSlowIn }, () => {
      this.isBlurred = true;
      this.timeLeft = 0;
    });
    if (this.viewCount >= this.maxViews) {
      this.isLocked = true;
    }
  }

  @Builder IconReveal(color: ResourceColor) {
    Image($r('app.media.ic_eye_open'))
      .width(22)
      .height(22)
      .fillColor(color)
  }

  @Builder IconHide(color: ResourceColor) {
    Image($r('app.media.ic_eye_close'))
      .width(22)
      .height(22)
      .fillColor(color)
  }

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

  @Builder IconScan(color: ResourceColor) {
    Image($r('app.media.ic_scan'))
      .width(16)
      .height(16)
      .fillColor(color)
      .objectFit(ImageFit.Contain)
  }

  @Builder IconTrash(color: ResourceColor) {
    Column({ space: 1 }) {
      Rect()
        .width(5)
        .height(1.2)
        .fill(color)
        .borderRadius(1)

      Rect()
        .width(12)
        .height(1.2)
        .fill(color)
        .borderRadius(1)

      Stack({ alignContent: Alignment.Center }) {
        Rect()
          .width(10)
          .height(9)
          .fillOpacity(0)
          .stroke(color)
          .strokeWidth(1.2)
          .radius(2)

        Row({ space: 2 }) {
          Rect().width(1).height(5).fill(color).borderRadius(1)
          Rect().width(1).height(5).fill(color).borderRadius(1)
        }
      }
      .width(10)
      .height(9)
    }
    .width(16)
    .height(16)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Column() {
      Row() {
        Text(this.title)
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .fontWeight(FontWeight.Medium)

        Blank()

        if (this.onClearClick && this.isInput) {
          Button({ type: ButtonType.Normal }) {
            this.IconTrash($r('app.color.text_tertiary'))
          }
          .width(36)
          .height(36)
          .borderRadius(10)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            if (this.onClearClick) {
              this.onClearClick();
            }
          })
        }
      }
      .width('100%')
      .height(40)
      .padding({ left: 16, right: 10 })

      Stack({ alignContent: Alignment.TopStart }) {
        if (this.isInput) {
          TextInput({
            text: this.content,
            placeholder: this.placeholder
          })
            .type(this.isBlurred ? InputType.Password : InputType.Normal)
            .showPasswordIcon(false)
            .cancelButton({ style: CancelButtonStyle.INPUT })
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
        } else if (!this.content) {
          Column({ space: 10 }) {
            Text('转换后结果会显示在这里')
              .fontSize(13)
              .fontColor($r('app.color.text_tertiary'))
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
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

        if (this.isBlurred && !this.isInput && !!this.content) {
          Stack() {
            Rect()
              .width('100%')
              .height('100%')
              .fill($r('app.color.blur_background'))

            Column({ space: 10 }) {
              Text('••••••••••••')
                .fontSize(22)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.isLocked ? $r('app.color.brand_danger') : $r('app.color.text_primary'))
              Text(this.isLocked ? '查看次数已耗尽' : '点击查看隐藏内容')
                .fontSize(14)
                .fontColor(this.isLocked ? $r('app.color.brand_danger') : $r('app.color.text_secondary'))
                .fontWeight(this.isLocked ? FontWeight.Medium : FontWeight.Regular)
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
      .height(this.contentHeight)
      .animation({ duration: 220, curve: Curve.FastOutSlowIn })

      if (this.timeLeft > 0 && !this.isBlurred) {
        Progress({ value: this.timeLeft, total: 100, type: ProgressType.Linear })
          .width('100%')
          .height(3)
          .color($r('app.color.brand_primary'))
          .backgroundColor($r('app.color.divider_color'))
      } else {
        Divider()
          .color($r('app.color.divider_color'))
          .width('100%')
          .strokeWidth(1)
      }

      Row() {
        if (this.isLocked) {
          Text('不可访问')
            .fontSize(12)
            .fontColor($r('app.color.brand_danger'))
        } else if (this.content && !this.isInput) {
          Row({ space: 8 }) {
            Text('剩余查看')
              .fontSize(12)
              .fontColor($r('app.color.text_tertiary'))
            Row({ space: 6 }) {
              ForEach([1, 2, 3], (index: number) => {
                Circle()
                  .width(6)
                  .height(6)
                  .fill(index > this.viewCount ? $r('app.color.brand_primary') : $r('app.color.text_tertiary'))
              })
            }
          }
        } else {
          Text(this.isInput ? '输入区' : '等待输出')
            .fontSize(12)
            .fontColor($r('app.color.text_tertiary'))
        }

        Blank()

        Row({ space: 4 }) {
          if (this.isInput && this.onScanClick) {
            Button({ type: ButtonType.Normal }) {
              this.IconScan($r('app.color.text_tertiary'))
            }
            .width(42)
            .height(42)
            .backgroundColor(Color.Transparent)
            .borderRadius(8)
            .onClick(() => {
              if (this.onScanClick) {
                this.onScanClick();
              }
            })
          }

          if (this.isInput || !!this.content) {
            Button({ type: ButtonType.Normal }) {
              if (this.isBlurred) {
                this.IconReveal($r('app.color.brand_primary'))
              } else {
                this.IconHide($r('app.color.text_secondary'))
              }
            }
            .width(42)
            .height(42)
            .backgroundColor(Color.Transparent)
            .borderRadius(8)
            .enabled(this.isInput ? true : (!!this.content && !this.isLocked))
            .opacity(this.isInput ? 1 : ((!!this.content && !this.isLocked) ? 1 : 0.35))
            .onClick(() => {
              this.startReveal();
            })
          }
        }
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height(44)
      .padding({ left: 16, right: 8 })
      .backgroundColor($r('app.color.tool_bar_background'))
      .borderRadius({ bottomLeft: 18, bottomRight: 18 })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(18)
    .shadow({ radius: 18, color: $r('app.color.shadow_normal'), offsetY: 6 })
    .clip(true)
  }
}
