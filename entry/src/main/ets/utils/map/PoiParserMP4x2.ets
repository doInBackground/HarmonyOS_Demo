import { fileIo } from '@kit.CoreFileKit';
import { Poi } from '../../bean/Poi';
import { LogUtil } from '@pura/harmony-utils';

class MP4CHUCKHEADER {
  ulSize: number = 0;
  ulFourCC: Uint8Array = new Uint8Array(4);
  static readonly sizeOf: number = 8;
}

class MP4EXTCHUCKHEADER {
  ulSize: number = 0;
  ulFourCC: number = 0;
  largeSize: number = 0;
  static readonly sizeOf: number = 16;
}

class GPS_ATTRIBUTE {
  ubStoreFreq: number = 0;
  byGMTOffset: number = 0;
  ubDummy: Uint8Array = new Uint8Array(2);
  static readonly sizeOf: number = 4;
}

class GPSINFOCHUCKTIME {
  byYear: number = 0;
  byMon: number = 0;
  byDay: number = 0;
  byHour: number = 0;
  byMin: number = 0;
  bySec: number = 0;
  static readonly sizeOf: number = 6;
}

class GPSINFOCHUCK {
  dwLat: number = 0;
  dwLon: number = 0;
  lAlt: number = 0;
  usSpeed: number = 0;
  sUTC: GPSINFOCHUCKTIME = new GPSINFOCHUCKTIME();
  ubDirection: number = 0;
  ubFlag: number = 0;
  ubVersion: number = 0;
  ubReserved: number = 0;
  static readonly sizeOf: number = 8 + 8 + 4 + 2 + GPSINFOCHUCKTIME.sizeOf + 4;
}

// const TAG = 'PoiParserMP4x2';
// const dateFormatter = new util.DateTimeFormat("yyyy/MM/dd HH:mm:ss");

function readGPSINFOCHUCK(buf: Uint8Array, index: number): GPSINFOCHUCK {
  const gps = new GPSINFOCHUCK();
  const view = new DataView(buf.buffer, index);

  gps.dwLat = view.getFloat64(0, true);
  gps.dwLon = view.getFloat64(8, true);
  gps.lAlt = view.getInt32(16, true);
  gps.usSpeed = view.getInt16(20, true);

  // LogUtil.debug(`单条数据-其他: dwLat=${gps.dwLat},dwLon=${gps.dwLon},lAlt=${gps.lAlt},usSpeed=${gps.usSpeed}`)

  const time = new GPSINFOCHUCKTIME();
  // time.byYear = buf[22]; //直接用字节数组"Uint8Array[]"的方式去读数据有问题,故接着用"DataView.getUint8()"的方式.
  // time.byMon = buf[23];
  // time.byDay = buf[24];
  // time.byHour = buf[25];
  // time.byMin = buf[26];
  // time.bySec = buf[27];
  time.byYear = view.getUint8(22);
  time.byMon = view.getUint8(23);
  time.byDay = view.getUint8(24);
  time.byHour = view.getUint8(25);
  time.byMin = view.getUint8(26);
  time.bySec = view.getUint8(27);
  gps.sUTC = time;
  // LogUtil.debug(`单条数据-时间: byYear=${buf[22]},byMon=${buf[23]},byDay=${buf[24]},byHour=${buf[25]},byMin=${buf[26]},bySec=${buf[27]}`)
  // LogUtil.debug(`单条数据-时间: byYear=${view.getUint8(22)},byMon=${view.getUint8(23)},byDay=${view.getUint8(24)},byHour=${view.getUint8(25)},byMin=${view.getUint8(26)},bySec=${view.getUint8(27)}`)

  // gps.ubDirection = view.getUint8(28);
  gps.ubDirection = buf[28];
  gps.ubFlag = buf[29];
  gps.ubVersion = buf[30]; //未用到.
  gps.ubReserved = buf[31]; //未用到.
  return gps;
}

