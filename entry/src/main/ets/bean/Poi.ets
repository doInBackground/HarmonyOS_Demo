@Observed
export class Poi {
  date?: string; //日期.[如:'2023/08/07 11:17:00']
  latitude?: number; //纬度.[如:22.611551]
  longitude?: number; //经度.[如:113.85876]
  active?: boolean; //GPS fixed or not.
  speed?: number; //速度.[如:2.0]
  angle?: number; //角度.[如:-204.0]
  event?: boolean; //是否事件.

  public same(poi: Poi): boolean {
    return Math.abs((this.latitude ?? 0) - (poi.latitude ?? 0)) < 0.0000001 && Math.abs((this.longitude ?? 0) - (poi.longitude ?? 0)) < 0.0000001
  }

  public locFrom(poi: Poi) {
    this.latitude = poi.latitude
    this.longitude = poi.longitude
    this.active = poi.active
    this.speed = poi.speed
    this.angle = poi.angle
  }
}