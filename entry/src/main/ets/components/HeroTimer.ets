import { formatTime, STATUS_IDLE, STATUS_RUNNING, STATUS_PAUSED } from '../model/BlindLevel';
import { COLOR_TRACK, COLOR_GREEN, COLOR_YELLOW, COLOR_RED, COLOR_TEXT_SUB } from '../model/Theme';

const RING_SIZE: number = 280;
const RING_STROKE: number = 14;
const MARKER_SIZE: number = 18;

@Component
export struct HeroTimer {
  @Prop @Watch('onRedraw') remainingSeconds: number = 0;
  @Prop @Watch('onRedraw') totalSeconds: number = 1;
  @Prop @Watch('onRedraw') status: string = STATUS_IDLE;
  @Prop @Watch('onRedraw') isRest: boolean = false;
  @Prop levelNumber: number = 1;
  @State breathUp: boolean = false;
  private breathTimer: number = -1;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private canvasReady: boolean = false;

  aboutToAppear(): void {
    this.breathTimer = setInterval(() => {
      if (this.isBreathing()) {
        this.breathUp = !this.breathUp;
      } else if (this.breathUp) {
        this.breathUp = false;
      }
    }, 450);
  }

  aboutToDisappear(): void {
    if (this.breathTimer !== -1) {
      clearInterval(this.breathTimer);
      this.breathTimer = -1;
    }
  }

  onRedraw(): void {
    this.draw();
  }

  isBreathing(): boolean {
    return this.status === STATUS_RUNNING && this.remainingSeconds > 0 && this.remainingSeconds <= 30;
  }

  progress(): number {
    const total: number = this.totalSeconds > 0 ? this.totalSeconds : 1;
    return Math.max(0, Math.min(1, this.remainingSeconds / total));
  }

  ringColor(): string {
    if (this.status === STATUS_PAUSED) {
      return COLOR_YELLOW;
    }
    return this.isRest ? COLOR_GREEN : COLOR_RED;
  }

  breathScale(): number {
    return (this.isBreathing() && this.breathUp) ? 1.12 : 1.0;
  }

  draw(): void {
    if (!this.canvasReady) {
      return;
    }
    const ctx: CanvasRenderingContext2D = this.context;
    const cx: number = RING_SIZE / 2;
    const cy: number = RING_SIZE / 2;
    const r: number = RING_SIZE / 2 - RING_STROKE / 2 - 2;
    const progress: number = this.progress();
    const startAngle: number = -Math.PI / 2;
    const endAngle: number = -Math.PI / 2 + progress * 2 * Math.PI;
    const color: string = this.ringColor();

    ctx.clearRect(0, 0, RING_SIZE, RING_SIZE);

    ctx.beginPath();
    ctx.arc(cx, cy, r, 0, 2 * Math.PI);
    ctx.strokeStyle = COLOR_TRACK;
    ctx.lineWidth = RING_STROKE;
    ctx.lineCap = 'round';
    ctx.stroke();

    if (progress > 0) {
      ctx.beginPath();
      ctx.arc(cx, cy, r, startAngle, endAngle);
      ctx.strokeStyle = color;
      ctx.lineWidth = RING_STROKE;
      ctx.lineCap = 'round';
      ctx.stroke();
    }

    const mx: number = cx + r * Math.cos(endAngle);
    const my: number = cy + r * Math.sin(endAngle);
    ctx.beginPath();
    ctx.arc(mx, my, MARKER_SIZE / 2, 0, 2 * Math.PI);
    ctx.fillStyle = color;
    ctx.fill();
  }

  build() {
    Stack() {
      Canvas(this.context)
        .width(RING_SIZE)
        .height(RING_SIZE)
        .onReady(() => {
          this.canvasReady = true;
          this.draw();
        })
      Column() {
        Text(formatTime(this.remainingSeconds))
          .fontSize(72)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.ringColor())
          .scale({ x: this.breathScale(), y: this.breathScale() })
          .animation({ duration: 420, curve: Curve.EaseInOut })
        Text(this.subLabel())
          .fontSize(15)
          .fontColor(COLOR_TEXT_SUB)
          .margin({ top: 6 })
      }
      .justifyContent(FlexAlign.Center)
    }
    .width(RING_SIZE)
    .height(RING_SIZE)
  }

  subLabel(): string {
    if (this.isRest) {
      return 'Level ' + this.levelNumber.toString() + ' · 休息';
    }
    return 'Level ' + this.levelNumber.toString();
  }
}
