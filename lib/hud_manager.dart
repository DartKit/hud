import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

enum HUDState {
  visible,
  hidden,
  pending,
}

class HudManager {
  static HudManager? _instance;
  HudManager._internal() {
    _instance = this;
    _init();
  }
  factory HudManager() => _instance ?? HudManager._internal();

  HUDState _state = HUDState.hidden;

  Timer? _delayTimer;
  Timer? _protectionTimer;

  HUDConfiguration config = HUDConfiguration();

  HUDState get state => _state;
  bool get isShowing => _state == HUDState.visible;

  DateTime timeStart = DateTime.now();
  void _init() {}

  void configure(HUDConfiguration newConfig) {
    config = newConfig;
  }

  void showPending({Duration? delay,bool? barrierDismissible}) {
    if (isShowing) return;
    _delayTimer?.cancel();
    _state = HUDState.pending;
    _delayTimer = Timer(delay??config.showDelay, () {
      if (!isShowing) {
        _showNow(barrierDismissible:barrierDismissible);
      }
    });
  }

  void presentInstantly({String? message}) {
    _fullReset();
    _showNow(message: message);
  }

  void hide({int milliseconds = 0}) {
    var timeStop = DateTime.now();
    var gap = timeStop.difference(timeStart).inMilliseconds;
    if ((milliseconds > 0) && (gap < milliseconds)) {
      var eyeCanLookGap = milliseconds - gap;
      Future.delayed(Duration(milliseconds:   eyeCanLookGap > 300? eyeCanLookGap: 300), () {
        _fullReset();
      });
      return;
    }
    _fullReset();
  }

  void _showNow({String? message,bool? barrierDismissible}) {
    if (isShowing) return;

    timeStart = DateTime.now();
    _state = HUDState.visible;

    _protectionTimer?.cancel();
    _protectionTimer = Timer(config.timeAutoHide, () {
      if (isShowing) {
        _fullReset();
      }
    });
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
            child: SizedBox(
          width: config.size.width,
          height: config.size.height,
          child: config.child ??
              LoadingAnimationWidget.flickr(
                leftDotColor: const Color(0xFF213B32),
                rightDotColor: const Color(0xFF0BBD87),
                size: 30,
              ),
        )),
      ),
      barrierDismissible: barrierDismissible??config.barrierDismissible,
      barrierColor: config.barrierColor,
    );
  }

  void _fullReset() {
    _cancelTimers();
    if (isShowing) {
      _state = HUDState.hidden;
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    }
  }

  // void _handleLongRunningTask() {
  //   _fullReset();
  //   Get.rawSnackbar(
  //     message: "操作超时，请重试",
  //     duration: const Duration(seconds: 1),
  //   );
  // }

  void _cancelTimers() {
    _delayTimer?.cancel();
    _protectionTimer?.cancel();
  }
}

class HUDConfiguration {
  final Duration showDelay;
  final Duration timeAutoHide;
  final Size size;
  final Color barrierColor;
  final bool barrierDismissible;
  final Widget? child;

  const HUDConfiguration({
    this.child,
    this.barrierDismissible = false,
    this.barrierColor = Colors.transparent,
    this.size = const Size(40, 40),
    this.showDelay = const Duration(milliseconds: 500),
    this.timeAutoHide = const Duration(seconds: 35),
  });

}
