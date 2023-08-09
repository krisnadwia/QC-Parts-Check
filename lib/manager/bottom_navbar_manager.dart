import 'package:flutter/material.dart';
import 'package:qc_parts_check/manager/pengecekan/home_screen_pengecekan_manager.dart';
import 'package:qc_parts_check/manager/supplier/home_screen_supplier_manager.dart';
import 'package:qc_parts_check/support_pages/profil/profile_screen.dart';
import '../support_pages/grafik/home_screen_graph.dart';
import '../utils/logout_popup.dart';

class BottomNavbarManager extends StatefulWidget {
  const BottomNavbarManager({super.key});

  @override
  State<StatefulWidget> createState() => _BottomNavbarManagerState();
}

class _BottomNavbarManagerState extends State<BottomNavbarManager> {
  int currentIndex = 0;
  final screens = [
    const HomeScreenPengecekanManager(),
    const HomeScreenSupplierManager(),
    const HomeScreenGraph(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showLogoutPopup(context),
      child: Scaffold(
        backgroundColor: const Color(0xffe7e430),
        body: IndexedStack(
          index: currentIndex,
          children: screens,
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(6),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                30,
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black45, spreadRadius: 0, blurRadius: 5),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                30,
              ),
              child: BottomNavigationBar(
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.black,
                selectedFontSize: 15,
                currentIndex: currentIndex,
                onTap: (index) => setState(() => currentIndex = index),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_customize_outlined),
                    tooltip: "Menu Utama",
                    label: "Menu Utama",
                    backgroundColor: Colors.grey,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.construction),
                    tooltip: "Supplier Part",
                    label: "Supplier Part",
                    backgroundColor: Colors.green,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.monitor_heart_outlined),
                    tooltip: "Grafik Part",
                    label: "Grafik Part",
                    backgroundColor: Colors.blue,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    tooltip: "Detail Profil",
                    label: "Detail Profil",
                    backgroundColor: Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
