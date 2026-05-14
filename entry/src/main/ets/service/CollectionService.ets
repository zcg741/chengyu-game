// CollectionService.ets - 成语收集系统服务
import { Chengyu } from '../model/ChengyuModel';
import { saveString, getString } from './StorageService';
import { getChengyuByWord } from './ChengyuService';
import { updateAchievementProgress } from './AchievementService';
import { AchievementType } from '../model/AchievementModel';

const STORAGE_KEY = 'collected_chengyu';

/**
 * 收集成语（答对后调用）
 * @param word 成语
 */
export async function collect(word: string): Promise<void> {
  try {
    const list = await getCollectedList();
    if (list.includes(word)) {
      return; // 已收集过，跳过
    }
    list.push(word);
    await saveString(STORAGE_KEY, JSON.stringify(list));
    
    // 用收藏总量推进成就，避免历史收藏和成就进度不一致。
    await updateAchievementProgress(AchievementType.COLLECT, list.length);
  } catch (error) {
    console.error('CollectionService.collect error:', error);
  }
}

/**
 * 是否已收集
 * @param word 成语
 * @returns 是否已收集
 */
export async function isCollected(word: string): Promise<boolean> {
  try {
    const list = await getCollectedList();
    return list.includes(word);
  } catch (error) {
    return false;
  }
}

/**
 * 获取已收集成语列表（word 数组）
 * @returns string[] 成语数组
 */
export async function getCollectedList(): Promise<string[]> {
  try {
    const json = await getString(STORAGE_KEY, '[]');
    return JSON.parse(json) as string[];
  } catch (error) {
    console.error('CollectionService.getCollectedList error:', error);
    return [];
  }
}

/**
 * 获取已收集成语数量
 * @returns 数量
 */
export async function getCollectedCount(): Promise<number> {
  const list = await getCollectedList();
  return list.length;
}

/**
 * 获取已收集成语的完整对象列表
 * @returns Chengyu[] 完整成语对象数组
 */
export async function getCollectedChengyuList(): Promise<Chengyu[]> {
  try {
    const words = await getCollectedList();
    const result: Chengyu[] = [];
    for (const word of words) {
      const chengyu = getChengyuByWord(word);
      if (chengyu) {
        result.push(chengyu);
      }
    }
    return result;
  } catch (error) {
    console.error('CollectionService.getCollectedChengyuList error:', error);
    return [];
  }
}

/**
 * 清除所有收集（调试用）
 */
export async function clearCollection(): Promise<void> {
  try {
    await saveString(STORAGE_KEY, '[]');
  } catch (error) {
    console.error('CollectionService.clearCollection error:', error);
  }
}
