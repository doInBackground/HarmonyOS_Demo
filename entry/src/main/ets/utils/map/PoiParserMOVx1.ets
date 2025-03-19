import { fileIo } from '@kit.CoreFileKit';
import util from '@ohos.util';
import { Poi } from '../../bean/Poi';

//=====================================结构体=====================================
class MP4MDHEADER {
  ulSize: number = 0; // int -> number
  // ulFourCC: number[] = new Array(4).fill(0); // byte[4] -> number[]
  ulFourCC: Uint8Array = new Uint8Array(4); // 使用Uint8Array替代byte[]
  static readonly sizeOf: number = 4 + 4; // 8
}

class MP4EXTMDHEADER {
  ulSize: number = 0; // int -> number
  ulFourCC: number = 0; // int -> number
  largeSize: number = 0; // long -> number
  static readonly sizeOf: number = 4 + 4 + 8; // 16
}

class MDHEADER {
  ulSize: number = 0; // int -> number
  ulFourCC: number = 0; // int -> number
  version: number = 0; // byte -> number
  // flags: number[] = new Array(3).fill(0); // byte[3] -> number[]
  flags: Uint8Array = new Uint8Array(3); // 使用Uint8Array替代byte[]
  static readonly sizeOf: number = 4 + 4 + 1 + 3; // 12
}

class HDLRHEADER {
  header: MDHEADER = new MDHEADER();
  pre_defined: number = 0; // int -> number
  // handler_type: number[] = new Array(4).fill(0); // byte[4]
  handler_type: Uint8Array = new Uint8Array(4); // 使用Uint8Array替代byte[]
  // reserved: number[] = new Array(12).fill(0);    // byte[12]
  reserved: Uint8Array = new Uint8Array(12); // 使用Uint8Array替代byte[]
  static readonly sizeOf: number = MDHEADER.sizeOf + 4 + 4 + 12; // 32
}

class STSDHEADER {
  header: MDHEADER = new MDHEADER();
  entry_count: number = 0; // int -> number
  static readonly sizeOf: number = MDHEADER.sizeOf + 4; // 16
}

class AUDIOSAMPLEDESC {
  size: number = 0; // int -> number
  data: number = 0; // int -> number
  // reserved: number[] = new Array(6).fill(0); // byte[6]
  reserved: Uint8Array = new Uint8Array(6); // 使用Uint8Array替代byte[]
  dataRef: number = 0; // short -> number
  version: number = 0; // short -> number
  revisionLevel: number = 0; // short -> number
  vendor: number = 0; // int -> number
  channelNo: number = 0; // short -> number
  bitsPerSample: number = 0; // short -> number
  cmpressionId: number = 0; // short -> number
  packetSize: number = 0; // short -> number
  sampleRate: number = 0; // short -> number
  padding4: number = 0; // short -> number
  static readonly sizeOf: number = 4 + 4 + 6 + 2 + 2 + 2 + 4 + 2 + 2 + 2 + 2 + 2 + 2; // 36
}

class STCOHEADER {
  header: MDHEADER = new MDHEADER();
  entry_count: number = 0; // int -> number
  static readonly sizeOf: number = MDHEADER.sizeOf + 4; // 16（修正原Java代码中的错误）
}

class RMCINFO {
  Hour: number = 0; // int -> number
  Minute: number = 0; // int -> number
  Second: number = 0; // int -> number
  Year: number = 0; // int -> number
  Month: number = 0; // int -> number
  Day: number = 0; // int -> number
  Status: string = ''; // char -> string
  NSind: string = ''; // char -> string
  EWind: string = ''; // char -> string
  reservd: string = ''; // char -> string
  Latitude: number = 0.0; // float -> number
  Longitude: number = 0.0; // float -> number
  Speed: number = 0.0; // float -> number
  Angle: number = 0.0; // float -> number
  static readonly sizeOf: number = 4 * 6 + 1 * 4 + 4 * 4; // 44
}

//=====================================方法1=====================================

