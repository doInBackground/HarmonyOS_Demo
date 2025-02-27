import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { DateUtil, FileUtil, JSONUtil, LogUtil, PreferencesUtil, ResUtil } from '@pura/harmony-utils';
import { efClientApi } from '@yunkss/ef_axios';
import { ErrorEvent, MessageEvents, worker } from '@kit.ArkTS';
import { Element, XmlUtils } from '../utils/XmlUtils';

@Entry
@Component
struct Index {
  workerInstance = new worker.ThreadWorker("entry/ets/workers/Worker.ets"); // 宿主线程中创建Worker对象

  build() {
    Scroll() { //Scroll(滚动布局).
      Column({ space: 16 }) { //Column(线性布局-垂直方向). [space:内部组件间距]
        //====================测试内容开始====================
        //TODO: Test-1:测试跳转界面.
        Row() { //Row(线性布局-水平方向).
          Button() { //Button(按钮控件).
            Text('测试跳转界面')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
          }
          .id("bt")
          .type(ButtonType.Capsule)
          .padding(10)
          .margin({
            top: 10,
            bottom: 10,
            left: 10,
            right: 10,
          })
          .backgroundColor('#0D9FFB')
          .width('50%')
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
        .backgroundColor('#666666')

        //TODO: Test-2:工具类-日志测试.
        Button() { //Button(按钮控件).
          Text('工具类-日志测试')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .padding(10)
        .backgroundColor('#0D9FFB')
        .width('100%')
        .onClick(() => { //按钮绑定onClick事件.
          //**********工具类-日志测试**********
          LogUtil.debug("日志工具类-debug\t", "我是一个日志.")
          LogUtil.info("日志工具类-info\t", "我是一个日志.")
          LogUtil.warn("日志工具类-warn\t", "我是一个日志.")
          LogUtil.error("日志工具类-error\t", "我是一个日志.")
          LogUtil.fatal("日志工具类-fatal\t", "我是一个日志.")
        })

        //TODO: Test-3:工具类-文件测试.
        Button() { //Button(按钮控件).
          Text('工具类-文件测试')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .padding(10)
        .backgroundColor('#0D9FFB')
        .width('100%')
        .onClick(() => { //按钮绑定onClick事件.
          //**********工具类-文件测试**********
          //路径:"/data/storage/el2/base/files"
          console.info(`${getContext().getApplicationContext().filesDir}`)
          //路径:"/data/storage/el2/base/haps/entry/files"
          console.info(`${getContext().filesDir}`)
          //路径:"/data/storage/el2/base/cache"
          console.info(`${getContext().getApplicationContext().cacheDir}`)
          //路径:"/data/storage/el2/base/haps/entry/cache"
          console.info(`${getContext().cacheDir}`)
          /*
          path0:/data/storage/el2/base/files
          path1:/data/storage/el2/base/haps/entry/files
          path2:/data/storage/el2/base/haps/entry/files/zuPus.txt
          path3:/data/storage/el2/base/haps/entry/files/download/wps/ppt/dev.text
          path4:/data/storage/el2/base/haps/entry/files/download/wps/wps
          path5:/data/storage/el2/base/haps/entry/files/download/apk/app.apk
          path6:/data/storage/el2/base/haps/entry/files/download/wps/ppt
          path7:/data/storage/el2/base/haps/entry/cache/download/wps/ppt/dev_s.text
          path8:/data/storage/el2/base/haps/entry/temp/download/wps/ppt/dev_max.text
           */
          let path0 = FileUtil.getFilesDirPath('', '', false);
          let path1 = FileUtil.getFilesDirPath('');
          let path2 = FileUtil.getFilesDirPath("", "zuPus.txt");
          let path3 = FileUtil.getFilesDirPath('download/wps/ppt', 'dev.text');
          let path4 = FileUtil.getFilesDirPath("download/wps/wps");
          let path5 = FileUtil.getFilesDirPath(`${getContext().filesDir}/download/apk`, "app.apk");
          let path6 = FileUtil.getFilesDirPath(`${getContext().filesDir}/download/wps/ppt`);
          let path7 = FileUtil.getCacheDirPath('download/wps/ppt', 'dev_s.text');
          let path8 = FileUtil.getTempDirPath('download/wps/ppt', 'dev_max.text');
          console.info(`路径:\n\npath0:${path0}\n\npath1:${path1}\n\npath2:${path2}\n\npath3:${path3}\n\npath4:${path4}\n\npath5:${path5}\n\npath6:${path6}\n\npath7:${path7}\n\npath8:${path8}`)
        })

        //TODO: Test-4:工具类-PreferencesUtil测试.
        Button() { //Button(按钮控件).
          Text('工具类-PreferencesUtil测试')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .padding(10)
        .backgroundColor('#0D9FFB')
        .width('100%')
        .onClick(() => { //按钮绑定onClick事件.
          //**********工具类-PreferencesUtil测试**********
          let id = PreferencesUtil.getSync('id', '')
          PreferencesUtil.put('id', `${DateUtil.getTodayTime()}`)
          LogUtil.debug(`PreferencesUtil测试: ${id}`)
        })

        //TODO: Test-5:工具类-RawFile内容读取测试.
        Button() { //Button(按钮控件).
          Text('工具类-RawFile内容读取测试')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .padding(10)
        .backgroundColor('#0D9FFB')
        .width('100%')
        .onClick(() => { //按钮绑定onClick事件.
          //**********工具类-RawFile内容读取测试**********
          ResUtil.getRawFileContentStr("settings_novatek.json").then((json) => {
            console.debug(`读取RawFile的JSON文件: \n\n${json}`); //打印.
          })
        })

        //TODO: Test-6:XML解析测试.
        Button() { //Button(按钮控件).
          Text('XML解析测试')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .padding(10)
        .backgroundColor('#0D9FFB')
        .width('100%')
        .onClick(() => { //按钮绑定onClick事件.
          ResUtil.getRawFileContentStr("xmlTestFile.xml").then((xml) => {
            //**********XML解析测试**********
            //数据构建.
            // xml = 'xxxxxxxxxxxxxxxxxx';
            // xml = '<?xml version="1.0" encoding="utf-8"?><note importance="high" logged="true"><company>John &amp; Hans</company><title>Happy</title></note>';
            // xml = '<Function><Cmd>3035</Cmd><Status>0</Status></Function>';
            // xml = '<file><name>/SD/Normal/F/FILE181001-093235-000506F.MOV</name><format size="1920x1080" fps="27" time="60.3">MOV</format><size>92602368</size><attr>RW</attr><time>2018-10-01 09:32:35</time></file>';
            // xml = '<Normal><file><name>/SD/Normal/F/FILE181001-093235-000506F.MOV</name><format size="1920x1080" fps="27" time="60.3">MOV</format><size>92602368</size><attr>RW</attr><time>2018-10-01 09:32:35</time></file></Normal>';
            xml = '<?xml version="1.0" encoding="utf-8"?><Normal><file><name>/SD/Normal/F/FILE181001-093235-000506F.MOV</name><format size="1920x1080" fps="27" time="60.3">MOV</format><size>92602368</size><attr>RW</attr><time>2018-10-01 09:32:35</time></file></Normal>';
            //开始解析.
            console.info(`xml解析:即将开始`); //打印.
            //方式一:自写工具.
            // let list = WclXmlUtils.parse(xml);
            // console.info(`xml解析:${JSONUtil.beanToJsonStr(list)}`); //打印.
            //方式二:开源工具.
            // let json = convert.xml2json(xml) as string
            // console.info(`xml解析:${json}`); //打印.
            //方式三:封装开源工具.
            let element: Element = XmlUtils.parse(xml)
            console.info(`xml解析:${JSONUtil.beanToJsonStr(element)}`); //打印.
          })
        })

        //TODO: Test-7:JSON解析测试.
        Button() { //Button(按钮控件).
          Text('JSON解析测试')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .padding(10)
        .backgroundColor('#0D9FFB')
        .width('100%')
        .onClick(() => { //按钮绑定onClick事件.
          ResUtil.getRawFileContentStr("jsonTestFile.json").then((json) => {
            //**********JSON解析测试**********
            //数据构建.
            // json = 'xxxxxxxxxxxxxxxxxx'; //格式错误时,工具类方法无返回.
            // json = '{"Id": "1080P","Index": 0}';
            // json = '[{"Id": "1080P","Index": 0},{"Id": "2K","Index": 1}]';
            json = '{"device_id":0, "device_name":"CDR", "software":"V1.0", "info":[{"cmd":1001,"status":1},{"cmd":1002,"status":1}]}';
            //工具类-开始测试.
            LogUtil.debug(`json解析:工具解析:即将开始`) //打印.
            let map: Map<string, object> = JSONUtil.jsonToMap(json) //此方法解析数组类型json时,也是key/value形式,key等于数据索引index.
            LogUtil.debug(`json解析:工具解析:完成:${JSONUtil.beanToJsonStr(map)}`) //打印.
            map.forEach((value, key) => {
              LogUtil.error(`json解析:工具解析: key=${key} value=${value}`); //打印.
              if (key == 'info') {
                let info = value as object[]
                info.forEach((value, index) => {
                  LogUtil.error(`json解析:工具解析: cmd=${value["cmd"]} status=${value["status"]}`); //打印.
                })
              }
            })
            //源生类-开始测试.
            //"JSON.parse()"该方法返回的数据类型为"any",即不确定的类型,想要确定实际的类型,需要断点运行"debug模式",通过属性查看.
            LogUtil.debug(`json解析:源生解析:即将开始`) //打印.
            let person: object = JSON.parse('{"name": "WCL", "age": 30, "city": "YC", "scores": [{"subject":"Chinese","score":100},{"subject":"English","score":99}]}')
            let scores: object[] = person["scores"] //JSON.parse()数组时返回的真正数据类型是"Array"类型,"Array"等价于"[]".
            scores.forEach((value, index) => {
              let subject: string = value["subject"]
              let score: number = value["score"]
              LogUtil.error(`json解析:源生解析: ${person['name']}  ${subject}=${score}`); //打印.
            })
          })
        })

        //TODO: Test-8:工具类-下载测试.
        Button() { //Button(按钮控件).
          Text('工具类-下载测试')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .padding(10)
        .backgroundColor('#0D9FFB')
        .width('100%')
        .onClick(() => { //按钮绑定onClick事件.
          //**********工具类-下载测试**********
          efClientApi.download({
            headers: {
              "efAxiosHeader": '旺旺崔冰冰',
            },
            // baseUrl:'http://192.168.1.254', //如有需要则自行设置.为单独接口需要更换基地址时设置(1.0.3+).
            url: 'https://img0.baidu.com/it/u=2191392668,814349101&fm=253&fmt=auto&app=138&f=JPEG?w=800&h=1399',
            filePath: 'download.jpg', //落地文件名.
          }, (progress: number) => {
            LogUtil.debug(`下载进度:${progress}`)
          }).then((value) => {
            LogUtil.debug(`下载进度:发生了神马1. ${value}`)
          }, () => {
            LogUtil.debug("下载进度:发生了神马2.")
          });
        })

        //TODO: Test-9:worker测试.
        Row() { //Row(线性布局-水平方向).
          Button() { //Button(按钮控件).
            Text('worker-启动')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
          }
          .type(ButtonType.Capsule)
          .padding(10)
          .backgroundColor('#0D9FFB')
          .width('50%')
          .onClick(() => { //按钮绑定onClick事件.
            //**********worker测试**********
            // const workerInstance = new worker.ThreadWorker("entry/ets/workers/Worker.ets"); // 宿主线程中创建Worker对象
            // const buffer = new ArrayBuffer(8);
            // workerInstance.postMessage(buffer, [buffer]); // 宿主线程向worker线程传递信息
            this.workerInstance.postMessage("START_SOCKET"); // 宿主线程向worker线程传递信息
            this.workerInstance.onmessage = (e: MessageEvents): void => { // 宿主线程接收worker线程信息
              LogUtil.debug(`worker-socket测试:宿主线程接收到worker线程发来的消息.${e.data}`)
              // let data: number = e.data; // data：worker线程发送的信息
              // console.info("main thread data is  " + data);
              // this.workerInstance.terminate(); // 销毁Worker对象

              //   <?xml version="1.0" encoding="UTF-8" ?>
              //   <Function>
              //   <Cmd>3020</Cmd>
              //   <Status>1</Status>
              //   </Function>

              //   <?xml version="1.0" encoding="UTF-8" ?>
              //   <Function>
              //   <Cmd>3020</Cmd>
              //   <Status>11</Status>
              //   </Function>

              // <?xml version="1.0" encoding="UTF-8" ?>
              // <Function>
              // <Cmd>3020</Cmd>
              // <Status>12</Status>
              // </Function>
            }
            this.workerInstance.onexit = (code) => { // 在调用terminate后，执行onexit
              console.log("main thread terminate");
              LogUtil.debug(`worker-socket测试:worker对象被销毁.`)
            }
            this.workerInstance.onerror = (err: ErrorEvent) => {
              console.log("main error message " + err.message);
              LogUtil.debug(`worker-socket测试:worker异常.${err.message}`)
            }
          })

          Button() { //Button(按钮控件).
            Text('worker-关闭')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
          }
          .type(ButtonType.Capsule)
          .padding(10)
          .backgroundColor('#0D9FFB')
          .width('50%')
          .onClick(() => { //按钮绑定onClick事件.
            //**********worker测试**********
            this.workerInstance.postMessage("STOP_SOCKET"); // 宿主线程向worker线程传递信息
            this.workerInstance.terminate(); // 销毁Worker对象
          })
        }
        .width('100%')

        //====================测试内容结束====================
      }
      .width('100%')
    }
    .height("100%")
    .width("100%")
    .backgroundColor('#00EAFF')
  }
}