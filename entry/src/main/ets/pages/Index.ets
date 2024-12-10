import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    // RelativeContainer() { //RelativeContainer(相对布局).
    //   Text(this.message)
    //     .id('HelloWorld')
    //     .fontSize(50)
    //     .fontWeight(FontWeight.Bold)
    //     .alignRules({
    //       center: { anchor: '__container__', align: VerticalAlign.Center },
    //       middle: { anchor: '__container__', align: HorizontalAlign.Center }
    //     })
    // }
    // .height('100%')
    // .width('100%')

    Column({ space: 16 }) { //Column(线性布局-垂直方向).
      Row() { //Row(线性布局-水平方向).
        Button() { //Button(按钮控件).
          Text('Next')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
        }
        .id("bt")
        .type(ButtonType.Capsule)
        .margin({
          left: 10
        })
        .backgroundColor('#0D9FFB')
        .width('50%')
        .height('50%')
        .onClick(() => { //按钮绑定onClick事件.
          console.info(`Succeeded in clicking the 'Next' button.`)
          router.pushUrl({ url: 'pages/SecondPage' }).then(() => { //跳转到第二个界面.
            console.info('Succeeded in jumping to the second page.')
          }).catch((err: BusinessError) => {
            console.error(`Failed to jump to the second page. Code is ${err.code}, message is ${err.message}`)
          })
        })
      }
      .width('100%')
      .height('20%')
      .backgroundColor('#666666')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#00EAFF')

  }
}