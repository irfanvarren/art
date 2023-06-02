import 'package:cloud_firestore/cloud_firestore.dart';

class Email {
  Email({
    required this.id,
    this.klien,
    this.barang = const [],
    this.gambar = '',
    this.tglBuat,
    this.tglEdit,
    this.tglProses,
    this.tglNotifikasi,
    this.namaKlien = '',
    this.namaBarang = '',
    this.jumlahBarang = '',
    this.satuan = '',
    this.catatan = '',
    this.containsPictures = false,
    this.prioritas = false,
    this.selesai = false,
  });
  final String id;
  final DocumentReference<Map<String, dynamic>>? klien;
  final List<dynamic> barang;
  final Timestamp? tglBuat;
  final Timestamp? tglEdit;
  final Timestamp? tglProses;
  final Timestamp? tglNotifikasi;
  String namaKlien;
  final String namaBarang;
  final String jumlahBarang;
  final String satuan;
  final String catatan;
  final String gambar;
  final bool containsPictures;
  final bool prioritas;
  final bool selesai;

  Map<String, dynamic> toJson() {
    return {
      'id': namaBarang,
      'barang': barang,
      'tgl_edit': tglEdit,
      'tgl_proses': tglProses,
      'tgl_notifikasi': tglNotifikasi,
      'nama_klien': namaKlien,
      'nama_barang': namaBarang,
      'jumlah_barang': jumlahBarang,
      'catatan': catatan,
      'gambar': gambar,
      'prioritas': prioritas,
      'selesai': selesai,
    };
  }
}

class Product {
  Product({
    this.namaBarang = '',
    this.jumlahBarang = 0,
    this.satuan = '',
  });

  final String namaBarang;
  final int jumlahBarang;
  final String satuan;

  Map<String, dynamic> toMap() {
    return {
      'nama_barang': namaBarang,
      'jumlah_barang': jumlahBarang,
      'satuan': satuan,
    };
  }
}

class Client {
  Client({
    required this.id,
    this.namaKlien = '',
    this.email = '',
    this.noHp = '',
    this.alamat = '',
  });
  final String id;
  final String namaKlien;
  final String email;
  final String noHp;
  final String alamat;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_klien': namaKlien,
      'email': email,
      'no_hp': noHp,
      'alamat': alamat,
    };
  }

  ///this method will prevent the override of toString
  String userAsString() {
    return '#${this.id} ${this.namaKlien}';
  }

  ///custom comparing function to check if two users are equal
  bool isEqual(Client model) {
    return this.id == model.id;
  }

  @override
  String toString() => namaKlien;
}

class InboxEmail extends Email {
  InboxEmail({
    required super.id,
    required super.tglBuat,
    super.namaKlien,
    super.catatan,
    required super.gambar,
    super.containsPictures,
    this.inboxType = InboxType.normal,
  });

  InboxType inboxType;
}

// The different mailbox pages that the Reply app contains.
enum MailboxPageType {
  inbox,
  starred,
  sent,
  trash,
  spam,
  drafts,
}

// Different types of mail that can be sent to the inbox.
enum InboxType {
  normal,
  spam,
}
