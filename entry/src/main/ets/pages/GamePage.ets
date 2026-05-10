// GamePage.ets - 游戏主界面
import { GAME_MODE, GAME_CONFIG } from '../utils/Constants';
import { GameViewModel } from '../viewmodel/GameViewModel';
import { TimerViewModel, TimerCallback, TimerFinishCallback } from '../viewmodel/TimerViewModel';
import { HintLevel } from '../model/GameState';
import { replaceTo, replaceToWithParams } from '../utils/NavUtil';
import { playSound, stopSound } from '../service/SoundService';

@Entry
@Component
struct GamePage {
  @State currentChengyu: string = '';
  @State currentExplanation: string = '';
  @State currentSource: string = '';
  @State hintText: string = '';
  @State userAnswer: string = '';
  @State score: number = 0;
  @State correctCount: number = 0;
  @State remainingTime: number = GAME_CONFIG.TIMER_MODE_DURATION;
  @State hintLevel: number = HintLevel.NONE;
  @State isAnswered: boolean = false;
  @State isCorrect: boolean = false;
  @State showResult: boolean = false;
  @State gameMode: string = GAME_MODE.TIMER;

  private gameViewModel: GameViewModel = new GameViewModel();
  private timerViewModel: TimerViewModel = new TimerViewModel();

  async aboutToAppear() {
    // 初始化游戏（默认计时模式）
    await this.gameViewModel.initGame(GAME_MODE.TIMER);
    this.gameMode = GAME_MODE.TIMER;
    this.loadQuestion();
    this.startTimer();
  }

  startTimer() {
    this.timerViewModel.setCallbacks(
      (remaining) => {
        this.remainingTime = remaining;
      },
      () => {
        this.gameViewModel.endGame();
        this.navigateToGameOver();
      }
    );
    this.timerViewModel.start(GAME_CONFIG.TIMER_MODE_DURATION);
  }

  navigateToGameOver() {
    const score = this.gameViewModel.getScore();
    const correctCount = this.gameViewModel.getCorrectCount();
    const wrongCount = this.gameViewModel.getWrongCount();
    const totalQuestions = this.gameViewModel.getTotalQuestions();

    try {
      const paramsMap: Record<string, Object> = {};
      paramsMap['score'] = score;
      paramsMap['correctCount'] = correctCount;
      paramsMap['wrongCount'] = wrongCount;
      paramsMap['totalQuestions'] = totalQuestions;
      replaceToWithParams('pages/GameOverPage', paramsMap);
    } catch (error) {
      console.error('Failed to navigate:', error);
    }
  }

  loadQuestion() {
    const question = this.gameViewModel.getCurrentQuestion();
    if (question) {
      this.currentExplanation = question.currentExplanation;
      this.hintLevel = question.hintLevel;
      this.isAnswered = false;
      this.isCorrect = false;
      this.userAnswer = '';
      this.showResult = false;
      this.updateHintText();
    }
  }

  updateHintText() {
    // 统一使用 ViewModel 的 getCurrentHintText() 获取提示文本
    this.hintText = this.gameViewModel.getCurrentHintText();
  }

  onAnswerSubmit() {
    if (!this.userAnswer.trim() || this.isAnswered) {
      return;
    }

    const correct = this.gameViewModel.submitAnswer(this.userAnswer);
    this.isCorrect = correct;
    this.isAnswered = correct;  // 只有答对才标记为已完成
    this.showResult = true;
    this.score = this.gameViewModel.getScore();
    this.correctCount = this.gameViewModel.getCorrectCount();

    if (correct) {
      playSound('correct');
    } else {
      playSound('wrong');
    }

    const question = this.gameViewModel.getCurrentQuestion();
    if (question) {
      this.hintLevel = question.hintLevel;
      if (!correct) {
        // 答错后清空输入框，直接显示更新后的提示（更多字母揭晓）
        this.userAnswer = '';
        this.updateHintText();
        // 2秒后隐藏结果提示
        setTimeout(() => {
          this.showResult = false;
        }, 2000);
      } else {
        this.updateHintText();
      }
    }
  }

