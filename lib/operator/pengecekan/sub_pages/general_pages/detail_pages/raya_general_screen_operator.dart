import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:csv/csv.dart';
import 'package:universal_html/html.dart' as html;

// For CSV Export
List<List<String>> itemList = [];

// URL function
_launchURL() async {
  const url = "https://postimages.org";
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  } else {
    throw "Could not launch $url";
  }
}

class RayaGeneralScreenOperator extends StatefulWidget {
  const RayaGeneralScreenOperator({super.key});

  @override
  State<StatefulWidget> createState() => _RayaGeneralScreenOperatorState();
}

class _RayaGeneralScreenOperatorState extends State<RayaGeneralScreenOperator> {
  var itemsNamaPart = [
    "Bearing Front Wheel",
    "Bearing Rear Wheel",
    "Bis JF",
    "Clamp Cable",
    "Flag Emblem",
    "Front Brake Pad",
    "Front Brake System",
    "GESITS Text Emblem",
    "Hinge Cushion",
    "Mirror LH",
    "Mirror RH",
    "Rear Brake Pad",
    "Rear Brake System",
    "Seat Assy",
    "Seat Lock",
    "Seat Lock Cable",
    "Spacer 11,2",
    "Spacer 13,7",
    "Spacer 24,2",
    "Spacer 60",
    "Spacer 75,5",
    "Spacer 97",
    "Spring Double Stand",
    "Spring Single Stand",
    "Sticker Perhatian",
    "Sticker Safety Breaker",
    "Sticker Tegangan Tinggi",
    "Sticker Tekanan Ban",
    "Valve Rim",
  ];

  var itemsNamaSupplier = [
    "PT WIKA Industri & Konstruksi",
    "PT Art Wire",
    "PT Niko Cahaya Elektrik",
    "PT PINDAD",
    "PT SUP",
    "PT NKP",
    "GEMATIC Co.,Ltd",
    "PT MAXXIS",
    "PT BATAVIA",
    "PT FANDILA",
    "PT YOKATA",
    "PT Ganding Toolsindo",
    "PT Rizki Dasa Prakasa",
  ];

  User? _user;

