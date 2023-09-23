import 'package:art/pages/client_add_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:art/layout/adaptive.dart';
import 'package:art/pages/price_quote_add_page.dart';
import 'package:art/widgets/price_quote_card_preview.dart';
import 'package:art/widgets/client_card_preview.dart';
import 'package:art/model/price_quote_model.dart';
import 'package:art/model/price_quote_store.dart';
import 'package:art/main.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'dart:async';

//import 'package:provider/provider.dart';
typedef StreamCallback = void Function(
    String? destination,
    Client? filterClient,
    String filterBarang,
    String filterPp,
    String filterPh);

class MailboxBody extends StatefulWidget {
  final BuildContext parentContext;
  final String username;
  final String destination;
  const MailboxBody(
      {super.key,
      required this.parentContext,
      required this.username,
      required this.destination});
  @override
  State<StatefulWidget> createState() => _MailboxBodyState();
}

class _MailboxBodyState extends State<MailboxBody> {
  late final String username;
  late final BuildContext parentContext;

  late String filterProduct;
  late List dataList;
  List? filteredDataList;
  Client? filterClient;
  String? filterBarang;

  StreamController<Map<String, dynamic>> streamController =
      StreamController<Map<String, dynamic>>();

  late String destination;
  @override
  void initState() {
    super.initState();
    username = widget.username;
    parentContext = widget.parentContext;
    dataList = [];
    filterProduct = '';
    destination = widget.destination;
    FirebaseFirestore.instance.settings = Settings(persistenceEnabled: false);
    getStream(widget.destination, null, null, null, null);

// Assuming you have a stream called myStream of type Stream<QuerySnapshot<dynamic>>
    // streamController.stream.listen((Map<String, dynamic> event) {
    //   streamController.add(event);
    // }, onError: (error) {
    //   streamController.addError(error);
    // }, onDone: () {
    //   streamController.close();
    // });
  }

