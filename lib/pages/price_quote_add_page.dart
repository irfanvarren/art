import 'package:art/model/price_quote_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:art/model/price_quote_store.dart';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ComposePage extends StatefulWidget {
  final bool? isEdit;
  final bool? isRepost;
  final String? editId;
  final String? username;
  ComposePage(
      {super.key, this.isEdit, this.editId, this.isRepost, this.username}) {
    //initializeNotification();
  }
  @override
  _ComposePageState createState() => _ComposePageState(
      isEditNull: isEdit, editIdNull: editId, isRepostNull: isRepost);
}

class _ComposePageState extends State<ComposePage> {
  bool? isRepostNull;
  bool? isEditNull;
  String? editIdNull;

  _ComposePageState(
      {required this.isRepostNull, this.isEditNull, this.editIdNull});

  int selectedIndex = -1;
  late List<Product> products = [];
  final TextEditingController _ppController = TextEditingController();
  final TextEditingController _namaBarangController = TextEditingController();
  final TextEditingController _jumlahBarangController = TextEditingController();
  final TextEditingController _satuanController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final _clientDropdownKey = GlobalKey<DropdownSearchState<int>>();

  bool isEdit = false;
  bool isRepost = false;
  String editId = '';
  String selectedClientRef = '';
  String selectedClientName = '';
  Client? selectedClient;
  late String? username;
  @override
  void initState() {
    super.initState();
    isEdit = isEditNull ?? false;
    isRepost = isRepostNull ?? false;
    editId = editIdNull!;
    username = widget.username ?? 'admin';
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
    DocumentReference klienRef =
        FirebaseFirestore.instance.collection('clients').doc(selectedClientRef);

    String namaKlien = selectedClientName;
    String noPp = _ppController.text;
    String namaBarang = _namaBarangController.text;
    String jumlahBarang = _jumlahBarangController.text;
    String satuan = _satuanController.text;
    String catatan = _catatanController.text;
    List<Map<String, dynamic>> productMaps =
        products.map((product) => product.toMap()).toList();

    if (isEdit) {
      List<String> mappedList = products
          .map(
            (Product item) =>
                item.namaBarang.toString() +
                ' ' +
                item.jumlahBarang.toString() +
                ' ' +
                item.satuan.toString(),
          )
          .toList();
      String namaBarangJoin = mappedList.join(', ');
      Map<String, dynamic> dataUpdate = {};
      if (isRepost) {
        String namaBarangJoin = mappedList.join(', ');

        DateTime currentDateTime = Timestamp.now().toDate();

        DateTime newDateTime = currentDateTime.add(Duration(days: 7));

        Timestamp tglNotifikasi = Timestamp.fromDate(newDateTime);

        dataUpdate = {
          'no_pp': noPp,
          'klien': klienRef,
          'nama_klien': namaKlien,
          'nama_barang': namaBarangJoin,
          'barang': productMaps,
          'catatan': catatan,
          'files': [],
          'selesai': false,
          'prioritas': false,
          'tgl_edit': Timestamp.now(),
          'tgl_notifikasi': tglNotifikasi
        };
      } else {
        dataUpdate = {
          'no_pp': noPp,
          'klien': klienRef,
          'nama_klien': namaKlien,
          'nama_barang': namaBarangJoin,
          'barang': productMaps,
          'catatan': catatan,
          'files': [],
          'tgl_edit': Timestamp.now(),
        };
      }
      FirebaseFirestore.instance
          .collection('price_quotes')
          .doc(editId)
          .update(dataUpdate)
          .then((_) {
        // Clear the form fields after successful submission
        DropdownSearchState<int>? dropdownState =
            _clientDropdownKey.currentState;
        if (dropdownState != null) {
          dropdownState.clear();
          // ...
        }
        _ppController.clear();
        _namaBarangController.clear();
        _jumlahBarangController.clear();
        _catatanController.clear();
        _satuanController.clear();

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
      List<String> mappedList = products
          .map(
            (Product item) =>
                item.namaBarang.toString() +
                ' ' +
                item.jumlahBarang.toString() +
                ' ' +
                item.satuan.toString(),
          )
          .toList();
      String namaBarangJoin = mappedList.join(', ');

      DateTime currentDateTime = Timestamp.now().toDate();

      DateTime newDateTime = currentDateTime.add(Duration(days: 7));

      Timestamp tglNotifikasi = Timestamp.fromDate(newDateTime);

      FirebaseFirestore.instance.collection('price_quotes').add({
        'no_pp': noPp,
        'no_ph': '',
        'klien': klienRef,
        'nama_klien': namaKlien,
        'nama_barang': namaBarangJoin,
        'barang': productMaps,
        'catatan': catatan,
        'username': username,
        'files': [],
        'tgl_buat': Timestamp.now(),
        'tgl_edit': Timestamp.now(),
        'tgl_notifikasi': tglNotifikasi,
        'notif': false,
        'prioritas': false,
        'selesai': false,
      }).then((_) {
        // Clear the form fields after successful submission
        DropdownSearchState<int>? dropdownState =
            _clientDropdownKey.currentState;
        if (dropdownState != null) {
          dropdownState.clear();
          // ...
        }
        _ppController.clear();
        _namaBarangController.clear();
        _jumlahBarangController.clear();
        _catatanController.clear();
        _satuanController.clear();

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

  Future<Map<String, dynamic>> getPriceQuote(String id, bool isEdit) async {
    Client clientRef = Client(id: '');
    if (isEdit) {
      DocumentSnapshot priceQuoteData = await FirebaseFirestore.instance
          .collection('price_quotes')
          .doc(id)
          .get();

      if (priceQuoteData.exists) {
        //String fieldExistence = documentSnapshot.data().containsKey(fieldName) ? 'Field $fieldName exists.' : 'Field $fieldName does not exist.';

        String namaKlien = '';

        await priceQuoteData['klien'].get().then((klienSnapshot) {
          if (klienSnapshot.exists) {
            namaKlien = klienSnapshot.data()!['nama_klien'];
            selectedClientName = namaKlien;
            selectedClientRef = klienSnapshot.id;
            clientRef = Client(
              id: klienSnapshot.id,
              namaKlien: namaKlien,
              email: klienSnapshot.data()!['email'],
              noHp: klienSnapshot.data()!['no_hp'],
              alamat: klienSnapshot.data()!['alamat'],
            );
          }
          selectedClient = clientRef;
        }).catchError((error) {
          print('Error retrieving data: $error');
        });
        String catatan = priceQuoteData['catatan'];
        String noPp = priceQuoteData['no_pp'];
        _catatanController.text = catatan;
        _ppController.text = noPp;

        if (priceQuoteData['barang'] != null) {
          List<Map<String, dynamic>> dataBarang =
              List<Map<String, dynamic>>.from(
                  priceQuoteData['barang'] as List<dynamic>);

          products = dataBarang.map((itemData) {
            return Product(
              namaBarang: itemData['nama_barang'] as String,
              satuan: itemData['satuan'] as String,
              jumlahBarang: itemData['jumlah_barang'] as int,
            );
          }).toList();
        }
      }
      return {
        'products': products,
        'clientRef': clientRef, // If not available in this case
      };
      //return products;
    } else {
      // return products;
      return {
        'products': products,
        'clientRef': clientRef, // If not available in this case
      };
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

    var senderEmail = 'flutterfan@gmail.com';
    String subject = '';

    final emailStore = Provider.of<EmailStore>(context);

    if (emailStore.selectedEmailId >= 0) {
      final currentEmail = emailStore.currentEmail;
      subject = currentEmail.namaKlien;
    }

    return FutureBuilder<Map<String, dynamic>>(
        future: getPriceQuote(editId, isEdit),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('');
          } else if (snapshot.hasError) {
            return Text('Error ${snapshot.error}');
          } else {
            products = snapshot.data!['products'];
            selectedClient = snapshot.data!['clientRef'];
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
                                _SubjectRow(
                                  subject: subject,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 12, top: 12),
                                  child: Text('No. Permintaan Penawaran',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Arial',
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: TextField(
                                    controller: _ppController,
                                    decoration: const InputDecoration.collapsed(
                                      hintText: 'No. Permintaan Penawaran',
                                    ),
                                    autofocus: false,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
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
                                  child: FutureBuilder<QuerySnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection('clients')
                                        .get(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        final items =
                                            snapshot.data!.docs.map((doc) {
                                          String id = doc.id;
                                          String namaKlien = doc['nama_klien'];
                                          String email = doc['email'];
                                          String noHp = doc['no_hp'];
                                          String alamat = doc['alamat'];
                                          String singkatan = doc['singkatan'];
                                          Client client = Client(
                                            id: id,
                                            namaKlien: namaKlien,
                                            singkatan: singkatan,
                                            email: email,
                                            noHp: noHp,
                                            alamat: alamat,
                                          );
                                          return client;
                                        }).toList();
                                        return DropdownSearch<Client>(
                                          key: _clientDropdownKey,
                                          items: items,
                                          // asyncItems: (String filter) =>
                                          //     getClientData(filter),
                                          onChanged: (Client? data) {
                                            selectedClientRef = data!.id;
                                            selectedClientName =
                                                data!.namaKlien;
                                          },
                                          itemAsString: (item) {
                                            String namaKlien = '';
                                            if (item.singkatan.isNotEmpty) {
                                              if (item.namaKlien.isNotEmpty) {
                                                namaKlien +=
                                                    (item.singkatan + ' - ');
                                              } else {
                                                namaKlien += item.singkatan;
                                              }
                                            }
                                            if (item.namaKlien.isNotEmpty) {
                                              namaKlien += item.namaKlien;
                                            }
                                            return namaKlien;
                                          },
                                          selectedItem: selectedClient,
                                          popupProps: PopupProps.menu(
                                            showSearchBox: true,
                                          ),
                                        );
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        return CircularProgressIndicator();
                                      }
                                    },
                                  ),
                                ),
                                //search
                                Container(
                                  child: ItemFormScreen(
                                    products: products,
                                  ),
                                ),
                                const _SectionDivider(),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 12, top: 12),
                                  child: Text('Catatan',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Arial',
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: TextField(
                                    controller: _catatanController,
                                    minLines: 6,
                                    maxLines: 20,
                                    decoration: const InputDecoration.collapsed(
                                      hintText: 'Catatan...',
                                    ),
                                    autofocus: false,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
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
        });
  }
}

class ItemForm extends StatelessWidget {
  final List<Product> products;
  final TextEditingController namaBarangController;
  final TextEditingController jumlahBarangController;
  final TextEditingController satuanController;
  final void Function() addItem;
  final void Function(int) deleteItem;
  final void Function(int) editItem;
  final void Function(int) updateItem;
  final void Function() cancelEditing;
  int selectedIndex;
  ItemForm({
    required this.selectedIndex,
    required this.products,
    required this.namaBarangController,
    required this.jumlahBarangController,
    required this.satuanController,
    required this.addItem,
    required this.deleteItem,
    required this.editItem,
    required this.updateItem,
    required this.cancelEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionDivider(),
          Container(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: DataTable(
                columnSpacing: 0,
                clipBehavior: Clip.hardEdge,
                showCheckboxColumn: true,
                horizontalMargin: 0,
                border: TableBorder.all(
                    color: Color(0xFF575757),
                    width: 1,
                    style: BorderStyle.solid),
                columns: _buildColumns(),
                rows: products.map(
                  (product) {
                    final index = products.indexOf(product);
                    return DataRow(
                      cells: [
                        DataCell(
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    editItem(index);
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    deleteItem(index);
                                  },
                                  child: Icon(
                                    Icons.delete,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataCell(Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                                constraints: BoxConstraints(maxWidth: 240),
                                child: Text(
                                    product.namaBarang +
                                        ' ' +
                                        product.jumlahBarang.toString() +
                                        ' ' +
                                        product.satuan,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Arial',
                                        fontWeight: FontWeight.bold))))),
                      ],
                    );
                  },
                ).toList(), // Adjust as needed
              ),
            ),
          ),
          Container(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(left: 12, top: 12),
              child: Text('Nama Barang',
                  style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Arial',
                      fontWeight: FontWeight.bold)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: namaBarangController,
              decoration: const InputDecoration.collapsed(
                hintText: 'Nama Barang',
              ),
              autofocus: false,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const _SectionDivider(),
          Container(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(left: 12, top: 12),
              child: Text('Jumlah Barang',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Arial',
                      fontWeight: FontWeight.bold)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: jumlahBarangController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              decoration: const InputDecoration.collapsed(
                hintText: 'Jumlah Barang',
              ),
              autofocus: false,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const _SectionDivider(),
          Container(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(left: 12, top: 12),
              child: Text('Satuan',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Arial',
                      fontWeight: FontWeight.bold)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: satuanController,
              decoration: const InputDecoration.collapsed(
                hintText: 'Satuan',
              ),
              autofocus: false,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (selectedIndex >= 0) {
                      updateItem(selectedIndex);
                    } else {
                      addItem();
                    }
                  },
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    child: Text(
                      selectedIndex >= 0 ? 'Update Barang' : 'Tambah Barang',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.0,
                      ),
                    ),
                  ),
                ),

                /*SizedBox(width: 16.0),
            ElevatedButton(
              onPressed: cancelEditing,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                child: Text(
                  'Batal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.0,
                  ),
                ),
              ),
            ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      DataColumn(
        label: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('Edit / Delete',
              style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.bold)),
        ),
      ),
      DataColumn(
        label: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('Barang',
              style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.bold)),
        ),
      ),
    ];
  }
}

class ItemFormScreen extends StatefulWidget {
  final List<Product> products;

  ItemFormScreen({required this.products});

  @override
  _ItemFormScreenState createState() =>
      _ItemFormScreenState(products: products);
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  List<Product> products;

  _ItemFormScreenState({required this.products});

  final TextEditingController _ppController = TextEditingController();
  final TextEditingController _namaKlienController = TextEditingController();
  final TextEditingController _namaBarangController = TextEditingController();
  final TextEditingController _jumlahBarangController = TextEditingController();
  final TextEditingController _satuanController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  int selectedIndex = -1;

  void addItem() {
    Product newItem = Product(
      namaBarang: _namaBarangController.text,
      jumlahBarang: int.parse(_jumlahBarangController.text),
      satuan: _satuanController.text,
    );
    setState(() {
      products.add(newItem);

      _namaBarangController.clear();
      _jumlahBarangController.clear();
      _satuanController.clear();
    });
  }

  void editItem(int index) {
    setState(() {
      _namaBarangController.text = products[index].namaBarang;
      _jumlahBarangController.text = products[index].jumlahBarang.toString();
      _satuanController.text = products[index].satuan;
      selectedIndex = index;
    });
  }

  void updateItem(int index) {
    Product updatedItem = Product(
      namaBarang: _namaBarangController.text.trim(),
      jumlahBarang: int.parse(_jumlahBarangController.text.trim()),
      satuan: _satuanController.text.trim(),
    );
    //if (updatedItem) {
    setState(() {
      products[index] = updatedItem;
      selectedIndex = -1;
      _namaBarangController.clear();
      _jumlahBarangController.clear();
      _satuanController.clear();
    });
    //}
  }

  void deleteItem(int index) {
    setState(() {
      products.removeAt(index);
    });
  }

  void cancelEditing() {
    setState(() {
      _namaBarangController.clear();
      _jumlahBarangController.clear();
      _satuanController.clear();
      selectedIndex = -1;
    });
  }

  @override
  void dispose() {
    // _itemController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    products = widget.products;
  }

  @override
  Widget build(BuildContext context) {
    return ItemForm(
      selectedIndex: selectedIndex,
      products: products,
      namaBarangController: _namaBarangController,
      jumlahBarangController: _jumlahBarangController,
      satuanController: _satuanController,
      addItem: addItem,
      deleteItem: deleteItem,
      editItem: editItem,
      updateItem: updateItem,
      cancelEditing: cancelEditing,
    );
  }
}

class _SubjectRow extends StatefulWidget {
  const _SubjectRow({required this.subject});

  final String subject;

  @override
  _SubjectRowState createState() => _SubjectRowState();
}

class _SubjectRowState extends State<_SubjectRow> {
  TextEditingController? _subjectController;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.subject);
  }

  @override
  void dispose() {
    _subjectController!.dispose();
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

class _SenderAddressRow extends StatefulWidget {
  const _SenderAddressRow({required this.senderEmail});

  final String senderEmail;

  @override
  __SenderAddressRowState createState() => __SenderAddressRowState();
}

class __SenderAddressRowState extends State<_SenderAddressRow> {
  late String senderEmail;

  @override
  void initState() {
    super.initState();
    senderEmail = widget.senderEmail;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final accounts = [
      'flutterfan@gmail.com',
      'materialfan@gmail.com',
    ];

    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      onSelected: (email) {
        setState(() {
          senderEmail = email;
        });
      },
      itemBuilder: (context) => <PopupMenuItem<String>>[
        PopupMenuItem<String>(
          value: accounts[0],
          child: Text(
            accounts[0],
            style: textTheme.bodyMedium,
          ),
        ),
        PopupMenuItem<String>(
          value: accounts[1],
          child: Text(
            accounts[1],
            style: textTheme.bodyMedium,
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(
          left: 12,
          top: 16,
          right: 10,
          bottom: 10,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                senderEmail,
                style: textTheme.bodyMedium,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipientsRow extends StatelessWidget {
  const _RecipientsRow({
    required this.recipients,
    required this.avatar,
  });

  final String recipients;
  final String avatar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Wrap(
              children: [
                Chip(
                  backgroundColor:
                      Theme.of(context).chipTheme.secondarySelectedColor,
                  padding: EdgeInsets.zero,
                  avatar: CircleAvatar(
                    backgroundImage: AssetImage(
                      avatar,
                      package: 'flutter_gallery_assets',
                    ),
                  ),
                  label: Text(
                    '',
                  ),
                ),
              ],
            ),
          ),
          InkResponse(
            customBorder: const CircleBorder(),
            onTap: () {},
            radius: 24,
            child: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
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
