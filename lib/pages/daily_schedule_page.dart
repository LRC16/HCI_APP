import 'package:flutter/material.dart';
import '../models/schedule_data.dart';
import '../widgets/dotted_border_painter.dart';
import 'package:intl/intl.dart';


class DailySchedulePage extends StatefulWidget {
  final DateTime selectedDate;

  DailySchedulePage({required this.selectedDate});
  

  @override
  _DailySchedulePageState createState() => _DailySchedulePageState();
}

class _DailySchedulePageState extends State<DailySchedulePage> {
  late List<Map<String, dynamic>> sharedTimeTable;
  late DateTime selectedDate = selectedDate;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    _initializeScheduleForDate(widget.selectedDate);
  }

  void _initializeScheduleForDate(DateTime date) {
    DateTime normalizedDate = DateTime(date.year, date.month, date.day);

    if (!schedules.containsKey(normalizedDate)) {
      schedules[normalizedDate] = [
  {
    "time": "08:00 - 09:00",
    "user": "me",
    "title": "Exercise",
    "type": "study_work",
    "score": 5  // me + study_work
  },
  {
    "time": "08:00 - 10:15",
    "user": "partner",
    "title": "Team Meeting",
    "type": "study_work",
    "score": 6  // partner + study_work
  },
  {
    "time": "11:00 - 12:30",
    "user": "me",
    "title": "Work on Project",
    "type": "study_work",
    "score": 5  // me + study_work
  },
  {
    "time": "14:00 - 15:00",
    "user": "me",
    "title": "Lecture",
    "type": "study_work",
    "score": 5  // me + study_work
  },
  {
    "time": "16:00 - 17:00",
    "user": "partner",
    "title": "Study in the Library",
    "type": "study_work",
    "score": 6  // partner + study_work
  },
  {
    "time": "00:00 - 06:00",
    "user": "me",
    "title": "Sleep",
    "type": "other",
    "score": 0  // other type
  },
  {
    "time": "00:00 - 05:00",
    "user": "partner",
    "title": "Sleep",
    "type": "other",
    "score": 0  // other type
  },
  {
    "time": "14:15 - 14:45",
    "user": "partner",
    "title": "Coffee",
    "type": "entertainment",
    "score": -4  // partner + entertainment
  },
  {
    "time": "18:15 - 19:45",
    "user": "me",
    "title": "Game",
    "type": "entertainment",
    "score": -5  // me + entertainment
  },
  {
    "time": "23:00 - 23:59",
    "user": "me",
    "title": "Sleep",
    "type": "other",
    "score": 0  // other type
  },
  {
    "time": "22:00 - 23:59",
    "user": "partner",
    "title": "Sleep",
    "type": "other",
    "score": 0  // other type
  },
  {
    "time": "20:00 - 21:15",
    "user": "both",
    "title": "Video Call",
    "type": "other",
    "score": -8  // other type
  },
      ];
    }

    // Sort events by start time
    schedules[normalizedDate]!.sort((a, b) {
      final startTimeA = _parseTime(a["time"].split(" - ")[0]);
      final startTimeB = _parseTime(b["time"].split(" - ")[0]);
      return startTimeA.compareTo(startTimeB);
    });

    sharedTimeTable = schedules[normalizedDate]!;
  }

  DateTime _parseTime(String time) {
    final parts = time.split(":");
    return DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double pixelPerMinute = 2.0; // 1 minute = 1 pixel
    List<Widget> meColumnWidgets = [];
    List<Widget> partnerColumnWidgets = [];
    List<Widget> columnWidgets = [];
    //List<Widget> timelineWidgets = [];
    DateTime currentTimeMe = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      0,
      0,
    );
    DateTime currentTimePartner = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      0,
      0,
    );

    for (int i = 0; i < sharedTimeTable.length; i++) {
      final slot = sharedTimeTable[i];
      final timeRange = slot["time"].split(" - ");
      final startTime = _parseTime(timeRange[0]);
      final endTime = _parseTime(timeRange[1]);
      final durationInMinutes = endTime.difference(startTime).inMinutes;

      // Add free time for both columns





      if (currentTimeMe.isBefore(startTime)&&currentTimePartner.isBefore(startTime)) {
        if (currentTimePartner.isBefore(currentTimeMe)){
          partnerColumnWidgets.add(_buildGapPartner(currentTimeMe.difference(currentTimePartner).inMinutes*pixelPerMinute, currentTimePartner, currentTimeMe));
          currentTimePartner = currentTimeMe;
        }
        if (currentTimePartner.isAfter(currentTimeMe)){
          meColumnWidgets.add(_buildGap(currentTimePartner.difference(currentTimeMe).inMinutes*pixelPerMinute, currentTimeMe, currentTimePartner));
          currentTimeMe = currentTimePartner;
        }





        

        columnWidgets.add(Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Expanded(child: Column(children: meColumnWidgets,)),
              Expanded(child: Column(children: partnerColumnWidgets)),
              ]
          ),
        );

        meColumnWidgets = [];
        partnerColumnWidgets = [];
        final gapDuration = startTime.difference(currentTimeMe).inMinutes;
        
        columnWidgets.add(_buildFreeTime(gapDuration * pixelPerMinute, currentTimeMe, startTime));
        
        //timelineWidgets.add(_buildTimelineGap(gapDuration * pixelPerMinute));
        currentTimeMe = startTime;
        currentTimePartner = startTime;

      }

      // Add event
      if (slot["user"] == "me") {
        if(currentTimeMe.isBefore(startTime)){
          final gapDuration = startTime.difference(currentTimeMe).inMinutes;
          meColumnWidgets.add(_buildGap(gapDuration * pixelPerMinute, currentTimeMe, startTime));
        }
        meColumnWidgets.add(_buildEventMe(
          title: slot["title"],
          height: durationInMinutes * pixelPerMinute,
          selectedUser: "me",
          startTime:startTime,
          endTime:endTime,
          type: slot["type"]
        ));
        currentTimeMe = endTime;
        
      } else if (slot["user"] == "partner") {
        
        if(currentTimePartner.isBefore(startTime)){
          final gapDuration = startTime.difference(currentTimePartner).inMinutes;
          partnerColumnWidgets.add(_buildGapPartner(gapDuration * pixelPerMinute, currentTimePartner, startTime));
        }
        partnerColumnWidgets.add(_buildEvent(
          title: slot["title"],
          height: durationInMinutes * pixelPerMinute,
          color: Colors.red[100]!,
          type: slot["type"]
        ));
        currentTimePartner = endTime;
      } else if (slot["user"] == "both") {
        if (currentTimePartner.isBefore(currentTimeMe)){
          partnerColumnWidgets.add(_buildGapPartner(-currentTimePartner.difference(currentTimeMe).inMinutes*pixelPerMinute, currentTimePartner, currentTimeMe));
          currentTimePartner = currentTimeMe;
        }
        else if(currentTimePartner.isAfter(currentTimeMe)){
          meColumnWidgets.add(_buildGap(currentTimePartner.difference(currentTimeMe).inMinutes*pixelPerMinute, currentTimeMe, currentTimePartner));
          currentTimeMe = currentTimePartner;
        }

        columnWidgets.add(Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Expanded(child: Column(children: meColumnWidgets,)),
              Expanded(child: Column(children: partnerColumnWidgets)),
              ]
          ),
        );
        meColumnWidgets = [];
        partnerColumnWidgets = [];


        columnWidgets.add(_buildEventMe(
          title: slot["title"],
          height: durationInMinutes * pixelPerMinute,
          selectedUser: "both",
          startTime: startTime,
          endTime: endTime,
          type: slot["type"]
        ));
        currentTimeMe = endTime;
        currentTimePartner = endTime;
      }

      // Add to timeline
      //timelineWidgets.add(_buildTimelineLabel("${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}"));

      // Update current time
    }

    // Handle remaining time after the last event
    DateTime endOfDay = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      23,
      59,
    );
    
    if (!currentTimeMe.isAfter(endOfDay)||!currentTimePartner.isAfter(endOfDay)) {
        if (currentTimePartner.isBefore(currentTimeMe)){
          partnerColumnWidgets.add(_buildGapPartner(-currentTimePartner.difference(currentTimeMe).inMinutes*pixelPerMinute, currentTimePartner, currentTimeMe));
          currentTimePartner = currentTimeMe;
        }
        else if(currentTimePartner.isAfter(currentTimeMe)){
          meColumnWidgets.add(_buildGap(currentTimePartner.difference(currentTimeMe).inMinutes*pixelPerMinute, currentTimeMe, currentTimePartner));
          currentTimeMe = currentTimePartner;
        }

        columnWidgets.add(Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Expanded(child: Column(children: meColumnWidgets,)),
              Expanded(child: Column(children: partnerColumnWidgets)),
              ]
          ),
        );
        meColumnWidgets = [];
        partnerColumnWidgets = [];
        final gapDuration = endOfDay.difference(currentTimeMe).inMinutes;
        
        columnWidgets.add(_buildFreeTime(gapDuration * pixelPerMinute, currentTimeMe, endOfDay));
        



        currentTimeMe = endOfDay;
        currentTimePartner = endOfDay;
      }

      DateTime today = widget.selectedDate;

  // Get the next day
  DateTime nextDay = today.add(Duration(days: 1));

  // Get the previous day
  DateTime previousDay = today.subtract(Duration(days: 1));

    return Scaffold(
  appBar: AppBar(
    actions: [
    IconButton(
      icon: Icon(Icons.today),
      onPressed: () {
        // Action when pressed
        Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DailySchedulePage(selectedDate: DateTime.now()),
        ),
      );
      },
    ),],
  
    title: GestureDetector(
    onTap: () async{  DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DailySchedulePage(selectedDate: pickedDate),
        ),
      );
    };
  },

    child : Text("Schedule for ${DateFormat('dd/MM/yyyy').format(widget.selectedDate)}", style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: Colors.grey.shade900,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic
      ),),
    )
  
  ),
  body: GestureDetector(
    onHorizontalDragEnd: (details) {
      // Detect swipe direction
      if (details.velocity.pixelsPerSecond.dx > 0) {
        // Swipe right: Go to previous day
        Navigator.of(context).pushReplacement(
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        DailySchedulePage(selectedDate: previousDay),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(-1.0, 0.0); // Slide from right
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 200), // Adjust duration
  ),
);

      } else if (details.velocity.pixelsPerSecond.dx < 0) {
        // Swipe left: Go to next day
        Navigator.of(context).pushReplacement(
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        DailySchedulePage(selectedDate: nextDay),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // Slide from right
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 200), // Adjust duration
  ),
);

        
      }
    },
    child:Column(
    children: [
      // Add your new widget here
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                DateTime startOfWeek = widget.selectedDate.subtract(Duration(days: widget.selectedDate.weekday - 1));
                DateTime day = startOfWeek.add(Duration(days: index));
                bool isSelected = day.day == widget.selectedDate.day;
                bool isToday = day.day == DateTime.now().day;

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        DailySchedulePage(selectedDate: day),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(-1.0, 0.0); 
      const end = Offset.zero;
      const curve = Curves.easeInOut;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      if(widget.selectedDate.isAfter(day)){
        
      }else{
      // Slide from right
      const begin1 = Offset(1.0, 0.0); 

      tween = Tween(begin: begin1, end: end).chain(CurveTween(curve: curve));
      }
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 200), // Adjust duration
  ),
);

                  },
                  child: Column(
                    children: [
                      Text(
                        day.day.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.blue : Colors.black,
                        ),
                      ),
                      Text(
                        ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"][day.weekday - 1],
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? Colors.blue : Colors.black,
                        ),
                      ),
                      if (isToday)
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // Profile Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue[100],
                      child: Icon(Icons.person, size: 30),
                    ),
                    SizedBox(height: 8),
                    Text("Me", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.red[100],
                      child: Icon(Icons.person_outline, size: 30),
                    ),
                    SizedBox(height: 8),
                    Text("Partner", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      // SingleChildScrollView goes here
      Expanded(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimelineLabel(),
              Expanded(child: Column(children: columnWidgets)),
              _buildTimelineLabelPartner()
              
            ],
          ),
        ),
      ),
    ],
  ),
  ),
  floatingActionButton: FloatingActionButton(
 onPressed: () async{  DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DailySchedulePage(selectedDate: pickedDate),
        ),
      );
    };
  },
 child: Icon(Icons.calendar_today),
 backgroundColor: Colors.blue[100]!,
),

);
  }

  Widget _buildGap(double height, DateTime startTime, DateTime endTime) {
    return GestureDetector(
                              onTap: () => _addPrivateEvent(startTime, endTime),
                              child: 
                            Container(
      height: height,
      margin: EdgeInsets.all(0),
      
      color: Colors.white,
        
    )
    ); 
  }

  Widget _buildGapPartner(double height, DateTime startTime, DateTime endTime) {
    return GestureDetector(
                              
                              child: 
                            Container(
      height: height,
      margin: EdgeInsets.all(0),
      
      color: Colors.white,
        
    )
    ); 
  }

  Widget _buildFreeTime(
    double height,
    DateTime startTime,
    DateTime endTime
) {
  return GestureDetector(
    onTap: () => _addEvent(startTime, endTime),
    child: Container(
      height: height,
      margin: EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: DottedBorderPainter(
          color: Colors.grey.shade400,
          strokeWidth: 2.0,
          gapWidth: 5.0,
        ),
        child: Center(
          child: Text(
            "Free Time For Both",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    )
  );
}




  Widget _buildEventMe({
  required String title,
  required double height,
  required String type,
  required String selectedUser, // 'me' or 'both'
  required DateTime startTime,
  required DateTime endTime,
}) {
  return GestureDetector(
    onLongPress: () => _delete(title, startTime, endTime),
    child: Container(
      height: height,
      margin: const EdgeInsets.all(0),
      // Main container with blue/purple background
      decoration: BoxDecoration(
        color: selectedUser == 'me' 
            ? Colors.blue[100]
            : Colors.purple[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Container(
          // Made container taller by reducing vertical margins
          margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0), // Reduced vertical margin
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0), // Increased vertical padding
          constraints: BoxConstraints(
            minHeight: height * 0.85, // Makes inner container take up most of the height
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0),
            borderRadius: BorderRadius.circular(0),
            border: Border.all(
              color: getColorForType(type),
              width: 5,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade900,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ),
      ),
    ),
  );
}

  void _delete(String title, DateTime startTime, DateTime endTime) async {
  bool? confirmDelete = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirm Deletion"),
        content: Text("Are you sure you want to delete this event?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text("Delete"),
          ),
        ],
      );
    },
  );

  if (confirmDelete == true) {
    int j = -1;

    for (int i = 0; i < sharedTimeTable.length; i++) {
      final slot = sharedTimeTable[i];
      final timeRange = slot["time"].split(" - ");
      final startTime0 = _parseTime(timeRange[0]);
      final endTime0 = _parseTime(timeRange[1]);

      if (title == slot["title"] && startTime == startTime0 && endTime == endTime0) {
        j = i;
        break;
      }
    }

    if (j != -1) {
      setState(() {
        schedules[widget.selectedDate]!.removeAt(j);

        // Sort events and refresh the schedule
        _initializeScheduleForDate(widget.selectedDate);
      });
    }
  }
}



  Widget _buildEvent({
    required String title,
    required double height,
    required Color color,
    required String type
  }) {return
      Container(
      height: height,
      margin: const EdgeInsets.all(0),
      // Main container with blue/purple background
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Container(
          // Made container taller by reducing vertical margins
          margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0), // Reduced vertical margin
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0), // Increased vertical padding
          constraints: BoxConstraints(
            minHeight: height * 0.85, // Makes inner container take up most of the height
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0),
            borderRadius: BorderRadius.circular(0),
            border: Border.all(
              color: getColorForType(type),
              width: 5,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade900,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ),
      ),
    );
  }

  

  Widget _buildTimelineLabel() {
  const double hourHeight = 60.0 * 2; // 1 hour = 60 pixels (1 minute = 1 pixel)

  List<Widget> timelineWidgets = [];
  for (int hour = 0; hour < 24; hour++) {
    timelineWidgets.add(
      Container(
        height: hourHeight,
        width: 50,
        alignment: Alignment.topCenter,
        child: Text(
          "${hour.toString().padLeft(2, '0')}:00",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }

  return Column(children: timelineWidgets);
}

Widget _buildTimelineLabelPartner() {
  const double hourHeight = 60.0 * 2; // 1 hour = 60 pixels (1 minute = 1 pixel)

  List<Widget> timelineWidgets = [];
  for (int hour = 1; hour < 25; hour++) {
    timelineWidgets.add(
      Container(
        height: hourHeight,
        width: 50,
        alignment: Alignment.topCenter,
        child: Text(
          "${hour.toString().padLeft(2, '0')}:00",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }

  return Column(children: timelineWidgets);
}

  void _addEvent(DateTime startTime, DateTime endTime) async {
    final TextEditingController titleController = TextEditingController();
    TimeOfDay? selectedStartTime = TimeOfDay.fromDateTime(startTime);
    TimeOfDay? selectedEndTime = TimeOfDay.fromDateTime(endTime);
    String selectedUser = "both"; // Default to "both"
    String selectedType = "other";
    int selectedScore = 0;

    final newEvent = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Add New Event"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: "Event Title"),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text("Start Time:"),
                      TextButton(
                        onPressed: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(startTime),
                          );
                          
                          if (pickedTime != null) {
                            if (DateTime(startTime.year,startTime.month, startTime.day,pickedTime.hour,pickedTime.minute).isBefore(startTime)) {
                              showDialog<void>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Invalid Time"),
                                  content: Text("Start time must be after ${TimeOfDay.fromDateTime(startTime).format(context)}"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }
                            if (!DateTime(startTime.year,startTime.month, startTime.day,pickedTime.hour,pickedTime.minute).isBefore(endTime)) {
                              showDialog<void>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Invalid Time"),
                                  content: Text("Start time must be before ${TimeOfDay.fromDateTime(endTime).format(context)}"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }
                            if(selectedEndTime != null){
                              if (!DateTime(startTime.year,startTime.month, startTime.day,pickedTime.hour,pickedTime.minute).isBefore
                                (DateTime(startTime.year,startTime.month, startTime.day,selectedEndTime!.hour,selectedEndTime!.minute))) {
                                  showDialog<void>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("Invalid Time"),
                                      content: Text("End time must be after start time"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("OK"),
                                        ),
                                      ],
                                    ),
                                  );
                                  return;
                                }
                            }
                            setState(() {
                              selectedStartTime = pickedTime;
                            });
                          }
                          

                        },
                        child: Text(
                          selectedStartTime?.format(context) ?? "Select",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text("End Time:"),
                      TextButton(
                        onPressed: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(endTime),
                          );
                          if (pickedTime != null) {
                            if (DateTime(endTime.year,endTime.month, endTime.day,pickedTime.hour,pickedTime.minute).isAfter(endTime)) {
                              showDialog<void>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Invalid Time"),
                                  content: Text("End time must be before ${TimeOfDay.fromDateTime(endTime).format(context)}"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }

                            if (!DateTime(startTime.year,startTime.month, startTime.day,pickedTime.hour,pickedTime.minute).isAfter
                              (startTime)) {
                                showDialog<void>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Invalid Time"),
                                    content: Text("End time must be after ${TimeOfDay.fromDateTime(startTime).format(context)}"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("OK"),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                            }
                            
                            if (selectedStartTime != null) {
                              if (!DateTime(startTime.year,startTime.month, startTime.day,pickedTime.hour,pickedTime.minute).isAfter
                              (DateTime(startTime.year,startTime.month, startTime.day,selectedStartTime!.hour,selectedStartTime!.minute))) {
                                showDialog<void>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Invalid Time"),
                                    content: Text("End time must be after start time"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("OK"),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }
                            }
                              
                            
                            setState(() {
                              selectedEndTime = pickedTime;
                            });
                          }
                        },
                        child: Text(
                          selectedEndTime?.format(context) ?? "Select",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  Row(
  children: [
    Text("For:"),
    Flexible(
      child: Row(
        children: [
          Radio<String>(
            value: "me",
            groupValue: selectedUser,
            onChanged: (value) {
              setState(() {
                selectedUser = value!;
              });
            },
          ),
          Text("Me"),
        ],
      ),
    ),
    Flexible(
      child: Row(
        children: [
          Radio<String>(
            value: "both",
            groupValue: selectedUser,
            onChanged: (value) {
              setState(() {
                selectedUser = value!;
              });
            },
          ),
          Text("Both"),
        ],
      ),
    ),
  ],
),
DropdownButtonFormField<int>(
  value: selectedScore,
  decoration: InputDecoration(
    labelText: 'Score',
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
  ),
  items: scores.map((int score) {
    return DropdownMenuItem<int>(
      value: score,
      child: Text(score.toString()),
    );
  }).toList(),
  onChanged: (int? newValue) {
    setState(() {
      selectedScore = newValue!;
    });
    // Use the selected score here
    print('Selected score: $newValue');
  },
  validator: (value) {
    if (value == null) {
      return 'Please select a score';
    }
    return null;
  },
),
      Padding(
  padding: const EdgeInsets.symmetric(vertical: 8.0),
  child: Column(  // Changed outer Row to Column
    children: [
      const Text('Type:', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8), // Add some spacing
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<String>(
                  value: 'study_work',
                  groupValue: selectedType,
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const Text('Study/Work'),
              ],
            ),
          ),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<String>(
                  value: 'entertainment',
                  groupValue: selectedType,
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const Text('Entertainment'),
              ],
            ),
          ),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<String>(
                  value: 'other',
                  groupValue: selectedType,
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const Text('Other'),
              ],
            ),
          ),
        ],
      ),
    ],
  ),
)

                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        selectedStartTime != null &&
                        selectedEndTime != null) {
                      Navigator.of(context).pop({
                        "title": titleController.text,
                        "startTime": selectedStartTime,
                        "endTime": selectedEndTime,
                        "user": selectedUser,
                        "type": selectedType,
                        "score": selectedScore
                      });
                    }
                  },
                  child: Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );

    if (newEvent != null) {
      // Extract event details
      String title = newEvent["title"];
      TimeOfDay startTime = newEvent["startTime"];
      TimeOfDay endTime = newEvent["endTime"];
      String user = newEvent["user"];
      String type = newEvent["type"];
      int score = newEvent["score"];

      // Add the event
      setState(() {
        schedules[widget.selectedDate]!.add({
          "time": "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}",
          "user": user,
          "title": title,
          "type" : type,
          "score": score
        });

        // Sort events and refresh the schedule
        _initializeScheduleForDate(widget.selectedDate);
      });
    }
  }

  
  void _addPrivateEvent(DateTime startTime, DateTime endTime) async {
    final TextEditingController titleController = TextEditingController();
    TimeOfDay? selectedStartTime = TimeOfDay.fromDateTime(startTime);
    TimeOfDay? selectedEndTime = TimeOfDay.fromDateTime(endTime);
    String selectedUser = "me"; // Default to "both"
    String selectedType = "other";
    int selectedScore = 0;

    final newEvent = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Add New Event"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: "Event Title"),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text("Start Time:"),
                      TextButton(
                        onPressed: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(startTime),
                          );
                          
                          if (pickedTime != null) {
                            if (DateTime(startTime.year,startTime.month, startTime.day,pickedTime.hour,pickedTime.minute).isBefore(startTime)) {
                              showDialog<void>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Invalid Time"),
                                  content: Text("Start time must be after ${TimeOfDay.fromDateTime(startTime).format(context)}"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }
                            if (!DateTime(startTime.year,startTime.month, startTime.day,pickedTime.hour,pickedTime.minute).isBefore(endTime)) {
                              showDialog<void>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Invalid Time"),
                                  content: Text("Start time must be before ${TimeOfDay.fromDateTime(endTime).format(context)}"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }
                            if(selectedEndTime != null){
                              if (!DateTime(startTime.year,startTime.month, startTime.day,pickedTime.hour,pickedTime.minute).isBefore
                                (DateTime(startTime.year,startTime.month, startTime.day,selectedEndTime!.hour,selectedEndTime!.minute))) {
                                  showDialog<void>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("Invalid Time"),
                                      content: Text("End time must be after start time"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("OK"),
                                        ),
                                      ],
                                    ),
                                  );
                                  return;
                                }
                            }
                            setState(() {
                              selectedStartTime = pickedTime;
                            });
                          }
                          

                        },
                        child: Text(
                          selectedStartTime?.format(context) ?? "Select",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text("End Time:"),
                      TextButton(
                        onPressed: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(endTime),
                          );
                          if (pickedTime != null) {
                            if (DateTime(endTime.year,endTime.month, endTime.day,pickedTime.hour,pickedTime.minute).isAfter(endTime)) {
                              showDialog<void>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Invalid Time"),
                                  content: Text("End time must be before ${TimeOfDay.fromDateTime(endTime).format(context)}"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }

                            if (!DateTime(startTime.year,startTime.month, startTime.day,pickedTime.hour,pickedTime.minute).isAfter
                              (startTime)) {
                                showDialog<void>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Invalid Time"),
                                    content: Text("End time must be after ${TimeOfDay.fromDateTime(startTime).format(context)}"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("OK"),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                            }
                            
                            if (selectedStartTime != null) {
                              if (!DateTime(startTime.year,startTime.month, startTime.day,pickedTime.hour,pickedTime.minute).isAfter
                              (DateTime(startTime.year,startTime.month, startTime.day,selectedStartTime!.hour,selectedStartTime!.minute))) {
                                showDialog<void>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Invalid Time"),
                                    content: Text("End time must be after start time"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("OK"),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }
                            }
                              
                            
                            setState(() {
                              selectedEndTime = pickedTime;
                            });
                          }
                        },
                        child: Text(
                          selectedEndTime?.format(context) ?? "Select",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  
                    
  DropdownButtonFormField<int>(
  value: selectedScore,
  decoration: InputDecoration(
    labelText: 'Score',
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
  ),
  items: scores.map((int score) {
    return DropdownMenuItem<int>(
      value: score,
      child: Text(score.toString()),
    );
  }).toList(),
  onChanged: (int? newValue) {
    setState(() {
      selectedScore = newValue!;
    });
    // Use the selected score here
    print('Selected score: $newValue');
  },
  validator: (value) {
    if (value == null) {
      return 'Please select a score';
    }
    return null;
  },
)
,
  Padding(
  padding: const EdgeInsets.symmetric(vertical: 8.0),
  child: Column(  // Changed outer Row to Column
    children: [
      const Text('Type:', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8), // Add some spacing
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<String>(
                  value: 'study_work',
                  groupValue: selectedType,
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const Text('Study/Work'),
              ],
            ),
          ),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<String>(
                  value: 'entertainment',
                  groupValue: selectedType,
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const Text('Entertainment'),
              ],
            ),
          ),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<String>(
                  value: 'other',
                  groupValue: selectedType,
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const Text('Other'),
              ],
            ),
          ),
        ],
      ),
    ],
  ),
)
 

                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        selectedStartTime != null &&
                        selectedEndTime != null) {
                      Navigator.of(context).pop({
                        "title": titleController.text,
                        "startTime": selectedStartTime,
                        "endTime": selectedEndTime,
                        "user": selectedUser,
                        "type": selectedType,
                        "score": selectedScore
                      });
                    }
                  },
                  child: Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );

    if (newEvent != null) {
      // Extract event details
      String title = newEvent["title"];
      TimeOfDay startTime = newEvent["startTime"];
      TimeOfDay endTime = newEvent["endTime"];
      String user = newEvent["user"];
      String type = newEvent["type"];
      int score = newEvent["score"];

      // Add the event
      setState(() {
        schedules[widget.selectedDate]!.add({
          "time": "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}",
          "user": user,
          "title": title,
          "type" : type,
          "score" : score
        });

        // Sort events and refresh the schedule
        _initializeScheduleForDate(widget.selectedDate);
      });
    }
  }

  
}