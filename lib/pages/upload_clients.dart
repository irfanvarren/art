import 'package:flutter/material.dart';
//import 'package:art/layout/adaptive.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:art/main.dart';

class UploadClientsPage extends StatelessWidget {
  const UploadClientsPage({super.key});
  void upload_clients() async {
    // final endpoint =
    //     'https://firestore.googleapis.com/v1/projects//databases/(default)/documents/clients';
    List<Map<String, dynamic>> documents = [
      {
        "nama_klien": "PT. SEPANJANG INTISURYA MULIA",
        "singkatan": "SISM",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. SAWIT MITRA ABADI",
        "singkatan": "SMA",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. CITRA SAWIT CERMERLANG",
        "singkatan": "CSC",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. SURYA AGRO PALMA",
        "singkatan": "SAP",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. AGRO ABADI CERMERLANG",
        "singkatan": "AAC",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. PALMA AGRO LESTARI JAYA",
        "singkatan": "PALJ",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. GLOBALINDO AGUNG LESTARI",
        "singkatan": "GAL",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. UNITED AGRO INDONESIA",
        "singkatan": "UAI",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. KHARISMA INTI USAHA",
        "singkatan": "KIU",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. DWIE WARNA KARYA",
        "singkatan": "DWK",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. CITRA BORNEO UTAMA",
        "singkatan": "CBU",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. SURYA BORNEO INDUSTRI",
        "singkatan": "SBI",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. PESONA CITRA PROPERTINDO",
        "singkatan": "PCP",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. SAWIT SUMBERMAS SARANA",
        "singkatan": "SSS",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. NALA PALMA CADUDASA",
        "singkatan": "NPC",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. SUMBER ALAM SELARAS",
        "singkatan": "SAS",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. HAMPARAN SENTOSA",
        "singkatan": "HS",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. ENGGANG ALAM SAWITA",
        "singkatan": "EAS",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. MUSIMAS",
        "singkatan": "MUSIMAS",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. PARNA AGROMAS",
        "singkatan": "PARNA",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. GRAND UTAMA MANDIRI",
        "singkatan": "GUM",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. TITIN BOYOK SAWIT MAKMUR",
        "singkatan": "TBSM",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. AGRINA SAWIT PERDANA",
        "singkatan": "ASP",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. BUMI TATA LESTARI",
        "singkatan": "BTL",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. ANUGERAH ENERGITAMA",
        "singkatan": "AE",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. AGRO BUMI KALTIM",
        "singkatan": "ABK",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. BANGUN BATARA RAYA",
        "singkatan": "BBR",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. BERKAT NABATI SEJAHTERA",
        "singkatan": "BNS",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. SAWIT NABATI AGRO",
        "singkatan": "SNA",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. BUMI SAWIT SEJAHTERA",
        "singkatan": "BSS",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. SUKSES KARYA SAWIT",
        "singkatan": "SKS",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. KALIMANTAN PRIMA AGRO MANDIRI",
        "singkatan": "KPAM",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. BUMITAMA GUNAJAYA AGRO",
        "singkatan": "BGA",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. KARYASUKSES UTAMA PRIMA",
        "singkatan": "KSUP",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. PATEN ALAM LESTARI",
        "singkatan": "PAL",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. FAJAR KITA KUSUMA",
        "singkatan": "FKK",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. GUNUNG RIJUAN SEJAHTERA",
        "singkatan": "GRS",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "KENCANA",
        "singkatan": "KENCANA",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. LIFERE AGRO KAPUAS",
        "singkatan": "LAK",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. MAJU KALIMANTAN HADAPAN",
        "singkatan": "MKH",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. MENTENG KENCANA MAS",
        "singkatan": "MKM",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. MULTI PERKASA SEJAHTERA",
        "singkatan": "MPS",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
      {
        "nama_klien": "PT. PESONA KHATULISTIWA NUSANTARA",
        "singkatan": "PKN",
        "alamat": "",
        "email": "",
        "no_hp": ""
      },
    ];
    await initializeFirebase();
    final firestoreInstance = FirebaseFirestore.instance;

    // Get the reference to the collection
    final collectionRef = firestoreInstance.collection('clients');

    // Create a batch to perform multiple writes at once
    final batch = firestoreInstance.batch();

    // Loop through the documents and add them to the batch
    for (final data in documents) {
      final documentRef =
          collectionRef.doc(); // Automatically generate a unique document ID
      batch.set(documentRef, data);
    }

    // Commit the batch
    await batch.commit();

    print('Documents added successfully');
    // // Create a list of requests to add each document
    // final requests = documents.map((data) {
    //   final document = {
    //     'fields': data,
    //   };
    //   return {
    //     'insert': document,
    //   };
    // }).toList();

    // // Create the request body
    // final body = {
    //   'writes': requests,
    // };

    // // Convert the body to JSON
    // final bodyJson = json.encode(body);

    // // Send the POST request to add the documents
    // final response = await http.post(
    //   Uri.parse(endpoint),
    //   headers: {
    //     'Content-Type': 'application/json',
    //   },
    //   body: bodyJson,
    // );

    // // Check the response status
    // if (response.statusCode == 200) {
    //   print('Documents added successfully');
    // } else {
    //   print('Failed to add documents. Response: ${response.body}');
    // }
  }

  @override
  Widget build(BuildContext context) {
    upload_clients();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onPressed: () {},
        ),
        title: const Text(
          "Logo",
        ),
      ),
      body: const Center(
        child: Text(
          "Home",
        ),
      ),
    );
  }
}
