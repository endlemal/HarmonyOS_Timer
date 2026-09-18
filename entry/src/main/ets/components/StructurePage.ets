import { BlindLevel, nextLevelId, LEVEL_NORMAL } from '../model/BlindLevel';
import { COLOR_BG, COLOR_CARD, COLOR_TEXT, COLOR_TEXT_SUB, COLOR_ACCENT, COLOR_RED, COLOR_BORDER } from '../model/Theme';
import { LevelCard } from './LevelCard';

@Component
export struct StructurePage {
  @Link levels: BlindLevel[];
  onFinishEdit: () => void = () => {};

  build() {
    Column() {
      Row() {
        Text('盲注结构表')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor(COLOR_TEXT)
        Blank()
        Text('左滑层级可删除')
          .fontSize(12)
          .fontColor(COLOR_TEXT_SUB)
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 24 })

      List({ space: 12 }) {
        ForEach(this.levels, (level: BlindLevel, index: number) => {
          ListItem() {
            LevelCard({ level: level, index: index + 1 })
          }
          .width('100%')
          .swipeAction({ end: this.deleteButton(level) })
        }, (level: BlindLevel) => level.id.toString())
      }
      .layoutWeight(1)
      .width('100%')
      .padding({ left: 20, right: 20 })
      .scrollBar(BarState.Off)
      .margin({ top: 16 })

      Column({ space: 12 }) {
        Button('+ 新增层级')
          .width('100%')
          .height(50)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(COLOR_TEXT)
          .backgroundColor(COLOR_CARD)
          .border({ width: 1, color: COLOR_BORDER })
          .borderRadius(16)
          .onClick(() => { this.addLevel(); })

        Button('完成编辑')
          .width('100%')
          .height(54)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .backgroundColor(COLOR_ACCENT)
          .borderRadius(16)
          .shadow({ radius: 14, color: 'rgba(224,53,47,0.35)', offsetY: 5 })
          .onClick(() => { this.onFinishEdit(); })
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLOR_BG)
  }

  @Builder
  deleteButton(level: BlindLevel) {
    Text('删除')
      .fontSize(14)
      .fontWeight(FontWeight.Bold)
      .fontColor(Color.White)
      .textAlign(TextAlign.Center)
      .width(76)
      .height('100%')
      .backgroundColor(COLOR_RED)
      .borderRadius(16)
      .onClick(() => { this.deleteLevel(level.id); })
  }

  deleteLevel(id: number): void {
    const newLevels: BlindLevel[] = [];
    for (let i = 0; i < this.levels.length; i++) {
      if (this.levels[i].id !== id) {
        newLevels.push(this.levels[i]);
      }
    }
    this.levels = newLevels;
  }

  addLevel(): void {
    const newLevels: BlindLevel[] = [];
    for (let i = 0; i < this.levels.length; i++) {
      newLevels.push(this.levels[i]);
    }
    newLevels.push(new BlindLevel(nextLevelId(), LEVEL_NORMAL, 20 * 60, 0, 0, 0));
    this.levels = newLevels;
  }
}
