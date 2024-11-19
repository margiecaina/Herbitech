import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../plant_and_disease_info/disease_info.dart';
import '../plant_and_disease_info/plant_info.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      _selectedDay = day;
      _focusedDay = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: _onDaySelected,
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Colors.green[600],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green[800]!, width: 2),
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.green[300],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green[500]!, width: 2),
                  ),
                  outsideDecoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  weekendTextStyle: TextStyle(
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  decoration: BoxDecoration(
                    color: Colors.green[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  leftChevronIcon: Icon(Icons.arrow_back, color: Colors.brown),
                  rightChevronIcon: Icon(Icons.arrow_forward, color: Colors.brown),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.green[700]),
                  weekendStyle: TextStyle(color: Colors.brown),
                ),
                calendarBuilders: CalendarBuilders(
                  singleMarkerBuilder: (context, date, events) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green[400],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the Plant Information page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlantInformationPage(),
                        ),
                      );
                    },
                    child: Text('Plants Information'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green[600],
                      minimumSize: Size(150, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the Disease Information page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DiseaseInformationPage(),
                        ),
                      );
                    },
                    child: Text('Diseases Information'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.orange[600],
                      minimumSize: Size(150, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              )

            ],
          ),
        ),
      ),
    );
  }
}
