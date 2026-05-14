// QuestionService.ets - 统一出题与答案判定服务
import { Chengyu } from '../model/ChengyuModel';
import { QUESTION_TYPE } from '../utils/Constants';
import { generateHintFromPinyin, generatePinyinHintFromPinyin } from '../utils/PinyinUtil';

const EASY_TYPES: string[] = [QUESTION_TYPE.PINYIN, QUESTION_TYPE.FILL_BLANK];
const HARD_TYPES: string[] = [QUESTION_TYPE.EXPLANATION, QUESTION_TYPE.DRAGON];
const ALL_TYPES: string[] = [QUESTION_TYPE.PINYIN, QUESTION_TYPE.FILL_BLANK, QUESTION_TYPE.EXPLANATION, QUESTION_TYPE.DRAGON];
const NEW_USER_GAME_LIMIT: number = 3;

export function createSeededRandom(seed: number): () => number {
  let state = Math.abs(Math.floor(seed)) % 2147483647;
  if (state === 0) {
    state = 1;
  }

  return () => {
    state = (state * 48271) % 2147483647;
    return state / 2147483647;
  };
}

export function normalizeAnswer(value: string): string {
  return value.replace(/[！!，,。.\、?？;；:：""''（）()\s]/g, '');
}

export function isAnswerCorrect(userAnswer: string, answer: string): boolean {
  return normalizeAnswer(userAnswer.trim()) === normalizeAnswer(answer);
}

export function generateFillBlank(word: string, seed?: number): string {
  if (!word || word.length < 4) {
    return word;
  }

  const len = word.length;
  const random = seed === undefined ? Math.random : createSeededRandom(seed);
  const hideCount = Math.min(Math.floor(random() * 2) + 1, len - 1);
  const indices: number[] = [];
  for (let i = 0; i < len; i++) {
    indices.push(i);
  }

  for (let i = indices.length - 1; i > 0; i--) {
    const j = Math.floor(random() * (i + 1));
    const temp = indices[i];
    indices[i] = indices[j];
    indices[j] = temp;
  }

  const hideIdx = new Set<number>(indices.slice(0, hideCount));
  return word.split('').map((ch: string, i: number) => hideIdx.has(i) ? '_' : ch).join('');
}

export function getQuestionPrompt(chengyu: Chengyu, questionType: string, prevLastChar: string = '', seed?: number): string {
  if (questionType === QUESTION_TYPE.EXPLANATION) {
    return chengyu.explanation || '';
  }
  if (questionType === QUESTION_TYPE.PINYIN) {
    return chengyu.pinyin || '';
  }
  if (questionType === QUESTION_TYPE.FILL_BLANK) {
    return generateFillBlank(chengyu.word, seed);
  }
  if (prevLastChar) {
    return `尾字「${prevLastChar}」，猜以它开头的成语！`;
  }
  return chengyu.explanation || '';
}

export function getHintText(word: string, pinyin: string, hintLevel: number): string {
  return generateHintFromPinyin(word, pinyin, hintLevel);
}

export function getPinyinHintText(word: string, pinyin: string, revealedCount: number): string {
  return generatePinyinHintFromPinyin(word, pinyin, revealedCount);
}

export function pickDynamicQuestionType(recentResults: boolean[], totalGames: number): string {
  if (totalGames < NEW_USER_GAME_LIMIT) {
    return EASY_TYPES[Math.floor(Math.random() * EASY_TYPES.length)];
  }

  if (recentResults.length === 0) {
    return ALL_TYPES[Math.floor(Math.random() * ALL_TYPES.length)];
  }

  const correctCount = recentResults.filter((result: boolean) => result).length;
  const correctRate = correctCount / recentResults.length;

  if (correctRate >= 0.6) {
    if (Math.random() < 0.7) {
      return HARD_TYPES[Math.floor(Math.random() * HARD_TYPES.length)];
    }
    return EASY_TYPES[Math.floor(Math.random() * EASY_TYPES.length)];
  }

  if (correctRate <= 0.4) {
    if (Math.random() < 0.7) {
      return EASY_TYPES[Math.floor(Math.random() * EASY_TYPES.length)];
    }
    return HARD_TYPES[Math.floor(Math.random() * HARD_TYPES.length)];
  }

  return ALL_TYPES[Math.floor(Math.random() * ALL_TYPES.length)];
}

export function getQuestionTypeName(questionType: string): string {
  if (questionType === QUESTION_TYPE.PINYIN) {
    return '拼音猜词';
  }
  if (questionType === QUESTION_TYPE.FILL_BLANK) {
    return '填空挑战';
  }
  if (questionType === QUESTION_TYPE.DRAGON) {
    return '成语接龙';
  }
  return '释义猜词';
}

export function getQuestionTypeIcon(questionType: string): string {
  if (questionType === QUESTION_TYPE.PINYIN) {
    return '🔤';
  }
  if (questionType === QUESTION_TYPE.FILL_BLANK) {
    return '✏️';
  }
  if (questionType === QUESTION_TYPE.DRAGON) {
    return '🐉';
  }
  return '📖';
}
