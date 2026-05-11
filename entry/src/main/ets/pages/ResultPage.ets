// ResultPage.ets - 答题结果页
import { GameViewModel } from '../viewmodel/GameViewModel';
import { replaceTo } from '../utils/NavUtil';
import { getCurrentTheme } from '../service/ThemeService';
import { Theme } from '../model/ThemeModel';

@Entry
@Component
struct ResultPage {
  @State isCorrect: boolean = false;
  @State userAnswer: string = '';
  @State correctAnswer: string = '';
  @State explanation: string = '';
  @State score: number = 0;

  // 主题颜色状态
  @State brandColor: string = '#FF6B35';
  @State bgPage: string = '#F5F5F5';
  @State bgCard: string = '#FFFFFF';
  @State textPrimary: string = '#333333';
  @State textSecondary: string = '#666666';

  aboutToAppear() {
    // 加载主题
    const theme = getCurrentTheme();
    this.brandColor = theme.brand;
    this.bgPage = theme.bgPage;
    this.bgCard = theme.bgCard;
    this.textPrimary = theme.textPrimary;
    this.textSecondary = theme.textSecondary;
  }

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
            .fontColor(this.textSecondary)
            .margin({ bottom: 8 });
        }

        Text(this.isCorrect ? '太棒了！' : this.correctAnswer)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isCorrect ? '#2E7D32' : this.textPrimary)
          .margin({ bottom: 12 });

        // 释义
        Text(this.explanation)
          .fontSize(16)
          .fontColor(this.textSecondary)
          .textAlign(TextAlign.Center)
          .lineHeight(24)
          .margin({ bottom: 20 });
      }
      .width('85%')
      .padding(20)
      .backgroundColor(this.bgCard)
      .borderRadius(16)
      .shadow({ radius: 8, color: '#0000001A', offsetX: 0, offsetY: 4 })
      .margin({ bottom: 40 });

      // 得分变化
      if (this.isCorrect) {
        Text('+10 分')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.brandColor)
          .margin({ bottom: 8 });
      } else {
        Text('继续加油！')
          .fontSize(20)
          .fontColor(this.textSecondary)
          .margin({ bottom: 8 });
      }

      Text(`当前得分: ${this.score}`)
        .fontSize(16)
        .fontColor(this.textSecondary)
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
    .backgroundColor(this.bgPage)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