function readMP4MDHEADER(fd: number, offset: number): MP4MDHEADER {
  const header = new MP4MDHEADER();
  const buffer = new ArrayBuffer(MP4MDHEADER.sizeOf); // 一次性读取8字节（ulSize + ulFourCC）
  const bytesRead = fileIo.readSync(fd, buffer, { offset: offset, length: MP4MDHEADER.sizeOf }); // 同步读取文件内容
  if (bytesRead !== MP4MDHEADER.sizeOf) {
    throw new Error(`读取MP4头信息失败，预期8字节，实际读取${bytesRead}字节`);
  }
  // 解析ulSize（大端序）
  const dataView = new DataView(buffer);
  header.ulSize = dataView.getInt32(0, false);
  header.ulFourCC = new Uint8Array(buffer.slice(4, 8)); // 提取ulFourCC字节数组
  return header;
}

// MDHEADER读取函数
function readMDHEADER(fd: number, offset: number): MDHEADER {
  const header = new MDHEADER();
  const len = MDHEADER.sizeOf
  const buffer = new ArrayBuffer(len); // ulSize(4)+ulFourCC(4)+version(1)+flags(3)
  const bytesRead = fileIo.readSync(fd, buffer, { offset, length: len });
  if (bytesRead !== len) {
    throw new Error("读取MDHEADER失败");
  }

  const dataView = new DataView(buffer);
  header.ulSize = dataView.getInt32(0, false);
  header.ulFourCC = dataView.getInt32(4, false);
  header.version = dataView.getUint8(8);
  header.flags = new Uint8Array(buffer.slice(9, 12));
  return header;
}

// HDLRHEADER读取函数
function readHDLRHEADER(fd: number, offset: number): HDLRHEADER {
  const header = new HDLRHEADER();
  const len = HDLRHEADER.sizeOf
  const buffer = new ArrayBuffer(len); // MDHEADER(12)+pre_defined(4)+handler_type(4)+reserved(12)
  const bytesRead = fileIo.readSync(fd, buffer, { offset, length: len });
  if (bytesRead !== len) {
    throw new Error("读取HDLRHEADER失败");
  }
  const dataView = new DataView(buffer);
  // 解析MDHEADER部分
  header.header = readMDHEADER(fd, offset);
  // 解析剩余字段
  header.pre_defined = dataView.getInt32(12, false);
  header.handler_type = new Uint8Array(buffer.slice(16, 20));
  header.reserved = new Uint8Array(buffer.slice(20, 32));
  return header;
}

// STCOHEADER读取函数
function readSTCOHEADER(fd: number, offset: number): STCOHEADER {
  const header = new STCOHEADER();
  const buffer = new ArrayBuffer(STCOHEADER.sizeOf); // MDHEADER(12)+entry_count(4)
  const bytesRead = fileIo.readSync(fd, buffer, { offset, length: STCOHEADER.sizeOf });
  if (bytesRead !== STCOHEADER.sizeOf) {
    throw new Error("读取STCOHEADER失败");
  }
  const dataView = new DataView(buffer);
  header.header = readMDHEADER(fd, offset);
  header.entry_count = dataView.getInt32(12, false);
  return header;
}

// AUDIOSAMPLEDESC读取函数
function readAUDIOSAMPLEDESC(fd: number, offset: number): AUDIOSAMPLEDESC {
  const desc = new AUDIOSAMPLEDESC();
  const buffer = new ArrayBuffer(AUDIOSAMPLEDESC.sizeOf);
  const bytesRead = fileIo.readSync(fd, buffer, { offset, length: AUDIOSAMPLEDESC.sizeOf });
  if (bytesRead !== AUDIOSAMPLEDESC.sizeOf) {
    throw new Error("读取AUDIOSAMPLEDESC失败");
  }

  const dataView = new DataView(buffer);
  let pos = 0;
  desc.size = dataView.getInt32(pos, false);
  pos += 4;
  desc.data = dataView.getInt32(pos, false);
  pos += 4;
  desc.reserved = new Uint8Array(buffer.slice(pos, pos + 6));
  pos += 6;
  desc.dataRef = dataView.getInt16(pos, false);
  pos += 2;
  desc.version = dataView.getInt16(pos, false);
  pos += 2;
  desc.revisionLevel = dataView.getInt16(pos, false);
  pos += 2;
  desc.vendor = dataView.getInt32(pos, false);
  pos += 4;
  desc.channelNo = dataView.getInt16(pos, false);
  pos += 2;
  desc.bitsPerSample = dataView.getInt16(pos, false);
  pos += 2;
  desc.cmpressionId = dataView.getInt16(pos, false);
  pos += 2;
  desc.packetSize = dataView.getInt16(pos, false);
  pos += 2;
  desc.sampleRate = dataView.getInt16(pos, false);
  pos += 2;
  desc.padding4 = dataView.getInt16(pos, false);
  return desc;
}

