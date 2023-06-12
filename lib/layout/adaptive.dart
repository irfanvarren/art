// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:animations/animations.dart';
import 'package:art/pages/client_add_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:adaptive_breakpoints/adaptive_breakpoints.dart';
import 'package:art/widgets/price_quote_body.dart';
import 'package:art/pages/price_quote_add_page.dart';
import 'package:art/main.dart';
//import 'package:provider/provider.dart';

/// The maximum width taken up by each item on the home screen.
//const maxHomeItemWidth = 1400.0;

const _iconAssetLocation = 'assets/icons';
const _kAnimationDuration = Duration(milliseconds: 300);
const double _kFlingVelocity = 2.0;

final desktopMailNavKey = GlobalKey<NavigatorState>();
final mobileMailNavKey = GlobalKey<NavigatorState>();

/// Returns a boolean value whether the window is considered medium or large size.
///
/// When running on a desktop device that is also foldable, the display is not
/// considered desktop. Widgets using this method might consider the display is
/// large enough for certain layouts, which is not the case on foldable devices,
/// where only part of the display is available to said widgets.
///
/// Used to build adaptive and responsive layouts.
bool isDisplayDesktop(BuildContext context) =>
    !isDisplayFoldable(context) &&
    getWindowType(context) >= AdaptiveWindowType.medium;

/// Returns boolean value whether the window is considered medium size.
///
/// Used to build adaptive and responsive layouts.
bool isDisplaySmallDesktop(BuildContext context) {
  return getWindowType(context) == AdaptiveWindowType.medium;
}

/// Returns a boolean value whether the display has a hinge that splits the
/// screen into two, left and right sub-screens. Horizontal splits (top and
/// bottom sub-screens) are ignored for this application.
bool isDisplayFoldable(BuildContext context) {
  /*final hinge = MediaQuery.of(context).hinge;
  if (hinge == null) {
    return false;
  } else {
    // Vertical
    return hinge.bounds.size.aspectRatio < 1;
  }*/
  return false;
}

class AdaptiveNav extends StatefulWidget {
  const AdaptiveNav({super.key, this.username});
  final String? username;

  @override
  State<AdaptiveNav> createState() => _AdaptiveNavState();
}

class _AdaptiveNavState extends State<AdaptiveNav> {
  UniqueKey _inboxKey = UniqueKey();
  String destination = 'clients';
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if the username is null or empty

      if (widget.username == null) {
        // User is not logged in, redirect to the login page
        Navigator.pushReplacementNamed(context, MyApp.rootRoute);
      }
    });
    final String username = widget.username ?? 'user';
    final isDesktop = isDisplayDesktop(context);
    final isTablet = isDisplaySmallDesktop(context);
    final navigationDestinations = <_Destination>[
      _Destination(
        type: 'clients',
        textLabel: 'Clients',
        icon: '$_iconAssetLocation/twotone-person-add-alt.png',
      ),
      _Destination(
        type: 'all',
        textLabel: "Penawaran Harga",
        icon: '$_iconAssetLocation/twotone_price_change.png',
      ),
      _Destination(
        type: 'prioritas',
        textLabel: 'Prioritas',
        icon: '$_iconAssetLocation/twotone_star.png',
      ),
      _Destination(
        type: 'done',
        textLabel: 'Done',
        icon: '$_iconAssetLocation/twotone_baseline_done_outline.png',
      ),
    ];

    if (isDesktop) {
      return _DesktopNav(
          inboxKey: _inboxKey,
          extended: !isTablet,
          destinations: navigationDestinations,
          onItemTapped: _onDestinationSelected,
          username: username,
          destination: destination);
    } else {
      return _MobileNav(
          inboxKey: _inboxKey,
          extended: !isTablet,
          destinations: navigationDestinations,
          onItemTapped: _onDestinationSelected,
          username: username,
          destination: destination);
    }
  }

  void _onDestinationSelected(int index, String selectedDestination) {
    /*var emailStore = Provider.of<EmailStore>(
      context,
      listen: false,
    );*/

    final isDesktop = isDisplayDesktop(context);

    /*if (emailStore.selectedMailboxPage != destination) {
      _inboxKey = UniqueKey();
    }*/

    //emailStore.selectedMailboxPage = destination;

    // if (isDesktop) {
    //   desktopMailNavKey.currentState!
    //       .pushReplacementNamed(MyApp.homeRoute, arguments: destination);
    // } else {
    //   mobileMailNavKey.currentState!
    //       .pushReplacementNamed(MyApp.homeRoute, arguments: destination);
    // }

    print('selected destination');
    print(selectedDestination);
    setState(() {
      destination = selectedDestination;
    });

    /* if (isDesktop) {
      while (desktopMailNavKey.currentState!.canPop()) {
        desktopMailNavKey.currentState!.pop();
      }
    } else {
      mobileMailNavKey.currentState!.pop();
    }*/

    /*if (emailStore.onMailView) {
      if (!isDesktop) {
        mobileMailNavKey.currentState!.pop();
      }

      emailStore.selectedEmailId = -1;
    }*/
  }
}