  @override
  void didUpdateWidget(covariant MailboxBody widget) {
    if (destination != widget.destination) {
      destination = widget.destination;
      streamController!.close();
      streamController = StreamController<Map<String, dynamic>>();

      getStream(widget.destination, null, null, null, null);
    }
    super.didUpdateWidget(widget);
  }

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }

  void triggerStreamBuilder(String? getDestination, Client? pFilterClient,
      String pFilterBarang, String filterPp, String filterPh) {
    print(getDestination! +
        '|' +
        widget.destination +
        '|' +
        destination +
        '|' +
        filterPp +
        '|' +
        filterPh);
    //setState(() {
    filterClient = pFilterClient;
    filterBarang = pFilterBarang;
    // Update the state or change any variables that will affect the StreamBuilder
    // You can use the passed data here
    //});
    //print(pFilterClient);
    //print(pFilterBarang);
    getStream(
        widget.destination, filterClient, filterBarang, filterPp, filterPh);
  }

  // Stream<Map<String, dynamic>> getStream(String destination) {
  void getStream(String destination, Client? filterClient, String? filterBarang,
      String? filterPp, String? filterPh) async {
    Stream<QuerySnapshot<dynamic>> myStream;

    if (widget.destination == 'clients') {
      myStream =
          await FirebaseFirestore.instance.collection('clients').snapshots();
    } else {
      Query myQuery;
      if (widget.destination == 'prioritas') {
        myQuery = await FirebaseFirestore.instance
            .collection('price_quotes')
            .where('selesai', isEqualTo: false)
            .where('prioritas', isEqualTo: true);
      } else if (widget.destination == 'done') {
        myQuery = await FirebaseFirestore.instance
            .collection('price_quotes')
            .where('selesai', isEqualTo: true);
      } else {
        myQuery = await FirebaseFirestore.instance
            .collection('price_quotes')
            .where('selesai', isEqualTo: false);
      }
      if (filterPp != null) {
        if (filterPp.isNotEmpty) {
          myQuery = myQuery.where('no_pp', isEqualTo: filterPp);
        }
      }
      if (filterPh != null) {
        if (filterPh.isNotEmpty) {
          myQuery = myQuery.where('no_ph', isEqualTo: filterPh);
        }
      }
      myQuery = myQuery.orderBy('tgl_buat', descending: true);
      myStream = myQuery.snapshots();
    }
    //return

    myStream.forEach((QuerySnapshot snapshot) {
      Map<String, dynamic> allObjects = {};
      allObjects['key'] = UniqueKey();
      if (widget.destination == 'clients') {
        List<Client> clients = [];

        snapshot.docs.forEach((DocumentSnapshot document) {
          Client client = Client(
            id: document.id,
            singkatan: document['singkatan'],
            namaKlien: document['nama_klien'],
            email: document['email'],
            noHp: document['no_hp'],
            alamat: document['alamat'],
          );
          if (filterClient != null) {
            if (client.id == filterClient!.id) {
              clients.add(client);
            }
          } else {
            clients.add(client);
          }
        });
        allObjects['data'] = clients;

        //return allObjects;
        streamController.add(allObjects);
      } else {
        Map<String, dynamic> allObjects = {};
        List<dynamic> price_quotes = [];
        snapshot.docs.forEach((DocumentSnapshot document) {
          Email price_quote = Email(
            id: document.id,
            noPp: document['no_pp'],
            noPh: document['no_ph'],
            namaBarang: document['nama_barang'],
            barang: document['barang'] as List<dynamic>,
            files: document['files'] as List<dynamic>,
            catatan: document['catatan'],
            klienRef:
                document['klien'] as DocumentReference<Map<String, dynamic>>,
            tglBuat: document['tgl_buat'],
            tglNotifikasi: document['tgl_notifikasi'],
            selesai: document['selesai'],
            prioritas: document['prioritas'],
          );
          if (filterClient != null && filterBarang != null) {
            if (price_quote.klienRef!.id == filterClient.id &&
                price_quote.namaBarang
                    .toLowerCase()
                    .contains(filterBarang.toLowerCase())) {
              price_quotes.add(price_quote);
            }
          } else if (filterClient != null) {
            if (price_quote.klienRef!.id == filterClient.id) {
              price_quotes.add(price_quote);
            }
          } else if (filterBarang != null) {
            if (price_quote.namaBarang
                .toLowerCase()
                .contains(filterBarang.toLowerCase())) {
              price_quotes.add(price_quote);
            }
          } else {
            price_quotes.add(price_quote);
          }
        });

        allObjects['data'] = price_quotes;

        List<Client> clients = [];

        allObjects['clients'] = clients;
        //return allObjects;
        streamController.add(allObjects);
      }
    });
  }

  List<Client> mapDocumentSnapshotsToUsers(List<DocumentSnapshot> snapshots) {
    return snapshots.map((snapshot) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      // Assuming User class has appropriate constructor
      Client user = Client(
        id: snapshot.id,
        namaKlien: data['nama_klien'] as String,
        // Other properties
      );
      return user;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments;

    if (widget.destination != destination) {
      destination = widget.destination;
      streamController!.close();
      streamController = StreamController<Map<String, dynamic>>();
      getStream(widget.destination, null, null, null, null);
    }
    //   streamController.close();
    //   getStream(myWidget.destination);

    final isDesktop = isDisplayDesktop(parentContext);
    final isTablet = isDisplaySmallDesktop(parentContext);
    final startPadding = isTablet
        ? 45.0
        : isDesktop
            ? 60.0
            : 20.0;
    final endPadding = isTablet
        ? 45.0
        : isDesktop
            ? 60.0
            : 20.0;

    final destinationString = destination
        .toString()
        .substring(destination.toString().indexOf('.') + 1);
    return SafeArea(
      bottom: false,
      child: StreamBuilder<Map<String, dynamic>>(
        stream: streamController.stream, //getStream(destination),
        builder: (context, streamSnapshot) {
          // here
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            // Stream is still loading, show a loading indicator or placeholder
            return CircularProgressIndicator();
          }
          if (streamSnapshot.connectionState == ConnectionState.active) {
            if (streamSnapshot.hasData) {
              // Access the documents from the snapshot

              List<Client> clientSearchItems = [];
              if (destination == 'clients') {
                // clientSearchItems = mapDocumentSnapshotsToUsers(documents);

                clientSearchItems =
                    streamSnapshot.data!['data'] as List<Client>;
                dataList = clientSearchItems;
              } else {
                dataList = streamSnapshot.data!['data'];

                filteredDataList = dataList;
              }
              return CardPreviewBody(
                  dataList: dataList,
                  clientSearchItems: clientSearchItems,
                  parentContext: parentContext,
                  destination: widget.destination,
                  username: username,
                  triggerStreamBuilder: triggerStreamBuilder);
            } else {
              return Center(child: Text('Data Kosong'));
            }
          } else {
            return Center(child: Text('Data Kosong'));
          }
        },
      ),
    );
  }
}

