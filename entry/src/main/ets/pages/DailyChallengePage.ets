// DailyChallengePage.ets - 每日挑战页面
import { loadChengyuData, getRandomChengyuWithSeed } from '../service/ChengyuService';
import { Chengyu, ChengyuWithIndex } from '../model/ChengyuModel';
import { navigateBack, replaceTo } from '../utils/NavUtil';
import { QUESTION_TYPE } from '../utils/Constants';
import { getDailyChallengeRecord, getTodayDateString, saveDailyChallengeResult, getDailyChallengeSummary } from '../service/DailyChallengeService';
import { incrementAchievement, updateAchievementProgress } from '../service/AchievementService';
import { AchievementType } from '../model/AchievementModel';
import { getPinyinHintText, getQuestionPrompt, isAnswerCorrect } from '../service/QuestionService';
import { collect } from '../service/CollectionService';

interface DailyQuestion {
  chengyu: Chengyu;
  userAnswer: string;
  isCorrect: boolean;
  isAnswered: boolean;
  hintLevel: number;
  questionType: string; // 题型
  hint: string; // 提示内容（填空后的成语等）
}

interface TypeConfigItem {
  name: string;
  icon: string;
}

@Entry
@Component
struct DailyChallengePage {
  @State questions: DailyQuestion[] = [];
  @State currentIndex: number = 0;
  @State userAnswer: string = '';
  @State showResult: boolean = false;
  @State isCorrect: boolean = false;
  @State isCompleted: boolean = false;
  @State correctCount: number = 0;
  @State dailyDate: string = '';
  @State isDailyDone: boolean = false;
  @State todayType: string = QUESTION_TYPE.EXPLANATION; // 今日题型
  @State todayTypeName: string = '释义猜词'; // 今日题型名称
  @State todayTypeIcon: string = '📖'; // 今日题型图标
  @StorageProp('status_bar_height') statusBarHeight: number = 0;

  // 题型配置（使用接口定义）
  private typeConfig: Record<string, TypeConfigItem> = {};

  async aboutToAppear() {
    const today = this.getTodayStr();
    this.dailyDate = today;
    const todayRecord = await getDailyChallengeRecord(today);
    this.isDailyDone = !!(todayRecord && todayRecord.completed);

    // 初始化题型配置
    this.typeConfig[QUESTION_TYPE.EXPLANATION] = { name: '释义猜词', icon: '📖' };
    this.typeConfig[QUESTION_TYPE.PINYIN] = { name: '拼音猜词', icon: '🔤' };
    this.typeConfig[QUESTION_TYPE.FILL_BLANK] = { name: '填空挑战', icon: '✏️' };
    this.typeConfig[QUESTION_TYPE.DRAGON] = { name: '成语接龙', icon: '🐉' };

    // 计算今日题型
    this.todayType = this.getTodayQuestionType();
    const config = this.typeConfig[this.todayType];
    this.todayTypeName = config.name;
    this.todayTypeIcon = config.icon;

    await loadChengyuData(0, '全部');
    this.generateDailyQuestions();
  }

  getTodayStr(): string {
    return getTodayDateString();
  }

  getDailySeed(): number {
    return Number(this.dailyDate.replace(/-/g, '')) || 1;
  }

  // 根据日期计算今日题型（4种题型每日轮换）
  getTodayQuestionType(): string {
    const now = new Date();
    const dayOfMonth = now.getDate();
    const typeKeys: string[] = [QUESTION_TYPE.PINYIN, QUESTION_TYPE.FILL_BLANK, QUESTION_TYPE.EXPLANATION, QUESTION_TYPE.DRAGON];
    return typeKeys[dayOfMonth % typeKeys.length];
  }

  generateDailyQuestions() {
    const dailySeed = this.getDailySeed();
    const list = getRandomChengyuWithSeed(10, [], dailySeed);
    this.questions = list.map((item: ChengyuWithIndex): DailyQuestion => {
      const c = item.chengyu;
      const hint = getQuestionPrompt(c, this.todayType, '', dailySeed + item.originalIndex);

      return {
        chengyu: c,
        userAnswer: '',
        isCorrect: false,
        isAnswered: false,
        hintLevel: 2,
        questionType: this.todayType,
        hint: hint // 添加提示字段
      };
    });
  }

  getCurrentQuestion(): DailyQuestion | null {
    if (this.currentIndex < this.questions.length) {
      return this.questions[this.currentIndex];
    }
    return null;
  }

