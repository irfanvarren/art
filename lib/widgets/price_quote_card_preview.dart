import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:art/main.dart';
import 'package:art/layout/adaptive.dart';
import 'package:art/pages/price_quote_view_page.dart';
import 'package:art/pages/price_quote_add_page.dart';
import 'package:art/model/price_quote_model.dart';
import 'package:art/model/price_quote_store.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:provider/provider.dart';

//const _assetsPackage = 'packages';
const _iconAssetLocation = 'assets/icons';

class MailPreviewCard extends StatelessWidget {
  const MailPreviewCard({
    super.key,
    required this.id,
    required this.username,
    required this.email,
    required this.catatan,
    required this.onDelete,
    required this.onDone,
    required this.onStar,
    required this.openEditPage,
    required this.openRepostPage,
    required this.isStarred,
    required this.onStarredMailbox,
    required this.namaBarang,
  });

  final String id;
  final String username;
  final String namaBarang;
  final String catatan;
  final Email email;
  final VoidCallback onDelete;
  final VoidCallback onDone;
  final VoidCallback onStar;
  final VoidCallback openEditPage;
  final VoidCallback openRepostPage;
  final bool isStarred;
  final bool onStarredMailbox;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // TODO(x): State restoration of mail view page is blocked because OpenContainer does not support restorablePush, https://github.com/flutter/gallery/issues/570.
    return OpenContainer(
      openBuilder: (context, closedContainer) {
        return MailViewPage(id: id, email: email);
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
        final mailPreview = _MailPreview(
          id: id,
          username: username,
          email: email,
          namaBarang: namaBarang,
          catatan: catatan,
          onTap: openContainer,
          onDone: onDone,
          onStar: onStar,
          onDelete: onDelete,
          openEditPage: openEditPage,
          openRepostPage: openRepostPage,
        );

        if (isDesktop) {
          return mailPreview;
        } else {
          return mailPreview;
          /*Dismissible(
            key: ObjectKey(email),
            dismissThresholds: const {
              DismissDirection.startToEnd: 0.8,
              DismissDirection.endToStart: 0.4,
            },
            onDismissed: (direction) {
              switch (direction) {
                case DismissDirection.endToStart:
                  if (onStarredMailbox) {
                    //  onStar();
                  }
                  break;
                case DismissDirection.startToEnd:
                  // onDone();
                  break;
                default:
              }
            },
            /*background: _DismissibleContainer(
              icon: 'twotone_delete',
              backgroundColor: colorScheme.primary,
              iconColor: Colors.blue,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsetsDirectional.only(start: 20),
            ),*/
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.endToStart) {
                if (onStarredMailbox) {
                  return true;
                }
                onStar();
                return false;
              } else {
                return true;
              }
            },
            /* secondaryBackground: _DismissibleContainer(
              icon: 'twotone_star',
              backgroundColor: isStarred
                  ? colorScheme.secondary
                  : theme.scaffoldBackgroundColor,
              iconColor: isStarred
                  ? colorScheme.onSecondary
                  : colorScheme.onBackground,
              alignment: Alignment.centerRight,
              padding: const EdgeInsetsDirectional.only(end: 20),
            ),*/
            child: mailPreview,
          );*/
        }
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

class _MailPreview extends StatelessWidget {
  const _MailPreview(
      {required this.id,
      required this.username,
      required this.namaBarang,
      required this.catatan,
      required this.email,
      required this.onTap,
      this.onDone,
      this.onStar,
      this.onDelete,
      this.openEditPage,
      this.openRepostPage});

  final String id;
  final String username;
  final String namaBarang;
  final String catatan;
  final Email email;
  final VoidCallback onTap;
  final VoidCallback? onStar;
  final VoidCallback? onDone;
  final VoidCallback? onDelete;
  final VoidCallback? openEditPage;
  final VoidCallback? openRepostPage;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    var emailStore = EmailStore();

