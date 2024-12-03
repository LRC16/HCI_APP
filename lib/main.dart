import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/daily_schedule_page.dart';
import 'pages/mental_load_page.dart';

void main() {
  runApp(MyApp());
}
Map<DateTime, List<Map<String, dynamic>>> schedules = {};
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schedule App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;
  DateTime currentDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(  // Use IndexedStack instead of a List
        index: _selectedIndex,
        children: [
          HomePage(),
          Navigator(  // Wrap only DailySchedulePage in a Navigator
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => DailySchedulePage(selectedDate: currentDate),
                maintainState: true,
              );
            },
          ),
          MentalLoadIndicator(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

 


// Calendar Page with Calendar Grid and Daily Schedule Navigation

