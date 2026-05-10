// AnswerInput.ets - 答案输入组件
@Component
export struct AnswerInput {
  @Prop answer: string = '';
  @Prop placeholder: string = '请输入成语';
  @Prop disabled: boolean = false;
  private onSubmit: () => void = () => {};
  private onTextChange: (text: string) => void = () => {};
  
  build() {
    Row() {
      // 输入框
      TextInput({ placeholder: this.placeholder, text: this.answer })
        .width('70%')
        .height(48)
        .backgroundColor(this.disabled ? '#F5F5F5' : Color.White)
        .borderRadius(24)
        .padding({ left: 20, right: 20 })
        .enabled(!this.disabled)
        .onChange((value: string) => {
          this.onTextChange(value);
        })
        .margin({ right: 12 });
      
      // 提交按钮
      Button('确定')
        .width(80)
        .height(48)
        .backgroundColor(this.disabled ? '#CCCCCC' : '#FF6B35')
        .borderRadius(24)
        .enabled(!this.disabled)
        .onClick(() => {
          if (!this.disabled) {
            this.onSubmit();
          }
        });
    }
    .width('100%')
    .justifyContent(FlexAlign.Center);
  }
}