    /*var emailStore = Provider.of<EmailStore>(
      context,
      listen: false,
    );*/
    return InkWell(
      onTap: () {
        /* Provider.of<EmailStore>(
          context,
          listen: false,
        ).selectedEmailId = id;
        onTap();*/
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          String priceQuoteTitle = '';
          if (email.klien != null) {
            if (email.noPp.isNotEmpty || email.noPh.isNotEmpty) {
              priceQuoteTitle += ('' + email.klien!.singkatan + ' | ');
            } else {
              priceQuoteTitle += email.klien!.singkatan;
            }
          }
          List<String> pp_ph = [];
          if (email.noPp.isNotEmpty) {
            pp_ph.add('PP : ' + email.noPp);
          }

          if (email.noPh.isNotEmpty) {
            pp_ph.add('PH : ' + email.noPh);
          }
          if (pp_ph.isNotEmpty) {
            priceQuoteTitle += pp_ph.join(' | ');
          }

          List<dynamic> existedFiles = email.files;

          print('existed files' + existedFiles.toString());
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            email.tglBuat != null
                                ? DateFormat('dd/MM/yyyy')
                                    .format(email.tglBuat!.toDate())
                                : DateFormat('dd/MM/yyyy')
                                    .format(Timestamp.now().toDate()),
                            textAlign: TextAlign.left,
                            style: textTheme.bodySmall,
                          ),
                        ),
                        if (username == 'admin')
                          (_MailPreviewActionBar(
                              id: id,
                              isStarred: email.prioritas,
                              isDone: email.selesai,
                              onDone: onDone,
                              onStar: onStar,
                              onDelete: onDelete,
                              openEditPage: openEditPage,
                              openRepostPage: openRepostPage))
                        else
                          Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: ImageIcon(
                              size: 20,
                              const AssetImage(
                                '$_iconAssetLocation/twotone_star.png',
                                // package: _assetsPackage,
                              ),
                              color: email.prioritas
                                  ? Color(0xFFFFBB00)
                                  : Colors.blue,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(priceQuoteTitle, style: textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Flex(
                    direction: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          'files : ' + (existedFiles.isNotEmpty ? '' : '-'),
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Flexible(
                        flex: 1,
                        fit: FlexFit.loose,
                        child: Container(
                          child: ExistedFilesList(existedFiles: existedFiles),
                        ),
                      ),

                      /* Flexible(
                        child: ExistedFilesList(existedFiles: existedFiles),
                      ),*/
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: 20,
                    ),
                    child: Text(
                      namaBarang.isNotEmpty
                          ? 'Barang : ' + namaBarang
                          : 'Barang : -',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: 20,
                    ),
                    child: Text(
                      catatan.isNotEmpty
                          ? 'Catatan : ' + catatan
                          : 'Catatan : -',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 5,
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  if (email.containsPictures) ...[
                    const Flexible(
                      fit: FlexFit.loose,
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          _PicturePreview(),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ExistedFilesList extends StatefulWidget {
  final List<dynamic> existedFiles;

  const ExistedFilesList({super.key, required this.existedFiles});
  @override
  _ExistedFilesListState createState() => _ExistedFilesListState();
}

class _ExistedFilesListState extends State<ExistedFilesList> {
  late List<dynamic> fileNames = widget.existedFiles;

  @override
  Widget build(BuildContext context) {
    print(fileNames);
    if (fileNames.isNotEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: fileNames.length,
        itemBuilder: (context, index) {
          String fileName = fileNames[index];
          return GestureDetector(
            //   onTap: onStar,
            child: Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : 10),
              child: Text(
                (index + 1).toString() + '. ' + fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () => generateDownloadUrl(fileName),
          );
        },
      );
    } else {
      return Container();
    }
  }

  Future<void> generateDownloadUrl(String fileName) async {
    try {
      final storageRef = FirebaseStorage.instance.ref(fileName);
      String downloadUrl = await storageRef.getDownloadURL();

      // Use the download URL as needed (e.g., navigate to a web view to display the file)
      // print('Download URL for $fileName: $downloadUrl');

      //if (await canLaunchUrl(Uri.parse(downloadUrl))) {

      //} else {
      print('Could not launch URL: $downloadUrl');
      //}

      final bool nativeAppLaunchSucceeded = await launchUrl(
          Uri.parse(downloadUrl),
          mode: LaunchMode.externalNonBrowserApplication);
      if (!nativeAppLaunchSucceeded) {
        await launchUrl(
          Uri.parse(downloadUrl),
          mode: LaunchMode.inAppWebView,
        );
      }
    } catch (e) {
      print('Error generating download URL: $e');
    }
  }
}

class _PicturePreview extends StatelessWidget {
  const _PicturePreview();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.builder(
        itemCount: 4,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 4),
            child: Image.asset(
              'attachments/paris_${index + 1}.jpg',
              gaplessPlayback: true,
              package: 'packages',
            ),
          );
        },
      ),
    );
  }
}

class _MailPreviewActionBar extends StatelessWidget {
  const _MailPreviewActionBar(
      {required this.id,
      required this.isStarred,
      required this.isDone,
      this.onStar,
      this.onDelete,
      this.onDone,
      this.openEditPage,
      this.openRepostPage});
  final String id;
  final bool isStarred;
  final bool isDone;
  final VoidCallback? onStar;
  final VoidCallback? onDone;
  final VoidCallback? onDelete;
  final VoidCallback? openEditPage;
  final VoidCallback? openRepostPage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white : Colors.blue;
    final isDesktop = isDisplayDesktop(context);
    final starredIconColor = isStarred ? Color(0xFFFFBB00) : color;
    /*  void openEditPage(String id, BuildContext context) {
      if (isDesktop) {
        desktopMailNavKey.currentState!.popUntil(
          (route) {
            var currentRoute = route.settings.name;

            if (currentRoute != MyApp.composeRoute) {
              desktopMailNavKey.currentState!.restorablePushNamed(
                  MyApp.composeRoute,
                  arguments: {'edit': true, 'id': id});
            }
            return true;
          },
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ComposePage(isEdit: true, editId: id)),
        );
      }
    }*/

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isDone) ...[
          IgnorePointer(
            ignoring: isDone,
            child: GestureDetector(
              onTap: onStar,
              child: Padding(
                padding: EdgeInsets.only(left: 8),
                child: ImageIcon(
                  size: 20,
                  const AssetImage(
                    '$_iconAssetLocation/twotone_star.png',
                    // package: _assetsPackage,
                  ),
                  color: starredIconColor,
                ),
              ),
            ),
          ),
        ],
        if (!isDone) ...[
          GestureDetector(
            onTap: onDone,
            child: Padding(
              padding: EdgeInsets.only(left: 8),
              child: ImageIcon(
                size: 20,
                const AssetImage(
                  '$_iconAssetLocation/twotone_baseline_done_outline.png',
                  // package: _assetsPackage,
                ),
                color: color,
              ),
            ),
          ),
        ],
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
        if (isDone) ...[
          GestureDetector(
            onTap: openRepostPage,
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: ImageIcon(
                    size: 20,
                    const AssetImage(
                      '$_iconAssetLocation/repost.png',
                      // package: _assetsPackage,
                    ),
                    color: color,
                  ),
                ),
                Text('repost', style: TextStyle(color: Colors.blue)),
              ],
            ),
          ),
        ]
      ],
    );
  }
}
