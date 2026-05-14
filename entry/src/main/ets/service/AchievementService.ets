// AchievementService.ets - 成就系统服务
import { Achievement, AchievementLevel, AchievementType, UserAchievement } from '../model/AchievementModel';
import { getNumber, saveNumber, getString, saveString, getBoolean, saveBoolean } from './StorageService';

// 所有成就定义
const ACHIEVEMENTS: Achievement[] = [
  // 新手成就（铜牌）
  {
    id: 'first_game',
    name: '初出茅庐',
    description: '完成第一次游戏',
    icon: '🎮',
    level: AchievementLevel.BRONZE,
    condition: { type: AchievementType.FIRST_GAME, target: 1, current: 0 },
    reward: 10
  },
  {
    id: 'play_10_games',
    name: '常客',
    description: '累计游玩10次',
    icon: '🎯',
    level: AchievementLevel.BRONZE,
    condition: { type: AchievementType.TOTAL_GAMES, target: 10, current: 0 },
    reward: 20
  },
  
  // 答题成就（银牌）
  {
    id: 'correct_50',
    name: '小有成就',
    description: '累计答对50题',
    icon: '✅',
    level: AchievementLevel.SILVER,
    condition: { type: AchievementType.TOTAL_CORRECT, target: 50, current: 0 },
    reward: 50
  },
  {
    id: 'correct_100',
    name: '百发百中',
    description: '累计答对100题',
    icon: '🎯',
    level: AchievementLevel.SILVER,
    condition: { type: AchievementType.TOTAL_CORRECT, target: 100, current: 0 },
    reward: 100
  },
  
  // 高分成就（金牌）
  {
    id: 'score_100',
    name: '百分达人',
    description: '单局得分超过100分',
    icon: '💯',
    level: AchievementLevel.GOLD,
    condition: { type: AchievementType.MAX_SCORE, target: 100, current: 0 },
    reward: 50
  },
  {
    id: 'score_300',
    name: '高分王者',
    description: '单局得分超过300分',
    icon: '🏆',
    level: AchievementLevel.GOLD,
    condition: { type: AchievementType.MAX_SCORE, target: 300, current: 0 },
    reward: 150
  },
  
  // 连胜成就（金牌）
  {
    id: 'streak_5',
    name: '连胜将军',
    description: '连续答对5题',
    icon: '🔥',
    level: AchievementLevel.GOLD,
    condition: { type: AchievementType.CONSECUTIVE_CORRECT, target: 5, current: 0 },
    reward: 30
  },
  {
    id: 'streak_10',
    name: '不败传说',
    description: '连续答对10题',
    icon: '⚡',
    level: AchievementLevel.DIAMOND,
    condition: { type: AchievementType.CONSECUTIVE_CORRECT, target: 10, current: 0 },
    reward: 100
  },
  
  // 游戏模式成就
  {
    id: 'play_timer_mode',
    name: '与时间赛跑',
    description: '玩过计时模式',
    icon: '⏱️',
    level: AchievementLevel.BRONZE,
    condition: { type: AchievementType.TIMER_MODE_PLAYED, target: 1, current: 0 },
    reward: 10
  },
  {
    id: 'play_challenge_mode',
    name: '挑战者',
    description: '玩过闯关模式',
    icon: '🎪',
    level: AchievementLevel.BRONZE,
    condition: { type: AchievementType.CHALLENGE_MODE_PLAYED, target: 1, current: 0 },
    reward: 10
  },
  
  // 难度成就
  {
    id: 'play_difficulty_2',
    name: '进阶玩家',
    description: '玩过中等难度',
    icon: '⭐',
    level: AchievementLevel.SILVER,
    condition: { type: AchievementType.PLAY_DIFFICULTY_2, target: 1, current: 0 },
    reward: 20
  },
  {
    id: 'play_difficulty_3',
    name: '高手无敌',
    description: '玩过困难难度',
    icon: '💎',
    level: AchievementLevel.GOLD,
    condition: { type: AchievementType.PLAY_DIFFICULTY_3, target: 1, current: 0 },
    reward: 50
  },
  
  // 特殊成就
  {
    id: 'perfect_game',
    name: '完美通关',
    description: '闯关模式无错通关',
    icon: '👑',
    level: AchievementLevel.DIAMOND,
    condition: { type: AchievementType.PERFECT_GAME, target: 1, current: 0 },
    reward: 200
  },
  {
    id: 'total_score_1000',
    name: '积分达人',
    description: '累计获得1000积分',
    icon: '🌟',
    level: AchievementLevel.SILVER,
    condition: { type: AchievementType.TOTAL_SCORE, target: 1000, current: 0 },
    reward: 50
  },
  
  // 每日挑战成就
  {
    id: 'daily_challenge_first',
    name: '挑战新手',
    description: '第一次完成每日挑战',
    icon: '📅',
    level: AchievementLevel.BRONZE,
    condition: { type: AchievementType.DAILY_CHALLENGE_FIRST, target: 1, current: 0 },
    reward: 20
  },
  {
    id: 'daily_streak_3',
    name: '坚持不懈',
    description: '连续3天完成每日挑战',
    icon: '🔥',
    level: AchievementLevel.SILVER,
    condition: { type: AchievementType.DAILY_STREAK, target: 3, current: 0 },
    reward: 50
  },
  {
    id: 'daily_streak_7',
    name: '一周达人',
    description: '连续7天完成每日挑战',
    icon: '🏆',
    level: AchievementLevel.GOLD,
    condition: { type: AchievementType.DAILY_STREAK, target: 7, current: 0 },
    reward: 100
  },
  
  // 收藏成就
  {
    id: 'collect_10',
    name: '初识成语',
    description: '收藏10个成语',
    icon: '📚',
    level: AchievementLevel.BRONZE,
    condition: { type: AchievementType.COLLECT, target: 10, current: 0 },
    reward: 20
  },
  {
    id: 'collect_50',
    name: '成语达人',
    description: '收藏50个成语',
    icon: '📖',
    level: AchievementLevel.SILVER,
    condition: { type: AchievementType.COLLECT, target: 50, current: 0 },
    reward: 50
  }
];

