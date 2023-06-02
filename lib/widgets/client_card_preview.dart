import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:art/main.dart';
import 'package:art/layout/adaptive.dart';
import 'package:art/pages/client_view_page.dart';
import 'package:art/pages/client_add_page.dart';
import 'package:art/model/price_quote_model.dart';
import 'package:art/model/price_quote_store.dart';
import 'package:intl/intl.dart';

//import 'package:provider/provider.dart';

//const _assetsPackage = 'packages';
const _iconAssetLocation = 'assets/icons';

class ClientPreviewCard extends StatelessWidget {
  const ClientPreviewCard(
      {super.key,
      required this.id,
      required this.username,
      required this.client,
      required this.onDelete,
      required this.openEditPage});

  final String id;
  final String username;
  final Client client;
  final VoidCallback onDelete;
  final VoidCallback openEditPage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // TODO(x): State restoration of mail view page is blocked because OpenContainer does not support restorablePush, https://github.com/flutter/gallery/issues/570.
    return OpenContainer(
      openBuilder: (context, closedContainer) {
        return ClientViewPage(id: id, client: client);
      },
      openColor: theme.cardColor,
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(0)),
      ),
      closedElevation: 0,
      closedColor: theme.cardColor,
      closedBuilder: (context, openContainer) {
        final isDesktop = isDisplayDesktop(context);
        final colorScheme = theme.colorScheme;
        final mailPreview = _ClientPreview(
          id: id,
          username: username,
          client: client,
          onTap: openContainer,
          onDelete: onDelete,
          openEditPage: openEditPage,
        );

        return mailPreview;
      },
    );
  }
}

class _DismissibleContainer extends StatelessWidget {
  const _DismissibleContainer({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.alignment,
    required this.padding,
  });

  final String icon;
  final Color backgroundColor;
  final Color iconColor;
  final Alignment alignment;
  final EdgeInsetsDirectional padding;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      alignment: alignment,
      curve: standardEasing,
      color: backgroundColor,
      duration: kThemeAnimationDuration,
      padding: padding,
      child: Material(
        color: Colors.transparent,
        child: ImageIcon(
          AssetImage(
            'assets/icons/$icon.png',
            package: 'packages',
          ),
          size: 36,
          color: iconColor,
        ),
      ),
    );
  }
}

class _ClientPreview extends StatelessWidget {
  const _ClientPreview(
      {required this.id,
      required this.username,
      required this.client,
      required this.onTap,
      this.onDelete,
      this.openEditPage});

  final String id;
  final String username;
  final Client client;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? openEditPage;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    /*var clientStore = Provider.of<ClientStore>(
      context,
      listen: false,
    );*/
    return InkWell(
      onTap: () {
        /* Provider.of<ClientStore>(
          context,
          listen: false,
        ).selectedClientId = id;
        onTap();*/
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: constraints.maxHeight),
            child: Container(
              padding: const EdgeInsets.all(14),
              child: Container(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            client.namaKlien,
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            client.email.isNotEmpty
                                ? 'Email : ' + client.email
                                : 'Email : -',
                            style: textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            client.noHp.isNotEmpty
                                ? 'No. Hp : ' + client.noHp
                                : 'No. HP : -',
                            style: textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            client.alamat.isNotEmpty
                                ? 'Alamat : ' + client.alamat
                                : 'Alamat : -',
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    // if (username == 'admin')
                    //   (
                    Container(
                      child: _ClientPreviewActionBar(
                          id: id,
                          onDelete: onDelete,
                          openEditPage: openEditPage),
                    )
                    //)
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ClientPreviewActionBar extends StatelessWidget {
  const _ClientPreviewActionBar(
      {required this.id, this.onDelete, this.openEditPage});
  final String id;
  final VoidCallback? onDelete;
  final VoidCallback? openEditPage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white : Colors.blue;
    final isDesktop = isDisplayDesktop(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: openEditPage,
          child: Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(
              Icons.edit,
              size: 20,
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onDelete,
          child: Padding(
            padding: EdgeInsets.only(left: 8),
            child: ImageIcon(
              size: 20,
              const AssetImage(
                '$_iconAssetLocation/twotone_delete.png',
                // package: _assetsPackage,
              ),
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
