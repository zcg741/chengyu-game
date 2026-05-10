// ChengyuCard.ets - 成语卡片组件
@Component
export struct ChengyuCard {
  @Prop chengyu: string = '';
  @Prop pinyin: string = '';
  @Prop explanation: string = '';
  @Prop showAnswer: boolean = false;
  
  build() {
    Column() {
      // 成语文字
      if (this.showAnswer) {
        Text(this.chengyu)
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 8 });
        
        Text(this.pinyin)
          .fontSize(16)
          .fontColor('#666666')
          .margin({ bottom: 16 });
      }
      
      // 释义
      Text(this.explanation)
        .fontSize(18)
        .fontColor('#555555')
        .textAlign(TextAlign.Center)
        .lineHeight(26)
        .margin({ top: this.showAnswer ? 0 : 12 });
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: '#0000001A', offsetX: 0, offsetY: 4 })
    .alignItems(HorizontalAlign.Center);
  }
}
