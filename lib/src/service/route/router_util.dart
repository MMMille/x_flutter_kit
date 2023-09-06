/// createTime: 2021/9/17 on 17:58
/// desc:
///
/// @author xueml

import 'dart:io';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:x_flutter_kit/src/service/route/bundle.dart';
import 'package:x_flutter_kit/src/service/route/router_history_stack.dart';
import 'package:x_flutter_kit/src/service/route/routes.dart';
import 'package:x_flutter_kit/todo_lib.dart';

class RouterUtil {
  factory RouterUtil() => _getInstance();

  static RouterUtil get instance => _getInstance();
  static RouterUtil? _instance;

  late FluroRouter _router;

  static RouterUtil _getInstance() {
    _instance ??= RouterUtil._internal();
    return _instance!;
  }

  RouterUtil._internal() {
    _init();
  }

  ///初始化
  void _init() {
    _router = FluroRouter();
    Routes.define(_router);
  }

  ///添加路由
  ///[route] 路由名称
  ///[handler] 路由处理器
  void addRoute(String route, RouteHandler handler) {
    Routes.addRoute(_router, route, handler);
  }

  RouteFactory? generator() {
    return _router.generator;
  }

  Bundle build([String route = '']) {
    return Bundle(route);
  }

  ///直接跳转
  Future navigate(Bundle bundle) {
    return navigateTo(bundle);
  }

  ///替换当前路由跳转
  Future navigateReplace(Bundle bundle) {
    return navigateTo(bundle, replace: true);
  }

  ///清除之前所有路由跳转
  Future navigateClear(Bundle bundle) {
    return navigateTo(bundle, clearStack: true);
  }

  ///清除路由为[untilRoute]之上的路由，然后在打开新的路由[bundle]里的route
  Future navigatePopUntil(String untilRoute, Bundle bundle) {
    popUntil(untilRoute);
    return navigate(bundle);
  }

  ///直接跳转同时接收页面返回值
  Future navigateResult(ValueChanged<Bundle> result, Bundle bundle) {
    return navigateTo(bundle).then((value) => result(value ?? Bundle()));
  }

  ///返回页面
  void pop([Bundle? bundle]) {
    Navigator.of(TodoLib.navigatorKey.currentContext!).pop(bundle);
  }

  ///返回页面直到路由为[untilRoute]时停止
  void popUntil(String untilRoute, [Bundle? bundle]) {
    Navigator.of(TodoLib.navigatorKey.currentContext!).popUntil((route) {
      if (route.settings.name == untilRoute) {
        (route.settings.arguments! as Bundle).copyWith(bundle);
        return true;
      }
      return false;
    });
  }

  ///移除指定[route]路由名称的路由
  bool removeRoute(String route) {
    final Route? history = RouterHistoryStack.instance.get(route);
    if (history == null) {
      return false;
    } else {
      Navigator.of(TodoLib.navigatorKey.currentContext!).removeRoute(history);
      return true;
    }
  }

  ///跳转
  Future navigateTo(
    Bundle bundle, {
    bool replace = false,
    bool clearStack = false,
    bool rootNavigator = false,
    bool maintainState = true,
    TransitionType transition = TransitionType.material,
    Duration? transitionDuration,
    RouteTransitionsBuilder? transitionBuilder,
  }) {
    ///arguments: 用于当使用popUntil时携带返回参数
    final RouteSettings routeSettings =
        RouteSettings(name: bundle.route, arguments: bundle);
    final route = bundle.route + bundle.toUri();
    if (Platform.isIOS) {
      transition = TransitionType.cupertino;
    }
    return _router.navigateTo(
      TodoLib.navigatorKey.currentContext!,
      route,
      replace: replace,
      clearStack: clearStack,
      maintainState: maintainState,
      rootNavigator: rootNavigator,
      transition: transition,
      transitionDuration: transitionDuration,
      transitionBuilder: transitionBuilder,
      routeSettings: routeSettings,
    );
  }
}
