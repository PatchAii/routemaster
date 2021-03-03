import 'package:flutter/material.dart';
import 'delegate.dart';

class RouteInfo {
  final String path;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;

  const RouteInfo({
    @required this.path,
    @required this.pathParameters,
    @required this.queryParameters,
  });
}

@immutable
abstract class RoutemasterRoute {
  RoutemasterRoute();

  String get pathTemplate;

  RoutemasterElement createElement(
      RoutemasterDelegate delegate, RouteInfo path);

  final bool Function(RouteInfo info) validate = (_) => true;
  final void Function(RoutemasterDelegate routemaster, RouteInfo info)
      onValidationFailed = (routemaster, _) {
    // TODO: Go to default path, not hard-coded '/'
    routemaster.replaceNamed('/');
  };
}

abstract class RoutemasterElement {
  bool maybeSetRoutes(Iterable<RoutemasterElement> routes);
  bool maybePush(RoutemasterElement route);
  bool maybePop();

  RoutemasterElement get currentRoute;

  RouteInfo get routeInfo;
}

abstract class MultiPageRouteElement extends RoutemasterElement {
  List<Page> createPages();

  void pop();
  void push(RoutemasterElement routerData);
  void setRoutes(List<RoutemasterElement> newRoutes);
}

abstract class SinglePageRouteElement extends RoutemasterElement {
  Page createPage();
}

class WidgetRoute extends RoutemasterRoute {
  final String pathTemplate;
  final Widget Function(RouteInfo info) builder;
  final bool Function(RouteInfo info) validate;
  final void Function(RoutemasterDelegate routemaster, RouteInfo info)
      onValidationFailed;

  WidgetRoute(
    this.pathTemplate,
    this.builder, {
    this.validate,
    this.onValidationFailed,
  })  : assert(pathTemplate != null),
        assert(builder != null);

  @override
  RoutemasterElement createElement(
      RoutemasterDelegate delegate, RouteInfo routeInfo) {
    return WidgetRouteElement(this, routeInfo);
  }
}

class WidgetRouteElement extends SinglePageRouteElement {
  final WidgetRoute widgetRoute;
  final RouteInfo routeInfo;

  RoutemasterElement get currentRoute => this;

  WidgetRouteElement(this.widgetRoute, this.routeInfo)
      : assert(widgetRoute != null),
        assert(routeInfo != null);

  Page createPage() {
    return MaterialPage(
      child: widgetRoute.builder(routeInfo),
      key: ValueKey(routeInfo),
    );
  }

  bool maybeSetRoutes(Iterable<RoutemasterElement> routes) {
    return false;
  }

  @override
  bool maybePush(RoutemasterElement route) {
    return false;
  }

  @override
  bool maybePop() {
    return false;
  }
}
