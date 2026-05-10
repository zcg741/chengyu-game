// ContextManager.ts - 管理UIAbilityContext（纯TypeScript，可被.ts和.ets文件导入）
import common from '@ohos.app.ability.common';

let appContext: common.UIAbilityContext | null = null;

/**
 * 设置UIAbilityContext
 */
export function setAppContext(context: common.UIAbilityContext): void {
  appContext = context;
}

/**
 * 获取UIAbilityContext
 */
export function getAppContext(): common.UIAbilityContext | null {
  return appContext;
}
