// StatsPage.ets - 游戏统计页面（精致设计版）
import { getNumber } from '../service/StorageService';
import { navigateBack } from '../utils/NavUtil';
import { getDailyChallengeAggregate } from '../service/DailyChallengeService';

const BG_PAGE: string = '#FAFAF7';
const BG_CARD: string = '#FFFFFF';
const BORDER_COLOR: string = '#E8E6E1';
const TEXT_PRIMARY: string = '#2C2C2C';
const TEXT_SECONDARY: string = '#888888';

@Entry
@Component
struct StatsPage {
  @State totalGames: number = 0;
  @State totalCorrect: number = 0;
  @State totalWrong: number = 0;
  @State highScore: number = 0;
  @State totalScore: number = 0;
  @State avgScore: string = '0';
  @State accuracy: string = '0';
  @StorageProp('status_bar_height') statusBarHeight: number = 0;

  async aboutToAppear() {
    const storedGames = await getNumber('total_games', 0);
    const achievementGames = Math.max(
      await getNumber('achievement_play_10_games_progress', 0),
      await getNumber('achievement_first_game_progress', 0)
    );
    this.totalGames = Math.max(storedGames, achievementGames);

    const achievementCorrect = Math.max(
      await getNumber('achievement_correct_50_progress', 0),
      await getNumber('achievement_correct_100_progress', 0)
    );
    this.totalCorrect = Math.max(await getNumber('total_correct', 0), achievementCorrect);
    this.totalWrong = await getNumber('total_wrong', 0);

    const dailyStats = await getDailyChallengeAggregate();
    this.totalGames += dailyStats.games;
    this.totalCorrect += dailyStats.correct;
    this.totalWrong += dailyStats.wrong;
    this.highScore = await getNumber('high_score', 0);
    this.totalScore = Math.max(await getNumber('total_score', 0), await getNumber('achievement_total_score_1000_progress', 0));

    const total = this.totalCorrect + this.totalWrong;
    this.accuracy = total > 0 ? ((this.totalCorrect / total) * 100).toFixed(1) : '0';
    this.avgScore = this.totalGames > 0 ? (this.totalScore / this.totalGames).toFixed(0) : '0';
  }