  onGetHint() {
    if (this.isAnswered) {
      return;
    }

    // getHint() 返回提示文本，必须使用该返回值
    const hint = this.gameViewModel.getHint();
    this.hintText = hint;

    const question = this.gameViewModel.getCurrentQuestion();
    if (question) {
      this.hintLevel = question.hintLevel;
    }

    this.score = this.gameViewModel.getScore();
  }

  onNextQuestion() {
    this.gameViewModel.nextQuestion();
    this.loadQuestion();
  }

  aboutToDisappear() {
    this.timerViewModel.destroy();
    stopSound();
  }

  build() {
    Column() {
      // 顶部信息栏
      Row() {
        // 返回按钮
        Button({ type: ButtonType.Normal }) {
          Text('←')
            .fontSize(18)
            .fontColor('#333333');
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.White)
        .borderRadius(20)
        .shadow({ radius: 4, color: '#0000000D', offsetX: 0, offsetY: 2 })
        .onClick(() => {
          this.timerViewModel.destroy();
          replaceTo('pages/HomePage');
        });

        // 分数
        Column() {
          Text('得分')
            .fontSize(11)
            .fontColor('#666666')
            .margin({ bottom: 2 });
          Text(this.score.toString())
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6B35');
        }
        .flexGrow(1)
        .alignItems(HorizontalAlign.Center);

        // 计时器或关卡
        if (this.gameMode === GAME_MODE.TIMER) {
          Column() {
            Text('剩余时间')
              .fontSize(11)
              .fontColor('#666666')
              .margin({ bottom: 2 });
            Row() {
              Text(this.remainingTime <= 10 ? '⚠️' : '⏱️')
                .fontSize(16)
                .margin({ right: 4 });
              Text(`${this.remainingTime}s`)
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.remainingTime <= 10 ? '#D32F2F' : '#333333');
            }
          }
        } else {
          Column() {
            Text('当前关卡')
              .fontSize(11)
              .fontColor('#666666')
              .margin({ bottom: 2 });
            Text(`第${this.gameViewModel.getCurrentLevel()}关`)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#4ECDC4');
          }
        }
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 16 })
      .backgroundColor(Color.White)
      .shadow({ radius: 8, color: '#0000000D', offsetX: 0, offsetY: 4 });

