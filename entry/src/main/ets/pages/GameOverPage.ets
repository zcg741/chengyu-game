// GameOverPage.ets - 游戏结束页
import { GameViewModel } from '../viewmodel/GameViewModel';
import { getNumber } from '../service/StorageService';
import { replaceTo, navigateToWithParams, getRouteParams } from '../utils/NavUtil';
import { getCurrentTheme, setTheme } from '../service/ThemeService';
import { Theme, THEMES } from '../model/ThemeModel';
import { shareScore as copyScoreShare } from '../service/ShareService';
import { getWrongBookStats } from '../service/WrongBookService';

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
  @State shareToastText: string = '分享内容已复制到剪贴板';
  @State recordsJson: string = '';
  @State pendingWrongCount: number = 0;

  // 使用 @StorageLink 监听主题变化（全局同步）
  @StorageLink('current_theme_id') @Watch('onThemeIdChange') themeId: string = 'classic';

  // 主题颜色状态
  @State brandColor: string = '#FF6B35';
  @State bgPage: string = '#F5F5F5';
  @State bgCard: string = '#FFFFFF';
  @State borderColr: string = '#E0E0E0';
  @State textPrimary: string = '#333333';
  @State textSecondary: string = '#666666';

  private gameViewModel: GameViewModel = new GameViewModel();

  // 根据 themeId 获取主题对象（避免索引访问）
  getThemeByID(themeId: string): Theme {
    if (themeId === 'classic') return THEMES.classic;
    if (themeId === 'green') return THEMES.green;
    if (themeId === 'blue') return THEMES.blue;
    if (themeId === 'dark') return THEMES.dark;
    return THEMES.classic;
  }

  applyTheme() {
    const theme = this.getThemeByID(this.themeId);
    this.brandColor = theme.brand;
    this.bgPage = theme.bgPage;
    this.bgCard = theme.bgCard;
    this.borderColr = theme.border;
    this.textPrimary = theme.textPrimary;
    this.textSecondary = theme.textSecondary;
  }

  onThemeIdChange() {
    this.applyTheme();
  }

  async aboutToAppear() {
    this.applyTheme();

    // 从路由参数中获取游戏数据
    const params = getRouteParams();
    if (params) {
      const scoreVal = params['score'];
      const correctVal = params['correctCount'];
      const wrongVal = params['wrongCount'];
      const totalVal = params['totalQuestions'];
      const recordsVal = params['records'];
      this.score = (scoreVal !== undefined && scoreVal !== null) ? Number(scoreVal) : 0;
      this.correctCount = (correctVal !== undefined && correctVal !== null) ? Number(correctVal) : 0;
      this.wrongCount = (wrongVal !== undefined && wrongVal !== null) ? Number(wrongVal) : 0;
      this.totalQuestions = (totalVal !== undefined && totalVal !== null) ? Number(totalVal) : 0;
      if (recordsVal) {
        this.recordsJson = String(recordsVal);
      }

      // 计算正确率
      if (this.totalQuestions > 0) {
        this.accuracy = ((this.correctCount / this.totalQuestions) * 100).toFixed(1);
      }
    }

    // 获取历史最高分
    this.highScore = await getNumber('high_score', 0);
    this.isNewRecord = this.score >= this.highScore && this.score > 0;

    const wrongStats = await getWrongBookStats();
    this.pendingWrongCount = wrongStats.pending;
  }

  build() {
    Column() {
      // 顶部标题区域
      Column() {
        Text('本局结算')
          .fontSize(26)
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
      .backgroundColor(this.brandColor);

      Scroll() {
        Column() {
          // 得分卡片
          Column() {
            Text('最终得分')
              .fontSize(14)
              .fontColor(this.textSecondary)
              .margin({ bottom: 12 });

            Text(this.score.toString())
              .fontSize(64)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.brandColor)
              .margin({ bottom: 24 });

            // 统计数据
            Row() {
              Column() {
                Text(this.correctCount.toString())
                  .fontSize(24)
                  .maxLines(1)
                  .textAlign(TextAlign.Center)
                  .width('100%')
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#2E7D32');
                Text('答对')
                  .fontSize(12)
                  .fontColor(this.textSecondary)
                  .margin({ top: 4 });
              }
              .width('25%')
              .alignItems(HorizontalAlign.Center);

              Column() {
                Text(this.wrongCount.toString())
                  .fontSize(24)
                  .maxLines(1)
                  .textAlign(TextAlign.Center)
                  .width('100%')
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#D32F2F');
                Text('答错')
                  .fontSize(12)
                  .fontColor(this.textSecondary)
                  .margin({ top: 4 });
              }
              .width('25%')
              .alignItems(HorizontalAlign.Center);

              Column() {
                Text(this.totalQuestions.toString())
                  .fontSize(24)
                  .maxLines(1)
                  .textAlign(TextAlign.Center)
                  .width('100%')
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#5C6BC0');
                Text('总题')
                  .fontSize(12)
                  .fontColor(this.textSecondary)
                  .margin({ top: 4 });
              }
              .width('25%')
              .alignItems(HorizontalAlign.Center);

              Column() {
                Text(this.accuracy + '%')
                  .fontSize(20)
                  .maxLines(1)
                  .textAlign(TextAlign.Center)
                  .width('100%')
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#E65100');
                Text('正确率')
                  .fontSize(12)
                  .fontColor(this.textSecondary)
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
          .backgroundColor(this.bgCard)
          .borderRadius(14)
          .border({ width: 1, color: this.borderColr })
          .shadow({ radius: 10, color: '#00000012', offsetX: 0, offsetY: 5 })
          .margin({ top: -20, bottom: 16 });

          // 最高分卡片
          Row() {
            Text('🏆')
              .fontSize(28)
              .margin({ right: 16 });

            Column() {
              Text('历史最高分')
                .fontSize(14)
                .fontColor(this.textSecondary)
                .margin({ bottom: 4 });
              Text(this.highScore.toString())
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.brandColor);
            }
            .alignItems(HorizontalAlign.Start);
          }
          .width('90%')
          .padding(18)
          .backgroundColor(this.bgCard)
          .borderRadius(12)
          .border({ width: 1, color: this.borderColr })
          .margin({ bottom: 16 });

          // 复盘建议
          if (this.wrongCount > 0 || this.pendingWrongCount > 0) {
            Column() {
              Row() {
                Text('📌')
                  .fontSize(24)
                  .margin({ right: 10 });
                Column() {
                  Text(this.wrongCount > 0 ? `本局 ${this.wrongCount} 个错题已加入错题本` : '错题本仍有待复习内容')
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.textPrimary);
                  Text(this.pendingWrongCount > 0 ? `当前待复习 ${this.pendingWrongCount} 个，连续答对 3 次后标记掌握` : '这局没有遗留错题')
                    .fontSize(12)
                    .fontColor(this.textSecondary)
                    .margin({ top: 4 });
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1);
              }
              .width('100%')
              .margin({ bottom: 14 });

              Button('复习错题')
                .width('100%')
                .height(44)
                .fontColor(Color.White)
                .backgroundColor('#E85D26')
                .borderRadius(22)
                .onClick(() => {
                  this.goToWrongReview();
                });
            }
            .width('90%')
            .padding(18)
            .backgroundColor(this.bgCard)
            .border({ width: 1, color: this.brandColor })
            .borderRadius(12)
            .margin({ bottom: 18 });
          }

          // 按钮区域
          Column() {
            Text('下一步')
              .fontSize(13)
              .fontColor(this.textSecondary)
              .width('85%')
              .textAlign(TextAlign.Start)
              .margin({ bottom: 10 })

            // 分享按钮 - 使用系统分享面板
            Button({ type: ButtonType.Normal }) {
              Row() {
                Text('📤')
                  .fontSize(20)
                  .margin({ right: 8 });
                Text('分享成绩')
                  .fontSize(16)
                  .fontColor(this.pendingWrongCount > 0 ? this.textPrimary : '#FFFFFF');
              }
            }
            .width('85%')
            .height(52)
            .backgroundColor(this.pendingWrongCount > 0 ? this.bgCard : '#4ECDC4')
            .border({ width: this.pendingWrongCount > 0 ? 1 : 0, color: this.borderColr })
            .borderRadius(26)
            .margin({ bottom: 12 })
            .onClick(() => {
              this.shareScore();
            });

            // 回顾题目按钮
            Button({ type: ButtonType.Normal }) {
              Row() {
                Text('📝')
                  .fontSize(20)
                  .margin({ right: 8 });
                Text('回顾题目')
                  .fontSize(16)
                  .fontColor(Color.White);
              }
            }
            .width('85%')
            .height(52)
            .backgroundColor('#7C4DFF')
            .borderRadius(26)
            .margin({ bottom: 12 })
            .onClick(() => {
              this.goToReview();
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
            .backgroundColor(this.brandColor)
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
                  .fontColor(this.textPrimary);
              }
            }
            .width('85%')
            .height(52)
            .backgroundColor(this.bgCard)
            .borderRadius(26)
            .border({ width: 2, color: this.borderColr })
            .onClick(() => {
              replaceTo('pages/HomePage');
            });
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .margin({ bottom: 28 });

          // 分享提示Toast
          if (this.showShareToast) {
            Text(this.shareToastText)
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
    .backgroundColor(this.bgPage)
    .alignItems(HorizontalAlign.Center)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  /**
   * 跳转到回顾页面
   */
  goToReview() {
    try {
      const paramsMap: Record<string, Object> = {};
      paramsMap['records'] = this.recordsJson;
      paramsMap['from'] = 'gameover';
      navigateToWithParams('pages/ReviewPage', paramsMap);
    } catch (error) {
      console.error('Failed to navigate to review:', error);
    }
  }

  goToWrongReview() {
    try {
      const paramsMap: Record<string, Object> = {};
      paramsMap['mode'] = 'wrongbook';
      paramsMap['from'] = 'gameover';
      navigateToWithParams('pages/ReviewPage', paramsMap);
    } catch (error) {
      console.error('Failed to navigate to wrong review:', error);
    }
  }

  /**
   * 分享成绩 - 使用系统剪贴板作为分享方式
   */
  async shareScore() {
    const ok = await copyScoreShare(this.score, this.correctCount, this.totalQuestions, this.accuracy);
    this.shareToastText = ok ? '已打开分享或复制到剪贴板' : '分享失败，请稍后重试';
    this.showShareToast = true;
    setTimeout(() => {
      this.showShareToast = false;
    }, 2000);
  }
}
