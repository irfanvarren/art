import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:art/constants.dart';
import 'package:art/routes.dart';
import 'package:art/pages/price_quote_add_page.dart';
import 'package:art/data/options.dart';
import 'package:art/firebase_options.dart';
import 'package:art/themes/app_theme_data.dart';
import 'package:art/routes.dart' as routes;
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:art/model/price_quote_model.dart';
import 'package:art/model/price_quote_store.dart';
import 'dart:async';
import 'package:flutter_background/flutter_background.dart' as background;
import 'package:workmanager/workmanager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await GetStorage.init();

  if (defaultTargetPlatform != TargetPlatform.linux &&
      defaultTargetPlatform != TargetPlatform.windows) {
    WidgetsFlutterBinding.ensureInitialized();
    await initializeFirebase();
    FirebaseFirestore.instance.settings = Settings(persistenceEnabled: false);
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    this.initialRoute,
    this.isTestMode = false,
  });

  final String? initialRoute;
  final bool isTestMode;
  static const String composeRoute = routes.composeRoute;
  static const String homeRoute = routes.homeRoute;
  static const String rootRoute = routes.rootRoute;

  static Route createComposeRoute(RouteSettings settings) {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) => ComposePage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeThroughTransition(
          fillColor: Theme.of(context).cardColor,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      settings: settings,
    );
  }

  @override
  State<MyApp> createState() => _AppState();
  // This widget is the root of your application.
}

class _AppState extends State<MyApp> with RestorationMixin {
  final _RestorableEmailState _appState = _RestorableEmailState();

  @override
  String get restorationId => 'replyState';

  @override
  void initState() {
    super.initState();
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_appState, 'state');
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<EmailStore>.value(
          value: _appState.value,
        ),
      ],
      child: ModelBinding(
        initialModel: AppOptions(
          themeMode: ThemeMode.light,
          textScaleFactor: systemTextScaleFactorOption,
          customTextDirection: CustomTextDirection.localeBased,
          locale: null,
          timeDilation: timeDilation,
          platform: defaultTargetPlatform,
          isTestMode: widget.isTestMode,
        ),
        child: Builder(
          builder: (context) {
            final options = AppOptions.of(context);
            return MaterialApp(
              restorationScopeId: 'rootApp',
              title: 'Home',
              debugShowCheckedModeBanner: false,
              themeMode: options.themeMode,
              theme: AppThemeData.lightThemeData.copyWith(
                platform: options.platform,
              ),
              darkTheme: AppThemeData.darkThemeData.copyWith(
                platform: options.platform,
              ),
              initialRoute: widget.initialRoute,
              locale: options.locale,
              localeListResolutionCallback: (locales, supportedLocales) {
                deviceLocale = locales?.first;
                return basicLocaleListResolution(locales, supportedLocales);
              },
              onGenerateRoute: (settings) =>
                  RouteConfiguration.onGenerateRoute(settings),
            );
          },
        ),
      ),
    );
  }
}

class _RestorableEmailState extends RestorableListenable<EmailStore> {
  @override
  EmailStore createDefaultValue() {
    return EmailStore();
  }

  @override
  EmailStore fromPrimitives(Object? data) {
    final appState = EmailStore();
    final appData = Map<String, dynamic>.from(data as Map);
    appState.selectedEmailId = appData['selectedEmailId'] as int;
    appState.onSearchPage = appData['onSearchPage'] as bool;

    // The index of the MailboxPageType enum is restored.
    final mailboxPageIndex = appData['selectedMailboxPage'] as int;
    appState.selectedMailboxPage = MailboxPageType.values[mailboxPageIndex];

    final starredEmailIdsList = appData['starredEmailIds'] as List<dynamic>;
    appState.starredEmailIds = {
      ...starredEmailIdsList.map<String>((dynamic id) => id as String),
    };
    final trashEmailIdsList = appData['trashEmailIds'] as List<dynamic>;
    appState.trashEmailIds = {
      ...trashEmailIdsList.map<String>((dynamic id) => id as String),
    };
    return appState;
  }

  @override
  Object toPrimitives() {
    return <String, dynamic>{
      'selectedEmailId': value.selectedEmailId,
      // The index of the MailboxPageType enum is stored, since the value
      // has to be serializable.
      'selectedMailboxPage': value.selectedMailboxPage.index,
      'onSearchPage': value.onSearchPage,
      'starredEmailIds': value.starredEmailIds.toList(),
      'trashEmailIds': value.trashEmailIds.toList(),
    };
  }
}

class PageWrapper extends StatefulWidget {
  const PageWrapper({
    super.key,
    required this.page,
    this.alignment = AlignmentDirectional.bottomStart,
    this.hasBottomNavBar = false,
  });

  final Widget page;
  final bool hasBottomNavBar;
  final AlignmentDirectional alignment;

  @override
  State<PageWrapper> createState() => _PageWrapperState();
}

class _PageWrapperState extends State<PageWrapper> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ApplyTextOptions(
      child: Stack(
        children: [
          Semantics(
            sortKey: const OrdinalSortKey(1),
            child: RestorationScope(
              restorationId: 'page_wrapper',
              child: widget.page,
            ),
          ),
          // if (!isDisplayFoldable(context))
          //   SafeArea(
          //     child: Align(
          //       alignment: widget.alignment,
          //       child: Padding(
          //         padding: EdgeInsets.symmetric(
          //             horizontal: 16.0,
          //             vertical: widget.hasBottomNavBar
          //                 ? kBottomNavigationBarHeight + 16.0
          //                 : 16.0),
          //         child: Semantics(
          //           sortKey: const OrdinalSortKey(0),
          //           label: "Back",
          //           button: true,
          //           enabled: true,
          //           excludeSemantics: true,
          //           child: FloatingActionButton.extended(
          //             heroTag: _BackButtonHeroTag(),
          //             key: const ValueKey('Back'),
          //             onPressed: () {
          //               Navigator.of(context).popUntil(
          //                   (route) => route.settings.name == '/home');
          //             },
          //             icon: IconTheme(
          //               data: IconThemeData(color: colorScheme.onPrimary),
          //               child: const BackButtonIcon(),
          //             ),
          //             label: Text(
          //               MaterialLocalizations.of(context).backButtonTooltip,
          //               style: textTheme.labelLarge!
          //                   .apply(color: colorScheme.onPrimary),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}

class _BackButtonHeroTag {}
