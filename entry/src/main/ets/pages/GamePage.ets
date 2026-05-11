// GamePage.ets - 游戏主界面
import { GAME_MODE, GAME_CONFIG, QUESTION_TYPE } from '../utils/Constants';
import { GameViewModel } from '../viewmodel/GameViewModel';
import { TimerViewModel, TimerCallback, TimerFinishCallback } from '../viewmodel/TimerViewModel';
import { HintLevel } from '../model/GameState';
import { replaceTo, replaceToWithParams, getRouteParams } from '../utils/NavUtil';
import { playSound, stopSound } from '../service/SoundService';
import { getCurrentTheme } from '../service/ThemeService';
import { Theme } from '../model/ThemeModel';

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
  @State lives: number = 3; // 生命值（闯关模式）
  @State questionType: string = '';

  // 主题颜色状态
  @State brandColor: string = '#FF6B35';
  @State bgPage: string = '#F5F5F5';
  @State bgCard: string = '#FFFFFF';
  @State borderColr: string = '#E0E0E0';
  @State textPrimary: string = '#333333';
  @State textSecondary: string = '#666666';
  @State bgLight: string = '#FFF8F5';

  // 动画状态
  @State resultScale: number = 1; // 结果图标缩放
  @State hintOpacity: number = 1; // 提示文字透明度
  @State cardTranslateX: number = 0; // 卡片平移动画

  private gameViewModel: GameViewModel = new GameViewModel();
  private timerViewModel: TimerViewModel = new TimerViewModel();
  private storyTimerId: number = 0; // 故事弹窗定时器ID
  
  // 故事弹窗状态
  @State showStoryDialog: boolean = false;
  @State storyChengyu: string = '';
  @State storySource: string = '';

  async aboutToAppear() {
    // 加载主题
    const theme = getCurrentTheme();
    this.brandColor = theme.brand;
    this.bgPage = theme.bgPage;
    this.bgCard = theme.bgCard;
    this.borderColr = theme.border;
    this.textPrimary = theme.textPrimary;
    this.textSecondary = theme.textSecondary;
    this.bgLight = theme.bgLight;

    // 读取路由参数
    const params = getRouteParams();
    let mode = GAME_MODE.TIMER;
    let difficulty = 0;
    let category = '';

    if (params) {
      mode = params['mode'] as string || GAME_MODE.TIMER;
      difficulty = params['difficulty'] as number || 0;
      category = params['category'] as string || '';
    }

    // 初始化游戏
    await this.gameViewModel.initGame(mode, difficulty, category);
    this.gameMode = mode;
    this.loadQuestion();

    // 读取生命值（闯关模式）
    this.lives = this.gameViewModel.getLives();

    // 计时模式启动计时器
    if (mode === GAME_MODE.TIMER) {
      this.startTimer();
    }
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
    const session = this.gameViewModel.getSession();
    const recordsJson = JSON.stringify(session.records || []);

    try {
      const paramsMap: Record<string, Object> = {};
      paramsMap['score'] = score;
      paramsMap['correctCount'] = correctCount;
      paramsMap['wrongCount'] = wrongCount;
      paramsMap['totalQuestions'] = totalQuestions;
      paramsMap['records'] = recordsJson;
      replaceToWithParams('pages/GameOverPage', paramsMap);
    } catch (error) {
      console.error('Failed to navigate:', error);
    }
  }

  loadQuestion() {
    const question = this.gameViewModel.getCurrentQuestion();
    if (question) {
      this.currentExplanation = question.currentExplanation;
      this.questionType = question.questionType || '';
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

  getQuestionTypeLabel(): string {
    const type = this.questionType;
    if (type === QUESTION_TYPE.PINYIN) return '拼音';
    if (type === QUESTION_TYPE.FILL_BLANK) return '填空';
    if (type === QUESTION_TYPE.DRAGON) return '接龙';
    return '释义';
  }

  getQuestionTypeIcon(): string {
    const type = this.questionType;
    if (type === QUESTION_TYPE.PINYIN) return '🔤';
    if (type === QUESTION_TYPE.FILL_BLANK) return '✏️';
    if (type === QUESTION_TYPE.DRAGON) return '🐉';
    return '📖';
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
    
    // 更新生命值（闯关模式）
    this.lives = this.gameViewModel.getLives();

    // 触发结果图标缩放动画
    this.resultScale = 1.5;
    setTimeout(() => {
      this.resultScale = 1;
    }, 300);

    if (correct) {
      playSound('correct');
      // 答对后展示成语故事/出处
      const question = this.gameViewModel.getCurrentQuestion();
      if (question && question.currentSource) {
        this.storyTimerId = setTimeout(() => {
          this.storyTimerId = 0;
          // 设置故事弹窗状态
          this.storyChengyu = question.currentChengyu || '';
          this.storySource = question.currentSource || '';
          this.showStoryDialog = true;
        }, 500) as number;
      }
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
        // 触发提示文字淡入动画
        this.hintOpacity = 0.5;
        setTimeout(() => {
          this.hintOpacity = 1;
        }, 100);
        // 2秒后隐藏结果提示
        setTimeout(() => {
          this.showResult = false;
          
          // 闯关模式下生命值耗尽，游戏结束
          if (this.gameMode === GAME_MODE.CHALLENGE && this.lives <= 0) {
            this.gameViewModel.endGame();
            this.navigateToGameOver();
          }
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
    // 取消未弹出的故事弹窗
    if (this.storyTimerId) {
      clearTimeout(this.storyTimerId);
      this.storyTimerId = 0;
    }

    // 卡片滑出动画
    this.cardTranslateX = -100;
    setTimeout(() => {
      this.gameViewModel.nextQuestion();
      this.loadQuestion();
      // 卡片滑入动画
      this.cardTranslateX = 100;
      setTimeout(() => {
        this.cardTranslateX = 0;
      }, 50);
    }, 300);
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
            .fontColor(this.textPrimary);
        }
        .width(40)
        .height(40)
        .backgroundColor(this.bgCard)
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
            .fontColor(this.textSecondary)
            .margin({ bottom: 2 });
          Text(this.score.toString())
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.brandColor);
        }
        .flexGrow(1)
        .alignItems(HorizontalAlign.Center);

        // 计时器或关卡
        if (this.gameMode === GAME_MODE.TIMER) {
          Column() {
            Text('剩余时间')
              .fontSize(11)
              .fontColor(this.textSecondary)
              .margin({ bottom: 2 });
            Row() {
              Text(this.remainingTime <= 10 ? '⚠️' : '⏱️')
                .fontSize(16)
                .margin({ right: 4 });
              Text(`${this.remainingTime}s`)
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.remainingTime <= 10 ? '#D32F2F' : this.textPrimary);
            }
          }
        } else {
          Column() {
            Text('当前关卡')
              .fontSize(11)
              .fontColor(this.textSecondary)
              .margin({ bottom: 2 });
            Text(`第${this.gameViewModel.getCurrentLevel()}关`)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#4ECDC4');

            // 生命值显示
            Row() {
              ForEach([1, 2, 3], (item: number) => {
                Text(item <= this.lives ? '❤️' : '🖤')
                  .fontSize(16)
                  .margin({ right: 2 });
              }, (item: number) => item.toString());
            }
            .margin({ top: 4 })
          }
        }
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 16 })
      .backgroundColor(this.bgCard)
      .shadow({ radius: 8, color: '#0000000D', offsetX: 0, offsetY: 4 });

      Scroll() {
        Column() {
          // 成语释义/拼音/填空/接龙 卡片
          Column() {
            Row() {
              Text(this.getQuestionTypeIcon())
                .fontSize(20)
                .margin({ right: 8 });
              Text(this.getQuestionTypeLabel())
                .fontSize(14)
                .fontColor(this.textSecondary)
                .fontWeight(FontWeight.Medium);
            }
            .margin({ bottom: 12 });

            Text(this.currentExplanation)
              .fontSize(22)
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Center)
              .lineHeight(32)
              .fontColor(this.textPrimary);
          }
          .width('90%')
          .padding(24)
          .backgroundColor(this.bgCard)
          .borderRadius(20)
          .shadow({ radius: 12, color: '#0000001A', offsetX: 0, offsetY: 6 })
          .margin({ top: 24, bottom: 20 })
          .translate({ x: this.cardTranslateX })
          .animation({
            duration: 300,
            curve: Curve.EaseOut,
            iterations: 1,
            playMode: PlayMode.Normal
          });

          // 提示区域
          Column() {
            Row() {
              Text('💡')
                .fontSize(20)
                .margin({ right: 8 });
              Text('提示')
                .fontSize(14)
                .fontColor(this.brandColor)
                .fontWeight(FontWeight.Medium);
            }
            .margin({ bottom: 12 });

            Text(this.hintText)
              .fontSize(36)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.brandColor)
              .letterSpacing(8);
          }
          .width('90%')
          .padding(24)
          .backgroundColor(this.bgLight)
          .borderRadius(20)
          .border({ width: 2, color: this.borderColr })
          .margin({ bottom: 24 });

          // 答案输入
          if (!this.isAnswered) {
            Column() {
              TextInput({ placeholder: '请输入成语', text: this.userAnswer })
                .width('100%')
                .height(52)
                .backgroundColor(this.bgCard)
                .borderRadius(26)
                .border({ width: 2, color: this.borderColr })
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
              .backgroundColor(this.brandColor)
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
                  .margin({ right: 8 })
                  .scale({ x: this.resultScale, y: this.resultScale })
                  .animation({
                    duration: 300,
                    curve: Curve.EaseOut,
                    iterations: 1,
                    playMode: PlayMode.Normal
                  });
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
            .opacity(this.hintOpacity)
            .animation({
              duration: 500,
              curve: Curve.EaseInOut,
              iterations: 1,
              playMode: PlayMode.Normal
            })
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
                  .fontColor(this.textPrimary)
                  .fontWeight(FontWeight.Medium);
              }
            }
            .layoutWeight(1)
            .height(52)
            .backgroundColor(this.bgCard)
            .borderRadius(26)
            .border({ width: 2, color: this.borderColr })
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
              .fontColor(this.textSecondary);
            Text(this.correctCount.toString())
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2E7D32');
            Text(' 题')
              .fontSize(14)
              .fontColor(this.textSecondary);
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
    .backgroundColor(this.bgPage)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])

    // 故事弹窗
    if (this.showStoryDialog) {
      AlertDialog({
        title: '📖 成语故事',
        message: `${this.storyChengyu}\n\n${this.storySource}`,
        confirm: {
          value: '知道了',
          action: () => {
            this.showStoryDialog = false;
          }
        }
      })
    }
  }
}
