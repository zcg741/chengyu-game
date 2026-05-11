// GameState.ets - 游戏状态模型
import { GAME_MODE } from '../utils/Constants';

export enum HintLevel {
  NONE = 0,
  FIRST = 1,
  SECOND = 2,
  ANSWER = 3
}

export interface GameRecord {
  // 当前题目索引
  currentIndex: number;
  // 当前题型（explanation/pinyin/fill_blank/dragon）
  questionType: string;
  // 当前成语
  currentChengyu: string;
  // 当前成语拼音
  currentPinyin: string;
  // 当前成语释义
  currentExplanation: string;
  // 当前成语出处
  currentSource: string;
  // 用户输入的答案
  userAnswer: string;
  // 提示等级
  hintLevel: number;
  // 错误次数
  errorCount: number;
  // 是否正确
  isCorrect: boolean;
  // 是否已回答
  isAnswered: boolean;
}

export interface GameSession {
  // 游戏模式
  mode: string;
  // 当前得分
  score: number;
  // 答对题数
  correctCount: number;
  // 答错题数
  wrongCount: number;
  // 连续答对题数（闯关模式）
  consecutiveCorrect: number;
  // 当前关卡（闯关模式）
  currentLevel: number;
  // 生命值（闯关模式）
  lives: number;
  // 剩余时间（计时模式，秒）
  remainingTime: number;
  // 是否游戏中
  isPlaying: boolean;
  // 是否游戏结束
  isGameOver: boolean;
  // 题目记录列表
  records: GameRecord[];
  // 已使用的成语索引（避免重复）
  usedIndices: number[];
}
