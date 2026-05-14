// ChengyuService.ets - 成语数据服务（从 rawfile/chengyu_data.json 加载）
import { Chengyu, ChengyuWithIndex } from '../model/ChengyuModel';
import common from '@ohos.app.ability.common';
import { getAppContext } from '../utils/ContextManager';
import { BusinessError } from '@ohos.base';

// 成语数据（从 rawfile JSON 加载，500+ 条）
let chengyuList: Chengyu[] = [];
let filteredList: Chengyu[] = []; // 当前过滤后的列表

function getUIContext(): common.UIAbilityContext | null {
  return getAppContext();
}

/**
 * 手动 UTF-8 解码（ArkTS 不支持 TextDecoder）
 * 将 Uint8Array（UTF-8 字节）正确解码为字符串
 */
function utf8ArrayToString(uint8Array: Uint8Array): string {
  let result = '';
  let i = 0;
  while (i < uint8Array.length) {
    const c = uint8Array[i];
    if (c < 0x80) {
      // 1字节 ASCII (0x00-0x7F)
      result += String.fromCharCode(c);
      i++;
    } else if (c < 0xE0) {
      // 2字节序列 (0xC0-0xDF)
      const c2 = uint8Array[i + 1];
      result += String.fromCharCode(((c & 0x1F) << 6) | (c2 & 0x3F));
      i += 2;
    } else if (c < 0xF0) {
      // 3字节序列 (0xE0-0xEF) - 包含大部分中文字符
      const c2 = uint8Array[i + 1];
      const c3 = uint8Array[i + 2];
      result += String.fromCharCode(((c & 0x0F) << 12) | ((c2 & 0x3F) << 6) | (c3 & 0x3F));
      i += 3;
    } else {
      // 4字节序列 (0xF0-0xF7) - 表情符号等
      const c2 = uint8Array[i + 1];
      const c3 = uint8Array[i + 2];
      const c4 = uint8Array[i + 3];
      const codePoint = ((c & 0x07) << 18) | ((c2 & 0x3F) << 12) | ((c3 & 0x3F) << 6) | (c4 & 0x3F);
      // 使用代理对表示 BMP 之外的字符
      result += String.fromCharCode(
        0xD800 + ((codePoint - 0x10000) >> 10),
        0xDC00 + ((codePoint - 0x10000) & 0x3FF)
      );
      i += 4;
    }
  }
  return result;
}

/**
 * 从 rawfile/chengyu_data.json 加载成语数据
 */
async function loadChengyuFromRawFile(): Promise<Chengyu[]> {
  const context = getAppContext();
  if (!context) {
    console.error('ChengyuService: 无法获取上下文');
    return getBuiltInFallbackData();
  }
   try {
    const fileData: Uint8Array = await context.resourceManager.getRawFileContent('chengyu_data.json');
    // 使用手动 UTF-8 解码（ArkTS 不支持 TextDecoder）
    const jsonStr = utf8ArrayToString(fileData);
    const data: Chengyu[] = JSON.parse(jsonStr);
    console.log(`ChengyuService: 从 JSON 加载了 ${data.length} 条成语`);
    return data;
  } catch (e) {
    console.error(`ChengyuService: 加载 JSON 失败，${JSON.stringify(e)}`);
    return getBuiltInFallbackData();
  }
}

/**
 * 内置后备数据（JSON 加载失败时使用）
 */
function getBuiltInFallbackData(): Chengyu[] {
  return [
    { word: '一心一意', pinyin: 'yī xīn yī yì', explanation: '形容做事专心，毫不分心', source: '《三国志》', difficulty: 1, category: '数字成语' },
    { word: '狐假虎威', pinyin: 'hú jiǎ hǔ wēi', explanation: '比喻依仗别人的势力来欺压人', source: '《战国策》', difficulty: 2, category: '动物成语' },
    { word: '开天辟地', pinyin: 'kāi tiān pì dì', explanation: '比喻前所未有的伟大事业', source: '《三五历纪》', difficulty: 1, category: '自然成语' },
  ];
}

/**
 * 加载成语数据
 * @param difficulty 难度筛选 (0=全部, 1-3=指定难度)
 * @param category 分类筛选 (空字符串=全部)
 * @returns Promise<Chengyu[]>
 */
export async function loadChengyuData(difficulty: number = 0, category: string = ''): Promise<Chengyu[]> {
  if (chengyuList.length === 0) {
    chengyuList = await loadChengyuFromRawFile();
  }
  filteredList = filterChengyu(chengyuList, difficulty, category);
  return filteredList;
}