  build() {
    Column() {
      this.buildHeader()

      Scroll() {
        Column() {
          // 核心数据卡片
          this.buildCoreStatsCard()
          // 等级评估卡片
          this.buildLevelCard()
          // 提升指南卡片
          this.buildTipsCard()
          Blank().height(32)
        }
        .alignItems(HorizontalAlign.Center)
        .width('100%')
        .padding({ left: 20, right: 20 })
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG_PAGE)
  }

  @Builder
  buildHeader() {
    Row() {
      Text('←')
        .fontSize(22)
        .fontColor(TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .margin({ right: 12 })
        .onClick(() => { navigateBack(); })

      Text('游戏统计')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(TEXT_PRIMARY)
        .layoutWeight(1)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: this.statusBarHeight + 10, bottom: 14 })
    .backgroundColor(BG_CARD)
  }

  @Builder
  buildCoreStatsCard() {
    Column() {
      Text('核心数据')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(TEXT_PRIMARY)
        .width('100%')
        .margin({ bottom: 14 })

      Row() {
        this.buildStatItem('🎮', '总场次', this.totalGames.toString(), '#E85D26')
        this.buildStatItem('✅', '答对', this.totalCorrect.toString(), '#3BB18E')
        this.buildStatItem('❌', '答错', this.totalWrong.toString(), '#C0392B')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .margin({ bottom: 14 })

      Row() {
        this.buildStatItem('🏆', '最高分', this.highScore.toString(), '#F5A623')
        this.buildStatItem('📊', '平均分', this.avgScore, '#7C4DFF')
        this.buildStatItem('🎯', '正确率', `${this.accuracy}%`, '#3BB18E')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .padding(18)
    .backgroundColor(BG_CARD)
    .borderRadius(14)
    .borderWidth(0.5)
    .borderColor(BORDER_COLOR)
    .margin({ top: 16, bottom: 12 })
  }

  @Builder
  buildStatItem(icon: string, label: string, value: string, color: string) {
    Column() {
      Text(icon)
        .fontSize(22)
        .margin({ bottom: 4 })
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
        .margin({ bottom: 2 })
      Text(label)
        .fontSize(11)
        .fontColor(TEXT_SECONDARY)
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildLevelCard() {
    Column() {
      Text('等级评估')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(TEXT_PRIMARY)
        .width('100%')
        .margin({ bottom: 10 })

      Row() {
        Text(this.getLevelName())
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getLevelColor())
        Text(this.getLevelDesc())
          .fontSize(12)
          .fontColor(TEXT_SECONDARY)
          .margin({ left: 8 })
      }
      .margin({ bottom: 10 })

      Progress({ value: this.totalGames, total: this.getNextLevelTarget(), type: ProgressType.Linear })
        .width('100%')
        .height(6)
        .color(this.getLevelColor())
        .backgroundColor('#F0F0F0')
        .borderRadius(3)

      Row() {
        Text(`已玩 ${this.totalGames} 局`)
          .fontSize(10)
          .fontColor('#AAAAAA')
        Text(`下一等级: ${this.getNextLevelTarget()} 局`)
          .fontSize(10)
          .fontColor('#AAAAAA')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 4 })
    }
    .width('100%')
    .padding(18)
    .backgroundColor(BG_CARD)
    .borderRadius(14)
    .borderWidth(0.5)
    .borderColor(BORDER_COLOR)
    .margin({ bottom: 12 })
  }

  @Builder
  buildTipsCard() {
    Column() {
      Text('提升指南')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(TEXT_PRIMARY)
        .width('100%')
        .margin({ bottom: 10 })

      this.buildTipItem('📚', '多看成语故事', '了解成语的典故和来源，更容易记忆')
      this.buildTipItem('🔍', '关注拼音首字母', '利用拼音首字母提示快速缩小范围')
      this.buildTipItem('📝', '反复练习错题', '在错题本中复习，避免重复犯错')
      this.buildTipItem('⏱️', '计时模式提速度', '提高答题速度，争取更多分数')
    }
    .width('100%')
    .padding(18)
    .backgroundColor(BG_CARD)
    .borderRadius(14)
    .borderWidth(0.5)
    .borderColor(BORDER_COLOR)
  }

  @Builder
  buildTipItem(icon: string, title: string, desc: string) {
    Row() {
      Text(icon)
        .fontSize(20)
        .margin({ right: 10 })

      Column() {
        Text(title)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(TEXT_PRIMARY)
          .margin({ bottom: 1 })
        Text(desc)
          .fontSize(11)
          .fontColor(TEXT_SECONDARY)
          .lineHeight(16)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 6, bottom: 6 })
  }

  getLevelName(): string {
    if (this.totalGames >= 50) return '🏆 成语大师';
    if (this.totalGames >= 30) return '🥇 成语达人';
    if (this.totalGames >= 15) return '🥈 成语爱好者';
    if (this.totalGames >= 5) return '🥉 成语学徒';
    return '📚 成语新手';
  }

  getLevelColor(): string {
    if (this.totalGames >= 50) return '#FFD700';
    if (this.totalGames >= 30) return '#E85D26';
    if (this.totalGames >= 15) return '#3BB18E';
    if (this.totalGames >= 5) return '#CD7F32';
    return '#AAAAAA';
  }

  getLevelDesc(): string {
    if (this.totalGames >= 50) return '最高等级！';
    if (this.totalGames >= 30) return '实力不凡！';
    if (this.totalGames >= 15) return '继续努力！';
    if (this.totalGames >= 5) return '初窥门径！';
    return '加油！';
  }

  getNextLevelTarget(): number {
    if (this.totalGames >= 50) return 50;
    if (this.totalGames >= 30) return 50;
    if (this.totalGames >= 15) return 30;
    if (this.totalGames >= 5) return 15;
    return 5;
  }
}