      Scroll() {
        Column() {
          // 成语释义卡片
          Column() {
            Row() {
              Text('📖')
                .fontSize(20)
                .margin({ right: 8 });
              Text('释义')
                .fontSize(14)
                .fontColor('#666666')
                .fontWeight(FontWeight.Medium);
            }
            .margin({ bottom: 12 });

            Text(this.currentExplanation)
              .fontSize(22)
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Center)
              .lineHeight(32)
              .fontColor('#333333');
          }
          .width('90%')
          .padding(24)
          .backgroundColor(Color.White)
          .borderRadius(20)
          .shadow({ radius: 12, color: '#0000001A', offsetX: 0, offsetY: 6 })
          .margin({ top: 24, bottom: 20 });

          // 提示区域
          Column() {
            Row() {
              Text('💡')
                .fontSize(20)
                .margin({ right: 8 });
              Text('提示')
                .fontSize(14)
                .fontColor('#D84315')
                .fontWeight(FontWeight.Medium);
            }
            .margin({ bottom: 12 });

            Text(this.hintText)
              .fontSize(36)
              .fontWeight(FontWeight.Bold)
              .fontColor('#D84315')
              .letterSpacing(8);
          }
          .width('90%')
          .padding(24)
          .backgroundColor('#FFF8F5')
          .borderRadius(20)
          .border({ width: 2, color: '#FFE0D5' })
          .margin({ bottom: 24 });

          // 答案输入
          if (!this.isAnswered) {
            Column() {
              TextInput({ placeholder: '请输入成语', text: this.userAnswer })
                .width('100%')
                .height(52)
                .backgroundColor(Color.White)
                .borderRadius(26)
                .border({ width: 2, color: '#E0E0E0' })
                .padding({ left: 24, right: 24 })
                .fontSize(18)
                .onChange((value: string) => {
                  this.userAnswer = value;
                });

              Button({ type: ButtonType.Normal }) {
                Text('确定')
                  .fontSize(18)
                  .fontColor(Color.White)
                  .fontWeight(FontWeight.Medium);
              }
              .width('100%')
              .height(52)
              .backgroundColor('#FF6B35')
              .borderRadius(26)
              .margin({ top: 12 })
              .onClick(() => this.onAnswerSubmit());
            }
            .width('90%')
            .alignItems(HorizontalAlign.Center)
            .margin({ bottom: 24 });
          }

          // 结果反馈
          if (this.showResult) {
            Column() {
              Row() {
                Text(this.isCorrect ? '✅' : '❌')
                  .fontSize(24)
                  .margin({ right: 8 });
                Text(this.isCorrect ? '回答正确！' : '回答错误')
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.isCorrect ? '#2E7D32' : '#D32F2F');
              }
              .margin({ bottom: 8 });

              // 答错后不显示完整答案，提示区域会自动更新（多揭示一个汉字）
              if (!this.isCorrect) {
                Text('继续加油，再试一次！')
                  .fontSize(15)
                  .fontColor('#D32F2F')
                  .margin({ top: 8 });
              }
            }
            .padding(20)
            .backgroundColor(this.isCorrect ? '#E8F5E9' : '#FFEBEE')
            .borderRadius(16)
            .margin({ bottom: 24 });
          }

          // 底部按钮
          Row() {
            if (this.isAnswered) {
              Button({ type: ButtonType.Normal }) {
                Row() {
                  Text('➡️')
                    .fontSize(18)
                    .margin({ right: 8 });
                  Text('下一题')
                    .fontSize(16)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Medium);
                }
              }
              .layoutWeight(1)
              .height(52)
              .backgroundColor('#4ECDC4')
              .borderRadius(26)
              .onClick(() => this.onNextQuestion());
            } else {
              Button({ type: ButtonType.Normal }) {
                Row() {
                  Text('💡')
                    .fontSize(18)
                    .margin({ right: 8 });
                  Text('提示')
                    .fontSize(16)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Medium);
                }
              }
              .layoutWeight(1)
              .height(52)
              .backgroundColor('#FFA726')
              .borderRadius(26)
              .onClick(() => this.onGetHint());
            }

            Button({ type: ButtonType.Normal }) {
              Row() {
                Text('🚪')
                  .fontSize(18)
                  .margin({ right: 8 });
                Text('结束')
                  .fontSize(16)
                  .fontColor('#333333')
                  .fontWeight(FontWeight.Medium);
              }
            }
            .layoutWeight(1)
            .height(52)
            .backgroundColor(Color.White)
            .borderRadius(26)
            .border({ width: 2, color: '#E0E0E0' })
            .margin({ left: 12 })
            .onClick(() => {
              this.gameViewModel.endGame();
              this.timerViewModel.destroy();
              this.navigateToGameOver();
            });
          }
          .width('90%')
          .justifyContent(FlexAlign.Center)
          .margin({ top: 20 });

          // 答题统计
          Row() {
            Text('📊 答对: ')
              .fontSize(14)
              .fontColor('#666666');
            Text(this.correctCount.toString())
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2E7D32');
            Text(' 题')
              .fontSize(14)
              .fontColor('#666666');
          }
          .margin({ top: 24, bottom: 16 });
        }
        .alignItems(HorizontalAlign.Center)
        .padding({ bottom: 32 })  // 避让底部导航条
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
