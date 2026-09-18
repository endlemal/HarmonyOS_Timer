export const LEVEL_NORMAL: string = 'normal';
export const LEVEL_BREAK: string = 'break';
export const LEVEL_ADD_ON_BREAK: string = 'addOnBreak';

export const STATUS_IDLE: string = 'idle';
export const STATUS_RUNNING: string = 'running';
export const STATUS_PAUSED: string = 'paused';

@Observed
export class BlindLevel {
  id: number;
  type: string;
  smallBlind: number;
  bigBlind: number;
  ante: number;
  durationSeconds: number;

  constructor(id: number, type: string = LEVEL_NORMAL, durationSeconds: number = 1200,
    smallBlind: number = 0, bigBlind: number = 0, ante: number = 0) {
    this.id = id;
    this.type = type;
    this.durationSeconds = durationSeconds;
    this.smallBlind = smallBlind;
    this.bigBlind = bigBlind;
    this.ante = ante;
  }
}

let levelIdSeed: number = 1000;

export function nextLevelId(): number {
  levelIdSeed += 1;
  return levelIdSeed;
}

export function createDefaultLevels(): BlindLevel[] {
  return [
    new BlindLevel(1, LEVEL_NORMAL, 20 * 60, 25, 50, 0),
    new BlindLevel(2, LEVEL_NORMAL, 20 * 60, 50, 100, 0),
    new BlindLevel(3, LEVEL_NORMAL, 20 * 60, 100, 200, 0)
  ];
}

export function isBreakLevel(type: string): boolean {
  return type === LEVEL_BREAK || type === LEVEL_ADD_ON_BREAK;
}

export function formatTime(totalSeconds: number): string {
  const s: number = Math.max(0, Math.floor(totalSeconds));
  const m: number = Math.floor(s / 60);
  const sec: number = s % 60;
  return m.toString() + ':' + (sec < 10 ? '0' : '') + sec.toString();
}

export function levelTypeLabel(type: string): string {
  if (type === LEVEL_BREAK) {
    return '休息';
  }
  if (type === LEVEL_ADD_ON_BREAK) {
    return 'add-on 休息';
  }
  return 'normal';
}

interface LevelDTO {
  id: number;
  type: string;
  smallBlind: number;
  bigBlind: number;
  ante: number;
  durationSeconds: number;
}

export function serializeLevels(levels: BlindLevel[]): string {
  const arr: LevelDTO[] = [];
  for (let i = 0; i < levels.length; i++) {
    const l: BlindLevel = levels[i];
    const dto: LevelDTO = {
      id: l.id,
      type: l.type,
      smallBlind: l.smallBlind,
      bigBlind: l.bigBlind,
      ante: l.ante,
      durationSeconds: l.durationSeconds
    };
    arr.push(dto);
  }
  return JSON.stringify(arr);
}

export function deserializeLevels(json: string): BlindLevel[] {
  if (json === '' || json === undefined || json === null) {
    return createDefaultLevels();
  }
  let arr: LevelDTO[] = [];
  try {
    arr = JSON.parse(json) as LevelDTO[];
  } catch (err) {
    return createDefaultLevels();
  }
  if (arr.length === 0) {
    return createDefaultLevels();
  }
  const result: BlindLevel[] = [];
  for (let i = 0; i < arr.length; i++) {
    const o: LevelDTO = arr[i];
    const id: number = Number(o.id) > 0 ? Number(o.id) : nextLevelId();
    const type: string = (o.type === LEVEL_BREAK || o.type === LEVEL_ADD_ON_BREAK) ? o.type : LEVEL_NORMAL;
    const durationSeconds: number = Number(o.durationSeconds) || 0;
    const smallBlind: number = Number(o.smallBlind) || 0;
    const bigBlind: number = Number(o.bigBlind) || 0;
    const ante: number = Number(o.ante) || 0;
    result.push(new BlindLevel(id, type, durationSeconds, smallBlind, bigBlind, ante));
  }
  return result;
}
