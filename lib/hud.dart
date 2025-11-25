
/*
// 🚀 终极简化使用方法：

// 基本用法
Hud.start();  // 请求开始
Hud.stop();   // 请求结束

// 包装异步任务（最佳实践）
final result = await Hud.during(
  http.get('https://api.example.com/data'),
  message: '正在加载数据'
);
* */

import 'hud_manager.dart';

/// Hud 便捷调用工具类
class Hud {
  static final HudManager _manager = HudManager();

  /// 初始化配置
  static void setup({
    Duration? delay,
    Duration? timeout,
  }) {
    _manager.configure(
      HUDConfiguration(
            showDelay: delay ?? _manager.config.showDelay,
        timeAutoHide: timeout ?? _manager.config.timeAutoHide,
    ),
    );
  }

  /// 开始请求（常用）
  static void show({int? delayMilliseconds,bool? barrierDismissible}) {
    _manager.hide();
    _manager.showPending(barrierDismissible:barrierDismissible,delay: delayMilliseconds == null? null: Duration(milliseconds: delayMilliseconds,));
  }

  /// 结束请求（常用）
  static void hide({int milliseconds = 0}) {
    _manager.hide(milliseconds:milliseconds);
  }

  /// 直接显示（特殊情况）
  static void msg({String? message}) {
    _manager.presentInstantly(message: message);
  }


  /// 包装异步任务（推荐）【在什么xx异步任务期间展示什么xx文案】
  static Future<T> during<T>(Future<T> task, {String? message}) async {
    show();
    try {
      final result = await task;
      hide();
      return result;
    } catch (e) {
      hide();
      rethrow;
    }
  }

  /// 获取状态信息
  static bool get isActive => _manager.isShowing;
}
