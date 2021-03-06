import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sign_in/router/index.dart';
import 'package:flutter_sign_in/utils/system/index.dart';

class ClickJumpSplash extends StatefulWidget {
  final String localImageUrl;
  final String goPagePath;

  const ClickJumpSplash({Key? key, required this.localImageUrl, required this.goPagePath}) : super(key: key);

  @override
  State<ClickJumpSplash> createState() => _ClickJumpSplashState();
}

class _ClickJumpSplashState extends State<ClickJumpSplash> with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late Timer _timer;
  int step = 3;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    animationExec();
  }

  @override
  void dispose() {
    _controller.dispose(); // 销毁动画
    _timer.cancel();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  void animationExec() {
    //创建动画控制器
    // 1.当创建一个AnimationController时，需要传递一个vsync参数，存在vsync时会防止屏幕外动画（动画的 UI不在当前屏幕时）消耗不必要的资源。
    // 2.通过将SingleTickerProviderStateMixin添加到类定义中，可以将stateful对象作为vsync的值。如果要使用自定义的State对象作为vsync时，请包含TickerProviderStateMixin
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: step * 1000),
    );

    final Animation<double> animation = Tween(begin: 0.0, end: 1.0).animate(_controller);

    animation.addStatusListener((status) {
      if (status == AnimationStatus.forward) startTiming();

      // 添加动画的监听，当动画完成后的状态是completed完成状态，则执行这边的代码，跳转到登录页
      if (status == AnimationStatus.completed) startJump();
    });

    // 开始执行动画
    _controller.forward();
  }

  // ! 如果产生按钮自己被点击,查看是不是开启了 自动跳过 的软件
  void startJump() async {
    barWidgetShow();

    Routers().navigateTo(widget.goPagePath, clearStack: true);
  }

  void startTiming() {
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      setState(() => step--);
      if (step == 0) timer.cancel();
    });
  }

  ///  生命周期变化时回调
  ///  类需要携带：with WidgetsBindingObserver 及 WidgetsBinding.instance.addObserver(this) 及 WidgetsBinding.instance.removeObserver(this);
  ///  resumed:应用可见并可响应用户操作
  ///  inactive:用户可见，但不可响应用户操作
  ///  paused:已经暂停了，用户不可见、不可操作
  ///  suspending：应用被挂起，此状态IOS永远不会回调
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      // 应用可见并可响应用户操作
      case AppLifecycleState.resumed:
        startTiming();
        _controller.forward();
        break;
      // 用户可见，但不可响应用户操作
      case AppLifecycleState.inactive:
        break;
      // 已经暂停了，用户不可见、不可操作
      case AppLifecycleState.paused:
        _timer.cancel();
        _controller.stop();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.transparent,
          child: Image.asset(
            widget.localImageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Positioned(
          top: 50.0,
          right: 20.0,
          child: OutlinedButton(
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(Size(130.w, 40.h)),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            onPressed: startJump,
            child: const Text('跳过'),
          ),
        ),
      ],
    );
  }
}
