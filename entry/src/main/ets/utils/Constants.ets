// Constants.ets - 游戏常量定义

// 游戏配置接口
interface GameConfig {
  TIMER_MODE_DURATION: number;
  CHALLENGE_MODE_COUNT: number;
  HINT_NONE: number;
  HINT_FIRST: number;
  HINT_SECOND: number;
  HINT_ANSWER: number;
  MAX_ERROR_COUNT: number;
  SCORE_PER_CORRECT: number;
  SCORE_PENALTY_HINT: number;
}

// 存储键接口
interface StorageKeys {
  HIGH_SCORE: string;
  TOTAL_GAMES: string;
  TOTAL_CORRECT: string;
}

// 游戏模式接口
interface GameMode {
  TIMER: string;
  CHALLENGE: string;
}

export const GAME_CONFIG: GameConfig = {
  // 计时模式时长（秒）
  TIMER_MODE_DURATION: 60,
  // 闯关模式需要连续答对的题目数
  CHALLENGE_MODE_COUNT: 5,
  // 提示等级
  HINT_NONE: 0,
  HINT_FIRST: 1,
  HINT_SECOND: 2,
  HINT_ANSWER: 3,
  // 最大错误次数（触发显示答案）
  MAX_ERROR_COUNT: 3,
  // 每题得分
  SCORE_PER_CORRECT: 10,
  // 提示扣分
  SCORE_PENALTY_HINT: 2
};

export const STORAGE_KEYS: StorageKeys = {
  HIGH_SCORE: 'high_score',
  TOTAL_GAMES: 'total_games',
  TOTAL_CORRECT: 'total_correct'
};

export const GAME_MODE: GameMode = {
  TIMER: 'timer',
  CHALLENGE: 'challenge'
};