class CardPreviewBody extends StatefulWidget {
  final List<Client> clientSearchItems;
  final List dataList;
  final Client? filteredClientData;
  final String destination;
  final String username;
  final BuildContext parentContext;
  final StreamCallback triggerStreamBuilder;

  const CardPreviewBody(
      {super.key,
      required this.dataList,
      required this.clientSearchItems,
      required this.destination,
      required this.username,
      this.filteredClientData,
      required this.parentContext,
      required this.triggerStreamBuilder});

  @override
  CardPreviewBodyState createState() => CardPreviewBodyState();
}

class CardPreviewBodyState extends State<CardPreviewBody> {
  late List filteredDataList =
      widget.dataList; // Declare a variable in the State class
  late List<Client> clientSearchItems;
  late Client? filteredClientData;
  late Client? filterClient;
  late String filterBarang = '';
  late String destination;
  late String username;
  late BuildContext parentContext;
  final clientDropdownKey = GlobalKey<DropdownSearchState<int>>();
  final ppDropdownKey = GlobalKey<DropdownSearchState<int>>();
  final phDropdownKey = GlobalKey<DropdownSearchState<int>>();
  Client? selectedClientData;
  String filterPp = '';
  String filterPh = '';
  late List dataList;
  List<Client> clientsList = [];
  List<String> ppList = [];
  List<String> phList = [];
  final TextEditingController _barangController = TextEditingController();
  final TextEditingController _noPhController = TextEditingController();
  Timer? _debounce;
  bool isNavigatorPopped = false;
  String doneError = '';

  @override
  void initState() {
    super.initState();
    print('init');
    dataList = widget.dataList;
    filteredClientData = widget.filteredClientData;
    username = widget.username;
    destination = widget.destination;
    parentContext = widget.parentContext;
    clientSearchItems = widget.clientSearchItems;
    filterClient = null;
  }

