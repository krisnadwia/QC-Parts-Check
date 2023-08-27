import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class G1PlasticGraphScreen extends StatefulWidget {
  const G1PlasticGraphScreen({super.key});

  @override
  State<StatefulWidget> createState() => _G1PlasticGraphScreenState();
}

class _G1PlasticGraphScreenState extends State<G1PlasticGraphScreen> {
  List<_ChartData> chartData = <_ChartData>[];
  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    getDataFromFireStore().then((results) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {});
      });
    });

    // Graph settings
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      zoomMode: ZoomMode.xy,
      enablePanning: true,
      enableMouseWheelZooming: true,
    );
    super.initState();
  }

  // Fetch data from Firestore to show in the graph
  Future<void> getDataFromFireStore() async {
    var snapShotsValue = await FirebaseFirestore.instance
        .collection("g1_plastic_parts")
        .orderBy("tanggalPengecekan", descending: false)
        .get();
    List<_ChartData> list = snapShotsValue.docs
        .map((e) => _ChartData(
            x: e.data()["tanggalPengecekan"],
            y: e.data()["qtyOk"],
            y1: e.data()["qtyNg"]))
        .toList();

    setState(() {
      chartData = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showChart();
  }

  Widget _showChart() {
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
                  Column(
                    children: [
                      const SizedBox(
                        height: 40,
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: const Text(
                          "GESITS G1 Plastic Parts",
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
      body: SfCartesianChart(
        // Chart title
        title: ChartTitle(
          text: "x = Tanggal Pengecekan \n y = Quantity",
        ),
        // Enable legend
        legend: Legend(
          isVisible: true,
        ),
        zoomPanBehavior: _zoomPanBehavior,
        tooltipBehavior: TooltipBehavior(
          enable: true,
          color: Colors.lightGreen,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        primaryXAxis: CategoryAxis(),
        series: <LineSeries<_ChartData, String>>[
          // Graph OK
          LineSeries<_ChartData, String>(
            dataSource: chartData,
            animationDuration: 4500,
            animationDelay: 2000,
            markerSettings: const MarkerSettings(
              isVisible: true,
              color: Colors.amber,
            ),
            xValueMapper: (_ChartData data, _) => data.x,
            yValueMapper: (_ChartData data, _) => data.y,
            name: "OK",
          ),
          // Graph NG
          LineSeries<_ChartData, String>(
            dataSource: chartData,
            animationDuration: 4500,
            animationDelay: 2000,
            markerSettings: const MarkerSettings(
              isVisible: true,
              color: Colors.amber,
            ),
            xValueMapper: (_ChartData data, _) => data.x,
            yValueMapper: (_ChartData data, _) => data.y1,
            name: "NG",
          ),
        ],
      ),
    );
  }
}

class _ChartData {
  _ChartData({
    this.x,
    this.y,
    this.y1,
  });

  final String? x;
  final int? y;
  final int? y1;
}
