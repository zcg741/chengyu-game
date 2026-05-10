// AboutPage.ets - 关于游戏
import { replaceTo } from '../utils/NavUtil';

const BRAND_ORANGE: string = '#E85D26';
const BG_PAGE: string = '#FAFAF7';
const TEXT_PRIMARY: string = '#2C2C2C';
const TEXT_SECONDARY: string = '#888888';
const BORDER_COLOR: string = '#E8E6E1';

@Entry
@Component
struct AboutPage {
  private readonly features: string[] = [
    '🎮 两种游戏模式：计时挑战 vs 闯关模式',
    '📚 丰富的成语词库，涵盖多个分类',
    '🏆 成就系统，激励持续学习',
    '📊 数据统计，追踪学习进度',
    '📝 错题本，巩固薄弱环节',
    '💡 智能提示，学习成语拼音',
    '📅 每日挑战，养成学习习惯',
    '🔊 音效反馈，提升游戏体验',
  ];

  build() {
    Column() {
      // 顶部导航
      Row() {
        Button({ type: ButtonType.Normal }) {
          Text('←')
            .fontSize(18)
            .fontColor(TEXT_PRIMARY);
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.White)
        .borderRadius(20)
        .borderWidth(0.5)
        .borderColor(BORDER_COLOR)
        .onClick(() => {
          replaceTo('pages/HomePage');
        });

        Text('关于妙语成语')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor(TEXT_PRIMARY)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 40 });
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 12 })
      .backgroundColor(Color.White);

      Divider()
        .color('#EEEEEE')
        .strokeWidth(0.5);

      Scroll() {
        Column() {
          // App 图标区域
          Column() {
            Text('🀄')
              .fontSize(56)
              .margin({ bottom: 12 });

            Text('妙语成语')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(BRAND_ORANGE);

            Text('Miaoyu Chengyu')
              .fontSize(12)
              .fontColor(TEXT_SECONDARY)
              .margin({ top: 4 });

            Text('版本 1.0.0')
              .fontSize(12)
              .fontColor(TEXT_SECONDARY)
              .margin({ top: 8 })
              .padding({ left: 12, right: 12, top: 4, bottom: 4 })
              .backgroundColor('#F5F5F5')
              .borderRadius(10);
          }
          .width('100%')
          .padding({ top: 40, bottom: 32 })
          .alignItems(HorizontalAlign.Center);

          // 游戏介绍
          Column() {
            this.buildSectionTitle('游戏介绍');
            Text('妙语成语是一款寓教于乐的 HarmonyOS 原生成语学习应用。通过游戏化的答题方式，帮助用户在趣味中掌握中华成语文化。')
              .fontSize(14)
              .fontColor(TEXT_PRIMARY)
              .lineHeight(22)
              .textAlign(TextAlign.Start)
              .width('100%');
          }
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 24 });

          // 功能特点
          Column() {
            this.buildSectionTitle('功能特点');
            Column() {
              ForEach(this.features, (item: string) => {
                Text(item)
                  .fontSize(14)
                  .fontColor(TEXT_PRIMARY)
                  .lineHeight(28)
                  .width('100%');
              });
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
            .backgroundColor(Color.White)
            .borderRadius(12)
            .borderWidth(0.5)
            .borderColor(BORDER_COLOR);
          }
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 24 });

          // 技术信息
          Column() {
            this.buildSectionTitle('技术信息');
            Column() {
              this.buildInfoRow('开发框架', 'ArkTS + ArkUI');
              Divider().color('#F5F5F5').strokeWidth(0.5);
              this.buildInfoRow('运行平台', 'HarmonyOS NEXT');
              Divider().color('#F5F5F5').strokeWidth(0.5);
              this.buildInfoRow('数据来源', '本地成语词库');
              Divider().color('#F5F5F5').strokeWidth(0.5);
              this.buildInfoRow('隐私说明', '纯离线，无数据收集');
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 6, bottom: 6 })
            .backgroundColor(Color.White)
            .borderRadius(12)
            .borderWidth(0.5)
            .borderColor(BORDER_COLOR);
          }
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 32 });

          Text('© 2026 妙语成语 · 纯离线游戏')
            .fontSize(11)
            .fontColor('#BBBBBB')
            .margin({ bottom: 40 });
        }
        .width('100%');
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor(BG_PAGE);
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG_PAGE)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder
  buildSectionTitle(title: string) {
    Row() {
      Divider()
        .vertical(true)
        .strokeWidth(3)
        .color(BRAND_ORANGE)
        .height(16)
        .margin({ right: 8 });
      Text(title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(TEXT_PRIMARY);
    }
    .margin({ bottom: 14 })
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  buildInfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor(TEXT_SECONDARY)
        .width(90);
      Text(value)
        .fontSize(14)
        .fontColor(TEXT_PRIMARY)
        .layoutWeight(1);
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .alignItems(VerticalAlign.Center);
  }
}
