// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

//import 'package:dual_screen/dual_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:art/main.dart';
import 'package:art/widgets/deffered_widget.dart';
import 'package:art/layout/adaptive.dart' deferred as home_page;
import 'package:art/pages/price_quote_add_page.dart'
    deferred as price_quote_add_page;
import 'package:art/pages/login.dart' as login_page;

import 'package:art/pages/upload_clients.dart' as upload_clients;

//import 'package:art/pages/home.dart';

const String composeRoute = '/price-quote-add';
const String homeRoute = '/home';
const String rootRoute = '/';

typedef PathWidgetBuilder = Widget Function(BuildContext, String?);

class Path {
  const Path(this.pattern, this.builder, {this.openInSecondScreen = false});

  /// A RegEx string for route matching.
  final String pattern;

  /// The builder for the associated pattern route. The first argument is the
  /// [BuildContext] and the second argument a RegEx match if that is included
  /// in the pattern.
  ///
  /// ```dart
  /// Path(
  ///   'r'^/demo/([\w-]+)$',
  ///   (context, matches) => Page(argument: match),
  /// )
  /// ```
  final PathWidgetBuilder builder;

  /// If the route should open on the second screen on foldables.
  final bool openInSecondScreen;
}

class RouteConfiguration {
  /// List of [Path] to for route matching. When a named route is pushed with
  /// [Navigator.pushNamed], the route name is matched with the [Path.pattern]
  /// in the list below. As soon as there is a match, the associated builder
  /// will be returned. This means that the paths higher up in the list will
  /// take priority.
  static List<Path> paths = [
    Path(
      r'^' + composeRoute,
      (context, match) => PageWrapper(
        page: DeferredWidget(
            price_quote_add_page.loadLibrary,
            // ignore: prefer_const_constructors
            () => price_quote_add_page.ComposePage()),
      ),
      openInSecondScreen: true,
    ),
    Path(
      r'^' + homeRoute,
      (context, match) => PageWrapper(
        page: DeferredWidget(
          home_page.loadLibrary,
          // ignore: prefer_const_constructors
          () => home_page.AdaptiveNav(),
        ),
      ),
      openInSecondScreen: true,
    ),
    Path(
      r'^/upload-clients',
      (context, match) => upload_clients.UploadClientPage(),
      openInSecondScreen: false,
    ),
    Path(
      r'^/',
      (context, match) => login_page.LoginPage(),
      openInSecondScreen: false,
    )
    /*Path(
      r'^/',
      (context, match) => const RootPage(),
      openInSecondScreen: false,
    ),*/
  ];

  /// The route generator callback used when the app is navigated to a named
  /// route. Set it on the [MaterialApp.onGenerateRoute] or
  /// [WidgetsApp.onGenerateRoute] to make use of the [paths] for route
  /// matching.
  static Route<dynamic>? onGenerateRoute(
    RouteSettings settings,
  ) {
    for (final path in paths) {
      final regExpPattern = RegExp(path.pattern);
      if (regExpPattern.hasMatch(settings.name!)) {
        final firstMatch = regExpPattern.firstMatch(settings.name!)!;
        final match = (firstMatch.groupCount == 1) ? firstMatch.group(1) : null;
        if (kIsWeb) {
          return NoAnimationMaterialPageRoute<void>(
            builder: (context) => path.builder(context, match),
            settings: settings,
          );
        } else {
          return MaterialPageRoute<void>(
            builder: (context) => path.builder(context, match),
            settings: settings,
          );
        }
      }
    }

    // If no match was found, we let [WidgetsApp.onUnknownRoute] handle it.
    return null;
  }
}

class NoAnimationMaterialPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationMaterialPageRoute({
    required super.builder,
    super.settings,
  });

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

/*class TwoPanePageRoute<T> extends OverlayRoute<T> {
  TwoPanePageRoute({
    required this.builder,
    super.settings,
  });

  final WidgetBuilder builder;

  @override
  Iterable<OverlayEntry> createOverlayEntries() sync* {
    yield OverlayEntry(builder: (context) {
      final hinge = MediaQuery.of(context).hinge?.bounds;
      if (hinge == null) {
        return builder.call(context);
      } else {
        return Positioned(
            top: 0,
            left: hinge.right,
            right: 0,
            bottom: 0,
            child: builder.call(context));
      }
    });
  }
  
}*/
