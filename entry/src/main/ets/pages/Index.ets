import { BlindLevel, createDefaultLevels, deserializeLevels, serializeLevels, STATUS_IDLE, STATUS_RUNNING, STATUS_PAUSED } from '../model/BlindLevel';
import { COLOR_BG, COLOR_ACCENT, COLOR_TEXT_SUB } from '../model/Theme';
import { TimerPage } from '../components/TimerPage';
import { StructurePage } from '../components/StructurePage';

const STORAGE_KEY: string = 'blind_levels_json';

@Entry
@Component
struct Index {
  @State @Watch('syncFromLevels') levels: BlindLevel[] = createDefaultLevels();
  @State currentIndex: number = 0;
  @State status: string = STATUS_IDLE;
  @State remainingSeconds: number = 0;
  @State activeTab: number = 0;
  private timerId: number = -1;
  private tabsController: TabsController = new TabsController();

  aboutToAppear(): void {
    PersistentStorage.persistProp(STORAGE_KEY, '');
    const json: string = AppStorage.get<string>(STORAGE_KEY) ?? '';
    this.levels = deserializeLevels(json);
    this.currentIndex = 0;
    this.status = STATUS_IDLE;
    this.remainingSeconds = this.levels.length > 0 ? this.levels[0].durationSeconds : 0;
  }

  aboutToDisappear(): void {
    this.stopTicking();
  }

  syncFromLevels(): void {
    if (this.levels.length === 0) {
      this.currentIndex = 0;
      this.remainingSeconds = 0;
    } else if (this.currentIndex >= this.levels.length) {
      this.currentIndex = this.levels.length - 1;
      this.remainingSeconds = this.levels[this.currentIndex].durationSeconds;
    } else if (this.status === STATUS_IDLE) {
      this.remainingSeconds = this.levels[this.currentIndex].durationSeconds;
    }
    this.saveLevels();
  }

  saveLevels(): void {
    AppStorage.setOrCreate(STORAGE_KEY, serializeLevels(this.levels));
  }

  startTicking(): void {
    if (this.timerId !== -1) {
      return;
    }
    this.timerId = setInterval(() => {
      this.tick();
    }, 1000);
  }

  stopTicking(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  tick(): void {
    if (this.status !== STATUS_RUNNING) {
      return;
    }
    if (this.remainingSeconds > 0) {
      this.remainingSeconds -= 1;
    }
    if (this.remainingSeconds <= 0) {
      this.advanceLevel();
    }
  }

  advanceLevel(): void {
    if (this.currentIndex < this.levels.length - 1) {
      this.currentIndex += 1;
      this.remainingSeconds = this.levels[this.currentIndex].durationSeconds;
    } else {
      this.stopTicking();
      this.status = STATUS_IDLE;
      this.remainingSeconds = 0;
    }
  }

  togglePlay(): void {
    if (this.status === STATUS_RUNNING) {
      this.pause();
    } else {
      this.start();
    }
  }

  start(): void {
    if (this.levels.length === 0) {
      return;
    }
    if (this.status === STATUS_IDLE && this.remainingSeconds <= 0) {
      this.remainingSeconds = this.levels[this.currentIndex].durationSeconds;
    }
    this.status = STATUS_RUNNING;
    this.startTicking();
  }

  pause(): void {
    this.status = STATUS_PAUSED;
    this.stopTicking();
  }

  goToLevel(index: number): void {
    if (this.levels.length === 0) {
      return;
    }
    const clamped: number = Math.max(0, Math.min(this.levels.length - 1, index));
    this.currentIndex = clamped;
    this.remainingSeconds = this.levels[clamped].durationSeconds;
    this.stopTicking();
    this.status = STATUS_IDLE;
  }

  previousLevel(): void {
    this.goToLevel(this.currentIndex - 1);
  }

  nextLevel(): void {
    this.goToLevel(this.currentIndex + 1);
  }

  adjustSeconds(delta: number): void {
    this.remainingSeconds = Math.max(0, this.remainingSeconds + delta);
  }

  resetToStart(): void {
    this.stopTicking();
    this.currentIndex = 0;
    this.remainingSeconds = this.levels.length > 0 ? this.levels[0].durationSeconds : 0;
    this.status = STATUS_IDLE;
    this.activeTab = 0;
    this.tabsController.changeIndex(0);
  }

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
      TabContent() {
        TimerPage({
          levels: $levels,
          currentIndex: $currentIndex,
          status: $status,
          remainingSeconds: $remainingSeconds,
          onToggle: () => { this.togglePlay(); },
          onPrevious: () => { this.previousLevel(); },
          onNext: () => { this.nextLevel(); },
          onAdjust: (delta: number) => { this.adjustSeconds(delta); }
        })
      }
      .tabBar(this.tabBuilder('计时', 0))

      TabContent() {
        StructurePage({
          levels: $levels,
          onFinishEdit: () => { this.resetToStart(); }
        })
      }
      .tabBar(this.tabBuilder('盲注结构', 1))
    }
    .barHeight(62)
    .barBackgroundColor(Color.White)
    .onChange((index: number) => { this.activeTab = index; })
    .backgroundColor(COLOR_BG)
    .width('100%')
    .height('100%')
  }

  @Builder
  tabBuilder(label: string, idx: number) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(14)
        .fontWeight(this.activeTab === idx ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.activeTab === idx ? COLOR_ACCENT : COLOR_TEXT_SUB)
      Row()
        .width(20)
        .height(3)
        .borderRadius(2)
        .backgroundColor(this.activeTab === idx ? COLOR_ACCENT : Color.Transparent)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
