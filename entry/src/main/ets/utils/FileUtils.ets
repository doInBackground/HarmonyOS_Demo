import { fileIo as fs } from '@kit.CoreFileKit'

/**
 * 从rawfile中拷贝数据到沙箱.
 * @param context 上下文.
 * @param rawFileName rawfile中文件的名字.
 * @param sandboxPath 要存储到沙箱的文件夹路径.
 * @returns
 * TODO:对于返回值是Promise的方法,通过调用返回值的"await/then()"能拿到"resolve()"的响应,通过调用返回值的"catch()"能拿到"reject()"的响应.两者只会拿到其一.
 */
export async function copyRaw2Sandbox(context: Context, rawFileName: string, sandboxPath: string): Promise<void> {
  return new Promise((resolve, reject) => {
    /**
     * 通过fd来进行拷贝，避免文件过大的内存占用问题.
     * data.fd是hap包的fd，data.offset表示目标文件在hap包中的偏移，data.length表示目标文件的长度
     */
    context.resourceManager.getRawFd(rawFileName, (err, data) => {
      if (err != null) {
        console.error(err.message)
        reject()
        return
      }
      if (!fs.accessSync(sandboxPath)) { //目标文件父路径不存在则创建.
        fs.mkdirSync(sandboxPath, true) //层级创建父目录.
      }
      let filePath = sandboxPath + "/" + rawFileName
      let dest = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE)
      let bufsize = 4096
      let buf = new ArrayBuffer(bufsize) //缓冲数组.
      let off = 0, len = 0, readedLen = 0
      while (len = fs.readSync(data.fd, buf, { offset: data.offset + off, length: bufsize })) { //通过buffer将rawfile文件内容copy到沙箱路径.
        readedLen += len
        fs.writeSync(dest.fd, buf, { offset: off, length: len })
        off = off + len
        if ((data.length - readedLen) < bufsize) { //最后一组数据的长度不足以填满缓冲数组,则将真实数据长度做记录,方便读取时只读该长度的数据.
          bufsize = data.length - readedLen
        }
      }
      fs.close(dest.fd)
      context.resourceManager.closeRawFd(rawFileName, (err, data) => {
        if (err != null) {
          console.log(err.message)
        } else {
          console.log("close success")
        }
      })
      resolve()
    })
  })
}