  @override
  void didUpdateWidget(covariant CardPreviewBody oldWidget) {
    print('didupdate');
    if (widget.dataList != dataList) {
      //   // Parent's counter has changed, perform necessary actions
      //   // or update the child's state accordingly
      if (_barangController.text.isNotEmpty) {
        filterBarang = _barangController.text;
      }
      //     setState(() {
      //       dataList = widget.dataList;
      filteredDataList = widget.dataList;
      //     });
      //   }
    }
    if (widget.clientSearchItems != clientSearchItems) {
      clientSearchItems = widget.clientSearchItems;
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> doneEmail(String documentId) async {
    if (documentId.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Masukkan No PH :'),
          content: Row(children: [
            Expanded(
              child: TextField(
                controller: _noPhController,
                onTap: () {},
                decoration: const InputDecoration.collapsed(
                  fillColor: Colors.white,
                  hintStyle: TextStyle(fontSize: 16),
                  hintText: 'No. PH...',
                ),
                autofocus: true,
              ),
            ),
            Text(doneError)
          ]),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tidak'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Get a reference to the document you want to update
                  DocumentReference documentReference = await FirebaseFirestore
                      .instance
                      .collection('price_quotes')
                      .doc(documentId);

                  // Update the document with the new data
                  if (_noPhController.text.isNotEmpty) {
                    documentReference.update(
                        {'selesai': true, 'no_ph': _noPhController.text});
                  } else {
                    documentReference.update({'selesai': true});
                  }
                  widget.triggerStreamBuilder(destination, filterClient,
                      filterBarang, filterPp, filterPh);

                  print('Data berhasil disimpan');
                } catch (e) {
                  print('Error !');
                }
                Navigator.of(context).pop();
              },
              child: Text('Ya'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> deleteEmail(String documentId) async {
    if (documentId.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirm'),
          content: Text('Apakah anda yakin ingin menghapus data ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tidak'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Get a reference to the document you want to update
                  DocumentReference documentReference = FirebaseFirestore
                      .instance
                      .collection('price_quotes')
                      .doc(documentId);

                  // Update the document with the new data
                  await documentReference.delete();
                  widget.triggerStreamBuilder(destination, filterClient,
                      filterBarang, filterPp, filterPh);
                  print('Data berhasil disimpan');
                } catch (e) {
                  print('Error !');
                }
                Navigator.of(context).pop();
              },
              child: Text('Ya'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> deleteClient(String documentId) async {
    if (documentId.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirm'),
          content: Text('Apakah anda yakin ingin menghapus data ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tidak'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Get a reference to the document you want to update
                  DocumentReference documentReference = FirebaseFirestore
                      .instance
                      .collection('clients')
                      .doc(documentId);

                  // Update the document with the new data
                  await documentReference.delete();
                  // widget.triggerStreamBuilder(
                  //     destination, filterClient, filterBarang);
                  setState(() {
                    selectedClientData = null;
                    filteredClientData = null;
                  });
                  print('Data berhasil disimpan');
                } catch (e) {
                  print('Error !');
                }
                Navigator.of(context).pop();
              },
              child: Text('Ya'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> unstarEmail(
      String documentId, Client? client, String barang) async {
    try {
      // Get a reference to the document you want to update
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('price_quotes').doc(documentId);

      // Update the document with the new data
      await documentReference.update({'prioritas': false});
      widget.triggerStreamBuilder(
          destination, filterClient, filterBarang, filterPp, filterPh);
      print('Data berhasil disimpan');
    } catch (e) {
      print('Error !');
    }
  }

  Future<void> starEmail(
      String documentId, Client? client, String barang) async {
    try {
      // Get a reference to the document you want to update
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('price_quotes').doc(documentId);

      // Update the document with the new data
      await documentReference.update({'prioritas': true});
      widget.triggerStreamBuilder(
          destination, filterClient, filterBarang, filterPp, filterPh);
      print('Data berhasil disimpan');
    } catch (e) {
      print('Error !');
    }
  }

  Future<void> openEditPage(
      String id, BuildContext context, bool isDesktop, bool isDone) async {
    if (isDesktop) {
      desktopMailNavKey.currentState!.popUntil(
        (route) {
          var currentRoute = route.settings.name;

          if (currentRoute != MyApp.composeRoute) {
            desktopMailNavKey.currentState!
                .restorablePushNamed(MyApp.composeRoute, arguments: {
              'edit': true,
              'done': false,
              'repost': false,
              'id': id
            });
          }
          return true;
        },
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ComposePage(
                isEdit: true, isDone: isDone, editId: id, isRepost: false)),
      );
    }
    widget.triggerStreamBuilder(
        destination, filterClient, filterBarang, filterPp, filterPh);
  }

  Future<void> openRepostPage(String id, bool isDone) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ComposePage(
              isEdit: true, isDone: isDone, editId: id, isRepost: true)),
    );

    widget.triggerStreamBuilder(
        destination, filterClient, filterBarang, filterPp, filterPh);
  }

  Future<void> openEditClient(
      String id, BuildContext context, bool isDesktop) async {
    if (isDesktop) {
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ClientAddPage(isEdit: true, editId: id)),
      );
    }
    widget.triggerStreamBuilder(
        destination, filterClient, filterBarang, filterPp, filterPh);
  }

  void filterDataListByClient(Client? client) {
    if (client != null) {
      // setState(() {
      filterClient = client;
      //});
      if (filterBarang.isNotEmpty) {
        filteredDataList = filteredDataList
            .where((data) =>
                (data as Email)
                    .namaBarang
                    .toLowerCase()
                    .contains(filterBarang.toLowerCase()) &&
                (data.klienRef as DocumentReference<Map<String, dynamic>>?)!
                        .id ==
                    client!.id)
            .toList();
      } else {
        filteredDataList = filteredDataList
            .where((data) =>
                (data as Email)
                    .klienRef!
                    .id /* (data.klien as DocumentReference<Map<String, dynamic>>?)!.id*/ ==
                client!.id)
            .toList();
      }

      // DocumentReference<Map<String, dynamic>> klienRef =
      //     FirebaseFirestore.instance.collection('clients').doc(client!.id);
      // DocumentSnapshot klienSnapshot = await klienRef.get();

      // if (klienSnapshot.isDefinedAndNotNull) {
      //   for (int index = 0; index < dataList!.length; index++) {
      //     Email priceQuoteDataList = dataList![index];

      //     if (priceQuoteDataList.klien!.id == client.id) {
      //       // Add the data to the filteredDataList
      //       // setState(() {
      //       print(filterBarang.toString());
      //       if (filterBarang != '') {
      //         if (priceQuoteDataList.namaBarang
      //                 .toUpperCase()
      //                 .contains(filterBarang!.toUpperCase()) &&
      //             !filteredDataList
      //                 .any((item) => item.id == dataList![index].id)) {
      //           filteredDataList.add(dataList![index]);
      //         }
      //       } else {
      //         if (!filteredDataList
      //             .any((item) => item.id == dataList[index].id)) {
      //           filteredDataList.add(dataList![index]);
      //         }
      //       }

      //       //  });
      //     } else {
      //       /// setState(() {
      //       filteredDataList = [];
      //       // });
      //     }
      //   }
      // }
    }
  }

  void filterDataListByName(String barang) {
    _debounce?.cancel();
    if (barang.isEmpty) {
      setState(() {
        filteredDataList = dataList;
      });
    }
    _debounce = Timer(Duration(milliseconds: 500), () {
      if (filterClient != null) {
        filteredDataList = dataList
            .where((data) =>
                (data as Email)
                    .namaBarang
                    .toLowerCase()
                    .contains(barang.toLowerCase()) &&
                (data.klienRef as DocumentReference<Map<String, dynamic>>?)!
                        .id ==
                    filterClient!.id)
            .toList();
      } else {
        filteredDataList = dataList
            .where((data) => (data as Email)
                .namaBarang
                .toLowerCase()
                .contains(barang.toLowerCase()))
            .toList();
      }
      setState(() {
        filteredDataList;
      });
    });
  }

  Future<List<String>> getPp() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('price_quotes')
        .where('no_pp', isNotEqualTo: "")
        .get();

    List<String> fieldValues = [];

    querySnapshot.docs.forEach((doc) {
      // Get the value of the specific field you want to retrieve
      String fieldValue =
          doc.get('no_pp'); // Replace 'fieldName' with your field name

      // Add the field value to the list
      fieldValues.add(fieldValue);
    });

    return fieldValues;
  }

