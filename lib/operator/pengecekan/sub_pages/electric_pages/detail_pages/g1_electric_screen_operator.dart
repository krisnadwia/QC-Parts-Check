import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:csv/csv.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class HeroPhotoViewRouteWrapper extends StatelessWidget {
  const HeroPhotoViewRouteWrapper({
    super.key,
    required this.imageProvider,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
  });

  final ImageProvider imageProvider;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Photo View",
        ),
        flexibleSpace: Material(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment(0.8, 1),
                colors: <Color>[
                  Color(0x28e3caca),
                  Color(0x2ad8de32),
                  Color(0x49ead66e),
                ],
                // Gradient from https://learnui.design/tools/gradient-generator.html
                tileMode: TileMode.mirror,
              ),
            ),
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
      ),
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: PhotoView(
          imageProvider: imageProvider,
          backgroundDecoration: backgroundDecoration,
          minScale: minScale,
          maxScale: maxScale,
          heroAttributes: const PhotoViewHeroAttributes(tag: "someTag"),
        ),
      ),
    );
  }
}

class PDFScreen extends StatelessWidget {
  final Uint8List pdfBytes;

  const PDFScreen(this.pdfBytes, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            final blob = html.Blob([pdfBytes]);
            final url = html.Url.createObjectUrlFromBlob(blob);
            html.AnchorElement(href: url)
              ..target = '_blank'
              ..download = 'doc.pdf'
              ..click();
            html.Url.revokeObjectUrl(url);
          },
          child: const Text('Download PDF'),
        ),
      ),
    );
  }
}

// For CSV Export
List<List<String>> itemList = [];

class G1ElectricScreenOperator extends StatefulWidget {
  const G1ElectricScreenOperator({super.key});

  @override
  State<StatefulWidget> createState() => _G1ElectricScreenOperatorState();
}

class _G1ElectricScreenOperatorState extends State<G1ElectricScreenOperator> {
  // Create a timestamp
  DateTime currentDateTime = DateTime.now();

