import 'package:art/model/price_quote_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:art/model/price_quote_store.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:art/main.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ClientAddPage extends StatefulWidget {
  final bool? isEdit;
  final String? editId;
  ClientAddPage({
    super.key,
    this.isEdit,
    this.editId,
  }) {
    //initializeNotification();
  }
  @override
  _ClientAddPagePageState createState() =>
      _ClientAddPagePageState(isEditNull: isEdit, editIdNull: editId);
}

class _ClientAddPagePageState extends State<ClientAddPage> {
  bool? isEditNull;
  String? editIdNull;

  _ClientAddPagePageState({this.isEditNull, this.editIdNull});

  int selectedIndex = -1;
  late List<Product> products = [];
  final TextEditingController _namaKlienController = TextEditingController();
  final TextEditingController _singkatanController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool isEdit = false;
  bool isRepost = false;
  String editId = '';

  @override
  void initState() {
    super.initState();
    isEdit = isEditNull ?? false;
    editId = editIdNull!;
  }

  Future<void> initializeNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse? response) async {
        print('Notification payload: $response');
      },
      onDidReceiveBackgroundNotificationResponse:
          (NotificationResponse? response) async {
        print('Notification payload: $response');
      },
    );
  }

  Future<void> scheduleNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    tz.initializeTimeZones();
    final location = tz.getLocation('Asia/Jakarta');
    final now = tz.TZDateTime.now(location);
    final newDateTime = now.add(Duration(seconds: 5));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Notification Title',
      'Notification Body',
      newDateTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void _submitForm(BuildContext context, bool isEdit, String editId) {
    //scheduleNotification();
    // Form is valid, proceed with data submission

    // Get the form values
    String namaKlien = _namaKlienController.text;
    String singkatan = _singkatanController.text;
    String email = _emailController.text;
    String noHp = _noHpController.text;
    String alamat = _alamatController.text;

    if (isEdit) {
      Map<String, dynamic> dataUpdate = {};
      if (isRepost) {
        dataUpdate = {
          'nama_klien': namaKlien,
          'email': email,
          'singkatan': singkatan,
          'no_hp': noHp,
          'alamat': alamat,
        };
      } else {
        dataUpdate = {
          'nama_klien': namaKlien,
          'singkatan': singkatan,
          'email': email,
          'no_hp': noHp,
          'alamat': alamat,
        };
      }
      FirebaseFirestore.instance
          .collection('clients')
          .doc(editId)
          .update(dataUpdate)
          .then((_) {
        // Clear the form fields after successful submission
        _namaKlienController.clear();
        _singkatanController.clear();
        _emailController.clear();
        _noHpController.clear();
        _alamatController.clear();
        _alamatController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data berhasil diubah !')),
        );
        Navigator.of(context).pop();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error, terjadi kesalahan saat mengubah data')),
        );
      });
    } else {
      // Create a new document in Firestore

      FirebaseFirestore.instance.collection('clients').add({
        'nama_klien': namaKlien,
        'singkatan': singkatan,
        'email': email,
        'no_hp': noHp,
        'alamat': alamat,
      }).then((_) {
        // Clear the form fields after successful submission
        _namaKlienController.clear();
        _singkatanController.clear();
        _emailController.clear();
        _noHpController.clear();
        _alamatController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data berhasil disimpan !')),
        );
        Navigator.of(context).pop();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error, terjadi kesalahan saat menyimpan data')),
        );
      });
    }
  }

  Future<void> getClientData(String id, bool isEdit) async {
    if (isEdit) {
      DocumentSnapshot priceQuoteData =
          await FirebaseFirestore.instance.collection('clients').doc(id).get();

      if (priceQuoteData.exists) {
        String namaKlien = priceQuoteData['nama_klien'];
        String singkatan = priceQuoteData['singkatan'];
        String email = priceQuoteData['email'];
        String noHp = priceQuoteData['no_hp'];
        String alamat = priceQuoteData['alamat'];

        _namaKlienController.text = namaKlien;
        _singkatanController.text = singkatan;
        _emailController.text = email;
        _noHpController.text = noHp;
        _alamatController.text = alamat;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      isEdit = arguments is Map<String, dynamic> ? arguments['edit'] : false;
      isRepost =
          arguments is Map<String, dynamic> ? arguments['repost'] : false;
      editId = arguments is Map<String, dynamic> ? arguments['id'] : '';
    }

    bool fetchDataComplete = false;

    return FutureBuilder<void>(
      future: getClientData(editId, isEdit),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('');
        } else if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        } else {
          return Scaffold(
            body: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Material(
                  color: Theme.of(context).cardColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SubjectRow(),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 12, top: 12),
                                child: Text('Singkatan',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Arial',
                                        fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: TextField(
                                  controller: _singkatanController,
                                  decoration: const InputDecoration.collapsed(
                                    hintText: 'Singkatan',
                                  ),
                                  autofocus: false,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              const _SectionDivider(),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 12, top: 12),
                                child: Text('Nama Klien',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Arial',
                                        fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: TextField(
                                  controller: _namaKlienController,
                                  decoration: const InputDecoration.collapsed(
                                    hintText: 'Nama Klien',
                                  ),
                                  autofocus: false,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              const _SectionDivider(),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 12, top: 12),
                                child: Text('Email',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Arial',
                                        fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: TextField(
                                  controller: _emailController,
                                  decoration: const InputDecoration.collapsed(
                                    hintText: 'Email',
                                  ),
                                  autofocus: false,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              const _SectionDivider(),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 12, top: 12),
                                child: Text('No Hp',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Arial',
                                        fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: TextField(
                                  controller: _noHpController,
                                  decoration: const InputDecoration.collapsed(
                                    hintText: 'No Hp',
                                  ),
                                  autofocus: false,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              const _SectionDivider(),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 12, top: 12),
                                child: Text('Alamat',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Arial',
                                        fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: TextField(
                                  controller: _alamatController,
                                  minLines: 6,
                                  maxLines: 20,
                                  decoration: const InputDecoration.collapsed(
                                    hintText: 'Alamat...',
                                  ),
                                  autofocus: false,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: ElevatedButton(
                            onPressed: () =>
                                _submitForm(context, isEdit, editId),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 16.0),
                              child: Text(
                                'Simpan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      thickness: 1.1,
      indent: 10,
      endIndent: 10,
    );
  }
}

class _SubjectRow extends StatefulWidget {
  const _SubjectRow();

  @override
  _SubjectRowState createState() => _SubjectRowState();
}

class _SubjectRowState extends State<_SubjectRow> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),
          IconButton(
            key: const ValueKey('ReplyExit'),
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
