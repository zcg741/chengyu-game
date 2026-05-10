// MedalView.ets - 通关勋章展示组件
@Component
export struct MedalView {
  @Prop level: number = 1;
  @Prop isUnlocked: boolean = false;
  @Prop medalName: string = '';
  
  private get medalEmoji(): string {
    if (!this.isUnlocked) {
      return '🔒';
    }
    switch (this.level) {
      case 1: return '🥉';
      case 2: return '🥈';
      case 3: return '🥇';
      case 4: return '👑';
      default: return '⭐';
    }
  }
  
  private get medalColor(): string {
    if (!this.isUnlocked) {
      return '#CCCCCC';
    }
    switch (this.level) {
      case 1: return '#CD7F32';
      case 2: return '#C0C0C0';
      case 3: return '#FFD700';
      case 4: return '#FF6B35';
      default: return '#4ECDC4';
    }
  }
  
  build() {
    Column() {
      // 勋章图标
      Text(this.medalEmoji)
        .fontSize(40)
        .margin({ bottom: 8 });
      
      // 关卡名称
      Text(this.medalName || `第${this.level}关`)
        .fontSize(14)
        .fontColor(this.isUnlocked ? this.medalColor : '#CCCCCC')
        .fontWeight(this.isUnlocked ? FontWeight.Bold : FontWeight.Normal);
    }
    .padding(12)
    .backgroundColor(this.isUnlocked ? '#FFF9F0' : '#F5F5F5')
    .borderRadius(12)
    .border({ width: 2, color: this.isUnlocked ? this.medalColor : '#E0E0E0' })
    .opacity(this.isUnlocked ? 1 : 0.5);
  }
}
