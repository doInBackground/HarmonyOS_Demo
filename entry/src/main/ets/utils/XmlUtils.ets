import convert from '@ohos/xml_js';

/**
 * 根据三方库工具,创建的解析XML的工具.
 * (比较通用,推荐使用)
 */
export class XmlUtils {
  /**
   * XML数据的解析,将结果以键值对的形式返回(不支持空值格式).
   * @param xml
   * @returns
   */
  public static parse(xml: string): RootElement {
    let json = convert.xml2json(xml) as string; //xml转json.
    let rootResult = JSON.parse(json) as RootElement //json转对象.
    return rootResult
  }
}

/**
 * 工具类将xml转成json数据时的根对象.
 */
export class RootElement {
  elements?: Element[]
}

/**
 * xml内容对象.
 */
export class Element {
  /**
   * type="element"时,name有值,elements有值,attributes可能有值.
   * type="text"时,text有值.
   */
  type?: string
  /**
   * 标签名.
   */
  name?: string
  /**
   * 文字内容.
   */
  text?: string
  /**
   * 标签中的参数.
   */
  attributes?: Record<string, string>
  /**
   * 子项.
   */
  elements?: Element[]
}

/*
举例:
xml数据:
<Normal>
  <file>
    <name>/SD/Normal/F/FILE181001-093235-000506F.MOV</name>
    <format size="1920x1080" fps="27" time="60.3">MOV</format>
    <size>92602368</size>
    <attr>RW</attr>
    <time>2018-10-01 09:32:35</time>
  </file>
</Normal>
json数据:
{
  "elements": [
    {
      "type": "element",
      "name": "Normal",
      "elements": [
        {
          "type": "element",
          "name": "file",
          "elements": [
            {
              "type": "element",
              "name": "name",
              "elements": [
                {
                  "type": "text",
                  "text": "/SD/Normal/F/FILE181001-093235-000506F.MOV"
                }
              ]
            },
            {
              "type": "element",
              "name": "format",
              "attributes": {
                "size": "1920x1080",
                "fps": "27",
                "time": "60.3"
              },
              "elements": [
                {
                  "type": "text",
                  "text": "MOV"
                }
              ]
            },
            {
              "type": "element",
              "name": "size",
              "elements": [
                {
                  "type": "text",
                  "text": "92602368"
                }
              ]
            },
            {
              "type": "element",
              "name": "attr",
              "elements": [
                {
                  "type": "text",
                  "text": "RW"
                }
              ]
            },
            {
              "type": "element",
              "name": "time",
              "elements": [
                {
                  "type": "text",
                  "text": "2018-10-01 09:32:35"
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
*/