// ThemePage.ets - 主题切换页面
import { getCurrentTheme, getCurrentThemeId, getThemeList, setTheme } from '../service/ThemeService';
import { Theme } from '../model/ThemeModel';
import { replaceTo } from '../utils/NavUtil';

@Entry
@Component
struct ThemePage {
  @State themes: Theme[] = [];
  @State currentThemeId: string = 'classic';

  aboutToAppear() {
    this.themes = getThemeList();
    this.currentThemeId = getCurrentThemeId();
  }

  build() {
    Column() {
      // 顶部标题栏
      this.buildHeader()

      // 主题列表
      List() {
        ForEach(this.themes, (theme: Theme) => {
          ListItem() {
            this.buildThemeCard(theme)
          }
          .padding({ left: 20, right: 20, bottom: 12 })
        }, (theme: Theme) => theme.id)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(getCurrentTheme().bgPage)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  buildHeader() {
    Row() {
      Button({ type: ButtonType.Normal }) {
        Text('←')
          .fontSize(18)
          .fontColor(getCurrentTheme().textPrimary);
      }
      .width(40)
      .height(40)
      .backgroundColor(getCurrentTheme().bgCard)
      .borderRadius(20)
      .shadow({ radius: 4, color: '#0000000D', offsetX: 0, offsetY: 2 })
      .onClick(() => {
        replaceTo('pages/HomePage');
      });

      Blank()

      Text('主题切换')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(getCurrentTheme().textPrimary);

      Blank()

      Column()
        .width(40)
        .height(40)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 12 })
    .backgroundColor(getCurrentTheme().bgCard)
    .shadow({ radius: 4, color: '#0000000D', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildThemeCard(theme: Theme) {
    Row() {
      // 颜色预览圆点
      Row() {
        Stack() {
          Circle({ width: 24, height: 24 })
            .fill(theme.brand);
          if (this.currentThemeId === theme.id) {
            Text('✓')
              .fontSize(14)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold);
          }
        }
      }
      .margin({ right: 16 })

      // 主题名称
      Column() {
        Text(theme.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(getCurrentTheme().textPrimary);
        Text(theme.id === 'dark' ? '深色护眼' : '浅色清透')
          .fontSize(11)
          .fontColor(getCurrentTheme().textSecondary)
          .margin({ top: 2 });
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 当前选中标记
      if (this.currentThemeId === theme.id) {
        Text('使用中')
          .fontSize(12)
          .fontColor(theme.brand)
          .fontWeight(FontWeight.Medium);
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(getCurrentTheme().bgCard)
    .borderRadius(12)
    .border({ width: this.currentThemeId === theme.id ? 2 : 0.5, color: this.currentThemeId === theme.id ? theme.brand : getCurrentTheme().border })
    .onClick(async () => {
      await setTheme(theme.id);
      this.currentThemeId = theme.id;
    })
  }
}
