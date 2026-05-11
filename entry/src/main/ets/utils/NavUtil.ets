// NavUtil.ets - 导航工具类（封装 router API）
// 注意：pushUrl/replaceUrl/back/getParams 已弃用，但仍是当前可用 API
// 未来需迁移到 Navigation 组件
import router from '@ohos.router';

/**
 * 导航到指定页面
 */
export function navigateTo(url: string): void {
  try {
    router.pushUrl({ url: url });
  } catch (error) {
    console.error('Navigation failed:', error);
  }
}

/**
 * 导航到指定页面（带参数）
 */
export function navigateToWithParams(url: string, params: Record<string, Object>): void {
  try {
    router.pushUrl({ url: url, params: params });
  } catch (error) {
    console.error('Navigation failed:', error);
  }
}

/**
 * 替换当前页面
 */
export function replaceTo(url: string): void {
  try {
    router.replaceUrl({ url: url });
  } catch (error) {
    console.error('Navigation failed:', error);
  }
}

/**
 * 替换当前页面（带参数）
 */
export function replaceToWithParams(url: string, params: Record<string, Object>): void {
  try {
    router.replaceUrl({ url: url, params: params });
  } catch (error) {
    console.error('Navigation failed:', error);
  }
}

/**
 * 返回上一页
 */
export function navigateBack(): void {
  try {
    router.back();
  } catch (error) {
    console.error('Navigation failed:', error);
  }
}

/**
 * 获取路由参数
 */
export function getRouteParams(): Record<string, Object> {
  try {
    return router.getParams() as Record<string, Object>;
  } catch (error) {
    console.error('Get route params failed:', error);
    return {} as Record<string, Object>;
  }
}
