// HomePage.ets - 首页（精致设计版）
import { GAME_MODE } from '../utils/Constants';
import { GameViewModel } from '../viewmodel/GameViewModel';
import { getCategories } from '../service/ChengyuService';
import { navigateTo, replaceTo } from '../utils/NavUtil';
import { getCurrentTheme, getCurrentThemeId } from '../service/ThemeService';

@Entry
@Component
struct HomePage {
  @State highScore: number = 0;
  @State totalGames: number = 0;
  @State selectedDifficulty: number = 0;
  @State selectedCategory: string = '全部';
  @State categories: string[] = ['全部'];
  private gameViewModel: GameViewModel = new GameViewModel();
  @State currentTabIndex: number = 0;
  @State brandColor: string = '#FF6B35';
  @State bgPage: string = '#FAFAF7';
  @State bgCard: string = '#FFFFFF';
  @State borderColor: string = '#E8E6E1';
  @State textPrimary: string = '#2C2C2C';
  @State textSecondary: string = '#888888';
  @State bgOrangeLight: string = '#FFF5F0';
  @State bgTealLight: string = '#F0FAF7';
  @State bgAmberLight: string = '#FFF8F0';
  @State currentThemeId: string = getCurrentThemeId();

  async aboutToAppear() {
    this.highScore = await this.gameViewModel.getHighScore();
    this.totalGames = await this.gameViewModel.getTotalGames();
    await this.loadCategories();
    // 重新加载主题（从主题页返回后刷新）
    const theme = getCurrentTheme();
    this.brandColor = theme.brand;
    this.bgPage = theme.bgPage;
    this.bgCard = theme.bgCard;
    this.borderColor = theme.border;
    this.textPrimary = theme.textPrimary;
    this.textSecondary = theme.textSecondary;
    this.bgOrangeLight = theme.bgLight;
    this.bgTealLight = theme.bgLight;
    this.bgAmberLight = theme.bgLight;
  }

  async loadCategories() {
    await this.gameViewModel.initGame(GAME_MODE.TIMER, 0);
    this.categories = getCategories();
  }

