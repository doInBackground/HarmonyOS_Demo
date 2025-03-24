import { LogUtil } from "@pura/harmony-utils"

export class Father {
  name: string = "Father"

  public speak() {
    LogUtil.debug(`I am Father.`)
  }
}

export class Son extends Father {
  name: string = "Son"

  public speak() {
    LogUtil.debug(`I am son.`)
  }

  public smile() {
    LogUtil.debug(`smile...`)
  }
}