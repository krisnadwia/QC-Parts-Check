import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:qc_parts_check/graph_pages/raya_general_graph_screen.dart';
import 'package:qc_parts_check/support_pages/my_calculator.dart';
import 'package:qc_parts_check/support_pages/raya_supplier_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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

class RayaGeneralScreen extends StatefulWidget {
  const RayaGeneralScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RayaGeneralScreenState();
}

class _RayaGeneralScreenState extends State<RayaGeneralScreen> {
  var itemsNamaPart = [
    "",
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
    "",
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

  // Text fields controllers
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _namaPartController = TextEditingController();
  final TextEditingController _namaSupplierController = TextEditingController();
  final TextEditingController _tanggalKedatanganController = TextEditingController();
  final TextEditingController _jumlahTotalController = TextEditingController(text: "0");
  final TextEditingController _tanggalPemeriksaanController = TextEditingController();
  final TextEditingController _qtyOkController = TextEditingController(text: "0");
  final TextEditingController _qtyNgController = TextEditingController(text: "0");
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _tanggalReturnController = TextEditingController();

  // Firestore collection reference
  final CollectionReference _rayaGeneralParts = FirebaseFirestore.instance.collection("raya_general_parts");
  List<DocumentSnapshot> documents = [];

  // Search text variable
  String searchText = "";

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
      _tanggalPemeriksaanController.text = documentSnapshot["tanggalPemeriksaan"];
      _qtyOkController.text = documentSnapshot["qtyOk"].toString();
      _qtyNgController.text = documentSnapshot["qtyNg"].toString();
      _problemController.text = documentSnapshot["problem"];
      _urlController.text = documentSnapshot["url"];
      _tanggalReturnController.text = documentSnapshot["tanggalReturn"];
    }