/**
 * 过滤成语数据
 * @param list 成语列表
 * @param difficulty 难度
 * @param category 分类
 * @returns 过滤后的成语列表
 */
function filterChengyu(list: Chengyu[], difficulty: number, category: string): Chengyu[] {
  let result = list;
  if (difficulty > 0) {
    result = result.filter(c => c.difficulty === difficulty);
  }
  if (category && category !== '全部') {
    result = result.filter(c => c.category === category);
  }
  return result;
}

function toIndexedList(list: Chengyu[]): ChengyuWithIndex[] {
  const result: ChengyuWithIndex[] = [];
  list.forEach((chengyu, index) => {
    const originalIndex = list === chengyuList ? index : chengyuList.findIndex(c => c.word === chengyu.word);
    result.push({
      chengyu: chengyu,
      originalIndex: originalIndex >= 0 ? originalIndex : index
    });
  });
  return result;
}

function createRandom(seed?: number): () => number {
  if (seed === undefined) {
    return Math.random;
  }

  let state = Math.abs(Math.floor(seed)) % 2147483647;
  if (state === 0) {
    state = 1;
  }

  return () => {
    state = (state * 48271) % 2147483647;
    return state / 2147483647;
  };
}

function shuffledItems(items: ChengyuWithIndex[], seed?: number): ChengyuWithIndex[] {
  const result = items.slice();
  const random = createRandom(seed);
  for (let i = result.length - 1; i > 0; i--) {
    const j = Math.floor(random() * (i + 1));
    const temp = result[i];
    result[i] = result[j];
    result[j] = temp;
  }
  return result;
}

/**
 * 获取随机成语（不重复）
 * @param count 需要的数量
 * @param usedIndices 已使用的索引
 * @returns 成语数组（包含原始索引）
 */
export function getRandomChengyu(count: number, usedIndices: number[]): ChengyuWithIndex[] {
  return getRandomChengyuWithSeed(count, usedIndices);
}

/**
 * 获取随机成语（支持传入种子，便于每日挑战固定题目）
 * @param count 需要的数量
 * @param usedIndices 已使用的原始索引
 * @param seed 随机种子；不传则使用 Math.random
 * @returns 成语数组（包含原始索引）
 */
export function getRandomChengyuWithSeed(count: number, usedIndices: number[], seed?: number): ChengyuWithIndex[] {
  const targetList = filteredList.length > 0 ? filteredList : chengyuList;
  const available = toIndexedList(targetList).filter(item => !usedIndices.includes(item.originalIndex));
  const result: ChengyuWithIndex[] = [];
  const shuffled = shuffledItems(available, seed);
  
  for (let i = 0; i < Math.min(count, shuffled.length); i++) {
    result.push(shuffled[i]);
  }
  
  return result;
}

/**
 * 根据难度获取成语
 * @param difficulty 难度等级 (1=简单, 2=中等, 3=困难)
 * @param category 分类筛选 (空字符串=全部)
 * @returns 成语数组
 */
export function getChengyuByDifficulty(difficulty: number, category: string = ''): Chengyu[] {
  let result = chengyuList;
  if (difficulty > 0) {
    result = result.filter(c => c.difficulty === difficulty);
  }
  if (category && category !== '全部') {
    result = result.filter(c => c.category === category);
  }
  return result;
}

/**
 * 获取所有分类
 * @returns 分类数组
 */
export function getCategories(): string[] {
  const categories = new Set<string>();
  chengyuList.forEach(c => categories.add(c.category));
  return ['全部', ...Array.from(categories)];
}

/**
 * 根据索引获取成语
 * @param index 索引
 * @returns 成语或undefined
 */
export function getChengyuByIndex(index: number): Chengyu | undefined {
  return chengyuList[index];
}

/**
 * 根据成语文本查找成语对象
 * @param word 成语文本
 * @returns 成语对象或 undefined
 */
export function getChengyuByWord(word: string): Chengyu | undefined {
  return chengyuList.find(c => c.word === word);
}

/**
 * 根据首字获取成语列表（用于接龙模式）
 * @param firstChar 首字
 * @returns 成语数组（包含原始索引）
 */
export function getChengyuByFirstChar(firstChar: string): ChengyuWithIndex[] {
  const result: ChengyuWithIndex[] = [];
  chengyuList.forEach((c, index) => {
    if (c.word && c.word.length > 0 && c.word[0] === firstChar) {
      const item: ChengyuWithIndex = {
        chengyu: c,
        originalIndex: index
      };
      result.push(item);
    }
  });
  return result;
}

/**
 * 获取总成语数量
 * @returns 数量
 */
export function getTotalCount(): number {
  return chengyuList.length;
}