class _Destination {
  const _Destination({
    required this.type,
    required this.textLabel,
    required this.icon,
  });

  // Which mailbox page to display. For example, 'Starred' or 'Trash'.
  final String type;

  // The localized text label for the inbox.
  final String textLabel;

  // The icon that appears next to the text label for the inbox.
  final String icon;
}

class _DesktopNav extends StatefulWidget {
  _DesktopNav({
    this.inboxKey,
    required this.extended,
    required this.destinations,
    required this.onItemTapped,
    required this.username,
    required this.destination,
  });
  final bool extended;
  final UniqueKey? inboxKey;
  final List<_Destination> destinations;
  final void Function(int, String) onItemTapped;
  final String username;
  final String destination;

  @override
  _DesktopNavState createState() => _DesktopNavState();
}

class _DesktopNavState extends State<_DesktopNav>
    with SingleTickerProviderStateMixin {
  late ValueNotifier<bool> _isExtended;
  late String selectedDestination = '';
  @override
  void initState() {
    super.initState();
    _isExtended = ValueNotifier<bool>(widget.extended);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
              color: theme.colorScheme.primary,
              height: 4.0,
            ),
          ),
          leading: _AppLogo(
              logoSize: 96.0, logoColor: Colors.white.withOpacity(0.0)),
          leadingWidth: 100.0,
          title: const Text('')),
      body: Row(
        children: [
          //Consumer<EmailStore>(
          //  builder: (context, model, child) {
          /*return*/
          LayoutBuilder(
            builder: (context, constraints) {
              /*final selectedIndex =
                  widget.destinations.indexWhere((destination) {
                return destination.type == 'all';
              });*/
              int selectedIndex = 0;
              return Container(
                color: Theme.of(context).navigationRailTheme.backgroundColor,
                child: SingleChildScrollView(
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _isExtended,
                        builder: (context, value, child) {
                          return NavigationRail(
                            destinations: [
                              for (var destination in widget.destinations)
                                NavigationRailDestination(
                                  icon: Material(
                                    key: ValueKey(
                                      'App-${destination.textLabel}',
                                    ),
                                    color: Colors.transparent,
                                    child: ImageIcon(
                                      AssetImage(
                                        destination.icon,
                                        // package: _assetsPackage,
                                      ),
                                    ),
                                  ),
                                  label: Text(destination.textLabel),
                                ),
                            ],
                            extended: true,
                            selectedIconTheme:
                                IconThemeData(color: ui.Color(0xFF6E6B78)),
                            selectedLabelTextStyle:
                                TextStyle(color: ui.Color(0xFF6E6B78)),
                            labelType: NavigationRailLabelType.none,
                            leading: (widget.username == 'admin')
                                ? _NavigationRailHeader(
                                    extended: _isExtended,
                                    selectedDestination: selectedDestination,
                                    username: widget.username)
                                : Container(),
                            selectedIndex: selectedIndex,
                            onDestinationSelected: (index) {
                              selectedDestination =
                                  widget.destinations[index].type;
                              widget.onItemTapped(
                                index,
                                widget.destinations[index].type,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // },
          //),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1340),
                child: _SharedAxisTransitionSwitcher(
                  defaultChild: _MailNavigator(
                    child: MailboxBody(
                      key: widget.inboxKey,
                      parentContext: context,
                      username: widget.username,
                      destination: widget.destination,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileNav extends StatefulWidget {
  const _MobileNav({
    this.inboxKey,
    required this.extended,
    required this.destinations,
    required this.onItemTapped,
    required this.username,
    required this.destination,
  });
  final bool extended;
  final UniqueKey? inboxKey;
  final List<_Destination> destinations;

  final String username;
  final String destination;
  //final Map<String, String> folders;
  final void Function(int, String) onItemTapped;

  @override
  _MobileNavState createState() => _MobileNavState();
}

class _MobileNavState extends State<_MobileNav> with TickerProviderStateMixin {
  late ValueNotifier<bool> _isExtended;

  final _bottomDrawerKey = GlobalKey(debugLabel: 'Bottom Drawer');
  late AnimationController _drawerController;
  late AnimationController _dropArrowController;
  late AnimationController _bottomAppBarController;
  late Animation<double> _drawerCurve;
  late Animation<double> _dropArrowCurve;
  late Animation<double> _bottomAppBarCurve;
  String selectedDestination = '';
  late String destination; // = widget.destination;
  int selectedIndex = 0;
  bool fabClosed = false;
  @override
  void initState() {
    super.initState();
    destination = 'clients';
    _isExtended = ValueNotifier<bool>(widget.extended);

    _drawerController = AnimationController(
      duration: _kAnimationDuration,
      value: 0,
      vsync: this,
    )..addListener(() {
        if (_drawerController.value < 0.01) {
          setState(() {
            //Reload state when drawer is at its smallest to toggle visibility
            //If state is reloaded before this drawer closes abruptly instead
            //of animating.
          });
        }
      });

    _dropArrowController = AnimationController(
      duration: _kAnimationDuration,
      vsync: this,
    );

    _bottomAppBarController = AnimationController(
      vsync: this,
      value: 1,
      duration: const Duration(milliseconds: 250),
    );

    _drawerCurve = CurvedAnimation(
      parent: _drawerController,
      curve: standardEasing,
      reverseCurve: standardEasing.flipped,
    );

    _dropArrowCurve = CurvedAnimation(
      parent: _dropArrowController,
      curve: standardEasing,
      reverseCurve: standardEasing.flipped,
    );

    _bottomAppBarCurve = CurvedAnimation(
      parent: _bottomAppBarController,
      curve: standardEasing,
      reverseCurve: standardEasing.flipped,
    );
  }

  @override
  void dispose() {
    _drawerController.dispose();
    _dropArrowController.dispose();
    _bottomAppBarController.dispose();
    super.dispose();
  }

  void changeFabClosed(bool closed) {
    setState(() {
      fabClosed = closed;
    });
  }

  bool get _bottomDrawerVisible {
    final status = _drawerController.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  void _toggleBottomDrawerVisibility() {
    if (_drawerController.value < 0.4) {
      _drawerController.animateTo(0.4, curve: standardEasing);
      _dropArrowController.animateTo(0.35, curve: standardEasing);
      return;
    }

    _dropArrowController.forward();
    _drawerController.fling(
      velocity: _bottomDrawerVisible ? -_kFlingVelocity : _kFlingVelocity,
    );
  }

  double get _bottomDrawerHeight {
    final renderBox =
        _bottomDrawerKey.currentContext!.findRenderObject() as RenderBox;
    return renderBox.size.height;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _drawerController.value -= details.primaryDelta! / _bottomDrawerHeight;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_drawerController.isAnimating ||
        _drawerController.status == AnimationStatus.completed) {
      return;
    }

    final flingVelocity =
        details.velocity.pixelsPerSecond.dy / _bottomDrawerHeight;

    if (flingVelocity < 0.0) {
      _drawerController.fling(
        velocity: math.max(_kFlingVelocity, -flingVelocity),
      );
    } else if (flingVelocity > 0.0) {
      _dropArrowController.forward();
      _drawerController.fling(
        velocity: math.min(-_kFlingVelocity, -flingVelocity),
      );
    } else {
      if (_drawerController.value < 0.6) {
        _dropArrowController.forward();
      }
      _drawerController.fling(
        velocity:
            _drawerController.value < 0.6 ? -_kFlingVelocity : _kFlingVelocity,
      );
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      if (notification is UserScrollNotification) {
        switch (notification.direction) {
          case ScrollDirection.forward:
            _bottomAppBarController.forward();
            break;
          case ScrollDirection.reverse:
            _bottomAppBarController.reverse();
            break;
          case ScrollDirection.idle:
            break;
        }
      }
    }
    return false;
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    final drawerSize = constraints.biggest;
    final drawerTop = drawerSize.height;

    final drawerAnimation = RelativeRectTween(
      begin: RelativeRect.fromLTRB(0.0, drawerTop, 0.0, 0.0),
      end: const RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(_drawerCurve);

    return Row(
      children: [
        NavigationRail(
          destinations: [
            for (var destination in widget.destinations)
              NavigationRailDestination(
                icon: Material(
                  key: ValueKey(
                    'App-${destination.textLabel}',
                  ),
                  color: Colors.transparent,
                  child: ImageIcon(
                    size: 20,
                    AssetImage(
                      destination.icon,
                      // package: _assetsPackage,
                    ),
                  ),
                ),
                label: Text(destination.textLabel),
              ),
          ],
          extended: false,
          selectedIconTheme: IconThemeData(color: ui.Color(0xFFC55B11)),
          selectedLabelTextStyle: TextStyle(color: ui.Color(0xFFC55B11)),
          labelType: NavigationRailLabelType.none,
          leading: const SizedBox(),
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              selectedIndex = index;
              selectedDestination = widget.destinations[selectedIndex].type;
              destination = selectedDestination;
              print('on destination selected' + selectedIndex.toString());
              print(destination);
            });
            widget.onItemTapped(
              index,
              widget.destinations[index].type,
            );
          },
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            key: _bottomDrawerKey,
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: _handleScrollNotification,
                // child: _MailNavigator(
                child: MailboxBody(
                    key: widget.inboxKey,
                    parentContext: context,
                    username: widget.username,
                    destination: destination),
                //  ),
              ),
              /*MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    _drawerController.reverse();
                    _dropArrowController.reverse();
                  },
                  child: Visibility(
                    maintainAnimation: true,
                    maintainState: true,
                    visible: _bottomDrawerVisible,
                    child: FadeTransition(
                      opacity: _drawerCurve,
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        color: Theme.of(context)
                            .bottomSheetTheme
                            .modalBackgroundColor,
                      ),
                    ),
                  ),
                ),
              ),*/
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print('build x');
    final theme = Theme.of(context);
    return _SharedAxisTransitionSwitcher(
      defaultChild: Scaffold(
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
              color: theme.colorScheme.primary,
              height: 4.0,
            ),
          ),
          leading: _AppLogo(
            logoSize: 40.0,
          ),
          leadingWidth: 100.0,
        ),
        body: LayoutBuilder(
          builder: _buildStack,
        ),
        floatingActionButton: _bottomDrawerVisible
            ? null
            : Padding(
                padding: EdgeInsetsDirectional.only(bottom: 12),
                child: _ReplyFab(
                    selectedDestination: selectedDestination,
                    username: widget.username,
                    changeFabClosed: changeFabClosed),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}

class _NavigationRailHeader extends StatelessWidget {
  const _NavigationRailHeader(
      {required this.extended,
      required this.selectedDestination,
      required this.username});

  final ValueNotifier<bool> extended;
  final String selectedDestination;
  final String username;
  void changeFabClosed(bool closed) {}
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final animation = NavigationRail.extendedAnimation(context);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 8,
                ),
                child: _ReplyFab(
                  extended: extended.value,
                  selectedDestination: selectedDestination,
                  username: username,
                  changeFabClosed: changeFabClosed,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _MailNavigator extends StatefulWidget {
  const _MailNavigator({
    required this.child,
  });

  final Widget child;

  @override
  _MailNavigatorState createState() => _MailNavigatorState();
}

class _MailNavigatorState extends State<_MailNavigator> {
  static const inboxRoute = '/reply/inbox';

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(context);

    return Navigator(
      restorationScopeId: 'replyMailNavigator',
      key: isDesktop ? desktopMailNavKey : mobileMailNavKey,
      initialRoute: inboxRoute,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case inboxRoute:
            return MaterialPageRoute<void>(
              builder: (context) {
                return _FadeThroughTransitionSwitcher(
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  child: widget.child,
                );
              },
              settings: settings,
            );
          case MyApp.homeRoute:
            return MaterialPageRoute<void>(
              builder: (context) {
                return _FadeThroughTransitionSwitcher(
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  child: widget.child,
                );
              },
              settings: settings,
            );
          case MyApp.composeRoute:
            return MyApp.createComposeRoute(settings);
        }
        return null;
      },
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo({required this.logoSize, this.logoColor});
  final double logoSize;
  final Color? logoColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Image.asset(
        'assets/logo.png',
      ),
    );
  }
}

class _ReplyFab extends StatefulWidget {
  const _ReplyFab(
      {this.extended = false,
      required this.selectedDestination,
      required this.username,
      required this.changeFabClosed});
  final String username;
  final bool extended;
  final Function(bool) changeFabClosed;
  final String selectedDestination;

  @override
  _ReplyFabState createState() => _ReplyFabState();
}

class _ReplyFabState extends State<_ReplyFab>
    with SingleTickerProviderStateMixin {
  static final fabKey = UniqueKey();
  static const double _mobileFabDimension = 56;

  void onPressed(String destination) {
    /*var onSearchPage = Provider.of<EmailStore>(
      context,
      listen: false,
    ).onSearchPage;
    */

    // Navigator does not have an easy way to access the current
    // route when using a GlobalKey to keep track of NavigatorState.
    // We can use [Navigator.popUntil] in order to access the current
    // route, and check if it is a ComposePage. If it is not a
    // ComposePage and we are not on the SearchPage, then we can push
    // a ComposePage onto our navigator. We return true at the end
    // so nothing is popped.
    if (destination == 'clients') {
    } else {
      desktopMailNavKey.currentState!.popUntil(
        (route) {
          var currentRoute = route.settings.name;

          if (currentRoute != MyApp.composeRoute /*&& !onSearchPage*/) {
            desktopMailNavKey.currentState!
                .restorablePushNamed(MyApp.composeRoute);
          }
          return true;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(context);
    final theme = Theme.of(context);
    const circleFabBorder = CircleBorder();
    String replyDestination = 'clients';
    if (widget.selectedDestination != null &&
        widget.selectedDestination.isNotEmpty) {
      replyDestination = widget.selectedDestination;
    }
    /*
    return Selector<EmailStore, bool>(
      selector: (context, emailStore) => emailStore.onMailView,
      builder: (context, onMailView, child) {
        final fabSwitcher = _FadeThroughTransitionSwitcher(
          fillColor: Colors.transparent,
          child: onMailView
              ? Icon(
                  Icons.reply_all,
                  key: fabKey,
                  color: Colors.black,
                )
              : const Icon(
                  Icons.create,
                  color: Colors.black,
                ),
        );
        final tooltip = onMailView ? 'Reply' : 'Compose';
      */
    final fabSwitcher = _FadeThroughTransitionSwitcher(
        fillColor: Colors.transparent,
        child: Icon(
          Icons.add,
          key: fabKey,
          color: Colors.black,
        ));
    final tooltip = 'Tambah Data';
    if (isDesktop) {
      final animation = NavigationRail.extendedAnimation(context);
      return Container(
        height: 56,
        padding: EdgeInsets.symmetric(
          vertical: ui.lerpDouble(0, 6, animation.value)!,
        ),
        child: animation.value == 0
            ? FloatingActionButton(
                key: const ValueKey('ReplyFab'),
                onPressed: () {
                  onPressed(replyDestination);
                },
                child: fabSwitcher,
              )
            : Align(
                alignment: AlignmentDirectional.centerStart,
                child: FloatingActionButton.extended(
                  key: const ValueKey('ReplyFab'),
                  label: Row(
                    children: [
                      fabSwitcher,
                      SizedBox(width: 16 * animation.value),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        widthFactor: animation.value,
                        child: Text(
                          tooltip,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                fontSize: 16,
                                color: theme.colorScheme.onSecondary,
                              ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    onPressed(replyDestination);
                  },
                ),
              ),
      );
    } else {
      /*desktopMailNavKey.currentState!.popUntil(
      (route) {
        var currentRoute = route.settings.name;

        if (currentRoute != MyApp.composeRoute /*&& !onSearchPage*/) {
          desktopMailNavKey.currentState!
              .restorablePushNamed(MyApp.composeRoute);
        }
        return true;
      },
    );*/

      // TODO(x): State restoration of compose page on mobile is blocked because OpenContainer does not support restorablePush, https://github.com/flutter/gallery/issues/570.
      if (widget.username == 'admin') {
        Widget openedPage;
        if (replyDestination == 'clients' || replyDestination.isEmpty) {
          openedPage = ClientAddPage(
            isEdit: false,
            editId: '',
          );
        } else {
          openedPage = ComposePage(
              isEdit: false,
              isDone: false,
              editId: '',
              username: widget.username);
        }

        return OpenContainer(
          openBuilder: (context, closedContainer) {
            return openedPage;
          },
          openColor: theme.cardColor,
          closedShape: circleFabBorder,
          closedColor: theme.colorScheme.secondary,
          closedElevation: 6,
          onClosed: (data) {
            widget.changeFabClosed(true);
          },
          closedBuilder: (context, openContainer) {
            //print('closed');
            //
            return Tooltip(
              message: tooltip,
              child: InkWell(
                key: const ValueKey('ReplyFab'),
                customBorder: circleFabBorder,
                onTap: openContainer,
                child: SizedBox(
                  height: _mobileFabDimension,
                  width: _mobileFabDimension,
                  child: Center(
                    child: fabSwitcher,
                  ),
                ),
              ),
            );
          },
        );
      } else {
        return Container();
      }
    }
    /*
      },
    );*/
  }
}

class _FadeThroughTransitionSwitcher extends StatelessWidget {
  const _FadeThroughTransitionSwitcher({
    required this.fillColor,
    required this.child,
  });

  final Widget child;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      transitionBuilder: (child, animation, secondaryAnimation) {
        return FadeThroughTransition(
          fillColor: fillColor,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      child: child,
    );
  }
}

class _SharedAxisTransitionSwitcher extends StatelessWidget {
  const _SharedAxisTransitionSwitcher({required this.defaultChild});

  final Widget defaultChild;

  @override
  Widget build(BuildContext context) {
    //return Selector<EmailStore, bool>(
    //  selector: (context, emailStore) => emailStore.onSearchPage,
    //  builder: (context, onSearchPage, child) {
    return PageTransitionSwitcher(
      //reverse: !onSearchPage,
      transitionBuilder: (child, animation, secondaryAnimation) {
        return SharedAxisTransition(
          fillColor: Theme.of(context).colorScheme.background,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.scaled,
          child: child,
        );
      },
      child: defaultChild,
      // child: onSearchPage ? const SearchPage() : defaultChild,
    );
    //  },
    // );
  }
}
