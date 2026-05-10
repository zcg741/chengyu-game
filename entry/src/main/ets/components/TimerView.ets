// TimerView.ets - 计时器显示组件
@Component
export struct TimerView {
  @Prop remainingTime: number = 60;
  @Prop totalTime: number = 60;
  
  private get progress(): number {
    return this.remainingTime / this.totalTime;
  }
  
  private get timerColor(): string {
    if (this.remainingTime <= 10) {
      return '#FF6B35'; // 红色警告
    } else if (this.remainingTime <= 30) {
      return '#FFA726'; // 橙色提醒
    }
    return '#4ECDC4'; // 绿色正常
  }
  
  build() {
    Column() {
      // 圆形进度条（简化版使用Row模拟）
      Stack() {
        // 背景圆
        Circle({ width: 80, height: 80 })
          .fill('#F0F0F0');
        
        // 进度文字
        Text(this.remainingTime.toString())
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.timerColor);
      }
      .width(80)
      .height(80)
      .margin({ bottom: 8 });
      
      Text('剩余时间')
        .fontSize(12)
        .fontColor('#999999');
    }
    .alignItems(HorizontalAlign.Center);
  }
}
