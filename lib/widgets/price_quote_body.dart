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
import 'package:http/http.dart' as http;
import 'dart:convert';

//import 'package:provider/provider.dart';
typedef StreamCallback = void Function(
    String? destination, Client? filterClient, String filterBarang);

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
    getStream(widget.destination, null, null);

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

      getStream(widget.destination, null, null);
    }
    super.didUpdateWidget(widget);
  }

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }

  void triggerStreamBuilder(
      String? getDestination, Client? pFilterClient, String pFilterBarang) {
    print(getDestination! + '|' + widget.destination + '|' + destination);
    //setState(() {
    filterClient = pFilterClient;
    filterBarang = pFilterBarang;
    // Update the state or change any variables that will affect the StreamBuilder
    // You can use the passed data here
    //});
    //print(pFilterClient);
    //print(pFilterBarang);
    getStream(widget.destination, filterClient, filterBarang);
  }

  // Stream<Map<String, dynamic>> getStream(String destination) {
  void getStream(
      String destination, Client? filterClient, String? filterBarang) async {
    Stream<QuerySnapshot<dynamic>> myStream;
    print('getStream');
    String url;
    Map<String, dynamic>? requestData = null;
    if (widget.destination == 'clients') {
      url =
          'https://firestore.googleapis.com/v1/projects/pt-art-d22b7/databases/(default)/documents/clients';
      requestData = null;
    } else if (widget.destination == 'prioritas') {
      url =
          'https://firestore.googleapis.com/v1/projects/pt-art-d22b7/databases/(default)/documents:runQuery';

      requestData = {
        'structuredQuery': {
          'from': [
            {'collectionId': 'price_quotes'}
          ],
          'where': {
            'compositeFilter': {
              'op': 'AND',
              'filters': [
                {
                  'fieldFilter': {
                    'field': {'fieldPath': 'selesai'},
                    'op': 'EQUAL',
                    'value': {'booleanValue': false}
                  }
                },
                {
                  'fieldFilter': {
                    'field': {'fieldPath': 'prioritas'},
                    'op': 'EQUAL',
                    'value': {'booleanValue': true}
                  }
                }
              ]
            }
          }
        }
      };
    } else if (widget.destination == 'done') {
      url =
          'https://firestore.googleapis.com/v1/projects/pt-art-d22b7/databases/(default)/documents:runQuery';

      requestData = {
        'structuredQuery': {
          'from': [
            {'collectionId': 'price_quotes'}
          ],
          'where': {
            'fieldFilter': {
              'field': {'fieldPath': 'selesai'},
              'op': 'EQUAL',
              'value': {'booleanValue': true}
            }
          }
        }
      };
    } else {
      url =
          'https://firestore.googleapis.com/v1/projects/pt-art-d22b7/databases/(default)/documents:runQuery';

      requestData = {
        'structuredQuery': {
          'from': [
            {'collectionId': 'price_quotes'}
          ],
          'where': {
            'fieldFilter': {
              'field': {'fieldPath': 'selesai'},
              'op': 'EQUAL',
              'value': {'booleanValue': false}
            }
          }
        }
      };
    }
    http.Response response;
    // print(requestData);
    if (requestData != null) {
      response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );
    } else {
      response = await http.get(Uri.parse(url));
    }
    List<dynamic> responseList = [];
    if (response.statusCode == 200) {
      Map<String, dynamic> allObjects = {};
      // Request successful, parse the response body
      // print(response.body);
      dynamic data = jsonDecode(response.body);

      if (data is List) {
        responseList = data;
      } else {
        data = data as Map<String, dynamic>;
        if (data.containsKey('documents')) {
          responseList = data['documents'];
        } else {
          print('not add');
          streamController.add(allObjects);
        }
      }

      if (widget.destination == 'clients') {
        List<Client> clients = [];
        responseList.forEach((element) {
          Client client = Client(
            id: element['name'].split('/').last,
            namaKlien: element['fields']['nama_klien']['stringValue'],
            email: element['fields']['email']['stringValue'],
            noHp: element['fields']['no_hp']['stringValue'],
            alamat: element['fields']['alamat']['stringValue'],
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
      } else {
        List<dynamic> price_quotes = [];
        print('responselist');
        print(responseList);
        responseList.forEach((element) {
          if (element != null) {
            print('element');
            print(element);
            Map<String, dynamic> fields;
            String price_quote_id = '';
            if ((requestData != null)) {
              if ((element as Map<String, dynamic>).containsKey('document')) {
                fields = element['document']['fields'];
                price_quote_id = element['document']['name'].split('/').last;
              } else {
                fields = {};
              }
            } else {
              fields = element['fields'];
              price_quote_id = element['name'].split('/').last;
            }
            //print(fields['barang']['arrayValue']);

            List<Map<String, dynamic>> barang = [];
            print(fields);
            if (fields.containsKey('barang') &&
                fields['barang'].containsKey('arrayValue')) {
              //print(fields['barang']['arrayValue']['values']);
              if (fields['barang']['arrayValue'] != {}) {
                List<dynamic> values =
                    (fields['barang']['arrayValue']['values']) ?? [];
                for (var value in values) {
                  if (value.containsKey('mapValue') &&
                      value['mapValue'].containsKey('fields')) {
                    Map<String, dynamic> fields = value['mapValue']['fields'];
                    Map<String, dynamic> updatedBarang = {};
                    for (var entry in fields.entries) {
                      String key = entry.key;
                      dynamic value = entry.value.values.first;
                      updatedBarang[key] = value;
                    }
                    barang.add(updatedBarang);
                  }
                }
              }
            }
            print('fields');
            print(fields);
            if (fields.isNotEmpty) {
              Email price_quote = Email(
                id: price_quote_id,
                namaBarang: fields['nama_barang']['stringValue'],
                barang: barang,
                catatan: fields['catatan']['stringValue'],
                klien: fields['klien']['referenceValue'].split('/').last,
                tglBuat: Timestamp.fromDate(
                    DateTime.parse(fields['tgl_buat']['timestampValue'])),
                tglNotifikasi: Timestamp.fromDate(
                    DateTime.parse(fields['tgl_notifikasi']['timestampValue'])),
                selesai: fields['selesai']['booleanValue'],
                prioritas: fields['prioritas']['booleanValue'],
              );

              if (filterClient != null && filterBarang != null) {
                if (price_quote.klien == filterClient.id &&
                    price_quote.namaBarang
                        .toLowerCase()
                        .contains(filterBarang.toLowerCase())) {
                  price_quotes.add(price_quote);
                }
              } else if (filterClient != null) {
                if (price_quote.klien == filterClient.id) {
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
            }
          }
        });

        allObjects['data'] = price_quotes;
      }
      print('add');
      print(allObjects);
      streamController.add(allObjects);
    } else {
      // Request failed, handle the error
      print('Request failed with status code: ${response.statusCode}' +
          response.body);
    }
    // if (widget.destination == 'clients') {
    //   myStream =
    //       await FirebaseFirestore.instance.collection('clients').snapshots();
    // } else if (widget.destination == 'prioritas') {
    //   myStream = await FirebaseFirestore.instance
    //       .collection('price_quotes')
    //       .where('selesai', isEqualTo: false)
    //       .where('prioritas', isEqualTo: true)
    //       .snapshots();
    // } else if (widget.destination == 'done') {
    //   myStream = await FirebaseFirestore.instance
    //       .collection('price_quotes')
    //       .where('selesai', isEqualTo: true)
    //       .snapshots();
    // } else {
    //   myStream = await FirebaseFirestore.instance
    //       .collection('price_quotes')
    //       .where('selesai', isEqualTo: false)
    //       .snapshots();
    // }
    // //return

    // myStream.forEach((QuerySnapshot snapshot) {
    //   Map<String, dynamic> allObjects = {};
    //   allObjects['key'] = UniqueKey();
    //   if (widget.destination == 'clients') {
    //     List<Client> clients = [];

    //     snapshot.docs.forEach((DocumentSnapshot document) {
    //       Client client = Client(
    //         id: document.id,
    //         namaKlien: document['nama_klien'],
    //         email: document['email'],
    //         noHp: document['no_hp'],
    //         alamat: document['alamat'],
    //       );
    //       if (filterClient != null) {
    //         if (client.id == filterClient!.id) {
    //           clients.add(client);
    //         }
    //       } else {
    //         clients.add(client);
    //       }
    //     });
    //     allObjects['data'] = clients;

    //     //return allObjects;
    //     streamController.add(allObjects);
    //   } else {
    //     Map<String, dynamic> allObjects = {};
    //     List<dynamic> price_quotes = [];
    //     snapshot.docs.forEach((DocumentSnapshot document) {
    //       Email price_quote = Email(
    //         id: document.id,
    //         namaBarang: document['nama_barang'],
    //         barang: document['barang'] as List<dynamic>,
    //         catatan: document['catatan'],
    //         klien: document['klien'] as DocumentReference<Map<String, dynamic>>,
    //         tglBuat: document['tgl_buat'],
    //         tglNotifikasi: document['tgl_notifikasi'],
    //         selesai: document['selesai'],
    //         prioritas: document['prioritas'],
    //       );
    //       if (filterClient != null && filterBarang != null) {
    //         if (price_quote.klien!.id == filterClient.id &&
    //             price_quote.namaBarang
    //                 .toLowerCase()
    //                 .contains(filterBarang.toLowerCase())) {
    //           price_quotes.add(price_quote);
    //         }
    //       } else if (filterClient != null) {
    //         if (price_quote.klien!.id == filterClient.id) {
    //           price_quotes.add(price_quote);
    //         }
    //       } else if (filterBarang != null) {
    //         if (price_quote.namaBarang
    //             .toLowerCase()
    //             .contains(filterBarang.toLowerCase())) {
    //           price_quotes.add(price_quote);
    //         }
    //       } else {
    //         price_quotes.add(price_quote);
    //       }
    //     });
    //     allObjects['data'] = price_quotes;

    //     List<Client> clients = [];

    //     allObjects['clients'] = clients;
    //     //return allObjects;
    //     streamController.add(allObjects);
    //   }
    // });
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
      getStream(widget.destination, null, null);
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
            if (streamSnapshot.hasData && streamSnapshot.data!.isNotEmpty) {
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
  Client? selectedClientData;
  late List dataList;
  List<Client> clientsList = [];
  final TextEditingController _barangController = TextEditingController();
  Timer? _debounce;
  bool isNavigatorPopped = false;

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
    super.didUpdateWidget(oldWidget);
  }

  Future<Map<String, dynamic>> getClient(String? idKlien) async {
    Map<String, dynamic> data = {'nama_klien': ''};
    if (idKlien != null) {
      String url =
          'https://firestore.googleapis.com/v1/projects/pt-art-d22b7/databases/(default)/documents/clients/$idKlien';
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        data['nama_klien'] =
            responseBody['fields']['nama_klien']['stringValue'];
      } else {
        // Request failed, handle the error
        print('Request failed with status code: ${response.statusCode}' +
            response.body);
      }
    } else {}
    return data;
  }

  Future<void> doneEmail(String documentId) async {
    String getUrl =
        'https://firestore.googleapis.com/v1/projects/pt-art-d22b7/databases/(default)/documents/price_quotes/$documentId';
    http.Response response = await http.get(Uri.parse(getUrl));
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      print(responseBody['fields']);
      final String url =
          'https://firestore.googleapis.com/v1/projects/pt-art-d22b7/databases/(default)/documents/price_quotes/$documentId';
      final Map<String, dynamic> data = responseBody['fields'];
      data['selesai'] = {'booleanValue': true};
      final requestBody = json.encode({'fields': data});
      final responseUpdate =
          await http.patch(Uri.parse(url), body: requestBody);
      if (responseUpdate.statusCode == 200) {
        widget.triggerStreamBuilder(destination, filterClient, filterBarang);
        print('Data berhasil disimpan');
      } else {
        print('Error !');
      }
    } else {
      print('Request failed with status code: ${response.statusCode}' +
          response.body);
    }
    // try {
    //   // Get a reference to the document you want to update
    //   DocumentReference documentReference =
    //       FirebaseFirestore.instance.collection('price_quotes').doc(documentId);

    //   // Update the document with the new data
    //   await documentReference.update({'selesai': true});
    //   widget.triggerStreamBuilder(destination, filterClient, filterBarang);

    //   print('Data berhasil disimpan');
    // } catch (e) {
    //   print('Error !');
    // }
  }

  Future<void> deleteEmail(String documentId) async {
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
              final String url =
                  'https://firestore.googleapis.com/v1/projects/pt-art-d22b7/databases/(default)/documents/price_quotes/$documentId';

              final response = await http.delete(Uri.parse(url));
              if (response.statusCode == 200) {
                widget.triggerStreamBuilder(
                    destination, filterClient, filterBarang);
                print('Data berhasil disimpan');
              } else {
                print('Error !');
              }
              // try {
              //   // Get a reference to the document you want to update
              //   DocumentReference documentReference = FirebaseFirestore.instance
              //       .collection('price_quotes')
              //       .doc(documentId);

              //   // Update the document with the new data
              //   await documentReference.delete();
              //   widget.triggerStreamBuilder(
              //       destination, filterClient, filterBarang);
              //   print('Data berhasil disimpan');
              // } catch (e) {
              //   print('Error !');
              // }
              Navigator.of(context).pop();
            },
            child: Text('Ya'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteClient(String documentId) async {
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
                DocumentReference documentReference = FirebaseFirestore.instance
                    .collection('clients')
                    .doc(documentId);

                // Update the document with the new data
                await documentReference.delete();
                widget.triggerStreamBuilder(
                    destination, filterClient, filterBarang);
                setState(() {
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

  Future<void> unstarEmail(
      String documentId, Client? client, String barang) async {
    String getUrl =
        'https://firestore.googleapis.com/v1/projects/pt-art-d22b7/databases/(default)/documents/price_quotes/$documentId';
    http.Response response = await http.get(Uri.parse(getUrl));
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      print(responseBody['fields']);
      final String url =
          'https://firestore.googleapis.com/v1/projects/pt-art-d22b7/databases/(default)/documents/price_quotes/$documentId';
      final Map<String, dynamic> data = responseBody['fields'];
      data['prioritas'] = {'booleanValue': false};
      final requestBody = json.encode({'fields': data});
      final responseUpdate =
          await http.patch(Uri.parse(url), body: requestBody);
      if (responseUpdate.statusCode == 200) {
        widget.triggerStreamBuilder(destination, filterClient, filterBarang);
        print('Data berhasil disimpan');
      } else {
        print('Error !');
      }
    } else {
      print('Request failed with status code: ${response.statusCode}' +
          response.body);
    }
    // try {
    //   // Get a reference to the document you want to update
    //   DocumentReference documentReference =
    //       FirebaseFirestore.instance.collection('price_quotes').doc(documentId);

    //   // Update the document with the new data
    //   await documentReference.update({'prioritas': false});
    //   widget.triggerStreamBuilder(destination, client, barang);
    //   print('Data berhasil disimpan');
    // } catch (e) {
    //   print('Error !');
    // }
  }

  Future<void> starEmail(
      String documentId, Client? client, String barang) async {
    String getUrl =
        'https://firestore.googleapis.com/v1/projects/pt-art-d22b7/databases/(default)/documents/price_quotes/$documentId';
    http.Response response = await http.get(Uri.parse(getUrl));
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      print(responseBody['fields']);
      final String url =
          'https://firestore.googleapis.com/v1/projects/pt-art-d22b7/databases/(default)/documents/price_quotes/$documentId';
      final Map<String, dynamic> data = responseBody['fields'];
      data['prioritas'] = {'booleanValue': true};
      final requestBody = json.encode({'fields': data});
      final responseUpdate =
          await http.patch(Uri.parse(url), body: requestBody);
      if (responseUpdate.statusCode == 200) {
        widget.triggerStreamBuilder(destination, filterClient, filterBarang);
        print('Data berhasil disimpan');
      } else {
        print('Error !');
      }
    } else {
      print('Request failed with status code: ${response.statusCode}' +
          response.body);
    }
    // final String url =
    //     'https://firestore.googleapis.com/v1/projects/pt-art-d22b7/databases/(default)/documents/price_quotes/$documentId';
    // final Map<String, dynamic> data = {
    //   'prioritas': {'booleanValue': true},
    // };
    // final requestBody = json.encode({'fields': data});
    // final response = await http.patch(Uri.parse(url), body: requestBody);

    // if (response.statusCode == 200) {
    //   widget.triggerStreamBuilder(destination, filterClient, filterBarang);
    //   print('Data berhasil disimpan');
    // } else {
    //   print('Error !');
    // }
    // try {
    //   // Get a reference to the document you want to update
    //   DocumentReference documentReference =
    //       FirebaseFirestore.instance.collection('price_quotes').doc(documentId);

    //   // Update the document with the new data
    //   await documentReference.update({'prioritas': true});

    //   widget.triggerStreamBuilder(destination, filterClient, filterBarang);
    //   print('Data berhasil disimpan');
    // } catch (e) {
    //   print('Error !');
    // }
  }

  Future<void> openEditPage(
      String id, BuildContext context, bool isDesktop, bool isDone) async {
    if (isDesktop) {
      desktopMailNavKey.currentState!.popUntil(
        (route) {
          var currentRoute = route.settings.name;

          if (currentRoute != MyApp.composeRoute) {
            desktopMailNavKey.currentState!.restorablePushNamed(
                MyApp.composeRoute,
                arguments: {'edit': true, 'repost': isDone, 'id': id});
          }
          return true;
        },
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ComposePage(isEdit: true, editId: id, isRepost: isDone)),
      );
    }
    widget.triggerStreamBuilder(destination, filterClient, filterBarang);
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
    widget.triggerStreamBuilder(destination, filterClient, filterBarang);
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
                (data.klien as DocumentReference<Map<String, dynamic>>?)!.id ==
                    client!.id)
            .toList();
      } else {
        filteredDataList = filteredDataList
            .where((data) =>
                (data as Email)
                    .klien! /*.id  (data.klien as DocumentReference<Map<String, dynamic>>?)!.id*/ ==
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
                (data.klien as DocumentReference<Map<String, dynamic>>?)!.id ==
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
      children: [
        if (destination == 'clients') ...[
          Container(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: DropdownSearch<Client>(
              key: clientDropdownKey,
              items: clientSearchItems,
              selectedItem: selectedClientData,
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
          Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                /*  child: FutureBuilder<QuerySnapshot>(
                  future:
                      FirebaseFirestore.instance.collection('clients').get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      clientsList = snapshot.data!.docs.map((doc) {
                        String id = doc.id;
                        String namaKlien = doc['nama_klien'];
                        String email = doc['email'];
                        String noHp = doc['no_hp'];
                        String alamat = doc['alamat'];
                        Client client = Client(
                          id: id,
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
                                                filterBarang);
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
            */
              ),
              Container(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
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

                    return FutureBuilder<Map<String, dynamic>>(
                      future: getClient(priceQuote.klien),
                      builder: (context, klienSnapshot) {
                        if (klienSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();
                        } else if (klienSnapshot.hasData) {
                          // DocumentSnapshot klienSnapshotData =
                          //     klienSnapshot.data!;

                          // Access the data from klienSnapshot
                          String namaKlien = klienSnapshot.data!['nama_klien'];
                          priceQuote.namaKlien = namaKlien;

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
