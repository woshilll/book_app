class FutureDo {
  /// 延迟执行后续方法
  static void doAfterExecutor(Function() afterExecutor, {Function? preExecutor, final int milliseconds = 1000}) {
    if (preExecutor != null) {
      preExecutor();
    }
    Future.delayed(Duration(milliseconds: milliseconds), (){
      afterExecutor();
    });
  }

  /// 延迟300毫秒执行后续方法
  static void doAfterExecutor300(Function() afterExecutor, {Function? preExecutor}) {
    doAfterExecutor(afterExecutor, preExecutor: preExecutor, milliseconds: 300);
  }
}