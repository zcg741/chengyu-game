// AchievementModel.ets - 成就系统数据模型

// 成就等级
export enum AchievementLevel {
  BRONZE = 1,    // 铜牌
  SILVER = 2,    // 银牌
  GOLD = 3,       // 金牌
  DIAMOND = 4     // 钻石
}

// 成就定义
export interface Achievement {
  id: string;              // 成就ID
  name: string;            // 成就名称
  description: string;     // 成就描述
  icon: string;            // 成就图标（emoji）
  level: AchievementLevel; // 成就等级
  condition: AchievementCondition; // 解锁条件
  reward: number;          // 奖励积分
}

// 成就条件类型
export interface AchievementCondition {
  type: AchievementType;   // 条件类型
  target: number;          // 目标值
  current: number;         // 当前值（从存储读取）
}

// 成就类型枚举
export enum AchievementType {
  // 游戏次数相关
  TOTAL_GAMES = 'total_games',           // 总游戏次数
  TOTAL_CORRECT = 'total_correct',       // 总答对题数
  TOTAL_SCORE = 'total_score',           // 总得分
  CONSECUTIVE_CORRECT = 'consecutive_correct', // 连续答对
  MAX_SCORE = 'max_score',             // 单局最高分
  
  // 游戏模式相关
  TIMER_MODE_PLAYED = 'timer_mode_played',   // 玩过计时模式
  CHALLENGE_MODE_PLAYED = 'challenge_mode_played', // 玩过闯关模式
  
  // 难度相关
  PLAY_DIFFICULTY_2 = 'play_difficulty_2', // 玩过中等难度
  PLAY_DIFFICULTY_3 = 'play_difficulty_3', // 玩过高难度
  
  // 特殊成就
  FIRST_GAME = 'first_game',           // 首次游戏
  PERFECT_GAME = 'perfect_game',     // 完美通关（闯关模式全对）
  SPEED_ANSWER = 'speed_answer',     // 快速答题（3秒内）
  
  // 每日挑战相关
  DAILY_CHALLENGE_FIRST = 'daily_challenge_first',     // 第一次完成每日挑战
  DAILY_STREAK = 'daily_streak',               // 每日挑战连续打卡天数
  
  // 收藏相关
  COLLECT = 'collect',         // 收藏成语数量
}

// 用户成就状态
export interface UserAchievement {
  achievementId: string;    // 成就ID
  isUnlocked: boolean;       // 是否已解锁
  progress: number;          // 当前进度
  unlockedAt?: string;      // 解锁时间
}
