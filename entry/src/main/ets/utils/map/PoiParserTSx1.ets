import { fileIo } from '@kit.CoreFileKit';
import { Poi } from '../../bean/Poi';

const TS_PACK_LEN = 188;
const READ_ONCE_BUF_SIZE = TS_PACK_LEN * 1024 * 10 * 3;
const TS_HEAD_LEN = 4;
const PES_HEAD_LEN = 6;

function gpsToLatLng(gps: number): number {
  const intPart = Math.floor(gps); //去除小数位.
  const degree = Math.floor(intPart / 100);
  return degree + (gps - degree * 100) / 60;
}

export async function parseFile(path: string): Promise<Poi[] | null> {
  if (!path) {
    return null;
  }

  try {
    const file = fileIo.openSync(path, fileIo.OpenMode.READ_ONLY);
    const array: Poi[] = [];
    let lastAngle = 0.0;

    const buf188 = new ArrayBuffer(TS_PACK_LEN);
    let bytesRead = 0;

    while ((bytesRead = fileIo.readSync(file.fd, buf188)) === TS_PACK_LEN) {
      const view = new Uint8Array(buf188);
      if ((view[0] === 0x47 && view[1] === 0x43 && view[2] === 0x00) || (view[0] === 0x47 && view[1] === 0x01 && (view[2] & 0xFF) === 0xE4)) {
        const dataView = new DataView(buf188, TS_HEAD_LEN + PES_HEAD_LEN);
        let pos = 0;
        const hour = dataView.getUint32(pos, true);
        pos += 4;
        const minute = dataView.getUint32(pos, true);
        pos += 4;
        const second = dataView.getUint32(pos, true);
        pos += 4;
        const year = dataView.getUint32(pos, true);
        pos += 4;
        const month = dataView.getUint32(pos, true);
        pos += 4;
        const day = dataView.getUint32(pos, true);
        pos += 4;

        const status = dataView.getUint8(pos++);
        const nSind = dataView.getUint8(pos++);
        const eWind = dataView.getUint8(pos++);
        const reservd = dataView.getUint8(pos++);

        const latitude = dataView.getFloat32(pos, true);
        pos += 4;
        const longitude = dataView.getFloat32(pos, true);
        pos += 4;
        const speed = dataView.getFloat32(pos, true);
        pos += 4;
        const angle = dataView.getFloat32(pos, true);
        pos += 4;

        // const calendar = i18n.getCalendar("UTC");
        // calendar.set(year + 2000, month + 1, day, hour, minute, second);

        // const dateFormatter = new util.DateTimeFormat("yyyy/MM/dd HH:mm:ss");
        const dateStr = `${year + 2000}/${month + 2}/${day} ${hour + 8}:${minute}:${second}` //东八区加8小时.

        const poi = new Poi();
        poi.date = dateStr;
        poi.latitude = gpsToLatLng(latitude) * (nSind === 0x4E ? 1 : -1); // 'N'的ASCII是0x4E
        poi.longitude = gpsToLatLng(longitude) * (eWind === 0x45 ? 1 : -1); // 'E'的ASCII是0x45
        poi.active = status === 0x41; // 'A'的ASCII是0x41
        poi.event = reservd === 1;
        poi.speed = speed * 1.852; //海里转公里
        poi.angle = speed === 0 ? lastAngle : angle;

        array.push(poi);
        lastAngle = poi.angle;
      }
    }

    fileIo.closeSync(file);

    if (array.length > 0) {
      if (!array[0].active) {
        for (const poi of array) {
          if (poi.active) {
            array[0].locFrom(poi);
            break;
          }
        }
      }
      return array;
    }
  } catch (e) {
    console.error("Parse Poi error:", JSON.stringify(e));
  }

  return null;
}