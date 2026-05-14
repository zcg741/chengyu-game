// WrongBookPage.ets - 错题本页面（精致设计版）
import { getChengyuByDifficulty, loadChengyuData } from '../service/ChengyuService';
import { Chengyu } from '../model/ChengyuModel';
import { navigateBack, navigateToWithParams } from '../utils/NavUtil';
import { clearWrongBook, getWrongBookRecords, recordReviewResult, WrongBookRecord } from '../service/WrongBookService';

const BG_PAGE: string = '#FAFAF7';
const BG_CARD: string = '#FFFFFF';
const BORDER_COLOR: string = '#E8E6E1';
const TEXT_PRIMARY: string = '#2C2C2C';
const TEXT_SECONDARY: string = '#888888';
const BRAND_ORANGE: string = '#E85D26';

@Entry
@Component
struct WrongBookPage {
  @State wrongChengyuList: Chengyu[] = [];
  @State wrongRecords: WrongBookRecord[] = [];
  @State showAnswer: string = '';
  @State showMastered: boolean = false;
  @State pendingCount: number = 0;
  @State masteredCount: number = 0;

  async aboutToAppear() {
    await this.loadWrongWords();
  }

  async loadWrongWords() {
    await loadChengyuData(0, '全部');
    this.wrongRecords = await getWrongBookRecords(this.showMastered);
    const allRecords = await getWrongBookRecords(true);
    this.masteredCount = allRecords.filter(record => record.mastered).length;
    this.pendingCount = allRecords.length - this.masteredCount;

    const wrongWords = this.wrongRecords.map(record => record.word);
    const allChengyu = getChengyuByDifficulty(0, '全部');
    this.wrongChengyuList = allChengyu.filter(c => wrongWords.includes(c.word));
  }

  async clearWrongBook() {
    this.wrongRecords = [];
    this.wrongChengyuList = [];
    this.pendingCount = 0;
    this.masteredCount = 0;
    await clearWrongBook();
  }

  getRecord(word: string): WrongBookRecord | undefined {
    return this.wrongRecords.find(record => record.word === word);
  }

  async markReview(item: Chengyu, isCorrect: boolean) {
    await recordReviewResult(item.word, isCorrect);
    await this.loadWrongWords();
  }

  getReviewStatusText(word: string): string {
    const record = this.getRecord(word);
    if (record && record.mastered) {
      return '已掌握';
    }
    return `错 ${record ? record.wrongCount : 1} 次 · 连对 ${record ? record.reviewCorrectStreak : 0}/3`;
  }

  getReviewStatusColor(word: string): string {
    const record = this.getRecord(word);
    return record && record.mastered ? '#2E7D32' : TEXT_SECONDARY;
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
      Row() {
        Text(`待复习 ${this.pendingCount}`)
          .fontSize(12)
          .fontColor(BRAND_ORANGE)
        Text(`已掌握 ${this.masteredCount}`)
          .fontSize(12)
          .fontColor(TEXT_SECONDARY)
          .margin({ left: 12 })
        Blank()
        Text(this.showMastered ? '隐藏已掌握' : '显示已掌握')
          .fontSize(12)
          .fontColor(BRAND_ORANGE)
          .onClick(() => {
            this.showMastered = !this.showMastered;
            this.loadWrongWords();
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 14, bottom: 6 })

      if (this.pendingCount > 0) {
        Button('开始错题复习')
          .width('90%')
          .height(44)
          .fontSize(15)
          .fontColor(Color.White)
          .backgroundColor(BRAND_ORANGE)
          .borderRadius(22)
          .margin({ top: 8, bottom: 8 })
          .alignSelf(ItemAlign.Center)
          .onClick(() => {
            const params: Record<string, Object> = {};
            params['mode'] = 'wrongbook';
            navigateToWithParams('pages/ReviewPage', params);
          })
      }

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

      Row() {
        Text(this.getReviewStatusText(item.word))
          .fontSize(11)
          .fontColor(this.getReviewStatusColor(item.word))
          .layoutWeight(1)

        Button('答对一次')
          .height(28)
          .fontSize(11)
          .fontColor(Color.White)
          .backgroundColor('#2E7D32')
          .borderRadius(14)
          .padding({ left: 10, right: 10 })
          .onClick(() => {
            this.markReview(item, true);
          })

        Button('仍不会')
          .height(28)
          .fontSize(11)
          .fontColor('#D32F2F')
          .backgroundColor('#FDF2F2')
          .borderRadius(14)
          .padding({ left: 10, right: 10 })
          .margin({ left: 8 })
          .onClick(() => {
            this.markReview(item, false);
          })
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
    .padding(14)
    .backgroundColor(BG_CARD)
    .borderRadius(12)
    .borderWidth(0.5)
    .borderColor(BORDER_COLOR)
  }
}
