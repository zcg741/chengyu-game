// DailyChallengePage.ets - 每日挑战页面
import { loadChengyuData, getRandomChengyu } from '../service/ChengyuService';
import { Chengyu } from '../model/ChengyuModel';
import { generatePinyinHint } from '../utils/PinyinUtil';
import { saveNumber, getNumber, getString, saveString } from '../service/StorageService';
import { navigateBack, replaceTo } from '../utils/NavUtil';

interface DailyQuestion {
  chengyu: Chengyu;
  userAnswer: string;
  isCorrect: boolean;
  isAnswered: boolean;
  hintLevel: number;
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

  async aboutToAppear() {
    const today = this.getTodayStr();
    this.dailyDate = today;
    const doneDate = await getString('daily_done_date', '');
    this.isDailyDone = (doneDate === today);

    await loadChengyuData(0, '全部');
    this.generateDailyQuestions();
  }

  getTodayStr(): string {
    const now = new Date();
    return `${now.getFullYear()}-${now.getMonth() + 1}-${now.getDate()}`;
  }

  generateDailyQuestions() {
    // 使用日期作为种子来生成固定的每日题目
    const list = getRandomChengyu(10, []);
    this.questions = list.map((c: Chengyu): DailyQuestion => ({
      chengyu: c,
      userAnswer: '',
      isCorrect: false,
      isAnswered: false,
      hintLevel: 2
    }));
  }

  getCurrentQuestion(): DailyQuestion | null {
    if (this.currentIndex < this.questions.length) {
      return this.questions[this.currentIndex];
    }
    return null;
  }

  onAnswerSubmit() {
    const q = this.getCurrentQuestion();
    if (!q || q.isAnswered || !this.userAnswer.trim()) {
      return;
    }

    const normalize = (str: string) => str.replace(/[！!，,。.\、?？;；:：""''（）()\s]/g, '');
    const correct = normalize(this.userAnswer.trim()) === normalize(q.chengyu.word);

    q.userAnswer = this.userAnswer.trim();
    q.isCorrect = correct;
    q.isAnswered = true;
    this.isCorrect = correct;
    this.showResult = true;

    if (correct) {
      this.correctCount++;
    }
  }

  onNextQuestion() {
    if (this.currentIndex < this.questions.length - 1) {
      this.currentIndex++;
      this.userAnswer = '';
      this.showResult = false;
      this.isCorrect = false;
    } else {
      this.isCompleted = true;
      // 记录今日完成
      saveString('daily_done_date', this.dailyDate);
    }
  }

  onGetHint() {
    const q = this.getCurrentQuestion();
    if (!q || q.isAnswered) {
      return;
    }
    if (q.hintLevel < 4) {
      q.hintLevel++;
    }
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
      .padding({ left: 16, right: 16, top: 16, bottom: 12 })
      .backgroundColor('#FFFFFF')

      // 进度条
      Progress({ value: this.currentIndex + 1, total: this.questions.length, type: ProgressType.Linear })
        .width('100%')
        .height(4)
        .color('#FF6B35')
        .backgroundColor('#F0F0F0')
        .padding({ left: 16, right: 16 })

      if (this.isCompleted) {
        // 完成页面
        Column() {
          Text('🎉')
            .fontSize(60)
            .margin({ bottom: 16 })
          Text('今日挑战完成！')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ bottom: 8 })
          Text(`答对 ${this.correctCount}/${this.questions.length} 题`)
            .fontSize(18)
            .fontColor('#666666')
            .margin({ bottom: 24 })

          // 答题详情
          Column() {
            ForEach(this.questions, (q: DailyQuestion) => {
              Row() {
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
                  .width('50%')
              }
              .width('100%')
              .padding({ top: 6, bottom: 6 })
            })
          }
          .width('90%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 24 })

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
              // 释义卡片
              Column() {
                Row() {
                  Text('📖')
                    .fontSize(20)
                    .margin({ right: 8 })
                  Text('释义')
                    .fontSize(14)
                    .fontColor('#888888')
                    .fontWeight(FontWeight.Medium)
                }
                .margin({ bottom: 12 })

                Text(this.getCurrentQuestion()?.chengyu.explanation || '')
                  .fontSize(22)
                  .fontWeight(FontWeight.Medium)
                  .textAlign(TextAlign.Center)
                  .lineHeight(32)
                  .fontColor('#333333')
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

                Text(generatePinyinHint(
                  this.getCurrentQuestion()?.chengyu.word || '',
                  this.getCurrentQuestion()?.hintLevel || 2
                ))
                  .fontSize(36)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FF6B35')
                  .letterSpacing(8)
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
                    .onClick(() => this.onAnswerSubmit())
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
