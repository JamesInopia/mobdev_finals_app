// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/material.dart' as _i3;
import 'package:flutter/material.dart';
import 'package:mobdev_finals_app/ui/views/template/app_template.dart' as _i2;
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i4;

class Routes {
  static const fixedLayoutView = '/';

  static const all = <String>{fixedLayoutView};
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(
      Routes.fixedLayoutView,
      page: _i2.FixedLayoutView,
    )
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.FixedLayoutView: (data) {
      final args = data.getArgs<FixedLayoutViewArguments>(
        orElse: () => const FixedLayoutViewArguments(),
      );
      return _i3.MaterialPageRoute<dynamic>(
        builder: (context) => _i2.FixedLayoutView(key: args.key),
        settings: data,
      );
    }
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class FixedLayoutViewArguments {
  const FixedLayoutViewArguments({this.key});

  final _i3.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant FixedLayoutViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

extension NavigatorStateExtension on _i4.NavigationService {
  Future<dynamic> navigateToFixedLayoutView({
    _i3.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.fixedLayoutView,
        arguments: FixedLayoutViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithFixedLayoutView({
    _i3.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.fixedLayoutView,
        arguments: FixedLayoutViewArguments(key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }
}
