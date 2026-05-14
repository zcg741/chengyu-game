// DailyChallengeService.ets - 每日挑战记录与连续打卡
import { getString, saveString } from './StorageService';

const DAILY_RECORDS_KEY = 'daily_challenge_records';
const LEGACY_DONE_DATE_KEY = 'daily_done_date';

export interface DailyChallengeRecord {
  date: string;
  completed: boolean;
  correctCount: number;
  total: number;
  type: string;
  completedAt: string;
}

export interface DailyChallengeSummary {
  today: string;
  todayCompleted: boolean;
  todayCorrectCount: number;
  todayTotal: number;
  streak: number;
}

export interface DailyChallengeAggregate {
  games: number;
  correct: number;
  wrong: number;
}

function pad2(value: number): string {
  return value < 10 ? `0${value}` : value.toString();
}

export function getTodayDateString(): string {
  const now = new Date();
  return `${now.getFullYear()}-${pad2(now.getMonth() + 1)}-${pad2(now.getDate())}`;
}

function addDays(dateText: string, delta: number): string {
  const parts = dateText.split('-');
  if (parts.length !== 3) {
    return dateText;
  }
  const date = new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]));
  date.setDate(date.getDate() + delta);
  return `${date.getFullYear()}-${pad2(date.getMonth() + 1)}-${pad2(date.getDate())}`;
}

async function getRecordMap(): Promise<Record<string, DailyChallengeRecord>> {
  try {
    const json = await getString(DAILY_RECORDS_KEY, '{}');
    const map = JSON.parse(json) as Record<string, DailyChallengeRecord>;

    const legacyDoneDate = await getString(LEGACY_DONE_DATE_KEY, '');
    if (legacyDoneDate && !map[legacyDoneDate]) {
      map[legacyDoneDate] = {
        date: legacyDoneDate,
        completed: true,
        correctCount: 0,
        total: 0,
        type: '',
        completedAt: legacyDoneDate
      };
    }

    return map;
  } catch (error) {
    console.error('DailyChallengeService.getRecordMap error:', error);
    return {};
  }
}

async function saveRecordMap(map: Record<string, DailyChallengeRecord>): Promise<void> {
  await saveString(DAILY_RECORDS_KEY, JSON.stringify(map));
}

export async function saveDailyChallengeResult(date: string, correctCount: number, total: number, type: string): Promise<void> {
  const map = await getRecordMap();
  map[date] = {
    date: date,
    completed: true,
    correctCount: correctCount,
    total: total,
    type: type,
    completedAt: new Date().toISOString()
  };
  await saveRecordMap(map);
  await saveString(LEGACY_DONE_DATE_KEY, date);
}

export async function getDailyChallengeRecord(date: string): Promise<DailyChallengeRecord | undefined> {
  const map = await getRecordMap();
  return map[date];
}

export async function getDailyChallengeSummary(today: string = getTodayDateString()): Promise<DailyChallengeSummary> {
  const map = await getRecordMap();
  const todayRecord = map[today];
  let streak = 0;
  let cursor = today;

  while (map[cursor] && map[cursor].completed) {
    streak++;
    cursor = addDays(cursor, -1);
  }

  return {
    today: today,
    todayCompleted: !!(todayRecord && todayRecord.completed),
    todayCorrectCount: todayRecord ? todayRecord.correctCount : 0,
    todayTotal: todayRecord ? todayRecord.total : 0,
    streak: streak
  };
}

export async function getDailyChallengeAggregate(): Promise<DailyChallengeAggregate> {
  const map = await getRecordMap();
  let games = 0;
  let correct = 0;
  let wrong = 0;

  Object.keys(map).forEach((date: string) => {
    const record = map[date];
    if (record.completed && record.total > 0) {
      games++;
      correct += record.correctCount;
      wrong += Math.max(0, record.total - record.correctCount);
    }
  });

  return {
    games: games,
    correct: correct,
    wrong: wrong
  };
}
