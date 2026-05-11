// NavUtil.ets - 导航工具类（封装 router API）
import { router } from '@kit.ArkUI';

/**
 * 导航到指定页面
 */
export function navigateTo(url: string): void {
  try {
    router.push({ url: url });
  } catch (error) {
    console.error('Navigation failed:', error);
  }
}

/**
 * 导航到指定页面（带参数）
 */
export function navigateToWithParams(url: string, params: Record<string, Object>): void {
  try {
    router.push({ url: url, params: params });
  } catch (error) {
    console.error('Navigation failed:', error);
  }
}

/**
 * 替换当前页面
 */
export function replaceTo(url: string): void {
  try {
    router.replace({ url: url });
  } catch (error) {
    console.error('Navigation failed:', error);
  }
}

/**
 * 替换当前页面（带参数）
 */
export function replaceToWithParams(url: string, params: Record<string, Object>): void {
  try {
    router.replace({ url: url, params: params });
  } catch (error) {
    console.error('Navigation failed:', error);
  }
}

/**
 * 返回上一页
 */
export function navigateBack(): void {
  try {
    router.backUrl();
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
