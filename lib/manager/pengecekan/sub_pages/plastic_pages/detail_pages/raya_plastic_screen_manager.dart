import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/html.dart' as html;

// For CSV Export
List<List<String>> itemList = [];

class RayaPlasticScreenManager extends StatefulWidget {
  const RayaPlasticScreenManager({super.key});

  @override
  State<StatefulWidget> createState() => _RayaPlasticScreenManagerState();
}

class _RayaPlasticScreenManagerState extends State<RayaPlasticScreenManager> {
  final ScrollController _scrollController = ScrollController();

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  }

  void _scrollUp() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  }

  var itemsStatus = [
    "Belum Disetujui Manager",
    "Sudah Disetujui Manager",
  ];

  User? _user;

  @override
  void initState() {
    super.initState();

    itemList = [
      <String>[
        "Nama Part",
        "Nama Supplier",
        "Tanggal Kedatangan",
        "Warna Part",
        "Jumlah Total",
        "Tanggal Pengecekan",
        "Qty OK",
        "Qty NG",
        "Problem",
        "URL",
        "Tanggal Return",
        "Ditambahkan Oleh",
        "Diperiksa Oleh",
        "Catatan",
        "Status",
      ]
    ];

    // Retrieve logged in user data
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _user = user;
      });
    });
  }

  // Text fields controllers
  final TextEditingController _searchTextNamaPartController =
      TextEditingController();
  final TextEditingController _searchTextTanggalKedatanganController =
      TextEditingController();
  final TextEditingController _searchTextTanggalPengecekanController =
      TextEditingController();
  final TextEditingController _namaPartController = TextEditingController();
  final TextEditingController _namaSupplierController = TextEditingController();
  final TextEditingController _tanggalKedatanganController =
      TextEditingController();
  final TextEditingController _warnaPartController = TextEditingController();
  final TextEditingController _jumlahTotalController = TextEditingController();
  final TextEditingController _tanggalPengecekanController =
      TextEditingController();
  final TextEditingController _qtyOkController = TextEditingController();
  final TextEditingController _qtyNgController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _tanggalReturnController =
      TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  final TextEditingController _ditambahkanOlehController =
      TextEditingController();
  final TextEditingController _diperiksaOlehController =
      TextEditingController();

  // Firestore collection reference
  final CollectionReference _rayaPlasticParts =
      FirebaseFirestore.instance.collection("raya_plastic_parts");
  List<DocumentSnapshot> documents = [];

  Stream<QuerySnapshot<Map<String, dynamic>>> getDataFromFirestore() {
    return FirebaseFirestore.instance
        .collection('raya_plastic_parts')
        .orderBy("tanggalPengecekan", descending: true)
        .snapshots();
  }

  // Search text variable
  String searchTextNamaPart = "";
  String searchTextTanggalKedatangan = "";
  String searchTextTanggalPengecekan = "";

  // Linkify function
  Future<void> _onOpen(LinkableElement link) async {
    if (await canLaunchUrl(Uri.parse(link.url))) {
      await launchUrl(
        Uri.parse(link.url),
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw "Could not launch $link";
    }
  }

  // This function is triggered when floating button or one of the edit buttons is pressed
  // Adding a product if no documentSnapshot is passed
  // If documentSnapshot != null the update an existing product
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = "create";
    if (documentSnapshot != null) {
      action = "update";

      _namaPartController.text = documentSnapshot["namaPart"];
      _namaSupplierController.text = documentSnapshot["namaSupplier"];
      _tanggalKedatanganController.text = documentSnapshot["tanggalKedatangan"];
      _warnaPartController.text = documentSnapshot["warnaPart"];
      _jumlahTotalController.text = documentSnapshot["jumlahTotal"].toString();
      _tanggalPengecekanController.text = documentSnapshot["tanggalPengecekan"];
      _qtyOkController.text = documentSnapshot["qtyOk"].toString();
      _qtyNgController.text = documentSnapshot["qtyNg"].toString();
      _problemController.text = documentSnapshot["problem"];
      _urlController.text = documentSnapshot["url"];
      _tanggalReturnController.text = documentSnapshot["tanggalReturn"];
      _statusController.text = documentSnapshot["status"];
      _catatanController.text = documentSnapshot["catatan"];
      _ditambahkanOlehController.text = documentSnapshot["ditambahkanOleh"];
      _diperiksaOlehController.text = documentSnapshot["diperiksaOleh"];
    }

    await showModalBottomSheet(
      backgroundColor: Colors.yellow,
      enableDrag: true,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            // Prevent the soft keyboard from covering text fields
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 5,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 30,
                        ),
                        tooltip: "Tutup",
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      const Center(
                        child: Text(
                          "Review Data",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.lightBlue,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextField(
                                readOnly: true,
                                controller: _namaPartController,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  labelText: "Nama Part",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.lightBlue,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextField(
                                readOnly: true,
                                controller: _namaSupplierController,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  labelText: "Nama Supplier",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.lightBlue,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextField(
                                readOnly: true,
                                controller: _tanggalKedatanganController,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  labelText: "Tanggal Kedatangan",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.lightBlue,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextField(
                                readOnly: true,
                                controller: _warnaPartController,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  labelText: "Warna Part",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.lightBlue,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextField(
                                readOnly: true,
                                controller: _jumlahTotalController,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  labelText: "Jumlah Total",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.lightBlue,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextField(
                                readOnly: true,
                                controller: _tanggalPengecekanController,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  labelText: "Tanggal Pengecekan",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.lightBlue,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextField(
                                readOnly: true,
                                controller: _qtyOkController,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  labelText: "Qty (OK)",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.lightBlue,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextField(
                                readOnly: true,
                                controller: _qtyNgController,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  labelText: "Qty (NG)",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.lightBlue,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextField(
                                readOnly: true,
                                controller: _problemController,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  labelText: "Problem",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.lightBlue,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextField(
                                readOnly: true,
                                controller: _urlController,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  labelText: "URL",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.lightBlue,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextField(
                                readOnly: true,
                                controller: _tanggalReturnController,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  labelText: "Tanggal Return",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextField(
                            readOnly: true,
                            controller: _statusController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(20),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.green,
                                  width: 2,
                                ),
                              ),
                              labelText: "Status",
                              suffixIcon: PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                ),
                                tooltip: "Pilih",
                                onSelected: (String value) {
                                  _statusController.text = value;
                                },
                                itemBuilder: (BuildContext context) {
                                  return itemsStatus.map<PopupMenuItem<String>>(
                                      (String value) {
                                    return PopupMenuItem(
                                      value: value,
                                      child: Text(
                                        value,
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextField(
                            controller: _catatanController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(20),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.greenAccent,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.green,
                                  width: 2,
                                ),
                              ),
                              labelText: "Catatan",
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 50,
                                child: StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(_user?.uid) // ID OF DOCUMENT
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    var document = snapshot.data!;
                                    return OutlinedButton(
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          "Accept",
                                        ),
                                        onPressed: () async {
                                          AlertDialog confirm = AlertDialog(
                                            title: const Text(
                                              "Konfirmasi!",
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            content: const SizedBox(
                                              height: 100,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Apakah Anda yakin ingin memvalidasi data ini?",
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                onPressed: () async {
                                                  HapticFeedback.vibrate();
                                                  final String namaPart =
                                                      _namaPartController.text;
                                                  final String namaSupplier =
                                                      _namaSupplierController
                                                          .text;
                                                  final String
                                                      tanggalKedatangan =
                                                      _tanggalKedatanganController
                                                          .text;
                                                  final String warnaPart =
                                                      _warnaPartController.text;
                                                  final num? jumlahTotal =
                                                      num.tryParse(
                                                          _jumlahTotalController
                                                              .text);
                                                  final String
                                                      tanggalPengecekan =
                                                      _tanggalPengecekanController
                                                          .text;
                                                  final num? qtyOk =
                                                      num.tryParse(
                                                          _qtyOkController
                                                              .text);
                                                  final num? qtyNg =
                                                      num.tryParse(
                                                          _qtyNgController
                                                              .text);
                                                  final String problem =
                                                      _problemController.text;
                                                  final String url =
                                                      _urlController.text;
                                                  final String tanggalReturn =
                                                      _tanggalReturnController
                                                          .text;
                                                  final String status =
                                                      _statusController.text;
                                                  final String catatan =
                                                      _catatanController.text;
                                                  final String ditambahkanOleh =
                                                      _ditambahkanOlehController
                                                          .text;
                                                  final String diperiksaOleh =
                                                      _diperiksaOlehController
                                                              .text =
                                                          document["name"];

                                                  if (action == "update") {
                                                    // Update the product
                                                    await _rayaPlasticParts
                                                        .doc(documentSnapshot!
                                                            .id)
                                                        .set({
                                                      "namaPart": namaPart,
                                                      "namaSupplier":
                                                          namaSupplier,
                                                      "tanggalKedatangan":
                                                          tanggalKedatangan,
                                                      "warnaPart": warnaPart,
                                                      "jumlahTotal":
                                                          jumlahTotal,
                                                      "tanggalPengecekan":
                                                          tanggalPengecekan,
                                                      "qtyOk": qtyOk,
                                                      "qtyNg": qtyNg,
                                                      "problem": problem,
                                                      "url": url,
                                                      "tanggalReturn":
                                                          tanggalReturn,
                                                      "status": status,
                                                      "catatan": catatan,
                                                      "ditambahkanOleh":
                                                          ditambahkanOleh,
                                                      "diperiksaOleh":
                                                          diperiksaOleh,
                                                    });
                                                  }

                                                  // Show a snackbar
                                                  if (!mounted) return;
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      backgroundColor:
                                                          Colors.blue,
                                                      content: Text(
                                                        "Successfully accept data!",
                                                      ),
                                                    ),
                                                  );
                                                  if (!mounted) return;
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  "Ya",
                                                ),
                                              ),
                                              TextButton(
                                                child: const Text(
                                                  "Tidak",
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          );
                                          showDialog(
                                            context: context,
                                            builder: (context) => confirm,
                                          );
                                        });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lime,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Hero(
              tag: "gesits-logo-raya",
              child: Image.asset(
                "assets/images/gesits-logo.png",
                width: 80,
              ),
            ),
            const Text(
              "Raya",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size(0, 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order By",
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Descending",
                  ),
                ],
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    " : ",
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    " : ",
                  ),
                ],
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tanggal Pengecekan",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "True",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    tooltip: "Download",
                    icon: const Icon(
                      Icons.file_download,
                    ),
                    onPressed: () {
                      AlertDialog download = AlertDialog(
                        title: const Text(
                          "Download!",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: const SizedBox(
                          height: 100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Apakah Anda ingin mengexport data ini?",
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              generateCsv();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.purple,
                                  content: Text(
                                    "GESITS Raya Plastic Parts was exported to Download folder!",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Ya",
                            ),
                          ),
                          TextButton(
                            child: const Text(
                              "Tidak",
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                      showDialog(
                        context: context,
                        builder: (context) => download,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
          tooltip: "Kembali",
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.black,
              ),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.cyan,
                Color.fromARGB(
                  200,
                  30,
                  220,
                  190,
                ),
              ],
            ),
          ),
          child: ListView(
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                        ),
                        gradient: const LinearGradient(
                          colors: [
                            Colors.teal,
                            Color.fromARGB(
                              200,
                              30,
                              220,
                              190,
                            ),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                    "Cari data berdasarkan:",
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    "• Nama Part",
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    "• Hari/Bulan/Tahun Kedatangan",
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    "• Hari/Bulan/Tahun Pengecekan",
                                  ),
                                ],
                              ),
                            ),
                            Card(
                              color: Colors.white70,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: TextField(
                                  controller: _searchTextNamaPartController,
                                  onChanged: (value) {
                                    setState(() {
                                      searchTextNamaPart = value;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    hintText: "Masukkan Nama Part",
                                    labelText: "Nama Part",
                                    prefixIcon: Icon(
                                      Icons.search,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              color: Colors.white70,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: TextField(
                                  inputFormatters: <TextInputFormatter>[
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  controller:
                                      _searchTextTanggalKedatanganController,
                                  onChanged: (value) {
                                    setState(() {
                                      searchTextTanggalKedatangan = value;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    hintText: "yyyy-MM-dd",
                                    labelText: "Tanggal Kedatangan",
                                    prefixIcon: Icon(
                                      Icons.search,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              color: Colors.white70,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: TextField(
                                  inputFormatters: <TextInputFormatter>[
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  controller:
                                      _searchTextTanggalPengecekanController,
                                  onChanged: (value) {
                                    setState(() {
                                      searchTextTanggalPengecekan = value;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    hintText: "yyyy-MM-dd",
                                    labelText: "Tanggal Pengecekan",
                                    prefixIcon: Icon(
                                      Icons.search,
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
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: const Text(
                          "GESITS Raya Plastic Parts",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 2,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ],
                            color: Colors.lightGreen,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: Center(
                          child: Image.asset(
                            "assets/images/img-raya.png",
                            width: 120,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Image.asset(
                              "assets/images/gesits-logo.png",
                              width: 200,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Image.asset(
                              "assets/images/wima-logo.png",
                              width: 200,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            tooltip: "Scroll Down",
            backgroundColor: Colors.yellow,
            onPressed: _scrollDown,
            child: const Icon(
              Icons.arrow_downward,
              color: Colors.blue,
            ),
          ),
          FloatingActionButton.small(
            tooltip: "Scroll Up",
            backgroundColor: Colors.blue,
            onPressed: _scrollUp,
            child: const Icon(
              Icons.arrow_upward,
              color: Colors.yellow,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          getDataFromFirestore();
        },
        child: StreamBuilder<QuerySnapshot>(
          stream: _rayaPlasticParts
              .orderBy("tanggalPengecekan", descending: true)
              .snapshots(),
          builder: (ctx, streamSnapshot) {
            if (streamSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              );
            }

            documents = (streamSnapshot.data!).docs;
            // ToDo Documents list added to filterTitle

            if (searchTextNamaPart.isNotEmpty) {
              documents = documents.where((element) {
                return element
                    .get("namaPart")
                    .toString()
                    .toLowerCase()
                    .contains(searchTextNamaPart.toLowerCase());
              }).toList();
            }

            if (searchTextTanggalKedatangan.isNotEmpty) {
              documents = documents.where((element) {
                return element
                    .get("tanggalKedatangan")
                    .toString()
                    .toLowerCase()
                    .contains(searchTextTanggalKedatangan.toLowerCase());
              }).toList();
            }

            if (searchTextTanggalPengecekan.isNotEmpty) {
              documents = documents.where((element) {
                return element
                    .get("tanggalPengecekan")
                    .toString()
                    .toLowerCase()
                    .contains(searchTextTanggalPengecekan.toLowerCase());
              }).toList();
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: documents.length,
              itemBuilder: (BuildContext context, int index) {
                final DocumentSnapshot documentSnapshot = documents[index];
                // Add the data to the itemList
                itemList.add(<String>[
                  documentSnapshot.get("namaPart"),
                  documentSnapshot.get("namaSupplier"),
                  documentSnapshot.get("tanggalKedatangan"),
                  documentSnapshot.get("warnaPart"),
                  documentSnapshot.get("jumlahTotal").toString(),
                  documentSnapshot.get("tanggalPengecekan"),
                  documentSnapshot.get("qtyOk").toString(),
                  documentSnapshot.get("qtyNg").toString(),
                  documentSnapshot.get("problem"),
                  documentSnapshot.get("url"),
                  documentSnapshot.get("tanggalReturn"),
                  documentSnapshot.get("ditambahkanOleh"),
                  documentSnapshot.get("diperiksaOleh"),
                  documentSnapshot.get("catatan"),
                  documentSnapshot.get("status"),
                ]);

                Map<String, double> dataMap = {
                  "Quantity (OK)": documentSnapshot["qtyOk"].toDouble(),
                  "Quantity (NG)": documentSnapshot["qtyNg"].toDouble(),
                };
                final colorList = <Color>[
                  Colors.blue,
                  Colors.red,
                ];
                return Padding(
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blueAccent,
                      ),
                      gradient: const LinearGradient(
                        colors: [
                          Colors.green,
                          Color.fromARGB(
                            200,
                            30,
                            220,
                            190,
                          ),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.blue,
                                    Color.fromARGB(
                                      200,
                                      30,
                                      220,
                                      190,
                                    ),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  "Document ID: ${documentSnapshot.id}",
                                  style: GoogleFonts.amiri(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white70,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: [
                                      // Press this button to edit a single product
                                      IconButton(
                                        tooltip: "Review",
                                        color: Colors.blue,
                                        icon: const Icon(
                                          Icons.remove_red_eye,
                                        ),
                                        onPressed: () =>
                                            _createOrUpdate(documentSnapshot),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Nama Part",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Nama Supplier",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Tanggal Kedatangan",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Warna Part",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Jumlah Total (OK + NG)",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Tanggal Pengecekan",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Qty (OK)",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Qty (NG)",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Problem",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "URL",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Tanggal Return",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const Column(
                                  children: [
                                    Text(
                                      " : ",
                                    ),
                                    Text(
                                      " : ",
                                    ),
                                    Text(
                                      " : ",
                                    ),
                                    Text(
                                      " : ",
                                    ),
                                    Text(
                                      " : ",
                                    ),
                                    Text(
                                      " : ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      " : ",
                                    ),
                                    Text(
                                      " : ",
                                    ),
                                    Text(
                                      " : ",
                                    ),
                                    Text(
                                      " : ",
                                    ),
                                    Text(
                                      " : ",
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      documentSnapshot["namaPart"],
                                    ),
                                    Text(
                                      documentSnapshot["namaSupplier"],
                                    ),
                                    Text(
                                      documentSnapshot["tanggalKedatangan"],
                                    ),
                                    Text(
                                      documentSnapshot["warnaPart"],
                                    ),
                                    Text(
                                      documentSnapshot["jumlahTotal"]
                                          .toString(),
                                    ),
                                    Text(
                                      documentSnapshot["tanggalPengecekan"],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      documentSnapshot["qtyOk"].toString(),
                                    ),
                                    Text(
                                      documentSnapshot["qtyNg"].toString(),
                                    ),
                                    Text(
                                      documentSnapshot["problem"],
                                    ),
                                    Linkify(
                                      onOpen: _onOpen,
                                      text: documentSnapshot["url"],
                                    ),
                                    Text(
                                      documentSnapshot["tanggalReturn"],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 2,
                                          ),
                                          color: Colors.yellow,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            top: 32,
                                            bottom: 32,
                                            left: 40,
                                            right: 40,
                                          ),
                                          child: PieChart(
                                            dataMap: dataMap,
                                            colorList: colorList,
                                            animationDuration: const Duration(
                                              milliseconds: 3200,
                                            ),
                                            chartLegendSpacing: 32,
                                            chartRadius: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3.2,
                                            initialAngleInDegree: 0,
                                            chartType: ChartType.disc,
                                            centerText: "Percentage",
                                            ringStrokeWidth: 32,
                                            legendOptions: const LegendOptions(
                                              showLegendsInRow: false,
                                              legendPosition:
                                                  LegendPosition.bottom,
                                              showLegends: true,
                                              legendShape: BoxShape.rectangle,
                                              legendTextStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            chartValuesOptions:
                                                const ChartValuesOptions(
                                              showChartValueBackground: true,
                                              showChartValues: true,
                                              showChartValuesInPercentage: true,
                                              showChartValuesOutside: true,
                                              decimalPlaces: 2,
                                            ),
                                            // gradientList: ---To add gradient colors---
                                            // emptyColorGradient: ---Empty Color gradient---
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white30,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.lightBlue,
                                          width: 2,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          children: [
                                            const Text(
                                              "Status",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white70,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Icon(
                                                      documentSnapshot[
                                                                  "status"] ==
                                                              "Belum Disetujui Manager"
                                                          ? Icons
                                                              .cancel_outlined
                                                          : Icons
                                                              .check_circle_outlined,
                                                      color: documentSnapshot[
                                                                  "status"] ==
                                                              "Belum Disetujui Manager"
                                                          ? Colors.red
                                                          : Colors.green,
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      documentSnapshot[
                                                          "status"],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 40,
                                ),
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white30,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.redAccent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          children: [
                                            const Text(
                                              "Ditambahkan Oleh",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white70,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: Text(
                                                  documentSnapshot[
                                                      "ditambahkanOleh"],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white30,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.yellowAccent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          children: [
                                            const Text(
                                              "Diperiksa Oleh",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white70,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      documentSnapshot[
                                                          "diperiksaOleh"],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white30,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.indigo,
                                          width: 2,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          children: [
                                            const Text(
                                              "Catatan Manager",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white70,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      documentSnapshot[
                                                          "catatan"],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

generateCsv() async {
  String csvData = const ListToCsvConverter().convert(itemList);
  DateTime now = DateTime.now();
  String formattedDate = DateFormat("yyyy-MM-dd-HH-mm-ss").format(now);

  if (kIsWeb) {
    final bytes = utf8.encode(csvData);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement("a") as html.AnchorElement
      ..href = url
      ..style.display = "none"
      ..download = "Raya_Plastic_Parts_$formattedDate.csv";
    html.document.body!.children.add(anchor);
    anchor.click();
    html.Url.revokeObjectUrl(url);
  } else if (Platform.isAndroid) {
    Directory generalDownloadDir = Directory("storage/emulated/0/Download");
    final File file = await (File(
            "${generalDownloadDir.path}/Raya_Plastic_Parts_$formattedDate.csv")
        .create());
    await file.writeAsString(csvData);
  }
}
