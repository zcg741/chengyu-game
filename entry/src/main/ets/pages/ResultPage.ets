// ResultPage.ets - 答题结果页
import { GameViewModel } from '../viewmodel/GameViewModel';
import { replaceTo } from '../utils/NavUtil';

@Entry
@Component
struct ResultPage {
  @State isCorrect: boolean = false;
  @State userAnswer: string = '';
  @State correctAnswer: string = '';
  @State explanation: string = '';
  @State score: number = 0;

  build() {
    Column() {
      // 结果图标
      Text(this.isCorrect ? '🎉' : '😅')
        .fontSize(60)
        .margin({ top: 60, bottom: 20 });

      // 结果文字
      Text(this.isCorrect ? '回答正确！' : '回答错误')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isCorrect ? '#2E7D32' : '#D32F2F')
        .margin({ bottom: 16 });

      // 正确答案展示
      Column() {
        if (!this.isCorrect) {
          Text('正确答案')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 8 });
        }

        Text(this.isCorrect ? '太棒了！' : this.correctAnswer)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isCorrect ? '#2E7D32' : '#333333')
          .margin({ bottom: 12 });

        // 释义
        Text(this.explanation)
          .fontSize(16)
          .fontColor('#555555')
          .textAlign(TextAlign.Center)
          .lineHeight(24)
          .margin({ bottom: 20 });
      }
      .width('85%')
      .padding(20)
      .backgroundColor(Color.White)
      .borderRadius(16)
      .shadow({ radius: 8, color: '#0000001A', offsetX: 0, offsetY: 4 })
      .margin({ bottom: 40 });

      // 得分变化
      if (this.isCorrect) {
        Text('+10 分')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF6B35')
          .margin({ bottom: 8 });
      } else {
        Text('继续加油！')
          .fontSize(20)
          .fontColor('#666666')
          .margin({ bottom: 8 });
      }

      Text(`当前得分: ${this.score}`)
        .fontSize(16)
        .fontColor('#555555')
        .margin({ bottom: 40 });

      // 按钮
      Button('继续答题')
        .width('70%')
        .height(48)
        .backgroundColor('#4ECDC4')
        .fontSize(18)
        .fontColor(Color.White)
        .borderRadius(24)
        .onClick(() => {
          replaceTo('pages/GamePage');
        });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
