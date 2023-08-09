import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;

// For CSV Export
List<List<String>> itemList = [];

class RayaSupplierScreenOperator extends StatefulWidget {
  const RayaSupplierScreenOperator({super.key});

  @override
  State<StatefulWidget> createState() => _RayaSupplierScreenOperatorState();
}

class _RayaSupplierScreenOperatorState extends State<RayaSupplierScreenOperator> {
  var itemsJenisPart = [
    "Metal Part",
    "Plastic Part",
    "General Part",
    "Electric Part",
  ];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    itemList = [<String>[
      "Nama Part",
      "Kode Part",
      "Jenis Part",
      "Nama Supplier",
    ]];
  }

  // Text fields controllers
  final TextEditingController _searchTextNamaPartController = TextEditingController();
  final TextEditingController _searchTextKodePartController = TextEditingController();
  final TextEditingController _searchTextJenisPartController = TextEditingController();
  final TextEditingController _searchTextNamaSupplierController = TextEditingController();
  final TextEditingController _namaPartController = TextEditingController();
  final TextEditingController _kodePartController = TextEditingController();
  final TextEditingController _jenisPartController = TextEditingController();
  final TextEditingController _namaSupplierController = TextEditingController();

  // Firestore collection reference
  final CollectionReference _rayaSupplier = FirebaseFirestore.instance.collection("raya_supplier");
  List<DocumentSnapshot> documents = [];

  Stream<QuerySnapshot<Map<String, dynamic>>> getDataFromFirestore() {
    return FirebaseFirestore.instance.collection('raya_supplier').orderBy("namaPart", descending: false).snapshots();
  }

  // Search text variable
  String searchTextNamaPart = "";
  String searchTextKodePart = "";
  String searchTextJenisPart = "";
  String searchTextNamaSupplier = "";

  // This function is triggered when floating button or one of the edit buttons is pressed
  // Adding a product if no documentSnapshot is passed
  // If documentSnapshot != null the update an existing product
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = "create";
    if (documentSnapshot != null) {
      action = "update";

      _namaPartController.text = documentSnapshot["namaPart"];
      _kodePartController.text = documentSnapshot["kodePart"];
      _jenisPartController.text = documentSnapshot["jenisPart"];
      _namaSupplierController.text = documentSnapshot["namaSupplier"];
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
                                      // The validator receives the text that the user has entered.
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Kode Part tidak boleh kosong!';
                                        }
                                        return null;
                                      },
                                      controller: _kodePartController,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(10),
                                        labelText: "Kode Part",
                                        hintText: "Masukkan Kode Part",
                                        prefixIcon: IconButton(
                                          onPressed: _kodePartController.clear,
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
                                      // The validator receives the text that the user has entered.
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Jenis Part tidak boleh kosong!';
                                        }
                                        return null;
                                      },
                                      controller: _jenisPartController,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(10),
                                        labelText: "Jenis Part",
                                        hintText: "Masukkan Jenis Part",
                                        prefixIcon: IconButton(
                                          onPressed: _jenisPartController.clear,
                                          icon: const Icon(Icons.clear),
                                        ),
                                        suffixIcon: PopupMenuButton<String>(
                                          icon: const Icon(
                                            Icons.arrow_drop_down,
                                          ),
                                          tooltip: "Pilih",
                                          onSelected: (String value) {
                                            _jenisPartController.text = value;
                                          },
                                          itemBuilder: (BuildContext context) {
                                            return itemsJenisPart.map<PopupMenuItem<String>>((String value) {
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
                                      // The validator receives the text that the user has entered.
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Nama Supplier tidak boleh kosong!';
                                        }
                                        return null;
                                      },
                                      controller: _namaSupplierController,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(10),
                                        labelText: "Nama Supplier",
                                        hintText: "Masukkan Nama Supplier",
                                        prefixIcon: IconButton(
                                          onPressed: _namaSupplierController.clear,
                                          icon: const Icon(Icons.clear),
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
                                            final String kodePart = _kodePartController.text;
                                            final String jenisPart = _jenisPartController.text;
                                            final String namaSupplier = _namaSupplierController.text;

                                            if (action == "create") {
                                              // Persist a new product to Firestore
                                              await _rayaSupplier.add({
                                                "namaPart": namaPart,
                                                "kodePart": kodePart,
                                                "jenisPart": jenisPart,
                                                "namaSupplier": namaSupplier,
                                              });
                                            }

                                            if (action == "update") {
                                              // Update the product
                                              await _rayaSupplier
                                                  .doc(documentSnapshot!.id)
                                                  .set({
                                                "namaPart": namaPart,
                                                "kodePart": kodePart,
                                                "jenisPart": jenisPart,
                                                "namaSupplier": namaSupplier,
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
                                            _kodePartController.text = "";
                                            _jenisPartController.text = "";
                                            _namaSupplierController.text = "";

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
    await _rayaSupplier.doc(productId).delete();

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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
          tooltip: "Kembali",
          onPressed: () {
            Navigator.of(context).pop();
          },
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
                    "Nama Part",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "False",
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
                                    "GESITS Raya Supplier Parts was exported to Download folder!",
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
        actions: [
          IconButton(
            // Add new data
            tooltip: "Create",
            icon: const Icon(
              Icons.add,
              color: Colors.black,
            ),
            onPressed: () {
              // Clear the text fields
              _namaPartController.text = "";
              _kodePartController.text = "";
              _jenisPartController.text = "";
              _namaSupplierController.text = "";
              _createOrUpdate();
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
        backgroundColor: const Color(0xa3e8d820),
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
                                  "• Kode Part",
                                ),
                                Text(
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  "• Jenis Part",
                                ),
                                Text(
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  "• Nama Supplier",
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
                                controller: _searchTextKodePartController,
                                onChanged: (value) {
                                  setState(() {
                                    searchTextKodePart = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: "Masukkan Kode Part",
                                  labelText: "Kode Part",
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
                                controller: _searchTextJenisPartController,
                                onChanged: (value) {
                                  setState(() {
                                    searchTextJenisPart = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: "Masukkan Jenis Part",
                                  labelText: "Jenis Part",
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
                                controller: _searchTextNamaSupplierController,
                                onChanged: (value) {
                                  setState(() {
                                    searchTextNamaSupplier = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: "Masukkan Nama Supplier",
                                  labelText: "Nama Supplier",
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
                Container(
                  padding: const EdgeInsets.all(20),
                  child: const Text(
                    "GESITS Raya Supplier",
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
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          getDataFromFirestore();
        },
        child: StreamBuilder<QuerySnapshot>(
          stream: _rayaSupplier
              .orderBy("namaPart", descending: false)
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

            if (searchTextKodePart.isNotEmpty) {
              documents = documents.where((element) {
                return element
                    .get("kodePart")
                    .toString()
                    .toLowerCase()
                    .contains(searchTextKodePart.toLowerCase());
              }).toList();
            }

            if (searchTextJenisPart.isNotEmpty) {
              documents = documents.where((element) {
                return element
                    .get("jenisPart")
                    .toString()
                    .toLowerCase()
                    .contains(searchTextJenisPart.toLowerCase());
              }).toList();
            }

            if (searchTextNamaSupplier.isNotEmpty) {
              documents = documents.where((element) {
                return element
                    .get("namaSupplier")
                    .toString()
                    .toLowerCase()
                    .contains(searchTextNamaSupplier.toLowerCase());
              }).toList();
            }

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (BuildContext context, int index) {
                final DocumentSnapshot documentSnapshot = documents[index];
                // Add the data to the itemList
                itemList.add(<String>[
                  documentSnapshot.get("namaPart"),
                  documentSnapshot.get("kodePart"),
                  documentSnapshot.get("jenisPart"),
                  documentSnapshot.get("namaSupplier"),
                ]);

                return Card(
                  color: Colors.white60,
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.red,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            "Nama Part: ${documentSnapshot["namaPart"]}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "Nama Supplier: ${documentSnapshot["namaSupplier"]}",
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          trailing: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white70,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: SizedBox(
                                  width: 100,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.cyanAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Kode Part: ${documentSnapshot["kodePart"]}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Jenis Part: ${documentSnapshot["jenisPart"]}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
    final anchor = html.document.createElement("a") as html.AnchorElement..href = url..style.display = "none"..download = "Raya_Supplier_Parts_$formattedDate.csv";
    html.document.body!.children.add(anchor);
    anchor.click();
    html.Url.revokeObjectUrl(url);
  }

  else if (Platform.isAndroid) {
    Directory generalDownloadDir = Directory("storage/emulated/0/Download");
    final File file = await (File(
        "${generalDownloadDir.path}/Raya_Supplier_Parts_$formattedDate.csv"
    ).create());
    await file.writeAsString(csvData);
  }
}
