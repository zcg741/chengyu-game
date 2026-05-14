// WrongBookService.ets - 错题本与复习掌握状态
import { getString, saveString } from './StorageService';

const WRONG_BOOK_KEY = 'wrong_book_records';
const LEGACY_WRONG_WORDS_KEY = 'wrong_words';
const MASTERED_STREAK_TARGET = 3;

export interface WrongBookRecord {
  word: string;
  wrongCount: number;
  reviewCorrectStreak: number;
  mastered: boolean;
  lastWrongAt: string;
  lastReviewedAt: string;
}

export interface WrongBookStats {
  total: number;
  pending: number;
  mastered: number;
}

async function getRecordMap(): Promise<Record<string, WrongBookRecord>> {
  try {
    const json = await getString(WRONG_BOOK_KEY, '{}');
    const map = JSON.parse(json) as Record<string, WrongBookRecord>;

    const legacyWords = await getString(LEGACY_WRONG_WORDS_KEY, '');
    if (legacyWords) {
      const now = new Date().toISOString();
      legacyWords.split(',').filter(word => word.length > 0).forEach(word => {
        if (!map[word]) {
          map[word] = {
            word: word,
            wrongCount: 1,
            reviewCorrectStreak: 0,
            mastered: false,
            lastWrongAt: now,
            lastReviewedAt: ''
          };
        }
      });
    }

    return map;
  } catch (error) {
    console.error('WrongBookService.getRecordMap error:', error);
    return {};
  }
}

async function saveRecordMap(map: Record<string, WrongBookRecord>): Promise<void> {
  await saveString(WRONG_BOOK_KEY, JSON.stringify(map));
  const legacyWords: string[] = [];
  Object.keys(map).forEach(word => {
    if (!map[word].mastered) {
      legacyWords.push(word);
    }
  });
  await saveString(LEGACY_WRONG_WORDS_KEY, legacyWords.join(','));
}

export async function recordWrongAnswer(word: string): Promise<void> {
  if (!word) {
    return;
  }

  const map = await getRecordMap();
  const now = new Date().toISOString();
  const current = map[word];

  if (current) {
    current.wrongCount++;
    current.reviewCorrectStreak = 0;
    current.mastered = false;
    current.lastWrongAt = now;
  } else {
    map[word] = {
      word: word,
      wrongCount: 1,
      reviewCorrectStreak: 0,
      mastered: false,
      lastWrongAt: now,
      lastReviewedAt: ''
    };
  }

  await saveRecordMap(map);
}

export async function recordReviewResult(word: string, isCorrect: boolean): Promise<void> {
  if (!word) {
    return;
  }

  const map = await getRecordMap();
  const now = new Date().toISOString();
  const current = map[word];

  if (!current) {
    return;
  }

  current.lastReviewedAt = now;
  if (isCorrect) {
    current.reviewCorrectStreak++;
    if (current.reviewCorrectStreak >= MASTERED_STREAK_TARGET) {
      current.mastered = true;
    }
  } else {
    current.wrongCount++;
    current.reviewCorrectStreak = 0;
    current.mastered = false;
    current.lastWrongAt = now;
  }

  await saveRecordMap(map);
}

export async function getWrongBookRecords(includeMastered: boolean = true): Promise<WrongBookRecord[]> {
  const map = await getRecordMap();
  const result: WrongBookRecord[] = [];
  Object.keys(map).forEach(word => {
    const record = map[word];
    if (includeMastered || !record.mastered) {
      result.push(record);
    }
  });
  return result.sort((a, b) => b.wrongCount - a.wrongCount);
}

export async function getPendingWrongWords(): Promise<string[]> {
  const records = await getWrongBookRecords(false);
  return records.map(record => record.word);
}

export async function getWrongBookStats(): Promise<WrongBookStats> {
  const records = await getWrongBookRecords(true);
  const mastered = records.filter(record => record.mastered).length;
  return {
    total: records.length,
    pending: records.length - mastered,
    mastered: mastered
  };
}

export async function clearWrongBook(): Promise<void> {
  await saveString(WRONG_BOOK_KEY, '{}');
  await saveString(LEGACY_WRONG_WORDS_KEY, '');
}
