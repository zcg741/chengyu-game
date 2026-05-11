// CollectionPage.ets - 成语图鉴/收集系统
import { getCollectedList, getCollectedChengyuList, getCollectedCount } from '../service/CollectionService';
import { Chengyu } from '../model/ChengyuModel';
import { getTotalCount } from '../service/ChengyuService';
import { navigateTo } from '../utils/NavUtil';
import { getCurrentTheme } from '../service/ThemeService';
import { Theme } from '../model/ThemeModel';

@Entry
@Component
struct CollectionPage {
  @State collectedList: Chengyu[] = [];
  @State totalCollected: number = 0;
  @State totalCount: number = 0;
  @State selectedChengyu: Chengyu | undefined = undefined;
  @State showDetail: boolean = false;

  // 主题颜色状态
  @State brandColor: string = '#FF6B35';
  @State bgPage: string = '#F5F5F5';
  @State bgCard: string = '#FFFFFF';
  @State borderColor: string = '#E0E0E0';
  @State textPrimary: string = '#333333';
  @State textSecondary: string = '#666666';

  async aboutToAppear() {
    // 加载主题
    const theme = getCurrentTheme();
    this.brandColor = theme.brand;
    this.bgPage = theme.bgPage;
    this.bgCard = theme.bgCard;
    this.borderColor = theme.border;
    this.textPrimary = theme.textPrimary;
    this.textSecondary = theme.textSecondary;

    await this.loadCollection();
  }

  async loadCollection() {
    try {
      this.collectedList = await getCollectedChengyuList();
      this.totalCollected = await getCollectedCount();
      this.totalCount = getTotalCount();
    } catch (error) {
      console.error('CollectionPage load error:', error);
    }
  }

  build() {
    Column() {
      // 顶部标题栏
      this.buildHeader()

      // 统计栏
      this.buildStatsBar()

      // 图鉴网格
      if (this.collectedList.length === 0) {
        this.buildEmptyState()
      } else {
        this.buildCollectionGrid()
      }

      // 详情弹窗
      if (this.showDetail && this.selectedChengyu) {
        this.buildDetailDialog();
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
        navigateTo('pages/HomePage');
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
    .padding({ left: 20, right: 20, top: 16, bottom: 12 })
    .backgroundColor(this.bgCard)
    .shadow({ radius: 4, color: '#0000000D', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildStatsBar() {
    Row() {
      Text(`已收集：${this.totalCollected} / ${this.totalCount}`)
        .fontSize(13)
        .fontColor(this.textSecondary);
      Blank();
      Stack() {
        Progress({ value: this.totalCollected, total: this.totalCount, type: ProgressType.Ring })
          .width(32)
          .height(32)
          .color(this.brandColor)
          .backgroundColor(this.borderColor);
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
  buildEmptyState() {
    Column() {
      Text('📚')
        .fontSize(64)
        .margin({ bottom: 16 });
      Text('暂无收集')
        .fontSize(16)
        .fontColor('#999999');
      Text('答对成语即可自动收集到这里')
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
      ForEach(this.collectedList, (item: Chengyu) => {
        GridItem() {
          this.buildChengyuCard(item)
        }
        .onClick(() => {
          this.selectedChengyu = item;
          this.showDetail = true;
        })
      }, (item: Chengyu) => item.word)
    }
    .columnsTemplate('1fr 1fr 1fr')
    .rowsTemplate(`repeat(${Math.ceil(this.collectedList.length / 3)}, 1fr)`)
    .width('94%')
    .layoutWeight(1)
    .margin({ left: '3%', right: '3%' })
    .padding({ top: 8, bottom: 16 })
    .scrollBar(BarState.Off)
  }

  @Builder
  buildChengyuCard(item: Chengyu) {
    Column() {
      Text(item.word)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 4 });
      Text(this.getPinyinInitials(item.pinyin))
        .fontSize(10)
        .fontColor('#999999');
    }
    .width('100%')
    .aspectRatio(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .border({ width: 1, color: '#EEEEEE' })
  }

  @Builder
  buildDetailDialog() {
    AlertDialog.show({
      title: this.selectedChengyu!.word,
      message: [
        `拼音：${this.selectedChengyu!.pinyin}`,
        ``,
        `释义：${this.selectedChengyu!.explanation}`,
        ``,
        this.selectedChengyu!.source ? `出处：${this.selectedChengyu!.source}` : ''
      ].join('\n'),
      confirm: {
        value: '关闭',
        action: () => {
          this.showDetail = false;
        }
      }
    });
  }

  /**
   * 获取拼音首字母（如：Y X Y Y）
   */
  getPinyinInitials(pinyin: string): string {
    if (!pinyin) return '';
    return pinyin.split(' ').map(p => p[0]?.toUpperCase() || '').join(' ');
  }
}
