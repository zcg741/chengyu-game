// GameViewModel.ets - 游戏核心逻辑ViewModel
import { ChengyuWithIndex } from '../model/ChengyuModel';
import { GameSession, GameRecord } from '../model/GameState';
import { GAME_CONFIG, GAME_MODE, QUESTION_TYPE } from '../utils/Constants';
import { loadChengyuData, getRandomChengyu, getChengyuByFirstChar } from '../service/ChengyuService';
import { saveNumber, getNumber, saveString, getString } from '../service/StorageService';
import { initAchievements, incrementAchievement, updateAchievementProgress } from '../service/AchievementService';
import { Achievement } from '../model/AchievementModel';
import { collect } from '../service/CollectionService';
import { recordWrongAnswer } from '../service/WrongBookService';
import { getHintText, getQuestionPrompt, isAnswerCorrect, pickDynamicQuestionType } from '../service/QuestionService';

export class GameViewModel {
  private session: GameSession;
  
  constructor() {
    this.session = this.createEmptySession();
  }
  
  /**
   * 创建空游戏会话
   */
  private createEmptySession(): GameSession {
    return {
      mode: GAME_MODE.TIMER,
      score: 0,
      correctCount: 0,
      wrongCount: 0,
      consecutiveCorrect: 0,
      currentLevel: 1,
      lives: 0,
      remainingTime: GAME_CONFIG.TIMER_MODE_DURATION,
      isPlaying: false,
      isGameOver: false,
      records: [],
      usedIndices: []
    };
  }
  
  private currentCategory: string = '';
  private prevChengyuLastChar: string = '';
  private recentResults: boolean[] = []; // 最近答题结果（用于动态难度调整）
  private readonly RECENT_RESULTS_MAX: number = 5; // 保留最近5题的结果
  private totalGamesBeforeStart: number = 0;

  /**
   * 初始化游戏
   * @param mode 游戏模式
   * @param difficulty 难度等级 (0=全部, 1=简单, 2=中等, 3=困难)
   * @param category 分类 (空字符串=全部)
   */
  async initGame(mode: string, difficulty: number = 0, category: string = ''): Promise<void> {
    this.currentCategory = category;
    await loadChengyuData(difficulty, category);
    await initAchievements(); // 初始化成就
    this.totalGamesBeforeStart = await getNumber('total_games', 0);
    
    // 加载已玩成语记录
    const playedStr = await getString('played_idioms', '[]');
    let playedIndices: number[] = [];
    try {
      playedIndices = JSON.parse(playedStr);
    } catch (e) {}
    
    const empty = this.createEmptySession();
    this.session = {
      mode: mode,
      score: empty.score,
      correctCount: empty.correctCount,
      wrongCount: empty.wrongCount,
      consecutiveCorrect: empty.consecutiveCorrect,
      currentLevel: empty.currentLevel,
      lives: mode === GAME_MODE.CHALLENGE ? GAME_CONFIG.MAX_LIVES : 0,
      remainingTime: GAME_CONFIG.TIMER_MODE_DURATION,
      isPlaying: true,
      isGameOver: false,
      records: empty.records,
      usedIndices: playedIndices
    };
    
    // 更新成就：首次游戏、游戏模式
    if (mode === GAME_MODE.TIMER) {
      await incrementAchievement('timer_mode_played');
    }
    if (mode === GAME_MODE.CHALLENGE) {
      await incrementAchievement('challenge_mode_played');
    }
    if (difficulty >= 2) {
      await incrementAchievement('play_difficulty_2');
    }
    if (difficulty >= 3) {
      await incrementAchievement('play_difficulty_3');
    }
    
    this.loadNextQuestion();
  }
  
  /**
   * 加载下一题（动态难度调整）
   */
  loadNextQuestion(): void {
    // 根据最近答题表现动态选题型
    const randomType = pickDynamicQuestionType(this.recentResults, this.totalGamesBeforeStart);

    let chengyuList: ChengyuWithIndex[] = [];

    // 接龙模式：找首字匹配的成语
    if (randomType === QUESTION_TYPE.DRAGON && this.prevChengyuLastChar) {
      const allMatches = getChengyuByFirstChar(this.prevChengyuLastChar);
      // 过滤已使用的
      chengyuList = allMatches.filter(item => !this.session.usedIndices.includes(item.originalIndex));
    }

    // 接龙无匹配或不是接龙模式：随机取题
    if (chengyuList.length === 0) {
      chengyuList = getRandomChengyu(1, this.session.usedIndices);
    }

    if (chengyuList.length === 0) {
      this.endGame();
      return;
    }

    const item = chengyuList[0];
    const chengyu = item.chengyu;
    const originalIndex = item.originalIndex;
    const explanation = getQuestionPrompt(chengyu, randomType, this.prevChengyuLastChar);

    const record: GameRecord = {
      currentIndex: originalIndex,  // ✅ 使用真实的原始索引
      questionType: randomType,
      currentChengyu: chengyu.word,
      currentPinyin: chengyu.pinyin,
      currentExplanation: explanation,
      currentSource: chengyu.source || '',
      userAnswer: '',
      hintLevel: 0,
      errorCount: 0,
      isCorrect: false,
      isAnswered: false
    };

    this.session.records.push(record);
    this.session.usedIndices.push(originalIndex);  // ✅ 推送正确的索引

    // 更新尾字（用于下一题接龙）
    this.prevChengyuLastChar = chengyu.word ? chengyu.word.slice(-1) : '';
  }
  