    await showModalBottomSheet(
      backgroundColor: Colors.white,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 50,
            left: 5,
            right: 5,
            // Prevent the soft keyboard from covering text fields
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 5,
          ),
          child: SingleChildScrollView(
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
                    "Tambah/Update Data",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      "* Wajib diisi",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                TextField(
                  controller: _namaPartController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(20),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.greenAccent,
                        width: 2,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 2,
                      ),
                    ),
                    labelText: "Nama Part",
                    hintText: "Masukkan Nama Part",
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
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      "* Opsional",
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                TextField(
                  controller: _namaSupplierController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(20),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.greenAccent,
                        width: 2,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 2,
                      ),
                    ),
                    labelText: "Nama Supplier",
                    hintText: "Masukkan Nama Supplier",
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
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      "* Opsional",
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                TextField(
                  controller: _tanggalKedatanganController,
                  // Editing controller of this TextField
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(20),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.greenAccent,
                        width: 2,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 2,
                      ),
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
                    hintText: "Masukkan Tanggal Kedatangan",
                    labelText: "Tanggal Kedatangan", // Label text of field
                  ),
                  readOnly: true, // Set it true, so that user will not able to edit text
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      "* Wajib diisi",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                TextField(
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ], // Only numbers can be entered
                  keyboardType: TextInputType.number,
                  controller: _jumlahTotalController,
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
                        color: Colors.red,
                        width: 2,
                      ),
                    ),
                    labelText: "Jumlah Total",
                    hintText: "Masukkan Jumlah Total",
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      "* Wajib diisi",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                TextField(
                  controller: _tanggalPemeriksaanController,
                  // Editing controller of this TextField
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(20),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.greenAccent,
                        width: 2,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 2,
                      ),
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
                            _tanggalPemeriksaanController.text = formattedDate; // Set output date to TextField value.
                          });
                        } else {
                          if (kDebugMode) {
                            print("Date is not selected");
                          }
                        }
                      },
                    ),
                    hintText: "Masukkan Tanggal Pemeriksaan",
                    labelText: "Tanggal Pemeriksaan", // Label text of field
                  ),
                  readOnly: true, // Set it true, so that user will not able to edit text
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      "* Wajib diisi",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                TextField(
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ], // Only numbers can be entered
                  keyboardType: TextInputType.number,
                  controller: _qtyOkController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(20),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.greenAccent,
                        width: 2,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 2,
                      ),
                    ),
                    suffixIcon: IconButton(
                      tooltip: "Calculate",
                      icon: const Icon(
                        Icons.calculate_outlined,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const MyCalculator(),
                          ),
                        );
                      },
                    ),
                    labelText: "Qty (OK)",
                    hintText: "Masukkan Jumlah OK",
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      "* Wajib diisi",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                TextField(
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ], // Only numbers can be entered
                  keyboardType: TextInputType.number,
                  controller: _qtyNgController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(20),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.greenAccent,
                        width: 2,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 2,
                      ),
                    ),
                    suffixIcon: IconButton(
                      tooltip: "Calculate",
                      icon: const Icon(
                        Icons.calculate_outlined,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const MyCalculator(),
                          ),
                        );
                      },
                    ),
                    labelText: "Qty (NG)",
                    hintText: "Masukkan Jumlah NG",
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      "* Opsional",
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                TextField(
                  controller: _problemController,
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
                        color: Colors.red,
                        width: 2,
                      ),
                    ),
                    labelText: "Problem",
                    hintText: "Masukkan Keterangan Problem",
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      "* Opsional",
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                TextField(
                  controller: _urlController,
                  // Editing controller of this TextField
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(20),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.greenAccent,
                        width: 2,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 2,
                      ),
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
                    hintText: "Masukkan Link URL",
                    labelText: "URL", // Label text of field
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      "* Opsional",
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                TextField(
                  controller: _tanggalReturnController,
                  // Editing controller of this TextField
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(20),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.greenAccent,
                        width: 2,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 2,
                      ),
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
                    hintText: "Masukkan Tanggal Return",
                    labelText: "Tanggal Return", // Label text of field
                  ),
                  readOnly: true, // Set it true, so that user will not able to edit text
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
                      HapticFeedback.vibrate();
                      final String namaPart = _namaPartController.text;
                      final String namaSupplier = _namaSupplierController.text;
                      final String tanggalKedatangan = _tanggalKedatanganController.text;
                      final num? jumlahTotal = num.tryParse(_jumlahTotalController.text);
                      final String tanggalPemeriksaan = _tanggalPemeriksaanController.text;
                      final num? qtyOk = num.tryParse(_qtyOkController.text);
                      final num? qtyNg = num.tryParse(_qtyNgController.text);
                      final String problem = _problemController.text;
                      final String url = _urlController.text;
                      final String tanggalReturn = _tanggalReturnController.text;

                      if (action == "create") {
                        // Persist a new product to Firestore
                        await _rayaGeneralParts.add({
                          "namaPart": namaPart,
                          "namaSupplier": namaSupplier,
                          "tanggalKedatangan": tanggalKedatangan,
                          "jumlahTotal": jumlahTotal,
                          "tanggalPemeriksaan": tanggalPemeriksaan,
                          "qtyOk": qtyOk,
                          "qtyNg": qtyNg,
                          "problem": problem,
                          "url": url,
                          "tanggalReturn": tanggalReturn,
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
                          "tanggalPemeriksaan": tanggalPemeriksaan,
                          "qtyOk": qtyOk,
                          "qtyNg": qtyNg,
                          "problem": problem,
                          "url": url,
                          "tanggalReturn": tanggalReturn,
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
                      _jumlahTotalController.text = "0";
                      _tanggalPemeriksaanController.text = "";
                      _qtyOkController.text = "0";
                      _qtyNgController.text = "0";
                      _problemController.text = "";
                      _urlController.text = "";
                      _tanggalReturnController.text = "";

                      if (!mounted) return;
                      // Hide the bottom sheet
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
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
          ],
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
          const Text(
            "Raya",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            color: Colors.black,
            icon: const Icon(
              Icons.auto_graph_outlined,
            ),
            tooltip: "Graph",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RayaGeneralGraphScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: "Cari Supplier Part",
            icon: const Icon(
              Icons.content_paste_search,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RayaSupplierScreen(),
                ),
              );
            },
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(
                Icons.filter_list,
                color: Colors.black,
              ),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
          ),
        ],
      ),

      // Add new data
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          // Clear the text fields
          _namaPartController.text = "";
          _namaSupplierController.text = "";
          _tanggalKedatanganController.text = "";
          _jumlahTotalController.text = "0";
          _tanggalPemeriksaanController.text = "";
          _qtyOkController.text = "0";
          _qtyNgController.text = "0";
          _problemController.text = "";
          _urlController.text = "";
          _tanggalReturnController.text = "";
          _createOrUpdate();
        },
        foregroundColor: Colors.white,
        tooltip: "Create",
        child: const Icon(
          Icons.add_rounded,
          size: 32,
        ),
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
                  child: Column(
                    children: [
                      const Text(
                        "Cari data berdasarkan Tanggal Pemeriksaan",
                      ),
                      const Text(
                        "(format: yyyy-MM-dd)",
                      ),
                      Card(
                        color: Colors.white70,
                        child: TextField(
                          autofocus: false,
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              searchText = value;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: "Tanggal Pemeriksaan",
                            prefixIcon: Icon(
                              Icons.search,
                            ),
                          ),
                        ),
                      ),
                    ],
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

      body: StreamBuilder<QuerySnapshot>(
        stream: _rayaGeneralParts
            .orderBy("tanggalPemeriksaan", descending: true)
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
          if (searchText.isNotEmpty) {
            documents = documents.where((element) {
              return element
                  .get("tanggalPemeriksaan")
                  .toString()
                  .toLowerCase()
                  .contains(searchText.toLowerCase());
            }).toList();
          }

          return ListView.separated(
            shrinkWrap: true,
            itemCount: documents.length,
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
            itemBuilder: (BuildContext context, int index) {
              final DocumentSnapshot documentSnapshot = documents[index];
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
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
                                  "Jumlah Total",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Tanggal Pemeriksaan",
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
                            Column(
                              children: const [
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
                                  documentSnapshot["tanggalPemeriksaan"],
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
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white60,
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
                            const SizedBox(
                              width: 40,
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
                                            children: [
                                              Text(
                                                "Yakin ingin menghapus data '${documentSnapshot["namaPart"]}' ?",
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
    );
  }
}