  Future<List<String>> getPh() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('price_quotes')
        .where('no_ph', isNotEqualTo: "")
        .get();

    List<String> fieldValues = [];

    querySnapshot.docs.forEach((doc) {
      // Get the value of the specific field you want to retrieve
      String fieldValue =
          doc.get('no_ph'); // Replace 'fieldName' with your field name

      // Add the field value to the list
      fieldValues.add(fieldValue);
    });
    return fieldValues;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(widget.parentContext);
    final isTablet = isDisplaySmallDesktop(widget.parentContext);
    final startPadding = isTablet
        ? 45.0
        : isDesktop
            ? 60.0
            : 20.0;
    final endPadding = isTablet
        ? 45.0
        : isDesktop
            ? 60.0
            : 20.0;

    print('build test');
    print(filteredDataList);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (destination == 'clients') ...[
          Container(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: DropdownSearch<Client>(
              key: clientDropdownKey,
              items: clientSearchItems,
              selectedItem: selectedClientData,
              itemAsString: (item) {
                String namaKlien = '';
                if (item.singkatan.isNotEmpty) {
                  if (item.namaKlien.isNotEmpty) {
                    namaKlien += (item.singkatan + ' - ');
                  } else {
                    namaKlien += item.singkatan;
                  }
                }
                if (item.namaKlien.isNotEmpty) {
                  namaKlien += item.namaKlien;
                }
                return namaKlien;
              },
              dropdownDecoratorProps: DropDownDecoratorProps(
                  textAlignVertical: TextAlignVertical.center,
                  dropdownSearchDecoration: InputDecoration(
                      hintText: 'Cari Klien...',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: (selectedClientData != null)
                          ? IconButton(
                              color: Colors.blue,
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  selectedClientData = null;
                                  filteredClientData = null;
                                  //filteredDataList = widget.dataList;
                                  // dataList = widget.dataList;
                                });
                                //widget.triggerStreamBuilder(
                                //   destination, filterClient, filterBarang);
                              },
                            )
                          : null)),
              onChanged: (Client? data) {
                setState(() {
                  selectedClientData = data;
                  filteredClientData = data;
                });
              },

