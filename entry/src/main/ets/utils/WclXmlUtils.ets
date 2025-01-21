import { ArrayList, util, xml } from '@kit.ArkTS';

export class WclXmlUtils {
  /**
   * XML数据的解析,将结果以键值对的形式返回(不支持空值格式).
   * @param xmlStr
   * @returns
   */
  public static parse(xmlStr: string): ArrayList<XmlKV> {
    let list = new ArrayList<XmlKV>();
    let xmlArr: XmlKV [] = [];
    let textEncoder = new util.TextEncoder();
    let arrbuffer = textEncoder.encodeInto(xmlStr);
    let that = new xml.XmlPullParser(arrbuffer.buffer as object as ArrayBuffer, 'UTF-8');
    let func = (key: string, value: string) => {
      key = key.trim()
      value = value.trim()
      if (key == "" && value == "") {
      } else {
        console.debug(`xml解析-过程:[${key}][${value}]`); //打印.
        if (key != "") {
          xmlArr.push(new XmlKV(key, ""))
        }
        if (value != "") {
          xmlArr.push(new XmlKV("", value))
        }
      }
      return true;
    }
    let options: xml.ParseOptions = { supportDoctype: true, ignoreNameSpace: true, tagValueCallbackFunction: func }
    try {
      that.parse(options);
      //处理解析出来的数据.
      for (let i = 0; i < xmlArr.length; i++) {
        if ((xmlArr[i].key != "") && (i < xmlArr.length - 2) && (xmlArr[i].key == xmlArr[i+2].key)) {//是"起始标签".
          list.add(new XmlKV(xmlArr[i].key, xmlArr[i+1].value));
          console.debug(`xml解析-结果:[key=${xmlArr[i].key} value=${xmlArr[i+1].value}]`); //打印.
        }
      }
    } catch (e) {
      console.error(`xml解析-出错:${e}}`); //打印.
    }
    return list;
  }
}

export class XmlKV {
  public key: string;
  public value: string;

  constructor(key: string, value: string) {
    this.key = key;
    this.value = value;
  }
}