  // Fungsi untuk mengambil data berdasarkan documentId
  Future<DocumentSnapshot> fetchDataById(String documentId) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('g1_electric_parts').doc(documentId).get();
    return documentSnapshot;
  }

  // Fungsi untuk membuat PDF dari data dokumen
  Future<Uint8List> _createPDF(DocumentSnapshot document) async {
    final pdf = pw.Document();

    final namaPart = document['namaPart'].toString();
    final namaSupplier = document['namaSupplier'].toString();
    final tanggalKedatangan = document['tanggalKedatangan'].toString();
    final jumlahTotal = document['jumlahTotal'].toString();
    final tanggalPengecekan = document['tanggalPengecekan'].toString();
    final jumlahOk = document['jumlahOk'].toString();
    final jumlahNg = document['jumlahNg'].toString();
    final catatan = document['catatan'].toString();
    final buktiPengecekan = document['buktiPengecekan'].toString();
    final ditambahkanOleh = document['ditambahkanOleh'].toString();
    final statusValidasi = document['statusValidasi'].toString();
    final divalidasiOleh = document['divalidasiOleh'].toString();
    final tanggalReturn = document['tanggalReturn'].toString();
    final direturnOleh = document['direturnOleh'].toString();

    // Mendownload gambar dan menyimpannya di cache sementara
    final fileBuktiPengecekan = await DefaultCacheManager().getSingleFile(buktiPengecekan);

    final ByteData ptLogo = await rootBundle.load('assets/images/wima-logo.png');
    final Uint8List bytesPt = ptLogo.buffer.asUint8List();
    final imgPtLogo = pw.MemoryImage(bytesPt);

    final ByteData productLogo = await rootBundle.load('assets/images/gesits-logo.png');
    final Uint8List bytesProduct = productLogo.buffer.asUint8List();
    final imgProductLogo = pw.MemoryImage(bytesProduct);

    if (await fileBuktiPengecekan.exists()) {
      final buktiPengecekan = pw.MemoryImage(fileBuktiPengecekan.readAsBytesSync());

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Image(imgPtLogo, height: 40),
                    pw.Image(imgProductLogo, height: 40),
                  ],
                ),
                pw.SizedBox(
                  height: 30,
                ),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.black),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            'Nama Part',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            'Nama Supplier',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            'Tanggal Kedatangan',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            'Jumlah Total',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(namaPart),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(namaSupplier),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(tanggalKedatangan),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(jumlahTotal),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(
                  height: 10,
                ),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.black),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            'Tanggal Pengecekan',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            'Jumlah OK',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            'Jumlah NG',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            'Catatan',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(tanggalPengecekan),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(jumlahOk),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(jumlahNg),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(catatan),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(
                  height: 10,
                ),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.black),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            'Bukti Pengecekan',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Image(buktiPengecekan, height: 200),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(
                  height: 10,
                ),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.black),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            'Ditambahkan Oleh',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            'Status Validasi',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            'Divalidasi Oleh',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            'Tanggal Return',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            'Direturn Oleh',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(ditambahkanOleh),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(statusValidasi),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(divalidasiOleh),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(tanggalReturn),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(direturnOleh),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  String jenisPart = "Electric Part";

  Stream<QuerySnapshot> getDataPart() {
    return FirebaseFirestore.instance.collection('g1_supplier').where('jenisPart', isEqualTo: jenisPart).snapshots();
  }

  String getSupplierForPart(String selectedPart, List<QueryDocumentSnapshot> documents) {
    for (var doc in documents) {
      if (doc['namaPart'] == selectedPart) {
        return doc['namaSupplier'];
      }
    }
    return "";
  }

  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();
  File? _image;
  final _filePath = '';

  Future<void> _pickImage() async {
    if (kIsWeb) {
      _uploadFile(_filePath);
    } else {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        _uploadImage(_image);
      }
    }
  }

  Future<void> _uploadFile(String filePath) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'heic'],
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      final fileBytes = result.files.first.bytes;
      final fileName = result.files.first.name;
      UploadTask uploadTask = FirebaseStorage.instance.ref('uploads/$fileName').putData(fileBytes!);

      await uploadTask;

      if (uploadTask.snapshot.state == TaskState.success) {
        final String downloadURL = await FirebaseStorage.instance.ref('uploads/$fileName').getDownloadURL();
        setState(() {
          _buktiPengecekanController.text = downloadURL;
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload file'),
          ),
        );
      }
    }
  }

  Future<void> _uploadImage(File? imageFile) async {
    if (imageFile == null) return;

    final Reference storageReference = _storage.ref().child('images/${DateTime.now()}.jpg');
    UploadTask uploadTask = storageReference.putFile(imageFile);

    await uploadTask;

    if (uploadTask.snapshot.state == TaskState.success) {
      final String downloadURL = await storageReference.getDownloadURL();
      setState(() {
        _buktiPengecekanController.text = downloadURL;
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to upload image'),
        ),
      );
    }
  }

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

  User? _user;

  @override
  void initState() {
    super.initState();

    itemList = [
      <String>[
        "Nama Part",
        "Nama Supplier",
        "Tanggal Kedatangan",
        "Jumlah Total",
        "Tanggal Pengecekan",
        "Jumlah OK",
        "Jumlah NG",
        "Catatan",
        "Bukti Pengecekan",
        "Ditambahkan Oleh",
        "Status Validasi",
        "Divalidasi Oleh",
        "Tanggal Return",
        "Direturn Oleh",
      ]
    ];

    // Retrieve logged in user data
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _user = user;
      });
    });

    _jumlahOkController.addListener(calculateSum);
    _jumlahNgController.addListener(calculateSum);
  }

  void calculateSum() {
    final num jumlahOk = num.tryParse(_jumlahOkController.text) ?? 0;
    final num jumlahNg = num.tryParse(_jumlahNgController.text) ?? 0;
    final num jumlahTotal = jumlahOk + jumlahNg;
    _jumlahTotalController.text = jumlahTotal.toString();
  }

  @override
  void dispose() {
    _jumlahOkController.dispose();
    _jumlahNgController.dispose();
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
  final TextEditingController _jumlahOkController = TextEditingController();
  final TextEditingController _jumlahNgController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  final TextEditingController _buktiPengecekanController = TextEditingController();
  final TextEditingController _ditambahkanOlehController = TextEditingController();
  final TextEditingController _statusValidasiController = TextEditingController();
  final TextEditingController _divalidasiOlehController = TextEditingController();
  final TextEditingController _tanggalReturnController = TextEditingController();
  final TextEditingController _direturnOlehController = TextEditingController();
  final TextEditingController _timeStampController = TextEditingController();
  final TextEditingController _keteranganNotifikasiController = TextEditingController();
  final TextEditingController _telahDibacaController = TextEditingController();

  // Firestore collection reference
  final CollectionReference _g1ElectricParts = FirebaseFirestore.instance.collection("g1_electric_parts");
  List<DocumentSnapshot> documents = [];

  Stream<QuerySnapshot<Map<String, dynamic>>> getDataFromFirestore() {
    return FirebaseFirestore.instance
        .collection('g1_electric_parts')
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

  Future<void> _detailView([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      await showGeneralDialog(
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        },
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.picture_as_pdf_outlined,
                    size: 30,
                  ),
                  label: const Text(
                    "Print",
                  ),
                  onPressed: () async {
                    final documentId = documentSnapshot.id; // Ganti dengan documentId yang sesuai
                    final document = await fetchDataById(documentId);
                    final pdfBytes = await _createPDF(document);
                    await Printing.layoutPdf(
                      onLayout: (PdfPageFormat format) async => pdfBytes,
                    );
                    if (!mounted) return;
                    if (kIsWeb) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PDFScreen(pdfBytes),
                        ),
                      );
                    }
                  },
                ),
                content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Nama Part",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              documentSnapshot["namaPart"],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Nama Supplier",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              documentSnapshot["namaSupplier"],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Tanggal Kedatangan",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              documentSnapshot["tanggalKedatangan"],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Jumlah Total",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              documentSnapshot["jumlahTotal"].toString(),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Tanggal Pengecekan",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              documentSnapshot["tanggalPengecekan"],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Jumlah OK",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              documentSnapshot["jumlahOk"].toString(),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Jumlah NG",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              documentSnapshot["jumlahNg"].toString(),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Catatan",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              documentSnapshot["catatan"],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Bukti Pengecekan",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 100,
                              width: 200,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Linkify(
                                  onOpen: _onOpen,
                                  text: documentSnapshot["buktiPengecekan"],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 10,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HeroPhotoViewRouteWrapper(
                                        imageProvider: NetworkImage(
                                          documentSnapshot["buktiPengecekan"],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Hero(
                                  tag: "someTag",
                                  child: Image.network(
                                    documentSnapshot["buktiPengecekan"],
                                    width: 200,
                                    loadingBuilder: (_, child, chunk) =>
                                        chunk != null ? const Text("loading...") : child,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Ditambahkan Oleh",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  documentSnapshot["ditambahkanOleh"],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Status Validasi",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  documentSnapshot["statusValidasi"],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Divalidasi Oleh",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  documentSnapshot["divalidasiOleh"],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Tanggal Return",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  documentSnapshot["tanggalReturn"],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Direturn Oleh",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  documentSnapshot["direturnOleh"],
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
  }

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = "create";
    if (documentSnapshot != null) {
      action = "update";

      _namaPartController.text = documentSnapshot["namaPart"];
      _namaSupplierController.text = documentSnapshot["namaSupplier"];
      _tanggalKedatanganController.text = documentSnapshot["tanggalKedatangan"];
      _jumlahTotalController.text = documentSnapshot["jumlahTotal"].toString();
      _tanggalPengecekanController.text = documentSnapshot["tanggalPengecekan"];
      _jumlahOkController.text = documentSnapshot["jumlahOk"].toString();
      _jumlahNgController.text = documentSnapshot["jumlahNg"].toString();
      _catatanController.text = documentSnapshot["catatan"];
      _buktiPengecekanController.text = documentSnapshot["buktiPengecekan"];
      _ditambahkanOlehController.text = documentSnapshot["ditambahkanOleh"];
      _statusValidasiController.text = documentSnapshot["statusValidasi"];
      _divalidasiOlehController.text = documentSnapshot["divalidasiOleh"];
      _tanggalReturnController.text = documentSnapshot["tanggalReturn"];
      _direturnOlehController.text = documentSnapshot["direturnOleh"];
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 30,
                            ),
                            label: const Text(
                              "Tutup",
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          Text(
                            action == "create" ? "Tambah Data" : "Update Data",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: action == "create" ? Colors.blue : Colors.indigo,
                            ),
                          ),
                        ],
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
                                      readOnly: true,
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
                                        prefixIcon: IconButton(
                                          onPressed: _namaPartController.clear,
                                          icon: const Icon(Icons.clear),
                                        ),
                                        suffixIcon: StreamBuilder<QuerySnapshot>(
                                          stream: getDataPart(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) return const CircularProgressIndicator();

                                            List<String> partOptions = [];
                                            for (var doc in snapshot.data!.docs) {
                                              partOptions.add(doc['namaPart']);
                                            }

                                            return PopupMenuButton<String>(
                                              icon: const Icon(
                                                Icons.arrow_drop_down,
                                              ),
                                              tooltip: "Pilih",
                                              onSelected: (value) {
                                                setState(() {
                                                  _namaPartController.text = value.toString();
                                                  // Dapatkan supplier dari Firestore dan isi TextField
                                                  _namaSupplierController.text = getSupplierForPart(
                                                    value.toString(),
                                                    snapshot.data!.docs,
                                                  );
                                                });
                                              },
                                              itemBuilder: (BuildContext context) {
                                                return partOptions.map((String value) {
                                                  return PopupMenuItem<String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList();
                                              },
                                            );
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
                                    TextFormField(
                                      readOnly: true,
                                      controller: _namaSupplierController,
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.all(10),
                                        labelText: "Nama Supplier",
                                        prefixIcon: Icon(Icons.settings_suggest_sharp),
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
                                              lastDate: DateTime(2101),
                                            );

                                            if (pickedDate != null) {
                                              if (kDebugMode) {
                                                print(pickedDate);
                                              }
                                              String formattedDate =
                                                  DateFormat("yyyy-MM-dd, EEEE", 'id_ID').format(pickedDate);
                                              if (kDebugMode) {
                                                print(formattedDate);
                                              }

                                              setState(() {
                                                _tanggalKedatanganController.text =
                                                    formattedDate; // Set output date to TextField value.
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
                                        labelText: "Jumlah Total",
                                        prefixIcon: Icon(Icons.settings_suggest_sharp),
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
                                              lastDate: DateTime(2101),
                                            );

                                            if (pickedDate != null) {
                                              if (kDebugMode) {
                                                print(pickedDate);
                                              }
                                              String formattedDate =
                                                  DateFormat("yyyy-MM-dd, EEEE", 'id_ID').format(pickedDate);
                                              if (kDebugMode) {
                                                print(formattedDate);
                                              }

                                              setState(() {
                                                _tanggalPengecekanController.text =
                                                    formattedDate; // Set output date to TextField value.
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
                                      controller: _jumlahOkController,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(10),
                                        labelText: "Jumlah OK",
                                        hintText: "Masukkan Jumlah OK",
                                        prefixIcon: IconButton(
                                          onPressed: _jumlahOkController.clear,
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
                                      controller: _jumlahNgController,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(10),
                                        labelText: "Jumlah NG",
                                        hintText: "Masukkan Jumlah NG",
                                        prefixIcon: IconButton(
                                          onPressed: _jumlahNgController.clear,
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
                                      controller: _catatanController,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(10),
                                        labelText: "Catatan",
                                        hintText: "Masukkan Catatan",
                                        prefixIcon: IconButton(
                                          onPressed: _catatanController.clear,
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
                                          "Upload   ↓",
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      readOnly: true,
                                      // The validator receives the text that the user has entered.
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Bukti Pengecekan tidak boleh kosong!';
                                        }
                                        return null;
                                      },
                                      controller: _buktiPengecekanController,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(10),
                                        labelText: "Bukti Pengecekan",
                                        prefixIcon: IconButton(
                                          onPressed: _buktiPengecekanController.clear,
                                          icon: const Icon(Icons.clear),
                                        ),
                                        suffixIcon: IconButton(
                                          tooltip: "Upload",
                                          icon: const Icon(
                                            Icons.cloud_upload,
                                          ),
                                          onPressed: _pickImage,
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
                              width: 130,
                              height: 50,
                              child: OutlinedButton.icon(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                                icon: Icon(
                                  action == "create" ? Icons.add : Icons.edit,
                                ),
                                label: Text(
                                  action == "create" ? "Create" : "Update",
                                  style: TextStyle(
                                    color: action == "create" ? Colors.blue : Colors.indigo,
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
                                              color: action == "create" ? Colors.blue : Colors.indigo,
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
                                            final String namaPart = _namaPartController.text;
                                            final String namaSupplier = _namaSupplierController.text;
                                            final String tanggalKedatangan = _tanggalKedatanganController.text;
                                            final num? jumlahTotal = num.tryParse(_jumlahTotalController.text);
                                            final String tanggalPengecekan = _tanggalPengecekanController.text;
                                            final num? jumlahOk = num.tryParse(_jumlahOkController.text);
                                            final num? jumlahNg = num.tryParse(_jumlahNgController.text);
                                            final String catatan = _catatanController.text;
                                            final String buktiPengecekan = _buktiPengecekanController.text;
                                            final String ditambahkanOleh = _ditambahkanOlehController.text;
                                            final String statusValidasi = _statusValidasiController.text;
                                            final String divalidasiOleh = _divalidasiOlehController.text;
                                            final String tanggalReturn = _tanggalReturnController.text;
                                            final String direturnOleh = _direturnOlehController.text;
                                            final String timeStamp = _timeStampController.text;
                                            final String keteranganNotifikasi = _keteranganNotifikasiController.text;
                                            final String telahDibaca = _telahDibacaController.text;

                                            if (action == "create") {
                                              // Persist a new data to Firestore
                                              await _g1ElectricParts.add({
                                                "namaPart": namaPart,
                                                "namaSupplier": namaSupplier,
                                                "tanggalKedatangan": tanggalKedatangan,
                                                "jumlahTotal": jumlahTotal,
                                                "tanggalPengecekan": tanggalPengecekan,
                                                "jumlahOk": jumlahOk,
                                                "jumlahNg": jumlahNg,
                                                "catatan": catatan,
                                                "buktiPengecekan": buktiPengecekan,
                                                "ditambahkanOleh": ditambahkanOleh,
                                                "statusValidasi": statusValidasi,
                                                "divalidasiOleh": divalidasiOleh,
                                                "tanggalReturn": tanggalReturn,
                                                "direturnOleh": direturnOleh,
                                              });

                                              await FirebaseFirestore.instance.collection('notifikasi').add({
                                                "timeStamp": timeStamp,
                                                "keteranganNotifikasi": keteranganNotifikasi,
                                                "telahDibaca": telahDibaca,
                                              });
                                            }

                                            if (action == "update") {
                                              // Update the data
                                              await _g1ElectricParts.doc(documentSnapshot!.id).set({
                                                "namaPart": namaPart,
                                                "namaSupplier": namaSupplier,
                                                "tanggalKedatangan": tanggalKedatangan,
                                                "jumlahTotal": jumlahTotal,
                                                "tanggalPengecekan": tanggalPengecekan,
                                                "jumlahOk": jumlahOk,
                                                "jumlahNg": jumlahNg,
                                                "catatan": catatan,
                                                "buktiPengecekan": buktiPengecekan,
                                                "ditambahkanOleh": ditambahkanOleh,
                                                "statusValidasi": statusValidasi,
                                                "divalidasiOleh": divalidasiOleh,
                                                "tanggalReturn": tanggalReturn,
                                                "direturnOleh": direturnOleh,
                                              });
                                            }

                                            // Show a snackbar
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                backgroundColor: action == "create" ? Colors.yellow : Colors.grey,
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
                                            _jumlahOkController.text = "";
                                            _jumlahNgController.text = "";
                                            _catatanController.text = "";
                                            _buktiPengecekanController.text = "";

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

  // Deleting a data by id
  Future<void> _deleteData(String dataId) async {
    await _g1ElectricParts.doc(dataId).delete();

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
              tag: "gesits-logo-g1",
              child: Image.asset(
                "assets/images/gesits-logo.png",
                width: 80,
              ),
            ),
            const Text(
              "G1",
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
                                    "GESITS G1 Electric Parts was exported to Download folder!",
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
                  Icons.add_circle_outlined,
                ),
                onPressed: () {
                  // Clear the text fields
                  _namaPartController.text = "";
                  _namaSupplierController.text = "";
                  _tanggalKedatanganController.text = "";
                  _jumlahTotalController.text = "";
                  _tanggalPengecekanController.text = "";
                  _jumlahOkController.text = "";
                  _jumlahNgController.text = "";
                  _catatanController.text = "";
                  _buktiPengecekanController.text = "";
                  _ditambahkanOlehController.text = document?["name"];
                  _statusValidasiController.text = "Belum Divalidasi";
                  _divalidasiOlehController.text = "";
                  _tanggalReturnController.text = "";
                  _direturnOlehController.text = "";
                  _timeStampController.text = "$currentDateTime";
                  _keteranganNotifikasiController.text = "Data ditambahkan: G1 Electric Part";
                  _telahDibacaController.text = "false";
                  _createOrUpdate();
                },
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
              tooltip: "Cari Data",
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
                          "GESITS G1 Electric Parts",
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
                            "assets/images/img-g1.png",
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
          stream: _g1ElectricParts.orderBy("tanggalPengecekan", descending: true).snapshots(),
          builder: (ctx, streamSnapshot) {
            if (streamSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              );
            }

            documents = (streamSnapshot.data!).docs;

            if (searchTextNamaPart.isNotEmpty) {
              documents = documents.where((element) {
                return element.get("namaPart").toString().toLowerCase().contains(searchTextNamaPart.toLowerCase());
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
                  documentSnapshot.get("jumlahTotal").toString(),
                  documentSnapshot.get("tanggalPengecekan"),
                  documentSnapshot.get("jumlahOk").toString(),
                  documentSnapshot.get("jumlahNg").toString(),
                  documentSnapshot.get("catatan"),
                  documentSnapshot.get("buktiPengecekan"),
                  documentSnapshot.get("ditambahkanOleh"),
                  documentSnapshot.get("statusValidasi"),
                  documentSnapshot.get("divalidasiOleh"),
                  documentSnapshot.get("tanggalReturn"),
                  documentSnapshot.get("direturnOleh"),
                ]);

                Map<String, double> dataMap = {
                  "Jumlah OK": documentSnapshot["jumlahOk"].toDouble(),
                  "Jumlah NG": documentSnapshot["jumlahNg"].toDouble(),
                };
                final colorList = <Color>[
                  Colors.blue,
                  Colors.red,
                ];
                return Material(
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _detailView(documentSnapshot),
                    child: Padding(
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
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 10,
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
                                          "Tanggal Kedatangan",
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
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
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
                                          documentSnapshot["tanggalKedatangan"],
                                        ),
                                        Text(
                                          documentSnapshot["tanggalPengecekan"],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
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
                                                chartType: ChartType.ring,
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
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white70,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            children: [
                                              // Press this button to edit a single data
                                              Padding(
                                                padding: const EdgeInsets.all(4),
                                                child: ElevatedButton.icon(
                                                  label: const Text(
                                                    "Update",
                                                    style: TextStyle(
                                                      color: Colors.orange,
                                                    ),
                                                  ),
                                                  icon: const Icon(
                                                    Icons.edit_outlined,
                                                    color: Colors.orange,
                                                  ),
                                                  onPressed: () => _createOrUpdate(documentSnapshot),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 30,
                                              ),
                                              // This icon button is used to delete a single data
                                              Padding(
                                                padding: const EdgeInsets.all(4),
                                                child: ElevatedButton.icon(
                                                  label: const Text(
                                                    "Delete",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.red,
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
                                                        height: 150,
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
                                                            _deleteData(documentSnapshot.id);
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
                                              ),
                                            ],
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
                                              color: Colors.lightBlue,
                                              width: 2,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              children: [
                                                const Text(
                                                  "Status Validasi",
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
                                                          documentSnapshot["statusValidasi"] == "Belum Divalidasi"
                                                              ? Icons.cancel_outlined
                                                              : Icons.check_circle_outlined,
                                                          color:
                                                              documentSnapshot["statusValidasi"] == "Belum Divalidasi"
                                                                  ? Colors.red
                                                                  : Colors.green,
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          documentSnapshot["statusValidasi"],
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
      ..download = "G1_Electric_Parts_$formattedDate.csv";
    html.document.body!.children.add(anchor);
    anchor.click();
    html.Url.revokeObjectUrl(url);
  } else if (Platform.isAndroid) {
    Directory generalDownloadDir = Directory("storage/emulated/0/Download");
    final File file = await (File("${generalDownloadDir.path}/G1_Electric_Parts_$formattedDate.csv").create());
    await file.writeAsString(csvData);
  }
}