//=====================================方法2=====================================

interface BoxInfo {
  tag: string;
  headerSize: number;
  size: number;
}

// 读取box标签函数
function readBoxTag(fd: number, offset: number): BoxInfo {
  const info: BoxInfo = { tag: "", headerSize: 8, size: 0 }; // 默认header大小8字节

  // 1. 读取基础头信息
  const p = readMP4MDHEADER(fd, offset);
  info.size = p.ulSize;

  // 2. 处理扩展头（当ulSize=1时）
  if (p.ulSize === 1) {
    const extBuffer = new ArrayBuffer(8); // 扩展头是8字节long
    const bytesRead = fileIo.readSync(fd, extBuffer, {
      offset: offset + 8,
      length: 8
    });
    if (bytesRead !== 8) {
      throw new Error("读取扩展头失败");
    }

    info.headerSize = 16; // 基础头8 + 扩展头8
    info.size = Number(new DataView(extBuffer).getBigUint64(0, false)); //注意精度丢失.
  }

  // 3. 转换FourCC为字符串
  try {
    // info.tag = String.fromCharCode.apply(null, Array.from(p.ulFourCC));
    // info.tag = buffer.from(p.ulFourCC).toString('US-ASCII');
    info.tag = util.TextDecoder.create('ascii').decodeToString(p.ulFourCC);
  } catch (e) {
    info.tag = "[Invalid Tag]";
  }
  return info;
}

interface BoxInfoO {
  found: boolean;
  pos?: number;
  headerSize?: number;
  boxSize?: number
}

// 查找指定box函数
function findBox(
  fd: number,
  targetTag: string,
  start: number,
  end: number
): BoxInfoO {
  let currentOffset = start;
  while (currentOffset < end) {
    try {
      // 1. 读取当前box信息
      const boxInfo = readBoxTag(fd, currentOffset);
      // 2. 调试日志（需实现日志模块）
      // logger.debug(`findBox: TAG: ${boxInfo.tag} at ${currentOffset}`);
      // 3. 匹配目标标签
      if (boxInfo.tag.toUpperCase() === targetTag.toUpperCase()) {
        // logger.debug(`Find TAG: ${boxInfo.tag}, Size: ${boxInfo.size}`);
        return {
          found: true,
          pos: currentOffset,
          headerSize: boxInfo.headerSize,
          boxSize: boxInfo.size
        };
      }
      // 4. 移动到下一个box
      currentOffset += boxInfo.size;
      if (boxInfo.size === 0) {
        break;
      } // 防止死循环
    } catch (e) {
      // 处理读取错误
      // logger.error("读取box失败：" + e.message);
      break;
    }
  }
  return { found: false };
}

//=====================================方法3=====================================

