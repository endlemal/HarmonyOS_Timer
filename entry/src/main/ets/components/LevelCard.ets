import { BlindLevel, LEVEL_NORMAL, LEVEL_BREAK, LEVEL_ADD_ON_BREAK } from '../model/BlindLevel';
import { COLOR_CARD, COLOR_TEXT, COLOR_TEXT_SUB, COLOR_ACCENT, COLOR_BORDER, COLOR_FIELD_BG } from '../model/Theme';

@Component
struct NumberField {
  @Prop label: string = '';
  @Prop value: number = 0;
  onChange: (v: number) => void = (v: number) => {};
  @State text: string = '';

  aboutToAppear(): void {
    this.text = this.value.toString();
  }

  build() {
    Row() {
      Text(this.label)
        .fontSize(12)
        .fontColor(COLOR_TEXT_SUB)
        .width(60)
      TextInput({ text: this.text, placeholder: '0' })
        .type(InputType.Number)
        .fontSize(14)
        .fontColor(COLOR_TEXT)
        .backgroundColor(COLOR_FIELD_BG)
        .borderRadius(10)
        .height(38)
        .layoutWeight(1)
        .onChange((v: string) => {
          this.text = v;
          this.onChange(parseInt(v) || 0);
        })
    }
    .layoutWeight(1)
  }
}

@Component
export struct LevelCard {
  @ObjectLink level: BlindLevel;
  @Prop index: number = 1;

  build() {
    Column() {
      Row() {
        Text('Level ' + this.index.toString())
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(COLOR_TEXT)
        Blank()
        Row({ space: 6 }) {
          this.typeChip('normal', LEVEL_NORMAL)
          this.typeChip('break', LEVEL_BREAK)
          this.typeChip('add-on', LEVEL_ADD_ON_BREAK)
        }
      }
      .width('100%')

      if (this.level.type === LEVEL_NORMAL) {
        Column({ space: 10 }) {
          Row({ space: 12 }) {
            NumberField({ label: '小盲', value: this.level.smallBlind, onChange: (v: number) => { this.level.smallBlind = v; } })
            NumberField({ label: '大盲', value: this.level.bigBlind, onChange: (v: number) => { this.level.bigBlind = v; } })
          }
          .width('100%')

          Row({ space: 12 }) {
            NumberField({ label: 'Ante', value: this.level.ante, onChange: (v: number) => { this.level.ante = v; } })
            NumberField({ label: '时间(分)', value: this.durationMinutes(), onChange: (v: number) => { this.level.durationSeconds = v * 60; } })
          }
          .width('100%')
        }
        .margin({ top: 12 })
      } else {
        Row({ space: 12 }) {
          NumberField({ label: '时长(分)', value: this.durationMinutes(), onChange: (v: number) => { this.level.durationSeconds = v * 60; } })
        }
        .width('100%')
        .margin({ top: 12 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(COLOR_CARD)
    .borderRadius(20)
    .border({ width: 1, color: COLOR_BORDER })
  }

  durationMinutes(): number {
    return Math.round(this.level.durationSeconds / 60);
  }

  @Builder
  typeChip(label: string, type: string) {
    Text(label)
      .fontSize(11)
      .fontColor(this.level.type === type ? Color.White : COLOR_TEXT_SUB)
      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      .backgroundColor(this.level.type === type ? COLOR_ACCENT : '#F0F0F0')
      .borderRadius(10)
      .onClick(() => { this.level.type = type; })
  }
}
