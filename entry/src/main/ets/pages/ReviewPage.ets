// ReviewPage.ets - 游戏回顾页面
import { GameRecord } from '../model/GameState';
import { getRouteParams, navigateBack } from '../utils/NavUtil';
import { getCurrentTheme, setTheme } from '../service/ThemeService';
import { Theme, THEMES } from '../model/ThemeModel';

@Entry
@Component
struct ReviewPage {
  @State records: GameRecord[] = [];
  @State totalQuestions: number = 0;
  @State correctCount: number = 0;

  // 使用 @StorageLink 监听主题变化（全局同步）
  @StorageLink('current_theme_id') themeId: string = 'classic';

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

  aboutToAppear() {
    // 加载主题
    const theme = this.getThemeByID(this.themeId);
    this.brandColor = theme.brand;
    this.bgPage = theme.bgPage;
    this.bgCard = theme.bgCard;
    this.borderColr = theme.border;
    this.textPrimary = theme.textPrimary;
    this.textSecondary = theme.textSecondary;

    // 从路由参数获取记录
    const params = getRouteParams();
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

  build() {
    Column() {
      // 顶部标题栏
      this.buildHeader()

      // 统计栏
      this.buildStatsBar()

      // 题目列表
      if (this.records.length === 0) {
        this.buildEmptyState()
      } else {
        this.buildRecordList()
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

      Text('答题回顾')
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
}
