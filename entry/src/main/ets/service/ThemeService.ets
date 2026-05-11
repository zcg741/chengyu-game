// ThemeService.ets - 主题皮肤服务
import { THEMES, Theme } from '../model/ThemeModel';
import { saveString, getString } from './StorageService';

const STORAGE_KEY = 'current_theme';
const APP_STORAGE_KEY = 'current_theme_id'; // AppStorage 键

// 根据 themeId 获取主题（避免索引访问）
function getThemeById(themeId: string): Theme {
  if (themeId === 'classic') return THEMES.classic;
  if (themeId === 'green') return THEMES.green;
  if (themeId === 'blue') return THEMES.blue;
  if (themeId === 'dark') return THEMES.dark;
  return THEMES.classic; // 默认
}

let currentTheme: Theme = THEMES.classic;

/**
 * 初始化主题（App 启动时调用）
 */
export async function initTheme(): Promise<void> {
  try {
    const themeId = await getString(STORAGE_KEY, 'classic');
    currentTheme = getThemeById(themeId);
    // 同步到 AppStorage（供所有页面监听）
    AppStorage.setOrCreate(APP_STORAGE_KEY, themeId);
  } catch (error) {
    console.error('ThemeService.initTheme error:', error);
    currentTheme = THEMES.classic;
    AppStorage.setOrCreate(APP_STORAGE_KEY, 'classic');
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
  const theme = getThemeById(themeId);
  if (theme === THEMES.classic && themeId !== 'classic') {
    console.error('ThemeService.setTheme: unknown theme', themeId);
    return;
  }
  currentTheme = theme;
  // 同步到 AppStorage（触发所有页面刷新）
  AppStorage.setOrCreate(APP_STORAGE_KEY, themeId);
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
  return [THEMES.classic, THEMES.green, THEMES.blue, THEMES.dark];
}

/**
 * 获取当前主题 ID
 * @returns 主题 ID
 */
export function getCurrentThemeId(): string {
  return currentTheme.id;
}
