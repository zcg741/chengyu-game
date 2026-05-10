// NavUtil.ets - 导航工具类（封装 router API）
// 注意：本文件内部使用已弃用的 router API 是封装目的，编译警告是预期行为
// 未来迁移到 Navigation 组件后可消除这些警告
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