export async function parseFile(path: string): Promise<Poi[] | null> {
  if (!path || !path.toLowerCase().endsWith('.mp4')) {
    return null;
  }

  try {
    const file = await fileIo.open(path, fileIo.OpenMode.READ_ONLY);
    const stat = await fileIo.stat(path);
    let pos = 0;
    let storeFreq = 1;
    let pois: Poi[] = [];

    while (pos < stat.size) {
      // await fileIo.lseek(file.fd, pos, fileIo.WhenceType.SEEK_SET);
      fileIo.lseek(file.fd, pos, fileIo.WhenceType.SEEK_SET);

      // Read chunk header
      const headerBuf = new Uint8Array(8);
      await fileIo.read(file.fd, headerBuf.buffer);
      const headerView = new DataView(headerBuf.buffer);

      const chunkHeader = new MP4CHUCKHEADER();
      chunkHeader.ulSize = headerView.getInt32(0, false);
      chunkHeader.ulFourCC = headerBuf.subarray(4, 8);

      const type = String.fromCharCode(...chunkHeader.ulFourCC);
      let chunkSize = chunkHeader.ulSize;
      let headerSize = MP4CHUCKHEADER.sizeOf;

      if (chunkHeader.ulSize === 1) {
        const extHeaderBuf = new Uint8Array(8);
        await fileIo.read(file.fd, extHeaderBuf.buffer);
        const extView = new DataView(extHeaderBuf.buffer);
        chunkSize = Number(extView.getBigInt64(0, false));
        headerSize = MP4EXTCHUCKHEADER.sizeOf;
      }

      if (chunkSize <= 0) {
        break;
      }

      if (type === 'gpsa') {
        const attrBuf = new Uint8Array(GPS_ATTRIBUTE.sizeOf);
        await fileIo.read(file.fd, attrBuf.buffer);
        const attrView = new DataView(attrBuf.buffer);
        storeFreq = attrView.getUint8(0);
      } else if (type === 'gps0') {
        const dataSize = chunkSize - headerSize;
        const gpsData = new Uint8Array(dataSize);
        await fileIo.read(file.fd, gpsData.buffer);

        let index = 0;
        while (index < gpsData.length) {
          const chuck = readGPSINFOCHUCK(gpsData, index);
          pois.push(chuckToPoi(chuck));
          index += GPSINFOCHUCK.sizeOf;
        }
      }

      pos += chunkSize;
    }

    fileIo.close(file.fd);

    // 角度计算和数据处理逻辑
    let lastAngle = pois.length > 0 ? pois[0].angle : 0;
    for (let i = 0; i < pois.length; i++) {
      if (i < pois.length - 1 && (pois[i].speed ?? 0) > 15) {
        const poi1 = pois[i];
        const poi2 = pois[i + 1];
        lastAngle = angleFromCoordinate(poi1.latitude ?? 0, poi1.longitude ?? 0, poi2.latitude ?? 0, poi2.longitude ?? 0);
      }
      pois[i].angle = lastAngle;
    }

    if (storeFreq > 1) {
      const fixedPois: Poi[] = [];
      pois.forEach(poi => {
        for (let i = 0; i < storeFreq; i++) {
          // fixedPois.push({ ...poi });
          fixedPois.push(poi);
        }
      });
      // return fixedPois;
      pois = fixedPois;
    }

    //IOS版逻辑: 只要发现一条数据的"active"为false,则认为解析出错.
    if (pois.length > 0) {
      for (const poi of pois) {
        if (!poi.active) {
          return null
        }
      }
      return pois;
    } else {
      return null;
    }
  } catch (e) {
    LogUtil.error(`Error parsing file: ${e}`)
    return null;
  }
}

function chuckToPoi(chuck: GPSINFOCHUCK): Poi {
  const poi = new Poi();
  const dateStr = `${chuck.sUTC.byYear + 2000}/${chuck.sUTC.byMon + 1}/${chuck.sUTC.byDay} ${chuck.sUTC.byHour + 8}:${chuck.sUTC.byMin}:${chuck.sUTC.bySec}` //东八区加8小时.
  poi.date = dateStr
  poi.latitude = gPSToLatLng(chuck.dwLat);
  poi.longitude = gPSToLatLng(chuck.dwLon);
  poi.active = chuck.ubFlag !== 0;
  poi.speed = chuck.usSpeed;
  poi.angle = chuck.ubDirection;
  return poi;
}

function angleFromCoordinate(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const dLon = lon2 - lon1;
  const y = Math.sin(dLon) * Math.cos(lat2);
  const x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLon);
  let brng = Math.atan2(y, x);
  brng = ((brng * 180 / Math.PI) + 360) % 360;
  return 360 - brng;
}

function gPSToLatLng(gps: number): number {
  const intPart = Math.floor(gps);
  const degree = Math.floor(intPart / 100);
  return degree + (gps - degree * 100) / 60;
}