// 用户成就缓存
let userAchievements: Map<string, UserAchievement> = new Map();

async function ensureUserAchievement(achievement: Achievement): Promise<UserAchievement> {
  const cached = userAchievements.get(achievement.id);
  if (cached) {
    return cached;
  }

  const key = `achievement_${achievement.id}`;
  const isUnlocked = await getBoolean(`${key}_unlocked`, false);
  const state: UserAchievement = {
    achievementId: achievement.id,
    isUnlocked: isUnlocked,
    progress: isUnlocked ? achievement.condition.target : await getNumber(`${key}_progress`, 0),
    unlockedAt: isUnlocked ? await getString(`${key}_time`, '') : undefined
  };
  userAchievements.set(achievement.id, state);
  return state;
}

/**
 * 初始化成就数据
 */
export async function initAchievements(): Promise<void> {
  for (const achievement of ACHIEVEMENTS) {
    const key = `achievement_${achievement.id}`;
    const isUnlocked = await getBoolean(`${key}_unlocked`, false);
    
    userAchievements.set(achievement.id, {
      achievementId: achievement.id,
      isUnlocked: isUnlocked,
      progress: isUnlocked ? achievement.condition.target : await getNumber(`${key}_progress`, 0),
      unlockedAt: isUnlocked ? await getString(`${key}_time`, '') : undefined
    });
  }
}

/**
 * 获取所有成就定义
 * @returns 成就数组
 */
export function getAllAchievements(): Achievement[] {
  return ACHIEVEMENTS;
}

/**
 * 获取用户成就状态
 * @returns 用户成就数组
 */
export function getUserAchievements(): UserAchievement[] {
  return Array.from(userAchievements.values());
}

/**
 * 检查成就是否解锁
 * @param achievementId 成就ID
 * @returns 是否解锁
 */
export function isAchievementUnlocked(achievementId: string): boolean {
  const ua = userAchievements.get(achievementId);
  return ua ? ua.isUnlocked : false;
}

/**
 * 更新成就进度
 * @param type 成就类型
 * @param value 当前值
 * @returns 新解锁的成就数组
 */
export async function updateAchievementProgress(type: string, value: number): Promise<Achievement[]> {
  const newlyUnlocked: Achievement[] = [];
  
  for (const achievement of ACHIEVEMENTS) {
    if (achievement.condition.type !== type) {
      continue;
    }
    
    const ua = await ensureUserAchievement(achievement);
    
    // 如果已解锁，跳过
    if (ua.isUnlocked) {
      continue;
    }
    
    // 更新进度
    ua.progress = Math.max(ua.progress, value);
    
    // 检查是否达成
    if (ua.progress >= achievement.condition.target) {
      ua.isUnlocked = true;
      ua.unlockedAt = new Date().toISOString();
      
      // 保存到存储
      const key = `achievement_${achievement.id}`;
      await saveBoolean(`${key}_unlocked`, true);
      await saveNumber(`${key}_progress`, ua.progress);
      await saveString(`${key}_time`, ua.unlockedAt);
      
      newlyUnlocked.push(achievement);
    } else {
      // 只保存进度
      const key = `achievement_${achievement.id}`;
      await saveNumber(`${key}_progress`, ua.progress);
    }
  }
  
  return newlyUnlocked;
}

/**
 * 增加计数类成就
 * @param type 成就类型
 * @param increment 增加量
 * @returns 新解锁的成就数组
 */
export async function incrementAchievement(type: string, increment: number = 1): Promise<Achievement[]> {
  const newlyUnlocked: Achievement[] = [];
  
  for (const achievement of ACHIEVEMENTS) {
    if (achievement.condition.type !== type) {
      continue;
    }
    
    const ua = await ensureUserAchievement(achievement);
    
    if (ua.isUnlocked) {
      continue;
    }
    
    ua.progress += increment;
    
    if (ua.progress >= achievement.condition.target) {
      ua.isUnlocked = true;
      ua.unlockedAt = new Date().toISOString();
      
      const key = `achievement_${achievement.id}`;
      await saveBoolean(`${key}_unlocked`, true);
      await saveNumber(`${key}_progress`, ua.progress);
      await saveString(`${key}_time`, ua.unlockedAt);
      
      newlyUnlocked.push(achievement);
    } else {
      const key = `achievement_${achievement.id}`;
      await saveNumber(`${key}_progress`, ua.progress);
    }
  }
  
  return newlyUnlocked;
}

/**
 * 获取已解锁成就数量
 * @returns 数量
 */
export function getUnlockedCount(): number {
  let count = 0;
  userAchievements.forEach(ua => {
    if (ua.isUnlocked) {
      count++;
    }
  });
  return count;
}

/**
 * 获取总成就数量
 * @returns 数量
 */
export function getTotalCount(): number {
  return ACHIEVEMENTS.length;
}

/**
 * 获取成就定义 by ID
 * @param id 成就ID
 * @returns 成就或undefined
 */
export function getAchievementById(id: string): Achievement | undefined {
  return ACHIEVEMENTS.find(a => a.id === id);
}
