import 'package:flutter/material.dart';

Map<DateTime, List<Map<String, dynamic>>> schedules = {};

final Map<String, Color> activityColorMap = {
  'study_work': Colors.red.shade400,
  'entertainment': Colors.green.shade400,
  'other': Colors.yellow.shade400,
};

final scores = List.generate(21, (index) => index - 10);

Color getColorForType(String type) {
  return activityColorMap[type] ?? Colors.grey; 
}