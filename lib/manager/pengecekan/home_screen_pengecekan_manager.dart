import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qc_parts_check/manager/pengecekan/sub_pages/electric_pages/electric_home_screen_manager.dart';
import 'package:qc_parts_check/manager/pengecekan/sub_pages/general_pages/general_home_screen_manager.dart';
import 'package:qc_parts_check/manager/pengecekan/sub_pages/metal_pages/metal_home_screen_manager.dart';
import 'package:qc_parts_check/manager/pengecekan/sub_pages/plastic_pages/plastic_home_screen_manager.dart';
import 'package:slide_digital_clock/slide_digital_clock.dart';
import 'package:ticker_text/ticker_text.dart';

class HomeScreenPengecekanManager extends StatefulWidget {
  const HomeScreenPengecekanManager({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenPengecekanManagerState();
}

class _HomeScreenPengecekanManagerState
    extends State<HomeScreenPengecekanManager> with TickerProviderStateMixin {
  List<DocumentSnapshot> documents = [];

  String date =
      DateFormat("EEEEE, dd/MMMM/yyyy", "id_ID").format(DateTime.now());

  User? _user;

  @override
  void initState() {
    super.initState();

    // Retrieve logged in user data
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _user = user;
      });
    });
  }

  // Animation function
  late final AnimationController _controller = AnimationController(
    duration: const Duration(
      seconds: 2,
    ),
    vsync: this,
  )..forward();

  // Animation settings
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String formatTimestampToDisplay(String timestampString) {
    try {
      // Parse the timestamp string into a DateTime object.
      DateTime timestamp = DateTime.parse(timestampString);

      // Define the desired date and time format.
      final DateFormat formatter = DateFormat('d MMMM y HH:mm:ss:S');

      // Format the timestamp.
      String formattedTimestamp = formatter.format(timestamp);

      return formattedTimestamp;
    } catch (e) {
      return "Invalid Timestamp";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xa3e8d820),
        title: const Text(
          "Pengecekan",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: const [
          SizedBox(
            width: 130,
            // constrain the parent width so the child overflows and scrolling takes effect
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: TickerText(
                // default values
                // controller: tickerTextController, // this is optional
                scrollDirection: Axis.horizontal,
                speed: 30,
                startPauseDuration: Duration(seconds: 1),
                endPauseDuration: Duration(seconds: 1),
                returnDuration: Duration(milliseconds: 100),
                primaryCurve: Curves.linear,
                returnCurve: Curves.easeOut,
                child: Text("Manager Quality Control"),
              ),
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
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifikasi')
                .orderBy("timeStamp", descending: true)
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
              return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (BuildContext context, int index) {
                  final DocumentSnapshot documentSnapshot = documents[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                        ),
                        gradient: documentSnapshot["telahDibaca"] == "false"
                            ? const LinearGradient(
                                colors: [
                                  Colors.teal,
                                  Color.fromARGB(
                                    200,
                                    30,
                                    220,
                                    190,
                                  ),
                                ],
                              )
                            : const LinearGradient(
                                colors: [
                                  Colors.yellow,
                                  Color.fromARGB(
                                    100,
                                    60,
                                    110,
                                    210,
                                  ),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              documentSnapshot["keteranganNotifikasi"],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              formatTimestampToDisplay(documentSnapshot["timeStamp"]),
                            ),
                            Visibility(
                              visible: documentSnapshot["telahDibaca"] == "false",
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await FirebaseFirestore.instance.collection('notifikasi').doc(documentSnapshot.id).set({
                                    "keteranganNotifikasi": documentSnapshot["keteranganNotifikasi"],
                                    "timeStamp": documentSnapshot["timeStamp"],
                                    "telahDibaca": "true",
                                  });
                                },
                                icon: const Icon(
                                  Icons.check,
                                ),
                                label: const Text('Mark as read'),
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
        ),
      ),
      body: Material(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(0.8, 1),
              colors: <Color>[
                Color(0x28e3caca),
                Color(0x2ad8de32),
                Color(0x49ead66e),
                Color(0x35f3cd0a),
                Color(0xfff3f19e),
                Color(0x76ecba17),
                Color(0x8cf39060),
                Color(0xa3fae927),
              ],
              // Gradient from https://learnui.design/tools/gradient-generator.html
              tileMode: TileMode.mirror,
            ),
          ),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Builder(
                    builder: (context) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.circle_notifications),
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                        label: const Text(
                          "Buka Notifikasi",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Hero(
                      tag: "wima-logo",
                      child: Image.asset(
                        "assets/images/wima-logo.png",
                        width: 150,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Hero(
                      tag: "gesits-logo",
                      child: Image.asset(
                        "assets/images/gesits-logo.png",
                        width: 150,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.lightBlueAccent,
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
                      child: DigitalClock(
                        hourMinuteDigitTextStyle: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(color: Colors.black),
                        secondDigitTextStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.black),
                        colon: const Text(
                          ":",
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.lightGreenAccent,
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
                        child: Text(
                          date,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Selamat Datang,",
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(_user?.uid) // ID OF DOCUMENT
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  var document = snapshot.data!;
                  return Container(
                    margin: const EdgeInsets.only(
                      left: 10,
                      right: 5,
                    ),
                    child: Text(
                      document["name"],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
              Center(
                child: ScaleTransition(
                  scale: _animation,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      "assets/images/img-gesits-g1.png",
                      width: 250,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Material(
                          color: const Color(0xb3a18b3b),
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MetalHomeScreenManager(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Hero(
                                    tag: "img-metal-part",
                                    child: Image.asset(
                                      "assets/images/img-metal-part.png",
                                      width: 100,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Metal Parts",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Material(
                          color: const Color(0xffc2ad29),
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PlasticHomeScreenManager(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Hero(
                                    tag: "img-plastic-part",
                                    child: Image.asset(
                                      "assets/images/img-plastic-part.png",
                                      width: 80,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Plastic Parts",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Material(
                          color: const Color(0xffcebd54),
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const GeneralHomeScreenManager(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Hero(
                                    tag: "img-general-part",
                                    child: Image.asset(
                                      "assets/images/img-general-part.png",
                                      width: 100,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "General Parts",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Material(
                          color: const Color(0xffbad347),
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ElectricHomeScreenManager(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Hero(
                                    tag: "img-electric-part",
                                    child: Image.asset(
                                      "assets/images/img-electric-part.png",
                                      width: 100,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Electric Parts",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
