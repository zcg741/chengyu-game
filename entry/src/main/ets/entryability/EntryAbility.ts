// EntryAbility.ts - 应用入口Ability
import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import display from '@ohos.display';
import { setAppContext } from '../utils/ContextManager';

export default class EntryAbility extends UIAbility {
  onCreate() {
    // 保存context到ContextManager
    setAppContext(this.context);
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    // 设置全屏并适配导航条
    windowStage.getMainWindow().then((win: window.Window) => {
      // 设置全屏布局（状态栏和导航条覆盖在内容上）
      win.setWindowLayoutFullScreen(true);

      // 获取状态栏和导航条高度，设置避让
      const avoidArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      const navigationBarArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);

      // 设置主窗口内容避让导航条
      // 获取屏幕密度用于 px→vp 转换
      let densityDPI = 160;
      try {
        densityDPI = display.getDefaultDisplaySync().densityDPI;
      } catch (e) {
        console.warn('Failed to get display info, using default DPI: ' + e);
      }

      if (navigationBarArea.bottomRect.height > 0) {
        const bottomHeight = navigationBarArea.bottomRect.height;
        const bottomHeightVp = bottomHeight * 160 / densityDPI;
        AppStorage.setOrCreate('navigation_bar_height', bottomHeightVp);
      }

      if (avoidArea.topRect.height > 0) {
        const topHeight = avoidArea.topRect.height;
        const topHeightVp = topHeight * 160 / densityDPI;
        AppStorage.setOrCreate('status_bar_height', topHeightVp);
      }
    }).catch((err: Error) => {
      console.error('Failed to get main window: ' + JSON.stringify(err));
    });

    // 加载首页
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        console.error('Failed to load the content. Cause:' + JSON.stringify(err));
        return;
      }
      console.info('Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy() {
    // 页面销毁
  }

  onForeground() {
    // 进入前台
  }

  onBackground() {
    // 进入后台
  }
}
