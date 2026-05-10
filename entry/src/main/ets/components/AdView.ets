// AdView.ets - 广告组件（占位实现）
// 注意：HarmonyOS NEXT 不支持 @ohos.ads 模块，使用占位组件

@Component
export struct AdView {
  @State adLoaded: boolean = false;
  
  aboutToAppear() {
    // 占位实现 - 不加载广告
    console.log('AdView: 广告功能暂不可用');
  }
  
  aboutToDisappear() {
    // 占位实现
  }
  
  build() {
    Column() {
      // 不显示任何广告内容
      Text('')
        .height(0);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center);
  }
}