  async onAnswerSubmit() {
    const q = this.getCurrentQuestion();
    if (!q || q.isAnswered || !this.userAnswer.trim()) {
      return;
    }

    const correct = isAnswerCorrect(this.userAnswer, q.chengyu.word);

    q.userAnswer = this.userAnswer.trim();
    q.isCorrect = correct;
    q.isAnswered = true;
    this.isCorrect = correct;
    this.showResult = true;

    if (correct) {
      this.correctCount++;
      await collect(q.chengyu.word);
    }
  }

  async onNextQuestion() {
    if (this.currentIndex < this.questions.length - 1) {
      this.currentIndex++;
      this.userAnswer = '';
      this.showResult = false;
      this.isCorrect = false;
    } else {
      this.isCompleted = true;
      // 记录今日完成
      await saveDailyChallengeResult(this.dailyDate, this.correctCount, this.questions.length, this.todayType);
      
      // 触发成就：首次完成每日挑战
      await incrementAchievement(AchievementType.DAILY_CHALLENGE_FIRST, 1);
      
      // 触发成就：连续打卡天数（会自动检查3天和7天）
      const summary = await getDailyChallengeSummary(this.dailyDate);
      await updateAchievementProgress(AchievementType.DAILY_STREAK, summary.streak);
    }
  }

  onGetHint() {
    const q = this.getCurrentQuestion();
    if (!q || q.isAnswered) {
      return;
    }
    const maxLevel = Math.max(q.chengyu.word.length - 1, 1);
    if (q.hintLevel < maxLevel) {
      q.hintLevel++;
      this.questions = this.questions.slice();
    }
  }

  getCurrentHintText(): string {
    const q = this.getCurrentQuestion();
    if (!q) {
      return '';
    }

    if (this.todayType === QUESTION_TYPE.PINYIN) {
      const prefix = q.chengyu.explanation || '根据拼音猜出完整成语';
      const pinyinHint = getPinyinHintText(q.chengyu.word, q.chengyu.pinyin, q.hintLevel);
      return `${prefix}\n${pinyinHint}`;
    }

    return getPinyinHintText(q.chengyu.word, q.chengyu.pinyin, q.hintLevel);
  }

  // 获取接龙模式提示（上一个成语的尾字）
  getDragonHint(): string {
    if (this.currentIndex === 0) {
      // 第一题随机给一个字
      const chars = this.getCurrentQuestion()?.chengyu.word || '';
      return chars.length > 0 ? chars[0] : '';
    }
    // 上一题成语的尾字
    const prevQuestion = this.questions[this.currentIndex - 1];
    const prevWord = prevQuestion?.chengyu.word || '';
    return prevWord.length > 0 ? prevWord[prevWord.length - 1] : '';
  }

  // 获取输入框提示文字
  getInputPlaceholder(): string {
    if (this.todayType === QUESTION_TYPE.EXPLANATION) {
      return '请输入成语（根据释义猜测）';
    } else if (this.todayType === QUESTION_TYPE.PINYIN) {
      return '请输入成语（根据拼音猜测）';
    } else if (this.todayType === QUESTION_TYPE.FILL_BLANK) {
      return '请输入完整成语（补全填空）';
    } else if (this.todayType === QUESTION_TYPE.DRAGON) {
      return '请输入成语（接龙模式）';
    }
    return '请输入成语';
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('←')
          .fontSize(22)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
          .margin({ right: 12 })
          .onClick(() => {
            navigateBack();
          })

        Text('每日挑战')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)

