@Entry
@Component
struct StaticServiceCard {
  build() {
    Stack() {
      Image($r('app.media.desk_icon'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover) // 使用 Cover 保证填满
    }
    .width('100%')
    .height('100%')
    .padding(0) // 强制去边距
    .margin(0)
    .backgroundColor($r('app.color.brand_primary')) // 设为图标主色，兜底防止白边
    .onClick(() => {
      postCardAction(this, {
        "action": "router",
        "abilityName": "EntryAbility",
        "params": {
          "targetPage": "index"
        }
      });
    })
  }
}