              // selectedItem: selectedClient,

              popupProps: PopupProps.menu(
                showSearchBox: true,
              ),
            ),
          ),
        ] else ...[
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: FutureBuilder<QuerySnapshot>(
                    future:
                        FirebaseFirestore.instance.collection('clients').get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        clientsList = snapshot.data!.docs.map((doc) {
                          String id = doc.id;
                          String namaKlien = doc['nama_klien'];
                          String singkatan = doc['singkatan'];
                          String email = doc['email'];
                          String noHp = doc['no_hp'];
                          String alamat = doc['alamat'];
                          Client client = Client(
                            id: id,
                            singkatan: singkatan,
                            namaKlien: namaKlien,
                            email: email,
                            noHp: noHp,
                            alamat: alamat,
                          );

                          return client;
                        }).toList();
                        return DropdownSearch<Client>(
                          key: clientDropdownKey,
                          items: clientsList,
                          selectedItem: selectedClientData,

                          itemAsString: (item) {
                            String namaKlien = '';
                            if (item.singkatan.isNotEmpty) {
                              if (item.namaKlien.isNotEmpty) {
                                namaKlien += (item.singkatan + ' - ');
                              } else {
                                namaKlien += item.singkatan;
                              }
                            }
                            if (item.namaKlien.isNotEmpty) {
                              namaKlien += item.namaKlien;
                            }
                            return namaKlien;
                          },
                          dropdownDecoratorProps: DropDownDecoratorProps(
                              textAlignVertical: TextAlignVertical.center,
                              dropdownSearchDecoration: InputDecoration(
                                  hintText: 'Cari Klien...',
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: (selectedClientData != null)
                                      ? IconButton(
                                          color: Colors.blue,
                                          icon: Icon(Icons.clear),
                                          onPressed: () {
                                            setState(() {
                                              selectedClientData = null;
                                              filterClient = null;
                                              // if (filterBarang.isNotEmpty) {
                                              //   filterDataListByName(
                                              //       filterBarang);
                                              // } else {
                                              //   filteredDataList = dataList;
                                              // }
                                              widget.triggerStreamBuilder(
                                                  destination,
                                                  filterClient,
                                                  filterBarang,
                                                  filterPp,
                                                  filterPh);
                                            });
                                          },
                                        )
                                      : null)),
                          onChanged: (Client? data) {
                            setState(() {
                              selectedClientData = data;
                              filterClient = data;
                            });
                            filterDataListByClient(data);
                          },

                          // selectedItem: selectedClient,

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
                Container(
                  padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: FutureBuilder<List<String>>(
                          future: getPp(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              ppList = snapshot.data!;
                              return DropdownSearch<String>(
                                key: ppDropdownKey,
                                items: ppList,
                                selectedItem:
                                    filterPp.isEmpty ? null : filterPp,
                                dropdownBuilder: (context, selectedItem) {
                                  return Container(
                                      child: Text(
                                    selectedItem ?? 'No. PP...',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'Arial',
                                        fontSize: 16,
                                        color:
                                            Color.fromARGB(255, 112, 112, 112)),
                                  ) // Adjust the height as needed
                                      );
                                },

                                dropdownDecoratorProps: DropDownDecoratorProps(
                                    textAlignVertical: TextAlignVertical.center,
                                    dropdownSearchDecoration: InputDecoration(
                                        hintText: 'No. PP...',
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: filterPp.isEmpty
                                            ? null
                                            : IconButton(
                                                color: Colors.blue,
                                                icon: Icon(Icons.clear),
                                                onPressed: () {
                                                  setState(() {
                                                    filterPp = '';
                                                  });
                                                  widget.triggerStreamBuilder(
                                                      destination,
                                                      filterClient,
                                                      filterBarang,
                                                      filterPp,
                                                      filterPh);
                                                },
                                              ))),
                                onChanged: (String? data) {
                                  setState(() {
                                    filterPp = data!;
                                  });
                                  widget.triggerStreamBuilder(
                                      destination,
                                      filterClient,
                                      filterBarang,
                                      filterPp,
                                      filterPh);
                                },

                                // selectedItem: selectedClient,

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
                      SizedBox(width: 8.0),
                      Expanded(
                        flex: 1,
                        child: FutureBuilder<List<String>>(
                          future: getPh(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              phList = snapshot.data!;
                              return DropdownSearch<String>(
                                key: phDropdownKey,
                                items: phList,
                                selectedItem:
                                    filterPh.isEmpty ? null : filterPh,
                                dropdownBuilder: (context, selectedItem) {
                                  return Container(
                                      child: Text(
                                    selectedItem ?? 'No. PH...',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'Arial',
                                        fontSize: 16,
                                        color:
                                            Color.fromARGB(255, 112, 112, 112)),
                                  ) // Adjust the height as needed
                                      );
                                },
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                    textAlignVertical: TextAlignVertical.center,
                                    dropdownSearchDecoration: InputDecoration(
                                        hintText: 'No. PH...',
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: filterPh.isEmpty
                                            ? null
                                            : IconButton(
                                                color: Colors.blue,
                                                icon: Icon(Icons.clear),
                                                onPressed: () {
                                                  setState(() {
                                                    filterPh = '';
                                                  });
                                                  widget.triggerStreamBuilder(
                                                      destination,
                                                      filterClient,
                                                      filterBarang,
                                                      filterPp,
                                                      filterPh);
                                                },
                                              ))),
                                onChanged: (String? data) {
                                  setState(() {
                                    filterPh = data!;
                                  });
                                  widget.triggerStreamBuilder(
                                      destination,
                                      filterClient,
                                      filterBarang,
                                      filterPp,
                                      filterPh);
                                },

                                // selectedItem: selectedClient,

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
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 18),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black, // Set the desired border color
                          width: 1.0, // Set the desired border width
                        ),
                      ),
                    ),
                    child: TextField(
                      onTap: () {},
                      controller: _barangController,
                      decoration: const InputDecoration.collapsed(
                        fillColor: Colors.white,
                        hintStyle: TextStyle(fontSize: 16),
                        hintText: 'Nama Barang...',
                      ),
                      autofocus: false,
                      onChanged: (value) {
                        setState(() {
                          filterBarang = value;

                          filterDataListByName(value);
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (filteredClientData != null) ...[
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: startPadding,
              end: endPadding,
              top: isDesktop ? 28 : 18,
              bottom: kToolbarHeight,
            ),
            child: ClientPreviewCard(
              id: filteredClientData!.id,
              username: username,
              client: filteredClientData ?? Client(id: ''),
              onDelete: () => deleteClient(filteredClientData!.id),
              openEditPage: () => openEditClient(
                  filteredClientData!.id, parentContext, isDesktop),
            ),
          )
        ] else ...[
          if (filteredDataList.isNotEmpty) ...[
            Expanded(
              child: ListView.separated(
                itemCount: filteredDataList.length,
                padding: EdgeInsetsDirectional.only(
                  start: startPadding,
                  end: endPadding,
                  top: isDesktop ? 28 : 18,
                  bottom: kToolbarHeight,
                ),
                primary: false,
                separatorBuilder: (context, index) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  if (destination == 'clients') {
                    Client client = filteredDataList[index];

                    return ClientPreviewCard(
                      id: client.id,
                      username: username,
                      client: client,
                      onDelete: () => deleteClient(client.id),
                      openEditPage: () =>
                          openEditClient(client.id, parentContext, isDesktop),
                    );
                  } else {
                    Email priceQuote = filteredDataList[index];

                    // Map<String, dynamic> priceQuoteDocument =
                    //     priceQuote as Map<String, dynamic>;
                    // Map<String, dynamic> priceQuoteDocument =
                    //     priceQuote.toJson();

                    List<dynamic> barang = priceQuote.barang;

                    List<String> mappedList = barang
                        .map(
                          (item) =>
                              item['nama_barang'].toString() +
                              ' ' +
                              item['jumlah_barang'].toString() +
                              ' ' +
                              item['satuan'].toString(),
                        )
                        .toList();
                    String namaBarang = mappedList.join(', ');
                    print(priceQuote.klienRef);
                    return FutureBuilder<DocumentSnapshot>(
                      future: priceQuote.klienRef!.get(),
                      builder: (context, klienSnapshot) {
                        print('future build test');
                        if (klienSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();
                        } else if (klienSnapshot.connectionState ==
                            ConnectionState.done) {
                          if (klienSnapshot.hasData &&
                              klienSnapshot.data!.exists) {
                            DocumentSnapshot klienSnapshotData =
                                klienSnapshot.data!;
                            Client priceQuoteClient = Client(
                              id: klienSnapshotData.id,
                              namaKlien: klienSnapshotData['nama_klien'],
                              singkatan: klienSnapshotData['singkatan'],
                              noHp: klienSnapshotData['no_hp'],
                              email: klienSnapshotData['email'],
                              alamat: klienSnapshotData['alamat'],
                            );
                            priceQuote.klien = priceQuoteClient;
                            // Access the data from klienSnapshot
                            String namaKlien = klienSnapshotData['nama_klien'];
                            priceQuote.namaKlien = namaKlien;
                          } else {
                            priceQuote.namaKlien = '-';
                          }

                          // Email priceQuote = Email(
                          //   //id: priceQuoteDocument.id,
                          //   id: priceQuoteDocument['id'],
                          //   tglBuat: priceQuoteDocument['tgl_buat'],
                          //   tglNotifikasi:
                          //       priceQuoteDocument['tgl_notifikasi'],
                          //   namaKlien: namaKlien,
                          //   selesai: priceQuoteDocument['selesai'],
                          //   prioritas:
                          //       priceQuoteDocument['prioritas'],
                          // );

                          return MailPreviewCard(
                            id: priceQuote.id,
                            username: username,
                            email: priceQuote,
                            namaBarang: namaBarang,
                            catatan: priceQuote.catatan,
                            onDone: () => doneEmail(priceQuote.id),
                            onDelete: () => deleteEmail(priceQuote.id),
                            onStar: () {
                              // print('onstar');
                              // print('client : ' + filterClient.toString());
                              // print('barang : ' + filterBarang);
                              if (priceQuote.prioritas) {
                                unstarEmail(
                                    priceQuote.id, filterClient, filterBarang);
                              } else {
                                starEmail(
                                    priceQuote.id, filterClient, filterBarang);
                              }
                            },
                            openEditPage: () => openEditPage(priceQuote.id,
                                parentContext, isDesktop, priceQuote.selesai),
                            openRepostPage: () => openRepostPage(
                                priceQuote.id, priceQuote.selesai),
                            isStarred: priceQuote.prioritas,
                            onStarredMailbox: false,
                          );
                        } else if (klienSnapshot.hasError) {
                          return Text('Error retrieving data');
                        } else {
                          return Text('No data available');
                        }
                      },
                    );
                  }
                },
              ),
            ),
          ] else ...[
            Expanded(
                child: Center(child: Text('Data Kosong / Tidak Ditemukan')))
          ]
        ],
      ],
    );
  }
}