  /**
   * 获取当前题目
   */
  getCurrentQuestion(): GameRecord | null {
    if (this.session.records.length === 0) {
      return null;
    }
    return this.session.records[this.session.records.length - 1];
  }
  
  /**
   * 获取当前成语出处
   */
  getCurrentSource(): string {
    const current: GameRecord | null = this.getCurrentQuestion();
    if (!current) {
      return '';
    }
    return current.currentSource || '';
  }
  
  /**
   * 提交答案
   * @param answer 用户答案
   * @returns 是否正确
   */
  async submitAnswer(answer: string): Promise<boolean> {
    const current: GameRecord | null = this.getCurrentQuestion();
    if (!current || current.isAnswered) {
      return false;
    }
    
    current.userAnswer = answer.trim();
    
    const isCorrect = isAnswerCorrect(current.userAnswer, current.currentChengyu);
    
    current.isCorrect = isCorrect;

    if (isCorrect) {
      current.isAnswered = true;
      await this.handleCorrectAnswer();
    } else {
      await this.handleWrongAnswer();
    }
    
    return isCorrect;
  }
  
  /**
   * 处理正确答案
   */
  private async handleCorrectAnswer(): Promise<void> {
    this.session.score += GAME_CONFIG.SCORE_PER_CORRECT;
    this.session.correctCount++;
    this.session.consecutiveCorrect++;

    // 记录答题结果（用于动态难度调整）
    this.recentResults.push(true);
    if (this.recentResults.length > this.RECENT_RESULTS_MAX) {
      this.recentResults.shift();
    }

    // 收集成语（答对后自动收集）
    const current: GameRecord | null = this.getCurrentQuestion();
    if (current) {
      await collect(current.currentChengyu);
    }

    // 检查连胜成就
    await updateAchievementProgress('consecutive_correct', this.session.consecutiveCorrect);
    
    // 闯关模式：检查是否通关
    if (this.session.mode === GAME_MODE.CHALLENGE) {
      if (this.session.consecutiveCorrect >= GAME_CONFIG.CHALLENGE_MODE_COUNT) {
        // 通关
        this.session.currentLevel++;
        this.session.consecutiveCorrect = 0;
        // 通关后奖励1条命
        if (this.session.lives < GAME_CONFIG.MAX_LIVES) {
          this.session.lives++;
        }
      }
    }
  }
  
  /**
   * 处理错误答案
   */
  private async handleWrongAnswer(): Promise<void> {
    this.session.wrongCount++;
    this.session.consecutiveCorrect = 0;

    // 记录答题结果（用于动态难度调整）
    this.recentResults.push(false);
    if (this.recentResults.length > this.RECENT_RESULTS_MAX) {
      this.recentResults.shift();
    }

    // 闯关模式下扣除生命值
    if (this.session.mode === GAME_MODE.CHALLENGE) {
      this.session.lives--;
    }
    
    const current: GameRecord | null = this.getCurrentQuestion();
    if (current) {
      current.errorCount++;
      // 答错后提升提示等级，最多到 wordLen-1（此时 generateHint 会返回完整答案）
      const wordLen = current.currentChengyu.length;
      if (current.hintLevel < wordLen - 1) {
        current.hintLevel++;
      }
      
      // 扣分
      this.session.score = Math.max(0, this.session.score - GAME_CONFIG.SCORE_PENALTY_HINT);
      await recordWrongAnswer(current.currentChengyu);
    }
  }
  
  /**
   * 获取提示
   * 提示等级：0=只显示拼音，1~N=揭示对应数量的汉字，N+1=显示完整答案
   * @returns 提示文本
   */
  getHint(): string {
    const current: GameRecord | null = this.getCurrentQuestion();
    if (!current || current.isAnswered) {
      return '';
    }
    
    const wordLen = current.currentChengyu.length;
    
    // 增加提示等级（最多到 wordLen-1，此时 generateHint 会返回完整答案）
    if (current.hintLevel < wordLen - 1) {
      current.hintLevel++;
    }
    
    // 扣分
    this.session.score = Math.max(0, this.session.score - GAME_CONFIG.SCORE_PENALTY_HINT);
    
    // 优先使用题库拼音字段生成首字母，避免汉字映射表误差。
    return getHintText(current.currentChengyu, current.currentPinyin, current.hintLevel);
  }
  
