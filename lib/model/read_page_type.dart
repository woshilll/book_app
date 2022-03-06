/// 阅读页样式
enum ReadPageType {
  /// 平滑
  smooth,
  /// 平滑动画
  smooth_1,
  smooth_2,
  smooth_3,
  smooth_4,
  smooth_5,
  smooth_6,
  // /// 覆盖
  // cover,
  // /// 仿真
  // emulation,
  /// 点击
  point
}
ReadPageType getReadPageTypeByStr(String? str) {
  switch(str) {
    case "smooth":
      return ReadPageType.smooth;
    case "smooth_1":
      return ReadPageType.smooth_1;
    case "smooth_2":
      return ReadPageType.smooth_2;
    case "smooth_3":
      return ReadPageType.smooth_3;
    case "smooth_4":
      return ReadPageType.smooth_4;
    case "smooth_5":
      return ReadPageType.smooth_5;
    case "smooth_6":
      return ReadPageType.smooth_6;
    case "point":
      return ReadPageType.point;
  }
  return ReadPageType.smooth;
}
