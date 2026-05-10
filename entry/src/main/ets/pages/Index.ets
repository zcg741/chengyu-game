// Index.ets - 应用入口页，重定向到首页
import { replaceTo } from '../utils/NavUtil';

@Entry
@Component
struct Index {
  aboutToAppear() {
    // 延迟一下确保页面加载完成
    setTimeout(() => {
      replaceTo('pages/HomePage');
    }, 100);
  }
  
  build() {
    Column() {
      Text('加载中...')
        .fontSize(20)
        .fontColor('#999999');
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#F5F5F5');
  }
}
