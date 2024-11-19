import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:herbitect_protoype1/bottom_navbar/scan.dart';

import 'bottom_navbar/history.dart';
import 'bottom_navbar/inventory.dart';
import 'bottom_navbar/monitoring.dart';
import 'bottom_navbar/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Define the five pages
  final List<Widget> _pages = [
    HistoryPage(),
    MonitorPage(),
    ScanPage(),
    InventoryPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade100,
        centerTitle: true,
        title: Text(
          '-Herbitech-',
          style: GoogleFonts.bebasNeue(
            fontSize: 35,
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.lightGreen[50],
          child: ListView(
            children: [
              DrawerHeader(
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png', // Correct path to the image
                    width: 125, // Set width to 125
                    height: 125, // Set height to 125
                    fit: BoxFit.cover, // Optional fit property
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text(
                  'Log Out',
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                },
              ),
              // Add About Us section in the Drawer
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text(
                  'About Us',
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Herbitech',
                    applicationVersion: '1.0.0',
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          'Herbitech is a mobile application developed for a specific organization '
                              'to leverage AI-driven image detection in providing real-time insights into herbal '
                              'plants and diseases. Utilizing the YOLOv8 object detection algorithm, the app enables '
                              'users to capture plant images and access detailed information on plant health, disease '
                              'identification, and management strategies. While not a substitute for expert botanists, '
                              'Herbitech supports the organization’s efforts to enhance early disease detection and promote '
                              'sustainable practices.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      // Display the selected page based on the current index
      body: _pages[_currentIndex],

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,  // Ensure all items are visible
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart_rounded),
            label: 'Monitor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_rounded),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
