// ThemeService.ets - 主题皮肤服务
import { THEMES, Theme } from '../model/ThemeModel';
import { saveString, getString } from './StorageService';

const STORAGE_KEY = 'current_theme';

let currentTheme: Theme = THEMES['classic'];

/**
 * 初始化主题（App 启动时调用）
 */
export async function initTheme(): Promise<void> {
  try {
    const themeId = await getString(STORAGE_KEY, 'classic');
    if (THEMES[themeId]) {
      currentTheme = THEMES[themeId];
    }
  } catch (error) {
    console.error('ThemeService.initTheme error:', error);
    currentTheme = THEMES['classic'];
  }
}

/**
 * 获取当前主题
 * @returns Theme 对象
 */
export function getCurrentTheme(): Theme {
  return currentTheme;
}

/**
 * 切换主题
 * @param themeId 主题 ID
 */
export async function setTheme(themeId: string): Promise<void> {
  if (!THEMES[themeId]) {
    console.error('ThemeService.setTheme: unknown theme', themeId);
    return;
  }
  currentTheme = THEMES[themeId];
  try {
    await saveString(STORAGE_KEY, themeId);
  } catch (error) {
    console.error('ThemeService.setTheme save error:', error);
  }
}

/**
 * 获取所有主题列表
 * @returns 主题数组
 */
export function getThemeList(): Theme[] {
  return Object.values(THEMES);
}

/**
 * 获取当前主题 ID
 * @returns 主题 ID
 */
export function getCurrentThemeId(): string {
  return currentTheme.id;
}
