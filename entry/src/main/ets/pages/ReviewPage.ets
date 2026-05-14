// ReviewPage.ets - 游戏回顾页面
import { GameRecord } from '../model/GameState';
import { getRouteParams, navigateBack } from '../utils/NavUtil';
import { getCurrentTheme, setTheme } from '../service/ThemeService';
import { Theme, THEMES } from '../model/ThemeModel';
import { QUESTION_TYPE } from '../utils/Constants';
import { Chengyu } from '../model/ChengyuModel';
import { getChengyuByWord, loadChengyuData } from '../service/ChengyuService';
import { getPendingWrongWords, recordReviewResult } from '../service/WrongBookService';
import { getPinyinHintText, isAnswerCorrect } from '../service/QuestionService';

@Entry
@Component
struct ReviewPage {
  @State records: GameRecord[] = [];
  @State totalQuestions: number = 0;
  @State correctCount: number = 0;
  @State isWrongReview: boolean = false;
  @State reviewQuestions: Chengyu[] = [];
  @State currentReviewIndex: number = 0;
  @State reviewAnswer: string = '';
  @State showReviewResult: boolean = false;
  @State reviewIsCorrect: boolean = false;
  @State reviewCorrectCount: number = 0;
  @State reviewFinished: boolean = false;

  // 使用 @StorageLink 监听主题变化（全局同步）
  @StorageLink('current_theme_id') @Watch('onThemeIdChange') themeId: string = 'classic';

  // 主题颜色
  @State brandColor: string = '#FF6B35';
  @State bgPage: string = '#FAFAF7';
  @State bgCard: string = '#FFFFFF';
  @State borderColr: string = '#E8E6E1'; // 注意：不能用 borderColor（与内置属性冲突）
  @State textPrimary: string = '#2C2C2C';
  @State textSecondary: string = '#888888';

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

    // 从路由参数获取记录
    const params = getRouteParams();
    const modeVal = params ? params['mode'] : undefined;
    this.isWrongReview = modeVal === 'wrongbook';
    if (this.isWrongReview) {
      await this.loadWrongReviewQuestions();
      return;
    }

