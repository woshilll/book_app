/// 阅读页样式
enum ReadPageType {
  /// 平滑
  // smooth,
  /// 平滑动画
  /// another_transformer_page_view
  // smooth_1,
  // smooth_2,
  // smooth_3,
  // smooth_4,
  // smooth_5,
  // smooth_6,
  // /// 覆盖
  // cover,
  // /// 仿真
  // emulation,
  /// 点击
  point,
  /// 滑动翻页
  slide,
  /// 上下滑动
  slideUpDown,
  /// 上下平滑
  // list,
}
ReadPageType getReadPageTypeByStr(String? str) {
  switch(str) {
    case "slide":
      return ReadPageType.slide;
    case "slideUpDown":
      return ReadPageType.slideUpDown;
    case "point":
      return ReadPageType.point;
  }
  return ReadPageType.slide;
}