  build() {
    Column() {
      // 顶部标题区域
      this.buildHeader()

      // 内容区 Tabs
      Tabs({ barPosition: BarPosition.End, index: this.currentTabIndex }) {
        TabContent() {
          this.buildGameTab()
        }
        .tabBar(this.buildTabBar('🎮', '游戏', 0))

        TabContent() {
          this.buildLearnTab()
        }
        .tabBar(this.buildTabBar('📚', '学习', 1))

        TabContent() {
          this.buildProfileTab()
        }
        .tabBar(this.buildTabBar('👤', '我的', 2))
      }
      .vertical(false)
      .barMode(BarMode.Fixed)
      .barWidth('100%')
      .barHeight(60)
      .animationDuration(250)
      .onChange((index: number) => {
        this.currentTabIndex = index;
      })
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgPage)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  // ========================
  // 顶部标题
  // ========================
  @Builder
  buildHeader() {
    Column() {
      Row() {
        Column() {
          Text('妙语成语')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.brandColor);
          Text('Miaoyu Chengyu')
            .fontSize(11)
            .fontColor('#AAAAAA')
            .margin({ top: 2 });
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        // 成就入口
        Stack() {
          Text('🏆')
            .fontSize(22)
        }
        .width(40)
        .height(40)
        .alignContent(Alignment.Center)
        .backgroundColor(this.bgOrangeLight)
        .borderRadius(20)
        .onClick(() => {
          navigateTo('pages/AchievementPage');
        })
      }
      .width('100%')
      .padding({ left: 24, right: 24 })

      // 分割线
      Divider()
        .color('#EEEEEE')
        .strokeWidth(0.5)
        .margin({ top: 16, bottom: 0 })
    }
    .padding({ top: 44 })
    .backgroundColor(Color.White)
  }

  // ========================
  // TabBar 样式
  // ========================
  @Builder
  buildTabBar(icon: string, text: string, tabIndex: number) {
    Column() {
      Text(icon)
        .fontSize(22)
        .margin({ bottom: 2 })
      Text(text)
        .fontSize(10)
        .fontColor(this.currentTabIndex === tabIndex ? this.brandColor : '#AAAAAA')
    }
    .width('100%')
    .height(60)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .borderWidth({ top: this.currentTabIndex === tabIndex ? 2 : 0 })
    .borderColor(this.brandColor)
  }

  // ========================
  // Tab 1: 开始游戏
  // ========================
  @Builder
  buildGameTab() {
    Scroll() {
      Column() {
        // 游戏模式
        this.buildSectionTitle('游戏模式')
        this.buildGameModeCard()

        // 难度选择
        this.buildSectionTitle('选择难度')
        this.buildDifficultyCard()

        // 分类选择
        this.buildSectionTitle('选择分类')
        this.buildCategoryCard()

        Text('纯离线游戏 · 无需联网')
          .fontSize(11)
          .fontColor('#BBBBBB')
          .margin({ top: 28, bottom: 40 })
      }
      .width('100%')
      .padding({ left: 20, right: 20 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  // 区块标题
  @Builder
  buildSectionTitle(title: string) {
    Row() {
      // 左侧色条
      Divider()
        .vertical(true)
        .strokeWidth(3)
        .color(this.brandColor)
        .height(16)
        .margin({ right: 8 })

      Text(title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.textPrimary)
    }
    .margin({ bottom: 14, top: 24 })
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  // 游戏模式卡片（浅底+左侧色条设计）
  @Builder
  buildGameModeCard() {
    Column() {
      // 计时模式
      Button() {
        Row() {
          // 左侧色条
          Column()
            .width(4)
            .height(40)
            .backgroundColor(this.brandColor)
            .borderRadius(2)
            .margin({ right: 14 })

          Column() {
            Text('计时模式')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.textPrimary)
              .width('100%')
            Text('1分钟内尽可能多答题')
              .fontSize(11)
              .fontColor(this.textSecondary)
              .margin({ top: 2 })
              .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Text('→')
            .fontSize(16)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height(68)
      .backgroundColor(this.bgOrangeLight)
      .borderRadius(12)
      .borderWidth(0.5)
      .borderColor(this.borderColor)
      .margin({ bottom: 10 })
      .onClick(() => {
        this.startGame(GAME_MODE.TIMER);
      })

      // 闯关模式
      Button() {
        Row() {
          Column()
            .width(4)
            .height(40)
            .backgroundColor(this.brandColor)
            .borderRadius(2)
            .margin({ right: 14 })

          Column() {
            Text('闯关模式')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.textPrimary)
              .width('100%')
            Text('连续答对5题即可通关')
              .fontSize(11)
              .fontColor(this.textSecondary)
              .margin({ top: 2 })
              .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Text('→')
            .fontSize(16)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height(68)
      .backgroundColor(this.bgTealLight)
      .borderRadius(12)
      .borderWidth(0.5)
      .borderColor(this.borderColor)
      .onClick(() => {
        this.startGame(GAME_MODE.CHALLENGE);
      })
    }
    .width('100%')
  }

  // 难度选择
  @Builder
  buildDifficultyCard() {
    Row() {
      this.buildChip('全部', 0, this.brandColor)
      this.buildChip('简单', 1, this.brandColor)
      this.buildChip('中等', 2, '#F5A623')
      this.buildChip('困难', 3, '#D94F4F')
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  buildChip(label: string, value: number, color: string) {
    Button(label)
      .height(34)
      .backgroundColor(this.selectedDifficulty === value ? color : this.bgCard)
      .fontColor(this.selectedDifficulty === value ? Color.White : this.textSecondary)
      .borderRadius(17)
      .borderWidth(this.selectedDifficulty === value ? 0 : 0.5)
      .borderColor(this.borderColor)
      .padding({ left: 14, right: 14 })
      .fontSize(13)
      .onClick(() => {
        this.selectedDifficulty = value;
      })
  }

  // 分类选择
  @Builder
  buildCategoryCard() {
    Scroll() {
      Row() {
        ForEach(this.categories, (category: string) => {
          Button(category)
            .height(34)
            .backgroundColor(this.selectedCategory === category ? this.brandColor : this.bgCard)
            .fontColor(this.selectedCategory === category ? Color.White : this.textSecondary)
            .borderRadius(17)
            .borderWidth(this.selectedCategory === category ? 0 : 0.5)
            .borderColor(this.borderColor)
            .padding({ left: 14, right: 14 })
            .fontSize(13)
            .margin({ right: 8 })
            .onClick(() => {
              this.selectedCategory = category;
            })
        })
      }
      .padding({ right: 20 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
  }

  // ========================
  // Tab 2: 学习中心
  // ========================
  @Builder
  buildLearnTab() {
    Scroll() {
      Column() {
        this.buildSectionTitle('学习工具')
        this.buildLearnGrid()

        this.buildSectionTitle('每日推荐')
        this.buildDailyChallengeCard()

        Blank()
          .height(40)
      }
      .width('100%')
      .padding({ left: 20, right: 20 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  // 学习网格（2x2）
  @Builder
  buildLearnGrid() {
    Column() {
      Row() {
        this.buildLearnCard('📚', '成语学习', this.bgTealLight, this.brandColor, 'pages/LearnPage')
        Blank().width(12)
        this.buildLearnCard('📝', '错题本', '#FFF0F0', '#D94F4F', 'pages/WrongBookPage')
      }
      .margin({ bottom: 12 })

      Row() {
        this.buildLearnCard('📚', '数据统计', '#F5F0FF', '#7C4DFF', 'pages/StatsPage')
        Blank().width(12)
        this.buildLearnCard('🎯', '每日挑战', this.bgAmberLight, '#F5A623', 'pages/DailyChallengePage')
      }

      // 成语图鉴入口（整行）
      Row() {
        this.buildLearnCardFull('📖', '成语图鉴', this.bgTealLight, this.brandColor, 'pages/CollectionPage')
      }
      .margin({ top: 12 })
    }
    .width('100%')
    .margin({ bottom: 16 })
  }

  @Builder
  buildLearnCardFull(icon: string, label: string, bgColor: string, iconColor: string, pageUrl: string) {
    Column() {
      Row() {
        Text(icon)
          .fontSize(22)
          .margin({ right: 12 })
        Text(label)
          .fontSize(14)
          .fontColor(this.textPrimary)
          .fontWeight(FontWeight.Medium)
        Blank()
        Text('→')
          .fontSize(16)
          .fontColor('#CCCCCC')
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding({ top: 16, bottom: 16, left: 20, right: 20 })
    .backgroundColor(bgColor)
    .borderRadius(14)
    .borderWidth(0.5)
    .borderColor(this.borderColor)
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      navigateTo(pageUrl);
    })
  }

  @Builder
  buildLearnCard(icon: string, label: string, bgColor: string, iconColor: string, pageUrl: string) {
    Column() {
      Text(icon)
        .fontSize(26)
        .margin({ bottom: 8 })
      Text(label)
        .fontSize(12)
        .fontColor(this.textPrimary)
        .fontWeight(FontWeight.Medium)
    }
    .width('48%')
    .padding({ top: 20, bottom: 16 })
    .backgroundColor(bgColor)
    .borderRadius(14)
    .borderWidth(0.5)
    .borderColor(this.borderColor)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      navigateTo(pageUrl);
    })
  }

  // 每日挑战卡片
  @Builder
  buildDailyChallengeCard() {
    Button() {
      Row() {
        Column() {
          Text('📅 每日挑战')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.textPrimary)
            .width('100%')
          Text('每天5题，坚持打卡赢成就')
            .fontSize(11)
            .fontColor(this.textSecondary)
            .margin({ top: 2 })
            .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text('→')
          .fontSize(16)
          .fontColor('#CCCCCC')
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(68)
    .backgroundColor(this.bgAmberLight)
    .borderRadius(12)
    .borderWidth(0.5)
    .borderColor(this.borderColor)
    .onClick(() => {
      navigateTo('pages/DailyChallengePage');
    })
  }

  // ========================
  // Tab 3: 个人中心
  // ========================
  @Builder
  buildProfileTab() {
    Scroll() {
      Column() {
        this.buildSectionTitle('我的数据')
        this.buildStatsCard()

        this.buildSectionTitle('更多')
        this.buildProfileMenu()

        Blank()
          .height(40)
      }
      .width('100%')
      .padding({ left: 20, right: 20 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  // 统计卡片（大数字设计）
  @Builder
  buildStatsCard() {
    Row() {
      // 最高分
      Column() {
        Column() {
          Text(this.highScore.toString())
            .fontSize(42)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.brandColor)
        }
        .width(72)
        .height(72)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.bgOrangeLight)
        .borderRadius(36)
        .margin({ bottom: 8 })

        Text('最高分')
          .fontSize(12)
          .fontColor(this.textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)

      Divider()
        .vertical(true)
        .strokeWidth(0.5)
        .color('#EEEEEE')
        .height(60)
        .margin({ left: 12, right: 12 })

      // 游戏次数
      Column() {
        Column() {
          Text(this.totalGames.toString())
            .fontSize(42)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.brandColor)
        }
        .width(72)
        .height(72)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.bgTealLight)
        .borderRadius(36)
        .margin({ bottom: 8 })

        Text('游戏次数')
          .fontSize(12)
          .fontColor(this.textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .padding({ top: 24, bottom: 24 })
    .backgroundColor(this.bgCard)
    .borderRadius(14)
    .borderWidth(0.5)
    .borderColor(this.borderColor)
    .margin({ bottom: 16 })
  }

  // 菜单列表
  @Builder
  buildProfileMenu() {
    Column() {
      this.buildMenuRow('🏆', '我的成就', 'pages/AchievementPage')
      Divider().color('#F5F5F5').strokeWidth(0.5)
      this.buildMenuRow('🎨', '主题切换', 'pages/ThemePage')
      Divider().color('#F5F5F5').strokeWidth(0.5)
      this.buildMenuRow('📊', '数据统计', 'pages/StatsPage')
      Divider().color('#F5F5F5').strokeWidth(0.5)
      this.buildMenuRow('❓', '游戏帮助', 'pages/HelpPage')
      Divider().color('#F5F5F5').strokeWidth(0.5)
      this.buildMenuRow('📄', '关于游戏', 'pages/AboutPage')
    }
    .width('100%')
    .backgroundColor(this.bgCard)
    .borderRadius(14)
    .borderWidth(0.5)
    .borderColor(this.borderColor)
  }

  @Builder
  buildMenuRow(icon: string, title: string, pageUrl: string) {
    Button() {
      Row() {
        Text(icon)
          .fontSize(18)
          .margin({ right: 14 })

        Text(title)
          .fontSize(15)
          .fontColor(this.textPrimary)
          .layoutWeight(1)
          .fontWeight(FontWeight.Medium)

        Text('→')
          .fontSize(16)
          .fontColor('#CCCCCC')
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .height(52)
    .backgroundColor(Color.Transparent)
    .borderRadius(0)
    .onClick(() => {
      navigateTo(pageUrl);
    })
  }

  // ========================
  // 开始游戏
  // ========================
  async startGame(mode: string) {
    try {
      await this.gameViewModel.initGame(mode, this.selectedDifficulty, this.selectedCategory);
      const paramsMap: Record<string, Object> = {};
      paramsMap['mode'] = mode;
      paramsMap['difficulty'] = this.selectedDifficulty;
      paramsMap['category'] = this.selectedCategory;
      replaceToWithParams('pages/GamePage', paramsMap);
    } catch (error) {
      console.error('Failed to start game:', error);
    }
  }
}