    if (params && params['records']) {
      try {
        this.records = JSON.parse(params['records'] as string) as GameRecord[];
        this.totalQuestions = this.records.length;
        this.correctCount = this.records.filter(r => r.isCorrect).length;
      } catch (e) {
        console.error('Failed to parse records:', e);
      }
    }
  }

  async loadWrongReviewQuestions() {
    await loadChengyuData(0, '全部');
    const words = await getPendingWrongWords();
    const result: Chengyu[] = [];
    words.forEach((word: string) => {
      const item = getChengyuByWord(word);
      if (item) {
        result.push(item);
      }
    });

    this.reviewQuestions = result;
    this.totalQuestions = result.length;
    this.correctCount = 0;
    this.currentReviewIndex = 0;
    this.reviewAnswer = '';
    this.showReviewResult = false;
    this.reviewIsCorrect = false;
    this.reviewCorrectCount = 0;
    this.reviewFinished = false;
  }

  build() {
    Column() {
      // 顶部标题栏
      this.buildHeader()

      if (this.isWrongReview) {
        this.buildWrongReviewBody()
      } else {
        // 统计栏
        this.buildStatsBar()

        // 题目列表
        if (this.records.length === 0) {
          this.buildEmptyState()
        } else {
          this.buildRecordList()
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgPage)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  buildHeader() {
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
        // 统一返回上一页（GameOverPage）
        navigateBack();
      });

      Blank()

      Text(this.isWrongReview ? '错题复习' : '答题回顾')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.textPrimary);

      Blank()

      // 占位
      Column()
        .width(40)
        .height(40)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 12 })
    .backgroundColor(this.bgCard)
    .shadow({ radius: 4, color: '#0000000D', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildStatsBar() {
    Row() {
      Text(`共 ${this.totalQuestions} 题`)
        .fontSize(13)
        .fontColor(this.textSecondary)
        .margin({ right: 16 });

      Text(`✅ ${this.correctCount}`)
        .fontSize(13)
        .fontColor('#2E7D32')
        .margin({ right: 12 });

      Text(`❌ ${this.totalQuestions - this.correctCount}`)
        .fontSize(13)
        .fontColor('#D32F2F');
    }
    .width('90%')
    .padding({ left: 16, right: 16, top: 10, bottom: 10 })
    .backgroundColor(this.bgCard)
    .borderRadius(12)
    .margin({ top: 16, bottom: 12 })
    .alignSelf(ItemAlign.Center)
  }

  @Builder
  buildEmptyState() {
    Column() {
      Text('📝')
        .fontSize(64)
        .margin({ bottom: 16 });
      Text('暂无记录')
        .fontSize(16)
        .fontColor('#999999');
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildWrongReviewBody() {
    if (this.reviewQuestions.length === 0) {
      Column() {
        Text('✅')
          .fontSize(56)
          .margin({ bottom: 14 })
        Text('暂无待复习错题')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.textPrimary)
        Text('答题时出错的成语会自动进入这里')
          .fontSize(13)
          .fontColor(this.textSecondary)
          .margin({ top: 8 })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    } else if (this.reviewFinished) {
      Column() {
        Text(this.reviewCorrectCount === this.reviewQuestions.length ? '🏆' : '📚')
          .fontSize(60)
          .margin({ bottom: 16 })
        Text('本轮复习完成')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.textPrimary)
          .margin({ bottom: 8 })
        Text(`答对 ${this.reviewCorrectCount} / ${this.reviewQuestions.length}`)
          .fontSize(16)
          .fontColor(this.textSecondary)
          .margin({ bottom: 24 })
        Button('返回错题本')
          .width('70%')
          .height(48)
          .backgroundColor(this.brandColor)
          .fontColor(Color.White)
          .borderRadius(24)
          .onClick(() => {
            navigateBack();
          })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    } else {
      Column() {
        Row() {
          Text(`${this.currentReviewIndex + 1}/${this.reviewQuestions.length}`)
            .fontSize(13)
            .fontColor(this.textSecondary)
          Blank()
          Text(`本轮答对 ${this.reviewCorrectCount}`)
            .fontSize(13)
            .fontColor(this.brandColor)
        }
        .width('90%')
        .margin({ top: 16, bottom: 12 })

        Progress({ value: this.currentReviewIndex + 1, total: this.reviewQuestions.length, type: ProgressType.Linear })
          .width('90%')
          .height(4)
          .color(this.brandColor)
          .backgroundColor(this.borderColr)
          .margin({ bottom: 20 })

        this.buildWrongReviewQuestionCard()
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
    }
  }

  @Builder
  buildWrongReviewQuestionCard() {
    Column() {
      Text('根据释义写出成语')
        .fontSize(13)
        .fontColor(this.textSecondary)
        .margin({ bottom: 12 })

      Text(this.getCurrentReviewQuestion().explanation)
        .fontSize(21)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.textPrimary)
        .textAlign(TextAlign.Center)
        .lineHeight(30)
        .margin({ bottom: 18 })

      Text(getPinyinHintText(
        this.getCurrentReviewQuestion().word,
        this.getCurrentReviewQuestion().pinyin,
        this.showReviewResult ? this.getCurrentReviewQuestion().word.length : 1
      ))
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.brandColor)
        .letterSpacing(4)
        .margin({ bottom: 18 })

      if (!this.showReviewResult) {
        TextInput({ placeholder: '请输入成语', text: this.reviewAnswer })
          .width('100%')
          .height(50)
          .backgroundColor(this.bgCard)
          .borderRadius(25)
          .border({ width: 1, color: this.borderColr })
          .padding({ left: 20, right: 20 })
          .fontSize(17)
          .onChange((value: string) => {
            this.reviewAnswer = value;
          })

        Button('提交答案')
          .width('100%')
          .height(48)
          .backgroundColor(this.brandColor)
          .fontColor(Color.White)
          .borderRadius(24)
          .margin({ top: 14 })
          .onClick(() => {
            this.submitWrongReviewAnswer();
          })
      } else {
        Column() {
          Text(this.reviewIsCorrect ? '回答正确' : '回答错误')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.reviewIsCorrect ? '#2E7D32' : '#D32F2F')
            .margin({ bottom: 8 })
          Text(`正确答案：${this.getCurrentReviewQuestion().word}`)
            .fontSize(15)
            .fontColor(this.textSecondary)
          Text(this.reviewIsCorrect ? '掌握进度已更新：继续连对可标记已掌握' : '这道题会保留在待复习列表')
            .fontSize(12)
            .fontColor(this.reviewIsCorrect ? '#2E7D32' : '#D32F2F')
            .margin({ top: 8 })
          if (this.getCurrentReviewQuestion().source) {
            Text(`出处：${this.getCurrentReviewQuestion().source}`)
              .fontSize(12)
              .fontColor(this.textSecondary)
              .margin({ top: 6 })
          }
          Button(this.currentReviewIndex < this.reviewQuestions.length - 1 ? '下一题' : '完成复习')
            .width('100%')
            .height(46)
            .backgroundColor(this.reviewIsCorrect ? '#2E7D32' : this.brandColor)
            .fontColor(Color.White)
            .borderRadius(23)
            .margin({ top: 16 })
            .onClick(() => {
              this.nextWrongReviewQuestion();
            })
        }
        .width('100%')
        .padding(14)
        .backgroundColor(this.reviewIsCorrect ? '#F1F8E9' : this.bgCard)
        .border({ width: 1, color: this.reviewIsCorrect ? '#C8E6C9' : this.borderColr })
        .borderRadius(12)
      }
    }
    .width('90%')
    .padding(22)
    .backgroundColor(this.bgCard)
    .borderRadius(14)
    .border({ width: 1, color: this.borderColr })
    .shadow({ radius: 8, color: '#00000010', offsetX: 0, offsetY: 4 })
  }

  @Builder
  buildRecordList() {
    List() {
      ForEach(this.records, (record: GameRecord, index: number) => {
        ListItem() {
          this.buildRecordCard(record, index)
        }
        .padding({ left: 16, right: 16, bottom: 12 })
      }, (record: GameRecord) => record.currentChengyu + record.currentIndex)
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  buildRecordCard(record: GameRecord, index: number) {
    Column() {
      // 顶部：题号 + 题型标签
      Row() {
        Text(`第 ${index + 1} 题`)
          .fontSize(13)
          .fontColor(this.textSecondary)
          .layoutWeight(1);

        Text(this.getQuestionTypeLabel(record.questionType))
          .fontSize(11)
          .fontColor(Color.White)
          .backgroundColor(this.getQuestionTypeColor(record.questionType))
          .borderRadius(8)
          .padding({ left: 8, right: 8, top: 2, bottom: 2 });
      }
      .margin({ bottom: 8 });

      // 成语（正确答案）
      Text(record.currentChengyu)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.textPrimary)
        .margin({ bottom: 4 });

      // 拼音
      if (record.currentPinyin) {
        Text(record.currentPinyin)
          .fontSize(12)
          .fontColor(this.textSecondary)
          .margin({ bottom: 8 });
      }

      // 你的答案 vs 正确答案
      Row() {
        Column() {
          Text('你的答案')
            .fontSize(10)
            .fontColor(this.textSecondary)
            .margin({ bottom: 2 });
          Text(record.userAnswer || '(未作答)')
            .fontSize(14)
            .fontColor(record.isCorrect ? '#2E7D32' : '#D32F2F')
            .fontWeight(record.isCorrect ? FontWeight.Medium : FontWeight.Normal);
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1);

        // 对错图标
        Text(record.isCorrect ? '✅' : '❌')
          .fontSize(24);
      }
      .margin({ bottom: 8 });

      // 释义（展开）
      if (record.currentExplanation) {
        Text(record.currentExplanation)
          .fontSize(12)
          .fontColor(this.textSecondary)
          .margin({ top: 4 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.bgCard)
    .borderRadius(12)
    .border({ width: 1, color: record.isCorrect ? '#C8E6C9' : '#FFCDD2' })
  }

  getQuestionTypeLabel(type: string): string {
    if (type === QUESTION_TYPE.PINYIN) return '拼音';
    if (type === QUESTION_TYPE.FILL_BLANK) return '填空';
    if (type === QUESTION_TYPE.DRAGON) return '接龙';
    return '释义';
  }

  getQuestionTypeColor(type: string): string {
    if (type === QUESTION_TYPE.PINYIN) return '#4ECDC4';
    if (type === QUESTION_TYPE.FILL_BLANK) return '#FF6B35';
    if (type === QUESTION_TYPE.DRAGON) return '#7C4DFF';
    return '#F5A623';
  }

  getCurrentReviewQuestion(): Chengyu {
    return this.reviewQuestions[this.currentReviewIndex];
  }

  async submitWrongReviewAnswer() {
    if (!this.reviewAnswer.trim() || this.showReviewResult) {
      return;
    }

    const question = this.getCurrentReviewQuestion();
    const correct = isAnswerCorrect(this.reviewAnswer, question.word);
    this.reviewIsCorrect = correct;
    this.showReviewResult = true;
    if (correct) {
      this.reviewCorrectCount++;
    }
    await recordReviewResult(question.word, correct);
  }

  nextWrongReviewQuestion() {
    if (this.currentReviewIndex < this.reviewQuestions.length - 1) {
      this.currentReviewIndex++;
      this.reviewAnswer = '';
      this.showReviewResult = false;
      this.reviewIsCorrect = false;
    } else {
      this.reviewFinished = true;
    }
  }
}
