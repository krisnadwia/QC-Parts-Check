import 'package:flutter/material.dart';
import 'package:qc_parts_check/admin/pengecekan/home_screen_pengecekan_admin.dart';
import 'package:qc_parts_check/admin/supplier/home_screen_supplier_admin.dart';
import 'package:qc_parts_check/support_pages/profil/profile_screen.dart';
import '../utils/logout_popup.dart';

class BottomNavbarAdmin extends StatefulWidget {
  const BottomNavbarAdmin({super.key});

  @override
  State<StatefulWidget> createState() => _BottomNavbarAdminState();
}

class _BottomNavbarAdminState extends State<BottomNavbarAdmin> {
  int _selectedIndex = 0;
  late PageController _pageController;
  bool didPop = true;

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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        showLogoutPopup(context);
        return;
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: SizedBox.expand(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _selectedIndex = index);
            },
            children: const [
              HomeScreenPengecekanAdmin(),
              HomeScreenSupplierAdmin(),
              ProfileScreen(),
            ],
          ),
        ),
        bottomNavigationBar: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(24),
            topLeft: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.amber,
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.black45,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                activeIcon: Container(
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.dashboard_customize_outlined),
                  ),
                ),
                icon: const Icon(Icons.dashboard_customize_outlined),
                tooltip: "Pengecekan",
                label: "Pengecekan",
              ),
              BottomNavigationBarItem(
                activeIcon: Container(
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.construction),
                  ),
                ),
                icon: const Icon(Icons.construction),
                tooltip: "Part",
                label: "Part",
              ),
              BottomNavigationBarItem(
                activeIcon: Container(
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.person),
                  ),
                ),
                icon: const Icon(Icons.person),
                tooltip: "Profil",
                label: "Profil",
              ),
            ],
          ),
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
