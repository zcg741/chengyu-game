// StorageService.ets - Preferences存储服务
import dataPreferences from '@ohos.data.preferences';
import { getAppContext } from '../utils/ContextManager';

const PREFERENCES_NAME = 'chengyu_game_prefs';

let preferences: dataPreferences.Preferences | null = null;

async function initPreferences(): Promise<dataPreferences.Preferences> {
  if (preferences) {
    return preferences;
  }
  
  const context = getAppContext();
  if (!context) {
    throw new Error('StorageService: context not initialized. Call setAppContext() first.');
  }
  
  try {
    preferences = await dataPreferences.getPreferences(context, PREFERENCES_NAME);
    return preferences;
  } catch (error) {
    console.error('Failed to init preferences:', error);
    throw new Error('Failed to init preferences: ' + String(error));
  }
}

/**
 * 保存字符串
 * @param key 键
 * @param value 值
 */
export async function saveString(key: string, value: string): Promise<void> {
  try {
    const prefs = await initPreferences();
    await prefs.put(key, value);
    await prefs.flush();
  } catch (error) {
    console.error('Failed to save string:', key, error);
  }
}

/**
 * 获取字符串
 * @param key 键
 * @param defaultValue 默认值
 * @returns 值
 */
export async function getString(key: string, defaultValue: string = ''): Promise<string> {
  try {
    const prefs = await initPreferences();
    return await prefs.get(key, defaultValue) as string;
  } catch (error) {
    console.error('Failed to get string:', key, error);
    return defaultValue;
  }
}

/**
 * 保存数字
 * @param key 键
 * @param value 值
 */
export async function saveNumber(key: string, value: number): Promise<void> {
  try {
    const prefs = await initPreferences();
    await prefs.put(key, value);
    await prefs.flush();
  } catch (error) {
    console.error('Failed to save number:', key, error);
  }
}

/**
 * 获取数字
 * @param key 键
 * @param defaultValue 默认值
 * @returns 值
 */
export async function getNumber(key: string, defaultValue: number = 0): Promise<number> {
  try {
    const prefs = await initPreferences();
    return await prefs.get(key, defaultValue) as number;
  } catch (error) {
    console.error('Failed to get number:', key, error);
    return defaultValue;
  }
}

/**
 * 保存布尔值
 * @param key 键
 * @param value 值
 */
export async function saveBoolean(key: string, value: boolean): Promise<void> {
  try {
    const prefs = await initPreferences();
    await prefs.put(key, value);
    await prefs.flush();
  } catch (error) {
    console.error('Failed to save boolean:', key, error);
  }
}

/**
 * 获取布尔值
 * @param key 键
 * @param defaultValue 默认值
 * @returns 值
 */
export async function getBoolean(key: string, defaultValue: boolean = false): Promise<boolean> {
  try {
    const prefs = await initPreferences();
    return await prefs.get(key, defaultValue) as boolean;
  } catch (error) {
    console.error('Failed to get boolean:', key, error);
    return defaultValue;
  }
}

/**
 * 删除键值对
 * @param key 键
 */
export async function remove(key: string): Promise<void> {
  try {
    const prefs = await initPreferences();
    await prefs.delete(key);
    await prefs.flush();
  } catch (error) {
    console.error('Failed to remove:', key, error);
  }
}

/**
 * 清除所有数据
 */
export async function clearAll(): Promise<void> {
  try {
    const prefs = await initPreferences();
    await prefs.clear();
    await prefs.flush();
  } catch (error) {
    console.error('Failed to clear all:', error);
  }
}
