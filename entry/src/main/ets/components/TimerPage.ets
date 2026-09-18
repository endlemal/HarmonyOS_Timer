import { BlindLevel, formatTime, isBreakLevel, LEVEL_NORMAL, STATUS_IDLE, STATUS_RUNNING, STATUS_PAUSED } from '../model/BlindLevel';
import { COLOR_BG, COLOR_CARD, COLOR_TEXT, COLOR_TEXT_SUB, COLOR_ACCENT, COLOR_GREEN, COLOR_YELLOW, COLOR_RED, COLOR_BORDER } from '../model/Theme';
import { HeroTimer } from './HeroTimer';

@Component
export struct TimerPage {
  @Link levels: BlindLevel[];
  @Link currentIndex: number;
  @Link status: string;
  @Link remainingSeconds: number;
  onToggle: () => void = () => {};
  onPrevious: () => void = () => {};
  onNext: () => void = () => {};
  onAdjust: (delta: number) => void = (delta: number) => {};

  build() {
    Column() {
      Row() {
        Text('盲注计时器')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor(COLOR_TEXT)
        Blank()
        Text(this.statusLabel())
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .padding({ left: 12, right: 12, top: 5, bottom: 5 })
          .backgroundColor(this.statusColor())
          .borderRadius(12)
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 24 })

      HeroTimer({
        remainingSeconds: this.remainingSeconds,
        totalSeconds: this.currentTotal(),
        status: this.status,
        isRest: this.currentIsRest(),
        levelNumber: this.currentIndex + 1
      })
      .margin({ top: 36 })

      this.levelInfo()

      Blank()

      this.controls()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLOR_BG)
  }

  currentLevel(): BlindLevel {
    if (this.levels.length === 0) {
      return new BlindLevel(0, LEVEL_NORMAL, 0, 0, 0, 0);
    }
    const idx: number = Math.max(0, Math.min(this.currentIndex, this.levels.length - 1));
    return this.levels[idx];
  }

  currentTotal(): number {
    return this.currentLevel().durationSeconds;
  }

  currentIsRest(): boolean {
    return isBreakLevel(this.currentLevel().type);
  }

  statusLabel(): string {
    if (this.status === STATUS_RUNNING) {
      return this.currentIsRest() ? '休息' : '进行';
    }
    if (this.status === STATUS_PAUSED) {
      return '暂停';
    }
    return '静止';
  }

  statusColor(): string {
    if (this.status === STATUS_PAUSED) {
      return COLOR_YELLOW;
    }
    if (this.status === STATUS_RUNNING && this.currentIsRest()) {
      return COLOR_GREEN;
    }
    return COLOR_RED;
  }

  playLabel(): string {
    if (this.status === STATUS_RUNNING) {
      return '暂停';
    }
    if (this.status === STATUS_PAUSED) {
      return '继续';
    }
    return '开始';
  }

  @Builder
  levelInfo() {
    if (this.levels.length === 0) {
      Text('暂无层级，请先编辑盲注结构')
        .fontSize(15)
        .fontColor(COLOR_TEXT_SUB)
        .margin({ top: 30 })
    } else if (this.currentIsRest()) {
      Text('休息 · ' + formatTime(this.currentLevel().durationSeconds))
        .fontSize(16)
        .fontColor(COLOR_TEXT_SUB)
        .margin({ top: 30 })
    } else {
      Row({ space: 28 }) {
        this.statBlock('小盲', this.currentLevel().smallBlind.toString())
        this.statBlock('大盲', this.currentLevel().bigBlind.toString())
        this.statBlock('Ante', this.currentLevel().ante.toString())
      }
      .margin({ top: 30 })
    }
  }

  @Builder
  statBlock(label: string, value: string) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontColor(COLOR_TEXT_SUB)
      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(COLOR_TEXT)
        .margin({ top: 2 })
    }
  }

  @Builder
  controls() {
    Row() {
      Stack() {
        Text('上一')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(COLOR_TEXT)
      }
      .width(52)
      .height(52)
      .borderRadius(16)
      .backgroundColor(COLOR_CARD)
      .border({ width: 1, color: COLOR_BORDER })
      .onClick(() => { this.onPrevious(); })

      Stack() {
        Text('-15s')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(COLOR_TEXT)
      }
      .width(52)
      .height(52)
      .borderRadius(16)
      .backgroundColor(COLOR_CARD)
      .border({ width: 1, color: COLOR_BORDER })
      .onClick(() => { this.onAdjust(-15); })

      Stack() {
        Text(this.playLabel())
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
      }
      .width(72)
      .height(72)
      .borderRadius(36)
      .backgroundColor(COLOR_ACCENT)
      .shadow({ radius: 14, color: 'rgba(224,53,47,0.35)', offsetY: 5 })
      .onClick(() => { this.onToggle(); })

      Stack() {
        Text('+15s')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(COLOR_TEXT)
      }
      .width(52)
      .height(52)
      .borderRadius(16)
      .backgroundColor(COLOR_CARD)
      .border({ width: 1, color: COLOR_BORDER })
      .onClick(() => { this.onAdjust(15); })

      Stack() {
        Text('下一')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(COLOR_TEXT)
      }
      .width(52)
      .height(52)
      .borderRadius(16)
      .backgroundColor(COLOR_CARD)
      .border({ width: 1, color: COLOR_BORDER })
      .onClick(() => { this.onNext(); })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .padding({ left: 20, right: 20 })
    .margin({ bottom: 28 })
  }
}
