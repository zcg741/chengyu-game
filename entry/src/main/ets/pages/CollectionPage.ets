// CollectionPage.ets - 成语图鉴/收集系统
import { getCollectedList, getCollectedChengyuList, getCollectedCount } from '../service/CollectionService';
import { Chengyu } from '../model/ChengyuModel';
import { getCategories, getChengyuByDifficulty, getTotalCount, loadChengyuData } from '../service/ChengyuService';
import { navigateBack } from '../utils/NavUtil';
import { getCurrentTheme, setTheme } from '../service/ThemeService';
import { Theme, THEMES } from '../model/ThemeModel';
import { getInitialLettersFromPinyin } from '../utils/PinyinUtil';
import { InfoDialogOptions, showInfoDialog } from '../utils/DialogUtil';

@Entry
@Component
struct CollectionPage {
  @State collectedList: Chengyu[] = [];
  @State allChengyuList: Chengyu[] = [];
  @State displayList: Chengyu[] = [];
  @State collectedWords: string[] = [];
  @State totalCollected: number = 0;
  @State totalCount: number = 0;
  @State selectedChengyu: Chengyu | undefined = undefined;
  @State selectedCategory: string = '全部';
  @State selectedDifficulty: number = 0;
  @State categories: string[] = ['全部'];
  @StorageProp('status_bar_height') statusBarHeight: number = 0;

  // 使用 @StorageLink 监听主题变化（全局同步）
  @StorageLink('current_theme_id') themeId: string = 'classic';

  // 主题颜色状态
  @State brandColor: string = '#FF6B35';
  @State bgPage: string = '#F5F5F5';
  @State bgCard: string = '#FFFFFF';
  @State borderColr: string = '#E0E0E0';
  @State textPrimary: string = '#333333';
  @State textSecondary: string = '#666666';

  // 根据 themeId 获取主题对象（避免索引访问）
  getThemeByID(themeId: string): Theme {
    if (themeId === 'classic') return THEMES.classic;
    if (themeId === 'green') return THEMES.green;
    if (themeId === 'blue') return THEMES.blue;
    if (themeId === 'dark') return THEMES.dark;
    return THEMES.classic;
  }

  async aboutToAppear() {
    // 加载主题
    const theme = this.getThemeByID(this.themeId);
    this.brandColor = theme.brand;
    this.bgPage = theme.bgPage;
    this.bgCard = theme.bgCard;
    this.borderColr = theme.border;
    this.textPrimary = theme.textPrimary;
    this.textSecondary = theme.textSecondary;

    await this.loadCollection();
  }

  async loadCollection() {
    try {
      await loadChengyuData(0, '全部');
      this.categories = getCategories();
      this.allChengyuList = getChengyuByDifficulty(0, '全部');
      this.collectedWords = await getCollectedList();
      this.collectedList = await getCollectedChengyuList();
      this.totalCollected = await getCollectedCount();
      this.totalCount = getTotalCount();
      this.refreshDisplayList();
    } catch (error) {
      console.error('CollectionPage load error:', error);
    }
  }

  refreshDisplayList() {
    let result = this.allChengyuList;
    if (this.selectedDifficulty > 0) {
      result = result.filter(item => item.difficulty === this.selectedDifficulty);
    }
    if (this.selectedCategory !== '全部') {
      result = result.filter(item => item.category === this.selectedCategory);
    }
    this.displayList = result;
  }

  isCollected(word: string): boolean {
    return this.collectedWords.includes(word);
  }

  build() {
    Column() {
      // 顶部标题栏
      this.buildHeader()

      // 统计栏
      this.buildStatsBar()

      this.buildFilterBar()

      // 图鉴网格
      if (this.displayList.length === 0) {
        this.buildEmptyState()
      } else {
        this.buildCollectionGrid()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgPage)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
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
        navigateBack();
      });

      Blank()

