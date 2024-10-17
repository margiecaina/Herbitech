import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:herbitect_protoype1/bottom_navbar/scan.dart';

import 'bottom_navbar/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 2;

  // Define the five pages
  final List<Widget> _pages = [
    const Page1(),
    const Page2(),
    const ScanPage(),
    const Page4(),
    const Page5(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade100,
        centerTitle: true,
        title: Text(
          '-Herbitect-',
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
            label: 'History',
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

// First Page (History)
class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'History',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Second Page (Monitor)
class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Monitoring',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Third Page (Scan)
class Page3 extends StatefulWidget {
  const Page3({super.key});

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Scan',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Fourth Page (Inventory)
class Page4 extends StatelessWidget {
  const Page4({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Inventory',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    );
  }
}

