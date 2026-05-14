// AchievementPage.ets - 成就展示页面（精致设计版）
import { navigateBack } from '../utils/NavUtil';
import { getBoolean, getNumber } from '../service/StorageService';
import { getAllAchievements } from '../service/AchievementService';
import { Achievement, AchievementLevel } from '../model/AchievementModel';

const BG_PAGE: string = '#FAFAF7';
const BG_CARD: string = '#FFFFFF';
const BORDER_COLOR: string = '#E8E6E1';
const TEXT_PRIMARY: string = '#2C2C2C';
const TEXT_SECONDARY: string = '#888888';

const ACHIEVEMENTS: Achievement[] = getAllAchievements();

@Entry
@Component
struct AchievementPage {
  @State unlockedMap: Map<string, boolean> = new Map();
  @State progressMap: Map<string, number> = new Map();
  @State unlockedCount: number = 0;

  async aboutToAppear() {
    await this.loadProgress();
  }

  async loadProgress() {
    let count = 0;
    for (const ach of ACHIEVEMENTS) {
      const key = `achievement_${ach.id}`;
      const isUnlocked = await getBoolean(`${key}_unlocked`, false);
      const progress = await getNumber(`${key}_progress`, 0);
      this.unlockedMap.set(ach.id, isUnlocked);
      this.progressMap.set(ach.id, progress);
      if (isUnlocked) { count++; }
    }
    this.unlockedCount = count;
  }

  build() {
    Column() {
      this.buildHeader()
      this.buildProgressBar()
      this.buildAchievementList()
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

      Text('成就系统')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(TEXT_PRIMARY)
        .layoutWeight(1)

      Text(`${this.unlockedCount}/${ACHIEVEMENTS.length}`)
        .fontSize(13)
        .fontColor('#E85D26')
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .backgroundColor('#FFF5F0')
        .borderRadius(10)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 14 })
    .backgroundColor(BG_CARD)
  }

  @Builder
  buildProgressBar() {
    Column() {
      Progress({ value: this.unlockedCount, total: ACHIEVEMENTS.length, type: ProgressType.Linear })
        .width('100%')
        .height(4)
        .color('#E85D26')
        .backgroundColor('#F0F0F0')
        .margin({ bottom: 4 })

      Row() {
        Text(`已解锁 ${this.unlockedCount} 个成就`)
          .fontSize(11)
          .fontColor(TEXT_SECONDARY)
        Blank()
        Text(`共 ${ACHIEVEMENTS.length} 个`)
          .fontSize(11)
          .fontColor('#AAAAAA')
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 12, bottom: 12 })
    .backgroundColor(BG_CARD)
    .border({ width: { bottom: 0.5 }, color: '#EEEEEE' })
  }

  @Builder
  buildAchievementList() {
    List() {
      ForEach(ACHIEVEMENTS, (ach: Achievement) => {
        ListItem() {
          AchievementCard({
            ach: ach,
            isUnlocked: this.unlockedMap.get(ach.id) || false,
            progress: this.progressMap.get(ach.id) || 0
          })
        }
        .padding({ left: 20, right: 20, top: 5, bottom: 5 })
      })
    }
    .layoutWeight(1)
    .width('100%')
    .scrollBar(BarState.Off)
  }

  getLevelText(level: AchievementLevel): string {
    switch (level) {
      case AchievementLevel.BRONZE: return '铜牌';
      case AchievementLevel.SILVER: return '银牌';
      case AchievementLevel.GOLD: return '金牌';
      case AchievementLevel.DIAMOND: return '钻石';
      default: return '';
    }
  }

  getLevelColor(level: AchievementLevel): string {
    switch (level) {
      case AchievementLevel.BRONZE: return '#CD7F32';
      case AchievementLevel.SILVER: return '#78909C';
      case AchievementLevel.GOLD: return '#FFA000';
      case AchievementLevel.DIAMOND: return '#0097A7';
      default: return '#888888';
    }
  }
}

@Component
struct AchievementCard {
  @Prop ach: Achievement;
  @Prop isUnlocked: boolean;
  @Prop progress: number;

  build() {
    Row() {
      // 图标
      Text(this.ach.icon)
        .fontSize(22)
        .width(44)
        .height(44)
        .textAlign(TextAlign.Center)
        .backgroundColor(this.isUnlocked ? this.getLevelColor(this.ach.level) + '18' : '#F0F0F0')
        .borderRadius(22)
        .opacity(this.isUnlocked ? 1 : 0.5)

      // 信息
      Column() {
        Row() {
          Text(this.ach.name)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.isUnlocked ? TEXT_PRIMARY : '#AAAAAA')

          if (this.isUnlocked) {
            Text(this.getLevelText(this.ach.level))
              .fontSize(9)
              .fontColor(this.getLevelColor(this.ach.level))
              .margin({ left: 6 })
              .padding({ left: 5, right: 5, top: 1, bottom: 1 })
              .backgroundColor(this.getLevelColor(this.ach.level) + '15')
              .borderRadius(3)
          }
        }

        Text(this.ach.description)
          .fontSize(11)
          .fontColor('#999999')
          .margin({ top: 2 })

        if (!this.isUnlocked) {
          Row() {
            Progress({ value: this.progress, total: this.ach.condition.target, type: ProgressType.Linear })
              .layoutWeight(1)
              .height(3)
              .color('#E85D26')
              .backgroundColor('#E0E0E0')
            Text(`${this.progress}/${this.ach.condition.target}`)
              .fontSize(9)
              .fontColor('#999999')
              .margin({ left: 6 })
          }
          .margin({ top: 6 })
        }

        Text(`奖励：${this.ach.reward} 积分`)
          .fontSize(9)
          .fontColor(this.isUnlocked ? '#C0392B' : '#BBBBBB')
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 10 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(BG_CARD)
    .borderRadius(12)
    .borderWidth(0.5)
    .borderColor(this.isUnlocked ? BORDER_COLOR : '#EEEEEE')
    .opacity(this.isUnlocked ? 1 : 0.75)
  }

  getLevelText(level: AchievementLevel): string {
    switch (level) {
      case AchievementLevel.BRONZE: return '铜牌';
      case AchievementLevel.SILVER: return '银牌';
      case AchievementLevel.GOLD: return '金牌';
      case AchievementLevel.DIAMOND: return '钻石';
      default: return '';
    }
  }

  getLevelColor(level: AchievementLevel): string {
    switch (level) {
      case AchievementLevel.BRONZE: return '#CD7F32';
      case AchievementLevel.SILVER: return '#78909C';
      case AchievementLevel.GOLD: return '#FFA000';
      case AchievementLevel.DIAMOND: return '#0097A7';
      default: return '#888888';
    }
  }
}