  /**
   * 获取当前提示文本
   */
  getCurrentHintText(): string {
    const current: GameRecord | null = this.getCurrentQuestion();
    if (!current) {
      return '';
    }

    // 如果已经答错到极限（闯关模式），直接显示答案
    if (current.errorCount >= GAME_CONFIG.MAX_ERROR_COUNT) {
      return current.currentChengyu;
    }

    return getHintText(current.currentChengyu, current.currentPinyin, current.hintLevel);
  }
  
  /**
   * 检查是否还能继续（闯关模式答错处理）
   */
  canContinue(): boolean {
    if (this.session.mode === GAME_MODE.CHALLENGE) {
      const current: GameRecord | null = this.getCurrentQuestion();
      if (current && !current.isCorrect && current.errorCount >= GAME_CONFIG.MAX_ERROR_COUNT) {
        return false;
      }
    }
    return !this.session.isGameOver;
  }
  
  /**
   * 进入下一题
   */
  nextQuestion(): void {
    if (this.session.isGameOver) {
      return;
    }
    this.loadNextQuestion();
  }
  
  /**
   * 结束游戏
   */
  async endGame(): Promise<Achievement[]> {
    if (this.session.isGameOver) {
      return [];
    }

    this.session.isPlaying = false;
    this.session.isGameOver = true;
    
    // 保存统计
    const totalGames = await getNumber('total_games', 0);
    await saveNumber('total_games', totalGames + 1);
    
    const totalCorrect = await getNumber('total_correct', 0);
    await saveNumber('total_correct', totalCorrect + this.session.correctCount);

    const totalWrong = await getNumber('total_wrong', 0);
    await saveNumber('total_wrong', totalWrong + this.session.wrongCount);
    
    const highScore = await getNumber('high_score', 0);
    const isNewRecord = this.session.score > highScore;
    if (isNewRecord) {
      await saveNumber('high_score', this.session.score);
    }
    
    // 检查成就
    const unlockedAchievements: Achievement[] = [];
    
    // 首次游戏
    if (totalGames === 0) {
      const result = await updateAchievementProgress('first_game', 1);
      unlockedAchievements.push(...result);
    }
    
    // 总游戏次数
    const gamesResult = await updateAchievementProgress('total_games', totalGames + 1);
    unlockedAchievements.push(...gamesResult);
    
    // 总答对题数
    const correctResult = await updateAchievementProgress('total_correct', totalCorrect + this.session.correctCount);
    unlockedAchievements.push(...correctResult);
    
    // 单局最高分
    const scoreResult = await updateAchievementProgress('max_score', this.session.score);
    unlockedAchievements.push(...scoreResult);
    
    // 总积分
    const totalScore = await getNumber('total_score', 0);
    await saveNumber('total_score', totalScore + this.session.score);
    const totalScoreResult = await updateAchievementProgress('total_score', totalScore + this.session.score);
    unlockedAchievements.push(...totalScoreResult);
    
    // 保存已玩成语记录
    await saveString('played_idioms', JSON.stringify(this.session.usedIndices));
    
    return unlockedAchievements;
  }
  
  /**
   * 获取游戏会话
   */
  getSession(): GameSession {
    return {
      mode: this.session.mode,
      score: this.session.score,
      correctCount: this.session.correctCount,
      wrongCount: this.session.wrongCount,
      consecutiveCorrect: this.session.consecutiveCorrect,
      currentLevel: this.session.currentLevel,
      remainingTime: this.session.remainingTime,
      isPlaying: this.session.isPlaying,
      isGameOver: this.session.isGameOver,
      lives: this.session.lives,
      records: this.session.records,
      usedIndices: this.session.usedIndices
    };
  }
  
  /**
   * 获取当前分数
   */
  getScore(): number {
    return this.session.score;
  }
  
  /**
   * 获取答对题数
   */
  getCorrectCount(): number {
    return this.session.correctCount;
  }
  
  /**
   * 获取答错题数
   */
  getWrongCount(): number {
    return this.session.wrongCount;
  }
  
  /**
   * 获取总答题数
   */
  getTotalQuestions(): number {
    return this.session.records.length;
  }
  
  /**
   * 获取当前关卡（闯关模式）
   */
  getCurrentLevel(): number {
    return this.session.currentLevel;
  }

  /**
   * 获取当前生命值（闯关模式）
   */
  getLives(): number {
    return this.session.lives || 0;
  }
  
  /**
   * 获取连续答对题数
   */
  getConsecutiveCorrect(): number {
    return this.session.consecutiveCorrect;
  }
  
  /**
   * 更新剩余时间（计时模式）
   */
  updateRemainingTime(time: number): void {
    this.session.remainingTime = time;
    
    if (time <= 0) {
      this.endGame();
    }
  }
  
  /**
   * 获取最高分
   */
  async getHighScore(): Promise<number> {
    return await getNumber('high_score', 0);
  }
  
  /**
   * 获取总游戏次数
   */
  async getTotalGames(): Promise<number> {
    return await getNumber('total_games', 0);
  }
  
  /**
   * 获取总答对题数
   */
  async getTotalCorrect(): Promise<number> {
    return await getNumber('total_correct', 0);
  }
}
