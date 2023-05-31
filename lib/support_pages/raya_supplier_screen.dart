import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RayaSupplierScreen extends StatefulWidget {
  const RayaSupplierScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RayaSupplierScreenState();
}

class _RayaSupplierScreenState extends State<RayaSupplierScreen> {
  // Text fields controllers
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _namaPartController = TextEditingController();
  final TextEditingController _namaSupplierController = TextEditingController();

  // Firestore collection reference
  final CollectionReference _rayaSupplier = FirebaseFirestore.instance.collection("raya_supplier");
  List<DocumentSnapshot> documents = [];

  // Search text variable
  String searchText = "";

  // This function is triggered when floating button or one of the edit buttons is pressed
  // Adding a product if no documentSnapshot is passed
  // If documentSnapshot != null the update an existing product
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = "create";
    if (documentSnapshot != null) {
      action = "update";

      _namaPartController.text = documentSnapshot["namaPart"];
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
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                          labelText: "Nama Part",
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                          labelText: "Nama Supplier",
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
                            HapticFeedback.vibrate();
                            final String namaPart = _namaPartController.text;
                            final String namaSupplier = _namaSupplierController.text;

                            if (action == "create") {
                              // Persist a new product to Firestore
                              await _rayaSupplier.add({
                                "namaPart": namaPart,
                                "namaSupplier": namaSupplier,
                              });
                            }

                            if (action == "update") {
                              // Update the product
                              await _rayaSupplier
                                  .doc(documentSnapshot!.id)
                                  .set({
                                "namaPart": namaPart,
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
                            _namaSupplierController.text = "";

                            if (!mounted) return;
                            // Hide the bottom sheet
                            Navigator.of(context).pop();
                          },
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
        actions: [
          IconButton(
            // Add new data
            tooltip: "Create",
            icon: const Icon(
              Icons.add_circle_outline,
              color: Colors.black,
            ),
            onPressed: () {
              // Clear the text fields
              _namaPartController.text = "";
              _namaSupplierController.text = "";
              _createOrUpdate();
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
                  child: Column(
                    children: [
                      const Text(
                        "Cari data berdasarkan Nama Part",
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
                            hintText: "Nama Part",
                            prefixIcon: Icon(
                              Icons.search,
                            ),
                          ),
                        ),
                      ),
                    ],
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

      body: StreamBuilder<QuerySnapshot>(
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
          if (searchText.isNotEmpty) {
            documents = documents.where((element) {
              return element
                  .get("namaPart")
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
                  child: ListTile(
                    title: Text(
                      "Nama Part: ${documentSnapshot["namaPart"]}",
                    ),
                    subtitle: Text(
                      "Nama Supplier: ${documentSnapshot["namaSupplier"]}",
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SizedBox(
                            width: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
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