      Text('成语图鉴')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.textPrimary);

      Blank()

      // 占位，保持标题居中
      Column()
        .width(40)
        .height(40)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: this.statusBarHeight + 10, bottom: 12 })
    .backgroundColor(this.bgCard)
    .shadow({ radius: 4, color: '#0000000D', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildStatsBar() {
    Row() {
      Column() {
        Text(`已收集：${this.totalCollected} / ${this.totalCount}`)
          .fontSize(13)
          .fontColor(this.textSecondary)
        Text(this.selectedCategory === '全部' ? '全部分类' : this.selectedCategory)
          .fontSize(11)
          .fontColor(this.brandColor)
          .margin({ top: 3 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Stack() {
        Progress({ value: this.totalCollected, total: this.totalCount, type: ProgressType.Ring })
          .width(32)
          .height(32)
          .color(this.brandColor)
          .backgroundColor(this.borderColr);
        Text(`${Math.round(this.totalCollected / this.totalCount * 100)}%`)
          .fontSize(8)
          .fontColor(this.brandColor)
          .fontWeight(FontWeight.Bold);
      }
    }
    .width('90%')
    .padding({ left: 16, right: 16, top: 10, bottom: 10 })
    .backgroundColor(this.bgCard)
    .borderRadius(12)
    .margin({ top: 16, bottom: 12 })
    .alignSelf(ItemAlign.Center)
  }

  @Builder
  buildFilterBar() {
    Column() {
      Scroll() {
        Row() {
          ForEach(this.categories, (category: string) => {
            Button(category)
              .height(30)
              .backgroundColor(this.selectedCategory === category ? this.brandColor : this.bgCard)
              .fontColor(this.selectedCategory === category ? Color.White : this.textSecondary)
              .borderRadius(15)
              .borderWidth(this.selectedCategory === category ? 0 : 0.5)
              .borderColor(this.borderColr)
              .fontSize(12)
              .padding({ left: 12, right: 12 })
              .margin({ right: 8 })
              .onClick(() => {
                this.selectedCategory = category;
                this.refreshDisplayList();
              })
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      Row() {
        this.buildDifficultyChip('全部', 0)
        this.buildDifficultyChip('简单', 1)
        this.buildDifficultyChip('中等', 2)
        this.buildDifficultyChip('困难', 3)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 10 })
    }
    .width('90%')
    .alignSelf(ItemAlign.Center)
    .margin({ bottom: 10 })
  }

  @Builder
  buildDifficultyChip(label: string, value: number) {
    Button(label)
      .height(30)
      .backgroundColor(this.selectedDifficulty === value ? this.brandColor : this.bgCard)
      .fontColor(this.selectedDifficulty === value ? Color.White : this.textSecondary)
      .borderRadius(15)
      .borderWidth(this.selectedDifficulty === value ? 0 : 0.5)
      .borderColor(this.borderColr)
      .fontSize(12)
      .padding({ left: 12, right: 12 })
      .onClick(() => {
        this.selectedDifficulty = value;
        this.refreshDisplayList();
      })
  }

  @Builder
  buildEmptyState() {
    Column() {
      Text('📚')
        .fontSize(64)
        .margin({ bottom: 16 });
      Text('暂无成语')
        .fontSize(16)
        .fontColor('#999999');
      Text('换个分类或难度看看')
        .fontSize(12)
        .fontColor('#BBBBBB')
        .margin({ top: 6 });
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildCollectionGrid() {
    Grid() {
      ForEach(this.displayList, (item: Chengyu) => {
        GridItem() {
          this.buildChengyuCard(item)
        }
        .onClick(() => {
          if (this.isCollected(item.word)) {
            this.selectedChengyu = item;
            this.showDetailDialog();
          }
        })
      }, (item: Chengyu) => item.word)
    }
    .columnsTemplate('1fr 1fr 1fr')
    .rowsGap(8)
    .columnsGap(8)
    .width('94%')
    .layoutWeight(1)
    .margin({ left: '3%', right: '3%' })
    .padding({ top: 8, bottom: 16 })
    .scrollBar(BarState.Off)
  }

  @Builder
  buildChengyuCard(item: Chengyu) {
    Column() {
      Text(this.isCollected(item.word) ? item.word : '未收集')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isCollected(item.word) ? '#333333' : '#BBBBBB')
        .margin({ bottom: 4 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis });

      Text(this.isCollected(item.word) ? this.getPinyinInitials(item.pinyin) : `${item.category} · ${this.getDifficultyText(item.difficulty)}`)
        .fontSize(10)
        .fontColor('#999999')
        .margin({ bottom: 4 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis });

      Text(this.isCollected(item.word) ? item.explanation : '答对后点亮')
        .fontSize(9)
        .fontColor(this.isCollected(item.word) ? '#666666' : '#AAAAAA')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('90%')
    }
    .width('100%')
    .aspectRatio(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.isCollected(item.word) ? Color.White : '#F4F4F4')
    .borderRadius(12)
    .border({ width: 1, color: '#EEEEEE' })
    .padding({ left: 4, right: 4 })
  }

  // 显示详情弹窗
  showDetailDialog() {
    const options: InfoDialogOptions = {
      title: this.selectedChengyu!.word,
      message: [
        `拼音：${this.selectedChengyu!.pinyin}`,
        ``,
        `释义：${this.selectedChengyu!.explanation}`,
        ``,
        this.selectedChengyu!.source ? `出处：${this.selectedChengyu!.source}` : ''
      ].join('\n'),
      confirmText: '关闭'
    };
    showInfoDialog(options);
  }

  /**
   * 获取拼音首字母（如：Y X Y Y）
   */
  getPinyinInitials(pinyin: string): string {
    if (!pinyin) return '';
    return getInitialLettersFromPinyin(pinyin).join(' ');
  }

  getDifficultyText(difficulty: number): string {
    if (difficulty === 1) return '简单';
    if (difficulty === 2) return '中等';
    if (difficulty === 3) return '困难';
    return '全部';
  }
}
