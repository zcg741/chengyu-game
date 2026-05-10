// LearnPage.ets - 成语学习页面（精致设计版）
import { getCategories, getChengyuByDifficulty } from '../service/ChengyuService';
import { Chengyu } from '../model/ChengyuModel';
import { navigateBack } from '../utils/NavUtil';

const BG_PAGE: string = '#FAFAF7';
const BG_CARD: string = '#FFFFFF';
const BORDER_COLOR: string = '#E8E6E1';
const TEXT_PRIMARY: string = '#2C2C2C';
const TEXT_SECONDARY: string = '#888888';
const BRAND_ORANGE: string = '#E85D26';

@Entry
@Component
struct LearnPage {
  @State categories: string[] = ['全部'];
  @State selectedCategory: string = '全部';
  @State chengyuList: Chengyu[] = [];
  @State expandedId: string = '';

  aboutToAppear() {
    this.categories = getCategories();
    this.loadChengyu();
  }

  loadChengyu() {
    this.chengyuList = getChengyuByDifficulty(0, this.selectedCategory);
  }

  build() {
    Column() {
      // 顶部导航栏
      this.buildHeader()

      // 分类选择（横向滚动）
      Scroll() {
        Row() {
          ForEach(this.categories, (category: string) => {
            Button(category)
              .height(34)
              .backgroundColor(this.selectedCategory === category ? BRAND_ORANGE : BG_CARD)
              .fontColor(this.selectedCategory === category ? Color.White : TEXT_SECONDARY)
              .borderRadius(17)
              .borderWidth(this.selectedCategory === category ? 0 : 0.5)
              .borderColor(BORDER_COLOR)
              .padding({ left: 14, right: 14 })
              .fontSize(13)
              .margin({ right: 8 })
              .onClick(() => {
                this.selectedCategory = category;
                this.loadChengyu();
              })
          })
        }
        .padding({ left: 20, right: 20 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .padding({ top: 12, bottom: 12 })
      .backgroundColor(BG_CARD)

      Divider().color('#EEEEEE').strokeWidth(0.5)

      // 数量提示
      Text(`${this.chengyuList.length} 个成语`)
        .fontSize(12)
        .fontColor(TEXT_SECONDARY)
        .margin({ top: 14, bottom: 6 })
        .padding({ left: 20 })
        .width('100%')

      // 成语列表
      List() {
        ForEach(this.chengyuList, (item: Chengyu) => {
          ListItem() {
            this.buildChengyuCard(item)
          }
          .padding({ left: 20, right: 20, top: 5, bottom: 5 })
        })
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

      Text('成语学习')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(TEXT_PRIMARY)
        .layoutWeight(1)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 14 })
    .backgroundColor(BG_CARD)
  }

  @Builder
  buildChengyuCard(item: Chengyu) {
    Column() {
      // 成语名称 + 难度 + 分类
      Row() {
        Text(item.word)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(TEXT_PRIMARY)
          .layoutWeight(1)

        // 难度星标
        Row({ space: 2 }) {
          ForEach([1, 2, 3], (level: number) => {
            Text('★')
              .fontSize(11)
              .fontColor(level <= item.difficulty ? '#F5A623' : '#E8E6E1')
          })
        }
        .margin({ right: 8 })

        // 分类标签
        Text(item.category)
          .fontSize(10)
          .fontColor(BRAND_ORANGE)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .backgroundColor('#FFF5F0')
          .borderRadius(4)
      }
      .width('100%')
      .margin({ bottom: 6 })

      // 拼音
      Text(item.pinyin)
        .fontSize(12)
        .fontColor(TEXT_SECONDARY)
        .width('100%')
        .margin({ bottom: 4 })

      // 释义
      Text(item.explanation)
        .fontSize(13)
        .fontColor('#555555')
        .lineHeight(20)
        .width('100%')
        .maxLines(this.expandedId === item.word ? 0 : 2)
        .margin({ bottom: this.expandedId === item.word ? 6 : 0 })

      // 展开详情
      if (this.expandedId === item.word && item.source) {
        Row() {
          Text('出处：')
            .fontSize(12)
            .fontColor('#AAAAAA')
            .fontWeight(FontWeight.Medium)
          Text(item.source)
            .fontSize(12)
            .fontColor(TEXT_SECONDARY)
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 6 })
        .border({ width: { top: 0.5 }, color: '#F0F0F0' })
        .padding({ top: 8 })
      }

      // 展开/收起按钮
      Text(this.expandedId === item.word ? '收起 ▲' : '展开详情 ▼')
        .fontSize(11)
        .fontColor(BRAND_ORANGE)
        .margin({ top: 6 })
        .alignSelf(ItemAlign.End)
        .onClick(() => {
          this.expandedId = this.expandedId === item.word ? '' : item.word;
        })
    }
    .width('100%')
    .padding(14)
    .backgroundColor(BG_CARD)
    .borderRadius(12)
    .borderWidth(0.5)
    .borderColor(BORDER_COLOR)
  }
}