// 主解析函数
export async function parseFile(path: string): Promise<Poi[] | null> {
  if (!path) {
    return null;
  }

  let fd: number | null = null;
  try {
    // 打开文件
    fd = (await fileIo.open(path, fileIo.OpenMode.READ_ONLY)).fd; // 只读模式
    const fileSize = Number(fileIo.statSync(path).size);

    if (fileSize <= 0) {
      return null;
    }

    const pois: Poi[] = [];
    let audioChunkOffsets: number[] = [];
    let audioChunkSize = 0;
    let gpsCount = 0;

    // 查找moov box
    const moovResult = findBox(fd, "moov", 0, fileSize);
    if (!moovResult.found || !moovResult.pos || !moovResult.boxSize) {
      return null;
    }

    let pos = moovResult.pos + moovResult.headerSize!;
    let end = moovResult.pos + moovResult.boxSize;

    // 遍历trak boxes
    do {
      const trakResult = findBox(fd, "trak", pos, end);
      if (!trakResult.found || !trakResult.pos || !trakResult.boxSize) {
        break;
      }

      pos = trakResult.pos + trakResult.boxSize;

      // 在trak中查找mdia
      const mdiaResult = findBox(fd, "mdia", trakResult.pos + trakResult.headerSize!, trakResult.pos + trakResult.boxSize);
      if (!mdiaResult.found || !mdiaResult.pos || !mdiaResult.boxSize) {
        continue;
      }

      const mdiaStart = mdiaResult.pos + mdiaResult.headerSize!;
      const mdiaEnd = mdiaResult.pos + mdiaResult.boxSize;

      // 查找hdlr
      const hdlrResult = findBox(fd, "hdlr", mdiaStart, mdiaEnd);
      if (!hdlrResult.found || !hdlrResult.pos || !hdlrResult.boxSize) {
        continue;
      }

      // 读取HDLRHEADER
      const hdlrHeader = readHDLRHEADER(fd, hdlrResult.pos);
      const handlerType = uint8ArrayToString(hdlrHeader.handler_type);

      if (handlerType.toUpperCase() !== "SOUN") {
        continue;
      }

      // 查找minf -> stbl -> stsd
      const minfResult = findBox(fd, "minf", mdiaStart, mdiaEnd);
      if (!minfResult.found || !minfResult.pos || !minfResult.boxSize) {
        continue;
      }

      const stblResult = findBox(fd, "stbl", minfResult.pos + minfResult.headerSize!, minfResult.pos + minfResult.boxSize);
      if (!stblResult.found || !stblResult.pos || !stblResult.boxSize) {
        continue;
      }

      const stblStart = stblResult.pos + stblResult.headerSize!;
      const stblEnd = stblResult.pos + stblResult.boxSize;

      // 读取音频采样描述
      const stsdResult = findBox(fd, "stsd", stblStart, stblEnd);
      if (!stsdResult.found || !stsdResult.pos || !stsdResult.boxSize) {
        continue;
      }

      const audioDesc = readAUDIOSAMPLEDESC(fd, stsdResult.pos + STSDHEADER.sizeOf);
      audioChunkSize = Number(audioDesc.channelNo * audioDesc.bitsPerSample * audioDesc.sampleRate / 8);

      // 读取STCO数据
      const stcoResult = findBox(fd, "stco", stblStart, stblEnd);
      if (!stcoResult.found || !stcoResult.pos || !stcoResult.boxSize) {
        continue;
      }

      const stcoHeader = readSTCOHEADER(fd, stcoResult.pos);
      gpsCount = Number(stcoHeader.entry_count);

      // 读取所有块偏移量
      const entryBuffer = new ArrayBuffer(stcoHeader.entry_count * 4);
      fileIo.readSync(fd, entryBuffer, {
        offset: stcoResult.pos + STCOHEADER.sizeOf,
        length: entryBuffer.byteLength
      });

      const dataView = new DataView(entryBuffer);
      for (let i = 0; i < stcoHeader.entry_count; i++) {
        audioChunkOffsets.push(dataView.getUint32(i * 4, false));
      }
    } while (pos < end);

    // 解析GPS数据
    const alignSize = calculateAlignSize(BigInt(audioChunkSize), 32 * 1024);
    const lastAngle = [0];

    for (const offset of audioChunkOffsets) {
      const position = offset + Number(alignSize);
      const buffer = new ArrayBuffer(4 * 4 + RMCINFO.sizeOf);

      fileIo.readSync(fd, buffer, {
        offset: position,
        length: buffer.byteLength
      });

      const dataView = new DataView(buffer);
      let pos = 8; // Skip first 8 bytes

      // 检查GPS标识
      const g = dataView.getUint8(pos++);
      const p = dataView.getUint8(pos++);
      const s = dataView.getUint8(pos++);
      pos += 5; // Skip 5 bytes

      if (g !== 0x47 || p !== 0x50 || s !== 0x53) {
        continue;
      }

      const poi = readPoi(dataView, pos, lastAngle);
      if (poi) {
        pois.push(poi);
      }
    }

    // 查找第一个有效POI
    if (pois.length > 0 && !pois[0].active) {
      for (const poi of pois) {
        if (poi.active) {
          pois[0].locFrom(poi);
          break;
        }
      }
    }

    return pois;
  } catch (e) {
    console.error("解析文件失败:", e);
    return null;
  } finally {
    if (fd !== null) {
      fileIo.close(fd);
    }
  }
}

