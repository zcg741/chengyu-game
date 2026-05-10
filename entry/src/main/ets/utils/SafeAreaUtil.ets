// SafeAreaUtil.ets - 安全区域工具类

/**
 * 获取导航条高度（vp）
 * 从AppStorage获取，默认28vp
 */
export function getNavigationBarHeight(): number {
  return AppStorage.get<number>('navigation_bar_height') || 28;
}

/**
 * 获取状态栏高度（vp）
 * 从AppStorage获取，默认0
 */
export function getStatusBarHeight(): number {
  return AppStorage.get<number>('status_bar_height') || 0;
}
