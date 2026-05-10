// ChengyuModel.ets - 成语数据模型

// 成语分类枚举
export enum ChengyuCategory {
  ALL = '全部',
  NUMBER = '数字成语',
  ANIMAL = '动物成语',
  NATURE = '自然成语',
  PERSON = '人物成语',
  FABLE = '寓言故事',
  HISTORY = '历史典故',
  MORAL = '道德修养',
  EMOTION = '情感表达',
  DESCRIBE = '形容描写'
}

export interface Chengyu {
  // 成语文本
  word: string;
  // 拼音（如：yi xin yi yi）
  pinyin: string;
  // 释义
  explanation: string;
  // 出处（可选）
  source?: string;
  // 示例（可选）
  example?: string;
  // 难度等级 1-3
  difficulty: number;
  // 分类
  category: string;
}

export interface ChengyuHint {
  // 首字母提示（如：Y X Y Y）
  initialLetters: string;
  // 当前提示等级
  hintLevel: number;
  // 当前显示的提示文本
  hintText: string;
}
