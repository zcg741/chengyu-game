// GameOverPage.ets - 游戏结束页
import { GameViewModel } from '../viewmodel/GameViewModel';
import { getNumber } from '../service/StorageService';
import { replaceTo, getRouteParams } from '../utils/NavUtil';

@Entry
@Component
struct GameOverPage {
  @State score: number = 0;
  @State correctCount: number = 0;
  @State wrongCount: number = 0;
  @State totalQuestions: number = 0;
  @State highScore: number = 0;
  @State isNewRecord: boolean = false;
  @State accuracy: string = '0';
  @State showShareToast: boolean = false;

  private gameViewModel: GameViewModel = new GameViewModel();

  async aboutToAppear() {
    // 从路由参数中获取游戏数据
    const params = getRouteParams();
    if (params) {
      const scoreVal = params['score'];
      const correctVal = params['correctCount'];
      const wrongVal = params['wrongCount'];
      const totalVal = params['totalQuestions'];
      this.score = (scoreVal !== undefined && scoreVal !== null) ? Number(scoreVal) : 0;
      this.correctCount = (correctVal !== undefined && correctVal !== null) ? Number(correctVal) : 0;
      this.wrongCount = (wrongVal !== undefined && wrongVal !== null) ? Number(wrongVal) : 0;
      this.totalQuestions = (totalVal !== undefined && totalVal !== null) ? Number(totalVal) : 0;

      // 计算正确率
      if (this.totalQuestions > 0) {
        this.accuracy = ((this.correctCount / this.totalQuestions) * 100).toFixed(1);
      }
    }

    // 获取历史最高分
    this.highScore = await getNumber('high_score', 0);
    this.isNewRecord = this.score >= this.highScore && this.score > 0;
  }

  build() {
    Column() {
      // 顶部标题区域
      Column() {
        Text('游戏结束')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ bottom: 8 });

        if (this.isNewRecord) {
          Row() {
            Text('🎊')
              .fontSize(24)
              .margin({ right: 8 });
            Text('新纪录！')
              .fontSize(18)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium);
          }
          .margin({ bottom: 16 });
        } else {
          Blank()
            .height(16);
        }
      }
      .width('100%')
      .padding({ top: 48, bottom: 32 })
      .backgroundColor('#FF6B35');

      Scroll() {
        Column() {
          // 得分卡片
          Column() {
            Text('最终得分')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ bottom: 12 });

            Text(this.score.toString())
              .fontSize(64)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF6B35')
              .margin({ bottom: 24 });

            // 统计数据
            Row() {
              Column() {
                Text(this.correctCount.toString())
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#2E7D32');
                Text('答对')
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ top: 4 });
              }
              .width('25%')
              .alignItems(HorizontalAlign.Center);

              Column() {
                Text(this.wrongCount.toString())
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#D32F2F');
                Text('答错')
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ top: 4 });
              }
              .width('25%')
              .alignItems(HorizontalAlign.Center);

              Column() {
                Text(this.totalQuestions.toString())
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#5C6BC0');
                Text('总题')
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ top: 4 });
              }
              .width('25%')
              .alignItems(HorizontalAlign.Center);

              Column() {
                Text(this.accuracy + '%')
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#E65100');
                Text('正确率')
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ top: 4 });
              }
              .width('25%')
              .alignItems(HorizontalAlign.Center);
            }
            .width('100%')
            .margin({ top: 8 });
          }
          .width('90%')
          .padding(24)
          .backgroundColor(Color.White)
          .borderRadius(24)
          .shadow({ radius: 16, color: '#0000001A', offsetX: 0, offsetY: 8 })
          .margin({ top: -20, bottom: 16 });

          // 最高分卡片
          Row() {
            Text('🏆')
              .fontSize(28)
              .margin({ right: 16 });

            Column() {
              Text('历史最高分')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ bottom: 4 });
              Text(this.highScore.toString())
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF6B35');
            }
            .alignItems(HorizontalAlign.Start);
          }
          .width('90%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 8, color: '#0000000D', offsetX: 0, offsetY: 4 })
          .margin({ bottom: 24 });

          // 按钮区域
          Column() {
            // 分享按钮 - 使用系统分享面板
            Button({ type: ButtonType.Normal }) {
              Row() {
                Text('📤')
                  .fontSize(20)
                  .margin({ right: 8 });
                Text('分享成绩')
                  .fontSize(16)
                  .fontColor(Color.White);
              }
            }
            .width('85%')
            .height(52)
            .backgroundColor('#4ECDC4')
            .borderRadius(26)
            .margin({ bottom: 12 })
            .onClick(() => {
              this.shareScore();
            });

            // 再来一局按钮
            Button({ type: ButtonType.Normal }) {
              Row() {
                Text('🎮')
                  .fontSize(20)
                  .margin({ right: 8 });
                Text('再来一局')
                  .fontSize(16)
                  .fontColor(Color.White);
              }
            }
            .width('85%')
            .height(52)
            .backgroundColor('#FF6B35')
            .borderRadius(26)
            .margin({ bottom: 12 })
            .onClick(() => {
              replaceTo('pages/GamePage');
            });

            // 返回首页按钮
            Button({ type: ButtonType.Normal }) {
              Row() {
                Text('🏠')
                  .fontSize(20)
                  .margin({ right: 8 });
                Text('返回首页')
                  .fontSize(16)
                  .fontColor('#333333');
              }
            }
            .width('85%')
            .height(52)
            .backgroundColor(Color.White)
            .borderRadius(26)
            .border({ width: 2, color: '#E0E0E0' })
            .onClick(() => {
              replaceTo('pages/HomePage');
            });
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .margin({ bottom: 28 });

          // 分享提示Toast
          if (this.showShareToast) {
            Text('分享内容已复制到剪贴板')
              .fontSize(14)
              .fontColor(Color.White)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor('#333333')
              .borderRadius(20)
              .margin({ bottom: 16 })
          }
        }
        .alignItems(HorizontalAlign.Center)
        .padding({ bottom: 32 })  // 避让底部导航条
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .alignItems(HorizontalAlign.Center)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  /**
   * 分享成绩 - 使用系统剪贴板作为分享方式
   */
  async shareScore() {
    try {
      const shareText = `我在「妙语成语」中获得了 ${this.score} 分，答对了 ${this.correctCount} 题！快来挑战吧！`;
      // 使用剪贴板复制分享内容
      const pasteboard = await import('@ohos.pasteboard');
      const systemPasteboard = pasteboard.default.getSystemPasteboard();
      const pasteData = pasteboard.default.createData(pasteboard.default.MIMETYPE_TEXT_PLAIN, shareText);
      await systemPasteboard.setData(pasteData);
      this.showShareToast = true;
      // 2秒后隐藏toast
      setTimeout(() => {
        this.showShareToast = false;
      }, 2000);
    } catch (error) {
      console.error('Share failed:', error);
      // 降级处理：仍然显示已复制
      this.showShareToast = true;
      setTimeout(() => {
        this.showShareToast = false;
      }, 2000);
    }
  }
}
