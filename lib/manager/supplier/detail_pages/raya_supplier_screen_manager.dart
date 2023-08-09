import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;

// For CSV Export
List<List<String>> itemList = [];

class RayaSupplierScreenManager extends StatefulWidget {
  const RayaSupplierScreenManager({super.key});

  @override
  State<StatefulWidget> createState() => _RayaSupplierScreenManagerState();
}

class _RayaSupplierScreenManagerState extends State<RayaSupplierScreenManager> {
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
    if (documentSnapshot != null) {

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
                      const Center(
                        child: Text(
                          "Detail",
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
                                controller: _namaPartController,
                                readOnly: true,
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
                                controller: _kodePartController,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  labelText: "Kode Part",
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
                                controller: _jenisPartController,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  labelText: "Jenis Part",
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
                                controller: _namaSupplierController,
                                readOnly: true,
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
                                child: IconButton(
                                  tooltip: "Detail",
                                  color: Colors.blue,
                                  icon: const Icon(
                                    Icons.remove_red_eye_outlined,
                                  ),
                                  onPressed: () => _createOrUpdate(documentSnapshot),
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
