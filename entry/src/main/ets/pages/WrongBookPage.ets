// WrongBookPage.ets - 错题本页面（精致设计版）
import { getNumber, saveNumber, getString, saveString } from '../service/StorageService';
import { getChengyuByDifficulty } from '../service/ChengyuService';
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
struct WrongBookPage {
  @State wrongWords: string[] = [];
  @State wrongChengyuList: Chengyu[] = [];
  @State showAnswer: string = '';

  async aboutToAppear() {
    await this.loadWrongWords();
  }

  async loadWrongWords() {
    const wrongStr = await getString('wrong_words', '');
    if (wrongStr) {
      this.wrongWords = wrongStr.split(',').filter(w => w.length > 0);
    }
    const allChengyu = getChengyuByDifficulty(0, '全部');
    this.wrongChengyuList = allChengyu.filter(c => this.wrongWords.includes(c.word));
  }

  async clearWrongBook() {
    this.wrongWords = [];
    this.wrongChengyuList = [];
    await saveString('wrong_words', '');
  }

  build() {
    Column() {
      // 顶部导航栏
      this.buildHeader()

      if (this.wrongChengyuList.length === 0) {
        this.buildEmptyState()
      } else {
        this.buildWrongList()
      }
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

      Text('错题本')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(TEXT_PRIMARY)
        .layoutWeight(1)

      if (this.wrongChengyuList.length > 0) {
        Text('清空')
          .fontSize(13)
          .fontColor('#C0392B')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor('#FDF2F2')
          .borderRadius(8)
          .onClick(() => { this.clearWrongBook(); })
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 14 })
    .backgroundColor(BG_CARD)
  }

  @Builder
  buildEmptyState() {
    Column() {
      Text('📝')
        .fontSize(50)
        .margin({ bottom: 14 })
      Text('还没有错题')
        .fontSize(16)
        .fontColor(TEXT_PRIMARY)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 6 })
      Text('答题时答错的成语会自动收录到这里')
        .fontSize(13)
        .fontColor(TEXT_SECONDARY)
        .textAlign(TextAlign.Center)
        .width('70%')
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildWrongList() {
    Column() {
      Text(`${this.wrongChengyuList.length} 个错题`)
        .fontSize(12)
        .fontColor(TEXT_SECONDARY)
        .margin({ top: 14, bottom: 6 })
        .padding({ left: 20 })
        .width('100%')

      List() {
        ForEach(this.wrongChengyuList, (item: Chengyu) => {
          ListItem() {
            this.buildWrongCard(item)
          }
          .padding({ left: 20, right: 20, top: 5, bottom: 5 })
        })
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
    }
  }

  @Builder
  buildWrongCard(item: Chengyu) {
    Column() {
      Row() {
        Column() {
          Text(item.word)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(TEXT_PRIMARY)
          Text(item.pinyin)
            .fontSize(12)
            .fontColor(TEXT_SECONDARY)
            .margin({ top: 3 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(this.showAnswer === item.word ? item.explanation : '点击查看释义')
          .fontSize(12)
          .fontColor(this.showAnswer === item.word ? '#555555' : BRAND_ORANGE)
          .maxLines(2)
          .textAlign(TextAlign.End)
          .width('50%')
          .onClick(() => {
            this.showAnswer = this.showAnswer === item.word ? '' : item.word;
          })
      }
      .width('100%')

      if (this.showAnswer === item.word && item.source) {
        Text(`出处：${item.source}`)
          .fontSize(11)
          .fontColor('#AAAAAA')
          .margin({ top: 6 })
          .width('100%')
          .border({ width: { top: 0.5 }, color: '#F0F0F0' })
          .padding({ top: 6 })
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor(BG_CARD)
    .borderRadius(12)
    .borderWidth(0.5)
    .borderColor(BORDER_COLOR)
  }
}