        Text(`${this.currentIndex + 1}/${this.questions.length}`)
          .fontSize(14)
          .fontColor('#666666')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: this.statusBarHeight + 10, bottom: 12 })
      .backgroundColor('#FFFFFF')

      // 进度条
      Progress({ value: this.currentIndex + 1, total: this.questions.length, type: ProgressType.Linear })
        .width('100%')
        .height(4)
        .color('#FF6B35')
        .backgroundColor('#F0F0F0')
        .padding({ left: 16, right: 16 })

      // 今日题型标签
      Row() {
        Text(this.todayTypeIcon)
          .fontSize(16)
          .margin({ right: 6 })
        Text(this.todayTypeName)
          .fontSize(14)
          .fontColor('#FF6B35')
          .fontWeight(FontWeight.Medium)
        Text('· 每日轮换')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ left: 6 })
      }
      .padding({ top: 8, bottom: 8 })
      .width('100%')
      .justifyContent(FlexAlign.Center)

      if (this.isCompleted) {
        // 完成页面
        Column() {
          // 成就图标
          Text(this.correctCount >= 8 ? '🏆' : this.correctCount >= 5 ? '🎉' : '💪')
            .fontSize(60)
            .margin({ bottom: 16 })

          Text('今日挑战完成！')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ bottom: 8 })

          // 成就评价
          Text(this.correctCount >= 8 ? '太厉害了！你是成语大师！' : 
               this.correctCount >= 5 ? '不错哦！继续加油！' : '还需努力，明天再来！')
            .fontSize(16)
            .fontColor('#666666')
            .margin({ bottom: 16 })

          // 得分卡片
          Row() {
            Column() {
              Text(this.correctCount.toString())
                .fontSize(32)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF6B35')
              Text('答对')
                .fontSize(12)
                .fontColor('#999999')
            }
            .layoutWeight(1)

            Column() {
              Text((this.questions.length - this.correctCount).toString())
                .fontSize(32)
                .fontWeight(FontWeight.Bold)
                .fontColor('#999999')
              Text('答错')
                .fontSize(12)
                .fontColor('#999999')
            }
            .layoutWeight(1)

            Column() {
              Text(Math.round(this.correctCount / this.questions.length * 100) + '%')
                .fontSize(32)
                .fontWeight(FontWeight.Bold)
                .fontColor('#4ECDC4')
              Text('正确率')
                .fontSize(12)
                .fontColor('#999999')
            }
            .layoutWeight(1)
          }
          .width('90%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .margin({ bottom: 24 })
          .shadow({ radius: 8, color: '#0000000D', offsetX: 0, offsetY: 4 })

          // 答题详情
          Column() {
            Text('答题详情')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .margin({ bottom: 12 })
              .width('100%')
              .textAlign(TextAlign.Start)

            ForEach(this.questions, (q: DailyQuestion, index: number) => {
              Row() {
                Text((index + 1).toString())
                  .fontSize(14)
                  .fontColor('#999999')
                  .width(24)
                Text(q.isCorrect ? '✅' : '❌')
                  .fontSize(16)
                  .margin({ right: 8 })
                Text(q.chengyu.word)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                  .layoutWeight(1)
                Text(q.chengyu.explanation)
                  .fontSize(12)
                  .fontColor('#888888')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('40%')
              }
              .width('100%')
              .padding({ top: 8, bottom: 8 })
              .border({ width: { bottom: 1 }, color: '#F0F0F0' })
            })
          }
          .width('90%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .margin({ bottom: 24 })
          .shadow({ radius: 8, color: '#0000000D', offsetX: 0, offsetY: 4 })

          Button('返回首页')
            .width('60%')
            .height(48)
            .backgroundColor('#FF6B35')
            .fontColor(Color.White)
            .borderRadius(24)
            .onClick(() => {
              replaceTo('pages/HomePage');
            })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .padding({ left: 16, right: 16 })
      } else {
        // 答题区域
        Scroll() {
          Column() {
            if (this.getCurrentQuestion()) {
              // 主提示卡片（根据题型显示不同内容）
              Column() {
                Row() {
                  Text(this.todayTypeIcon)
                    .fontSize(20)
                    .margin({ right: 8 })
                  Text(this.todayTypeName)
                    .fontSize(14)
                    .fontColor('#888888')
                    .fontWeight(FontWeight.Medium)
                }
                .margin({ bottom: 12 })

                // 根据题型显示不同提示内容
                if (this.todayType === QUESTION_TYPE.EXPLANATION) {
                  // 释义猜词：显示释义
                  Text(this.getCurrentQuestion()?.chengyu.explanation || '')
                    .fontSize(22)
                    .fontWeight(FontWeight.Medium)
                    .textAlign(TextAlign.Center)
                    .lineHeight(32)
                    .fontColor('#333333')
                } else if (this.todayType === QUESTION_TYPE.PINYIN) {
                  // 拼音猜词：显示拼音
                  Text(this.getCurrentQuestion()?.chengyu.pinyin || '')
                    .fontSize(28)
                    .fontWeight(FontWeight.Bold)
                    .textAlign(TextAlign.Center)
                    .letterSpacing(4)
                    .fontColor('#FF6B35')
                } else if (this.todayType === QUESTION_TYPE.FILL_BLANK) {
                  // 填空挑战：显示填空后的成语
                  Text(this.getCurrentQuestion()?.hint || '')
                    .fontSize(42)
                    .fontWeight(FontWeight.Bold)
                    .textAlign(TextAlign.Center)
                    .letterSpacing(8)
                    .fontColor('#FF6B35')
                } else if (this.todayType === QUESTION_TYPE.DRAGON) {
                  // 成语接龙：显示上一个成语的尾字提示
                  Column() {
                    Text('上一个成语的尾字是：')
                      .fontSize(14)
                      .fontColor('#888888')
                      .margin({ bottom: 8 })
                    Text(this.getDragonHint())
                      .fontSize(48)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#FF6B35')
                    Text('请猜以这个字开头的成语！')
                      .fontSize(14)
                      .fontColor('#888888')
                      .margin({ top: 8 })
                  }
                }
              }
              .width('90%')
              .padding(24)
              .backgroundColor(Color.White)
              .borderRadius(20)
              .shadow({ radius: 12, color: '#0000001A', offsetX: 0, offsetY: 6 })
              .margin({ top: 24, bottom: 20 })

              // 提示区域
              Column() {
                Row() {
                  Text('💡')
                    .fontSize(20)
                    .margin({ right: 8 })
                  Text('提示')
                    .fontSize(14)
                    .fontColor('#FF6B35')
                    .fontWeight(FontWeight.Medium)
                }
                .margin({ bottom: 12 })

                Text(this.getCurrentHintText())
                  .fontSize(this.todayType === QUESTION_TYPE.PINYIN ? 16 : 32)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FF6B35')
                  .textAlign(TextAlign.Center)
                  .lineHeight(this.todayType === QUESTION_TYPE.PINYIN ? 26 : 40)
                  .letterSpacing(this.todayType === QUESTION_TYPE.PINYIN ? 0 : 6)
                  .width('100%')
                  .maxLines(3)
              }
              .width('90%')
              .padding(24)
              .backgroundColor('#FFF8F5')
              .borderRadius(20)
              .border({ width: 2, color: '#FFE0D5' })
              .margin({ bottom: 24 })

              // 输入和结果
              if (!this.showResult) {
                Column() {
                  TextInput({ 
                    placeholder: this.getInputPlaceholder(), 
                    text: this.userAnswer 
                  })
                    .width('100%')
                    .height(52)
                    .backgroundColor(Color.White)
                    .borderRadius(26)
                    .border({ width: 2, color: '#E0E0E0' })
                    .padding({ left: 24, right: 24 })
                    .fontSize(18)
                    .onChange((value: string) => {
                      this.userAnswer = value;
                    })

                  Row() {
                    Button({ type: ButtonType.Normal }) {
                      Text('提示')
                        .fontSize(16)
                        .fontColor(Color.White)
                    }
                    .width('30%')
                    .height(48)
                    .backgroundColor('#FFA726')
                    .borderRadius(24)
                    .onClick(() => this.onGetHint())

                    Button({ type: ButtonType.Normal }) {
                      Text('确定')
                        .fontSize(16)
                        .fontColor(Color.White)
                    }
                    .width('65%')
                    .height(48)
                    .backgroundColor('#FF6B35')
                    .borderRadius(24)
                    .margin({ left: 8 })
                    .onClick(() => { this.onAnswerSubmit(); })
                  }
                  .width('100%')
                  .margin({ top: 12 })
                }
                .width('90%')
              } else {
                // 结果
                Column() {
                  Row() {
                    Text(this.isCorrect ? '✅' : '❌')
                      .fontSize(24)
                      .margin({ right: 8 })
                    Text(this.isCorrect ? '回答正确！' : '回答错误')
                      .fontSize(20)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.isCorrect ? '#4ECDC4' : '#EF5350')
                  }
                  .margin({ bottom: 8 })

                  if (!this.isCorrect) {
                    Text(`正确答案: ${this.getCurrentQuestion()?.chengyu.word || ''}`)
                      .fontSize(16)
                      .fontColor('#666666')
                  }

                  Button('下一题')
                    .width('60%')
                    .height(48)
                    .backgroundColor('#4ECDC4')
                    .fontColor(Color.White)
                    .borderRadius(24)
                    .margin({ top: 16 })
                    .onClick(() => this.onNextQuestion())
                }
                .width('90%')
                .padding(20)
                .backgroundColor(this.isCorrect ? '#E8F8F5' : '#FEF2F1')
                .borderRadius(16)
              }
            }
          }
          .alignItems(HorizontalAlign.Center)
        }
        .layoutWeight(1)
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
