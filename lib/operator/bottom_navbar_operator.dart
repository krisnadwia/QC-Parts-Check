import 'package:flutter/material.dart';
import 'package:qc_parts_check/operator/pengecekan/home_screen_pengecekan_operator.dart';
import 'package:qc_parts_check/operator/supplier/home_screen_supplier_operator.dart';
import 'package:qc_parts_check/support_pages/profil/profile_screen.dart';
import 'package:qc_parts_check/utils/logout_popup.dart';

import '../support_pages/grafik/home_screen_graph.dart';

class BottomNavbarOperator extends StatefulWidget {
  const BottomNavbarOperator({super.key});

  @override
  State<StatefulWidget> createState() => _BottomNavbarOperatorState();
}

class _BottomNavbarOperatorState extends State<BottomNavbarOperator> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showLogoutPopup(context),
      child: Scaffold(
        body: SizedBox.expand(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _selectedIndex = index);
            },
            children: const [
              HomeScreenPengecekanOperator(),
              HomeScreenSupplierOperator(),
              HomeScreenGraph(),
              ProfileScreen(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          unselectedItemColor: Colors.black,
          selectedItemColor: Colors.white,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_customize_outlined),
              tooltip: "Pengecekan",
              label: "Pengecekan",
              backgroundColor: Colors.orange,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.construction),
              tooltip: "Part",
              label: "Part",
              backgroundColor: Colors.green,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.monitor_heart_outlined),
              tooltip: "Grafik",
              label: "Grafik",
              backgroundColor: Colors.blue,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              tooltip: "Profil",
              label: "Profil",
              backgroundColor: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Using this page controller you can make beautiful animation effects
      _pageController.animateToPage(
        index,
        duration: const Duration(
          milliseconds: 500,
        ),
        curve: Curves.easeOut,
      );
    });
  }
}