// 辅助函数
function calculateAlignSize(size: bigint, align: number): bigint {
  const rem = size % BigInt(align);
  return rem === 0n ? size : size + BigInt(align) - rem;
}

function uint8ArrayToString(arr: Uint8Array): string {
  return String.fromCharCode(...Array.from(arr));
}

//=====================================方法4=====================================

// 主转换函数
function readPoi(dataView: DataView, offset: number, lastAngle: number[]): Poi { //lastAngle: { value: number }
  const poi = new Poi();
  let pos = offset;

  // 读取时间信息
  const readUint = () => {
    const value = dataView.getUint32(pos, true); // 小端序
    pos += 4;
    return value;
  };

  const hour = readUint();
  const minute = readUint();
  const second = readUint();
  const year = readUint();
  const month = readUint();
  const day = readUint();

  // 读取状态信息
  const status = dataView.getUint8(pos++);
  const nSind = dataView.getUint8(pos++);
  const eWind = dataView.getUint8(pos++);
  const reservd = dataView.getUint8(pos++);

  // 读取浮点数值（小端序）
  const readFloat = () => {
    const value = dataView.getFloat32(pos, true);
    pos += 4;
    return value;
  };

  const latitude = readFloat();
  const longitude = readFloat();
  const speed = readFloat();
  const angle = readFloat();

  // // 构建日期对象
  // const utcDate = new Date(Date.UTC(
  //   year + 2000,
  //   month - 1, // JavaScript月份从0开始
  //   day,
  //   hour,
  //   minute,
  //   second
  // ));
  // poi.date = utcDate.toISOString();
  poi.date = `${year + 2000}/${month + 2}/${day} ${hour + 8}:${minute}:${second}` //东八区加8小时.

  // 转换坐标
  poi.latitude = gPSToLatLng(latitude) * (nSind === 0x4E ? 1 : -1); // 'N'的ASCII是0x4E
  poi.longitude = gPSToLatLng(longitude) * (eWind === 0x45 ? 1 : -1); // 'E'的ASCII是0x45

  // 设置状态
  poi.active = status === 0x41; // 'A'的ASCII是0x41
  poi.event = reservd === 1;

  // 转换速度单位（海里 -> 公里）
  poi.speed = speed * 1.852;
  if (poi.speed === 0) {
    poi.angle = lastAngle[0];
  } else {
    poi.angle = angle;
    lastAngle[0] = angle;
  }
  // poi.angle = poi.speed === 0 ? lastAngle[0] : angle;
  // lastAngle[0] = angle;
  return poi;
}

// 辅助函数
function gPSToLatLng(gps: number): number {
  const intPart = Math.floor(gps);
  const degree = Math.floor(intPart / 100);
  return degree + (gps - degree * 100) / 60;
}

// // 同步读取工具函数
// function readFully(fd: number, buffer: ArrayBuffer, options: { offset: number }): void {
//   const bytesRead = fileIo.readSync(fd, buffer, options);
//   if (bytesRead !== buffer.byteLength) {
//     throw new Error("读取数据不完整");
//   }
// }
//
// // 读取无符号整型（小端序）
// function readUint32LE(fd: number, offset: number): number {
//   const buffer = new ArrayBuffer(4);
//   readFully(fd, buffer, { offset });
//   return new DataView(buffer).getUint32(0, true);
// }
//
// // 读取浮点数（小端序）
// function readFloatLE(fd: number, offset: number): number {
//   const buffer = new ArrayBuffer(4);
//   readFully(fd, buffer, { offset });
//   return new DataView(buffer).getFloat32(0, true);
// }