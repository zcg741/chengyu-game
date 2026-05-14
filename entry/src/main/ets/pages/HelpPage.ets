// HelpPage.ets - 游戏帮助页面
import { navigateBack } from '../utils/NavUtil';
import { Theme, THEMES } from '../model/ThemeModel';

interface HelpItem {
  title: string;
  desc: string;
  icon?: string;
}

@Entry
@Component
struct HelpPage {
  @State brandColor: string = '#FF6B35';
  @State bgPage: string = '#FAFAF7';
  @State bgCard: string = '#FFFFFF';
  @State borderColr: string = '#E8E6E1'; // 注意：不能用 borderColor（与内置属性冲突）
  @State textPrimary: string = '#2C2C2C';
  @State textSecondary: string = '#888888';
  @StorageProp('status_bar_height') statusBarHeight: number = 0;

  // 使用 @StorageLink 监听主题变化（全局同步）
  @StorageLink('current_theme_id') themeId: string = 'classic';

  // 根据 themeId 获取主题对象（避免索引访问）
  getThemeByID(themeId: string): Theme {
    if (themeId === 'classic') return THEMES.classic;
    if (themeId === 'green') return THEMES.green;
    if (themeId === 'blue') return THEMES.blue;
    if (themeId === 'dark') return THEMES.dark;
    return THEMES.classic;
  }

  aboutToAppear() {
    const theme = this.getThemeByID(this.themeId);
    this.brandColor = theme.brand;
    this.bgPage = theme.bgPage;
    this.bgCard = theme.bgCard;
    this.borderColr = theme.border;
    this.textPrimary = theme.textPrimary;
    this.textSecondary = theme.textSecondary;
  }

  build() {
    Column() {
      this.buildHeader()
      this.buildContent()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgPage)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder
  buildHeader() {
    Row() {
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

      Text('游戏帮助')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.textPrimary)

      Blank()

      Column().width(40).height(40)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: this.statusBarHeight + 10, bottom: 12 })
    .backgroundColor(this.bgCard)
    .shadow({ radius: 4, color: '#0000000D', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildContent() {
    Scroll() {
      Column() {
        this.buildSection('🎮 游戏模式', [
          { title: '计时模式', desc: '在60秒内尽可能多答题。每答对一题得10分，使用提示扣5分。时间结束后游戏结束。' },
          { title: '闯关模式', desc: '连续答对5题即可通关！通关后进入下一关，并获得额外生命值。初始3条命，答错扣1条命。' }
        ])

        this.buildSection('📝 题型说明', [
          { title: '拼音题', desc: `显示成语的拼音（如：yi xin yi yi），请输入正确的成语。提示会逐步揭晓声母。`, icon: '🔤' },
          { title: '填空题', desc: `成语中部分汉字被隐藏（如：一_ __意），请填入缺失的汉字。`, icon: '✏️' },
          { title: '释义题', desc: `显示成语的释义，请猜出对应的成语。这是最有挑战的题型！`, icon: '📖' },
          { title: '接龙题', desc: `以上一题成语的尾字开头，猜一个新的成语（如：一心一意 → 意味深长）。`, icon: '🐉' }
        ])

        this.buildSection('💡 提示系统', [
          { title: '如何使用', desc: '点击"提示"按钮可以获取帮助。每次使用提示会扣5分，但会揭晓更多字母。' },
          { title: '提示等级', desc: '提示会逐步显示：先显示声母 → 再显示部分汉字 → 最后显示完整答案。' }
        ])

        this.buildSection('🏆 成就系统', [
          { title: '成就类型', desc: '达成特定条件即可解锁成就，包括：首次游戏、答题数量、最高分、连胜记录、游戏模式、难度挑战等。' },
          { title: '成就奖励', desc: '解锁成就可以获得积分奖励，用于提升等级和解锁新功能。' }
        ])

        this.buildSection('📚 成语图鉴', [
          { title: '自动收集', desc: '每次答对成语后，该成语会自动收集到"成语图鉴"中。' },
          { title: '查看详情', desc: '在"学习中心"→"成语图鉴"中可以查看所有已收集的成语，点击可查看拼音、释义和出处。' }
        ])

        this.buildSection('📊 数据统计', [
          { title: '统计内容', desc: '在"学习中心"→"数据统计"中可以查看：总游戏次数、总答对题数、最高分、总积分、成就进度等。' },
          { title: '每日挑战', desc: '每天可参加一次每日挑战（5题），坚持打卡可以提升成就进度！' }
        ])

        this.buildSection('💡 游戏技巧', [
          { title: 'Tip 1', desc: '先观察题型，再决定是否需要提示。释义题难度较高，建议尽早使用提示。' },
          { title: 'Tip 2', desc: '闯关模式下，优先保证正确率。连续答对5题比快速答题更重要。' },
          { title: 'Tip 3', desc: '收集成语图鉴不仅可以复习，还能帮你发现新的成语！' }
        ])

        Text('📧 如有其他问题，请联系开发者')
          .fontSize(12)
          .fontColor(this.textSecondary)
          .margin({ top: 24, bottom: 40 })
      }
      .width('100%')
      .padding({ left: 20, right: 20 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  buildSection(title: string, items: HelpItem[]) {
    Column() {
      // 区块标题
      Row() {
        Divider()
          .vertical(true)
          .strokeWidth(3)
          .color(this.brandColor)
          .height(16)
          .margin({ right: 8 });
        Text(title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.textPrimary);
      }
      .margin({ bottom: 12, top: 20 })

      // 内容卡片
      Column() {
        ForEach(items, (item: HelpItem, index: number) => {
          Column() {
            Row() {
              if (item.icon) {
                Text(item.icon)
                  .fontSize(16)
                  .margin({ right: 8 });
              }
              Text(item.title)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.textPrimary);
            }
            .width('100%')
            .margin({ bottom: 4 })

            Text(item.desc)
              .fontSize(12)
              .fontColor(this.textSecondary)
              .lineHeight(18)
              .width('100%')
              .textAlign(TextAlign.Start)
          }
          .width('100%')
          .padding({ left: 12, right: 12, top: 10, bottom: 10 })

          if (index < items.length - 1) {
            Divider()
              .color('#F5F5F5')
              .strokeWidth(0.5);
          }
        }, (item: HelpItem) => item.title)
      }
      .width('100%')
      .backgroundColor(this.bgCard)
      .borderRadius(12)
      .borderWidth(0.5)
      .borderColor(this.borderColr)
    }
    .width('100%')
  }
}