  @override
  void initState() {
    super.initState();

    itemList = [<String>[
      "Nama Part",
      "Nama Supplier",
      "Tanggal Kedatangan",
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
    ]];

    // Retrieve logged in user data
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _user = user;
      });
    });

    _qtyOkController.addListener(calculateSum);
    _qtyNgController.addListener(calculateSum);
  }

  void calculateSum() {
    final num qtyOk = num.tryParse(_qtyOkController.text) ?? 0;
    final num qtyNg = num.tryParse(_qtyNgController.text) ?? 0;
    final num result = qtyOk + qtyNg;
    _jumlahTotalController.text = result.toString();
  }

  @override
  void dispose() {
    _qtyOkController.dispose();
    _qtyNgController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  // Text fields controllers
  final TextEditingController _searchTextNamaPartController = TextEditingController();
  final TextEditingController _searchTextTanggalKedatanganController = TextEditingController();
  final TextEditingController _searchTextTanggalPengecekanController = TextEditingController();
  final TextEditingController _namaPartController = TextEditingController();
  final TextEditingController _namaSupplierController = TextEditingController();
  final TextEditingController _tanggalKedatanganController = TextEditingController();
  final TextEditingController _jumlahTotalController = TextEditingController();
  final TextEditingController _tanggalPengecekanController = TextEditingController();
  final TextEditingController _qtyOkController = TextEditingController();
  final TextEditingController _qtyNgController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _tanggalReturnController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  final TextEditingController _ditambahkanOlehController = TextEditingController();
  final TextEditingController _diperiksaOlehController = TextEditingController();

  // Firestore collection reference
  final CollectionReference _rayaGeneralParts = FirebaseFirestore.instance.collection("raya_general_parts");
  List<DocumentSnapshot> documents = [];

  Stream<QuerySnapshot<Map<String, dynamic>>> getDataFromFirestore() {
    return FirebaseFirestore.instance.collection('raya_general_parts').orderBy("tanggalPengecekan", descending: true).snapshots();
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
                      Center(
                        child: Text(
                          action == "create"
                              ? "Tambah Data"
                              : "Update Data",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: action == "create"
                                ? Colors.blue
                                : Colors.indigo,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
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
                                child: Column(
                                  children: [
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "   * Wajib diisi",
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                        Text(
                                          "Pilih   ↓",
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      // The validator receives the text that the user has entered.
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Nama Part tidak boleh kosong!';
                                        }
                                        return null;
                                      },
                                      controller: _namaPartController,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(10),
                                        labelText: "Nama Part",
                                        hintText: "Masukkan Nama Part",
                                        prefixIcon: IconButton(
                                          onPressed: _namaPartController.clear,
                                          icon: const Icon(Icons.clear),
                                        ),
                                        suffixIcon: PopupMenuButton<String>(
                                          icon: const Icon(
                                            Icons.arrow_drop_down,
                                          ),
                                          tooltip: "Pilih",
                                          onSelected: (String value) {
                                            _namaPartController.text = value;
                                          },
                                          itemBuilder: (BuildContext context) {
                                            return itemsNamaPart.map<PopupMenuItem<String>>((String value) {
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
                                  ],
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
                                child: Column(
                                  children: [
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "   * Opsional",
                                          style: TextStyle(
                                            color: Colors.green,
                                          ),
                                        ),
                                        Text(
                                          "Pilih   ↓",
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      controller: _namaSupplierController,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(10),
                                        labelText: "Nama Supplier",
                                        hintText: "Masukkan Nama Supplier",
                                        prefixIcon: IconButton(
                                          onPressed: _namaSupplierController.clear,
                                          icon: const Icon(Icons.clear),
                                        ),
                                        suffixIcon: PopupMenuButton<String>(
                                          icon: const Icon(
                                            Icons.arrow_drop_down,
                                          ),
                                          tooltip: "Pilih",
                                          onSelected: (String value) {
                                            _namaSupplierController.text = value;
                                          },
                                          itemBuilder: (BuildContext context) {
                                            return itemsNamaSupplier.map<PopupMenuItem<String>>((String value) {
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
                                  ],
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
                                child: Column(
                                  children: [
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "   * Wajib diisi",
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                        Text(
                                          "Pilih   ↓",
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      readOnly: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Tanggal Kedatangan tidak boleh kosong!';
                                        }
                                        return null;
                                      },
                                      controller: _tanggalKedatanganController,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(10),
                                        labelText: "Tanggal Kedatangan",
                                        hintText: "Masukkan Tanggal Kedatangan",
                                        prefixIcon: IconButton(
                                          onPressed: _tanggalKedatanganController.clear,
                                          icon: const Icon(Icons.clear),
                                        ),
                                        suffixIcon: IconButton(
                                          tooltip: "Pilih",
                                          icon: const Icon(
                                            Icons.calendar_today,
                                          ),
                                          onPressed: () async {
                                            DateTime? pickedDate = await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2000),
                                              // DateTime.now() - not to allow to choose before today.
                                              lastDate: DateTime(2101),
                                            );

                                            if (pickedDate != null) {
                                              if (kDebugMode) {
                                                print(pickedDate);
                                              } // pickedDate output format => 2021-03-10 00:00:00.000
                                              String formattedDate = DateFormat("yyyy-MM-dd").format(pickedDate);
                                              if (kDebugMode) {
                                                print(formattedDate);
                                              } // Formatted date output using intl package =>  2021-03-16
                                              // You can implement different kind of Date Format here according to your requirement

                                              setState(() {
                                                _tanggalKedatanganController.text = formattedDate; // Set output date to TextField value.
                                              });
                                            } else {
                                              if (kDebugMode) {
                                                print("Date is not selected");
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
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
                                child: Column(
                                  children: [
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "   * Otomatis",
                                          style: TextStyle(
                                            color: Colors.cyan,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextField(
                                      readOnly: true,
                                      controller: _jumlahTotalController,
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.all(10),
                                        labelText: "Jumlah Total (OK + NG)",
                                        hintText: "OK + NG",
                                        prefixIcon: Icon(
                                          Icons.settings_suggest_sharp
                                        ),
                                      ),
                                    ),
                                  ],
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
                                child: Column(
                                  children: [
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "   * Wajib diisi",
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                        Text(
                                          "Pilih   ↓",
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      readOnly: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Tanggal Pengecekan tidak boleh kosong!';
                                        }
                                        return null;
                                      },
                                      controller: _tanggalPengecekanController,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(10),
                                        labelText: "Tanggal Pengecekan",
                                        hintText: "Masukkan Tanggal Pengecekan",
                                        prefixIcon: IconButton(
                                          onPressed: _tanggalPengecekanController.clear,
                                          icon: const Icon(Icons.clear),
                                        ),
                                        suffixIcon: IconButton(
                                          tooltip: "Pilih",
                                          icon: const Icon(
                                            Icons.calendar_today_outlined,
                                          ),
                                          onPressed: () async {
                                            DateTime? pickedDate = await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2000),
                                              // DateTime.now() - not to allow to choose before today.
                                              lastDate: DateTime(2101),
                                            );

                                            if (pickedDate != null) {
                                              if (kDebugMode) {
                                                print(pickedDate);
                                              } // pickedDate output format => 2021-03-10 00:00:00.000
                                              String formattedDate = DateFormat("yyyy-MM-dd").format(pickedDate);
                                              if (kDebugMode) {
                                                print(formattedDate);
                                              } // Formatted date output using intl package =>  2021-03-16
                                              // You can implement different kind of Date Format here according to your requirement

                                              setState(() {
                                                _tanggalPengecekanController.text = formattedDate; // Set output date to TextField value.
                                              });
                                            } else {
                                              if (kDebugMode) {
                                                print("Date is not selected");
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
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
                                child: Column(
                                  children: [
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "   * Wajib diisi",
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Jumlah OK tidak boleh kosong!';
                                        }
                                        return null;
                                      },
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly,
                                      ], // Only numbers can be entered
                                      keyboardType: TextInputType.number,
                                      controller: _qtyOkController,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(10),
                                        labelText: "Qty (OK)",
                                        hintText: "Masukkan Jumlah OK",
                                        prefixIcon: IconButton(
                                          onPressed: _qtyOkController.clear,
                                          icon: const Icon(Icons.clear),
                                        ),
                                      ),
                                    ),
                                  ],
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
                                child: Column(
                                  children: [
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "   * Wajib diisi",
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Jumlah NG tidak boleh kosong!';
                                        }
                                        return null;
                                      },
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly,
                                      ], // Only numbers can be entered
                                      keyboardType: TextInputType.number,
                                      controller: _qtyNgController,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(10),
                                        labelText: "Qty (NG)",
                                        hintText: "Masukkan Jumlah NG",
                                        prefixIcon: IconButton(
                                          onPressed: _qtyNgController.clear,
                                          icon: const Icon(Icons.clear),
                                        ),
                                      ),
                                    ),
                                  ],
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
                                child: Column(
                                  children: [
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "   * Opsional",
                                          style: TextStyle(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      controller: _problemController,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(10),
                                        labelText: "Problem",
                                        hintText: "Masukkan Keterangan Problem",
                                        prefixIcon: IconButton(
                                          onPressed: _problemController.clear,
                                          icon: const Icon(Icons.clear),
                                        ),
                                      ),
                                    ),
                                  ],
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
                                child: Column(
                                  children: [
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "   * Opsional",
                                          style: TextStyle(
                                            color: Colors.green,
                                          ),
                                        ),
                                        Text(
                                          "Upload   ↓",
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      controller: _urlController,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(10),
                                        labelText: "URL",
                                        hintText: "Masukkan Link URL",
                                        prefixIcon: IconButton(
                                          onPressed: _urlController.clear,
                                          icon: const Icon(Icons.clear),
                                        ),
                                        suffixIcon: IconButton(
                                          tooltip: "Upload",
                                          icon: const Icon(
                                            Icons.cloud_upload,
                                          ),
                                          onPressed: () async {
                                            _launchURL();
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
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
                                child: Column(
                                  children: [
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "   * Opsional",
                                          style: TextStyle(
                                            color: Colors.green,
                                          ),
                                        ),
                                        Text(
                                          "Pilih   ↓",
                                        ),
                                      ],
                                    ),
                                    TextField(
                                      readOnly: true,
                                      controller: _tanggalReturnController,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(10),
                                        labelText: "Tanggal Return",
                                        hintText: "Masukkan Tanggal Return",
                                        prefixIcon: IconButton(
                                          onPressed: _tanggalReturnController.clear,
                                          icon: const Icon(Icons.clear),
                                        ),
                                        suffixIcon: IconButton(
                                          tooltip: "Pilih",
                                          icon: const Icon(
                                            Icons.calendar_month_outlined,
                                          ),
                                          onPressed: () async {
                                            DateTime? pickedDate = await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2000),
                                              // DateTime.now() - not to allow to choose before today.
                                              lastDate: DateTime(2101),
                                            );

                                            if (pickedDate != null) {
                                              if (kDebugMode) {
                                                print(pickedDate);
                                              } // pickedDate output format => 2021-03-10 00:00:00.000
                                              String formattedDate = DateFormat("yyyy-MM-dd").format(pickedDate);
                                              if (kDebugMode) {
                                                print(formattedDate);
                                              } // Formatted date output using intl package =>  2021-03-16
                                              // You can implement different kind of Date Format here according to your requirement

                                              setState(() {
                                                _tanggalReturnController.text = formattedDate; // Set output date to TextField value.
                                              });
                                            } else {
                                              if (kDebugMode) {
                                                print("Date is not selected");
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: 100,
                              height: 50,
                              child: OutlinedButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  action == "create"
                                      ? "Create"
                                      : "Update",
                                  style: TextStyle(
                                    color: action == "create"
                                        ? Colors.blue
                                        : Colors.indigo,
                                  ),
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
                                    content: SizedBox(
                                      height: 100,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            action == "create"
                                                ? "Apakah Anda yakin ingin menambah data ini?"
                                                : "Apakah Anda yakin ingin mengubah data ini?",
                                            style: TextStyle(
                                              color: action == "create"
                                                  ? Colors.blue
                                                  : Colors.indigo,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          // Validate returns true if the form is valid, or false otherwise.
                                          if (_formKey.currentState!.validate()) {
                                            HapticFeedback.vibrate();
                                            final String namaPart = _namaPartController.text;
                                            final String namaSupplier = _namaSupplierController.text;
                                            final String tanggalKedatangan = _tanggalKedatanganController.text;
                                            final num? jumlahTotal = num.tryParse(_jumlahTotalController.text);
                                            final String tanggalPengecekan = _tanggalPengecekanController.text;
                                            final num? qtyOk = num.tryParse(_qtyOkController.text);
                                            final num? qtyNg = num.tryParse(_qtyNgController.text);
                                            final String problem = _problemController.text;
                                            final String url = _urlController.text;
                                            final String tanggalReturn = _tanggalReturnController.text;
                                            final String status = _statusController.text;
                                            final String catatan = _catatanController.text;
                                            final String ditambahkanOleh = _ditambahkanOlehController.text;
                                            final String diperiksaOleh = _diperiksaOlehController.text;

                                            if (action == "create") {
                                              // Persist a new product to Firestore
                                              await _rayaGeneralParts.add({
                                                "namaPart": namaPart,
                                                "namaSupplier": namaSupplier,
                                                "tanggalKedatangan": tanggalKedatangan,
                                                "jumlahTotal": jumlahTotal,
                                                "tanggalPengecekan": tanggalPengecekan,
                                                "qtyOk": qtyOk,
                                                "qtyNg": qtyNg,
                                                "problem": problem,
                                                "url": url,
                                                "tanggalReturn": tanggalReturn,
                                                "status": status,
                                                "catatan": catatan,
                                                "ditambahkanOleh": ditambahkanOleh,
                                                "diperiksaOleh": diperiksaOleh,
                                              });
                                            }

                                            if (action == "update") {
                                              // Update the product
                                              await _rayaGeneralParts
                                                  .doc(documentSnapshot!.id)
                                                  .set({
                                                "namaPart": namaPart,
                                                "namaSupplier": namaSupplier,
                                                "tanggalKedatangan": tanggalKedatangan,
                                                "jumlahTotal": jumlahTotal,
                                                "tanggalPengecekan": tanggalPengecekan,
                                                "qtyOk": qtyOk,
                                                "qtyNg": qtyNg,
                                                "problem": problem,
                                                "url": url,
                                                "tanggalReturn": tanggalReturn,
                                                "status": status,
                                                "catatan" : catatan,
                                                "ditambahkanOleh": ditambahkanOleh,
                                                "diperiksaOleh": diperiksaOleh,
                                              });
                                            }

                                            // Show a snackbar
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                backgroundColor: action == "create"
                                                    ? Colors.yellow
                                                    : Colors.grey,
                                                content: Text(
                                                  action == "create"
                                                      ? "Successfully create data!"
                                                      : "Successfully update data!",
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            );

                                            // Clear the text fields
                                            _namaPartController.text = "";
                                            _namaSupplierController.text = "";
                                            _tanggalKedatanganController.text = "";
                                            _jumlahTotalController.text = "";
                                            _tanggalPengecekanController.text = "";
                                            _qtyOkController.text = "";
                                            _qtyNgController.text = "";
                                            _problemController.text = "";
                                            _urlController.text = "";
                                            _tanggalReturnController.text = "";

                                            if (!mounted) return;
                                            // Hide the bottom sheet
                                            Navigator.of(context).pop();
                                            Navigator.pop(context);
                                          }
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
                                },
                              ),
                            ),
                          ],
                        ),
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

  // Deleting a product by id
  Future<void> _deleteProduct(String productId) async {
    await _rayaGeneralParts.doc(productId).delete();

    if (!mounted) return;
    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "Successfully delete data!",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
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
                                "Apakah Anda ingin mendownload data ini?",
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
                                    "GESITS Raya General Parts was exported to Download folder!",
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
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(_user?.uid) // ID OF DOCUMENT
                .snapshots(),
            builder: (context, snapshot) {
              var document = snapshot.data;
              return IconButton(
                  tooltip: "Create",
                  icon: const Icon(
                    Icons.add,
                  ),
                  onPressed: () {
                    // Clear the text fields
                    _namaPartController.text = "";
                    _namaSupplierController.text = "";
                    _tanggalKedatanganController.text = "";
                    _jumlahTotalController.text = "";
                    _tanggalPengecekanController.text = "";
                    _qtyOkController.text = "";
                    _qtyNgController.text = "";
                    _problemController.text = "";
                    _urlController.text = "";
                    _tanggalReturnController.text = "";
                    _statusController.text = "Belum Disetujui Manager";
                    _catatanController.text = "";
                    _ditambahkanOlehController.text = document?["name"];
                    _diperiksaOlehController.text = "";
                    _createOrUpdate();
                  }
              );
            },
          ),
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
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
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
                                controller: _searchTextTanggalKedatanganController,
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
                                controller: _searchTextTanggalPengecekanController,
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
                        "GESITS Raya General Parts",
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

      body: RefreshIndicator(
        onRefresh: () async {
          getDataFromFirestore();
        },
        child: StreamBuilder<QuerySnapshot>(
          stream: _rayaGeneralParts
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
              itemCount: documents.length,
              itemBuilder: (BuildContext context, int index) {
                final DocumentSnapshot documentSnapshot = documents[index];
                // Add the data to the itemList
                itemList.add(<String>[
                  documentSnapshot.get("namaPart"),
                  documentSnapshot.get("namaSupplier"),
                  documentSnapshot.get("tanggalKedatangan"),
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
                return Card(
                  margin: const EdgeInsets.all(8),
                  color: Colors.tealAccent,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.deepPurpleAccent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                      tooltip: "Update",
                                      color: Colors.orange,
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                      ),
                                      onPressed: () => _createOrUpdate(documentSnapshot),
                                    ),
                                    const SizedBox(
                                      height: 40,
                                    ),
                                    // This icon button is used to delete a single product
                                    IconButton(
                                      tooltip: "Delete",
                                      color: Colors.red,
                                      icon: const Icon(
                                        Icons.delete_outline,
                                      ),
                                      onPressed: () {
                                        // Create a delete confirmation dialog
                                        AlertDialog delete = AlertDialog(
                                          title: const Text(
                                            "Peringatan!",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          content: SizedBox(
                                            height: 200,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Yakin ingin menghapus data *${documentSnapshot["namaPart"]}* ?",
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () {
                                                _deleteProduct(documentSnapshot.id);
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
                                          builder: (context) => delete,
                                        );
                                      },
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
                                    documentSnapshot["jumlahTotal"].toString(),
                                  ),
                                  Text(
                                    documentSnapshot["tanggalPengecekan"],
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
                                        image: const DecorationImage(
                                          image: AssetImage(
                                            "assets/images/gradient.gif",
                                          ),
                                          fit: BoxFit.fill,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
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
                                          chartRadius: MediaQuery.of(context).size.width / 3.2,
                                          initialAngleInDegree: 0,
                                          chartType: ChartType.disc,
                                          centerText: "Percentage",
                                          ringStrokeWidth: 32,
                                          legendOptions: const LegendOptions(
                                            showLegendsInRow: false,
                                            legendPosition: LegendPosition.bottom,
                                            showLegends: true,
                                            legendShape: BoxShape.rectangle,
                                            legendTextStyle: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          chartValuesOptions: const ChartValuesOptions(
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
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Icon(
                                                    documentSnapshot["status"] == "Belum Disetujui Manager"
                                                        ? Icons.cancel_outlined
                                                        : Icons.check_circle_outlined,
                                                    color: documentSnapshot["status"] == "Belum Disetujui Manager"
                                                        ? Colors.red
                                                        : Colors.green,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    documentSnapshot["status"],
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
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Text(
                                                documentSnapshot["ditambahkanOleh"],
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
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    documentSnapshot["diperiksaOleh"],
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
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    documentSnapshot["catatan"],
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
    final anchor = html.document.createElement("a") as html.AnchorElement..href = url..style.display = "none"..download = "Raya_General_Parts_$formattedDate.csv";
    html.document.body!.children.add(anchor);
    anchor.click();
    html.Url.revokeObjectUrl(url);
  }

  else if (Platform.isAndroid) {
    Directory generalDownloadDir = Directory("storage/emulated/0/Download");
    final File file = await (File(
        "${generalDownloadDir.path}/Raya_General_Parts_$formattedDate.csv"
    ).create());
    await file.writeAsString(csvData);
  }
}
