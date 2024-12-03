import 'package:flutter/material.dart';

class MentalLoadIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mental Load Indicator")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Your Mental Load: __%"),
            Text("Partner's Mental Load: __%"),
          ],
        ),
      ),
    );
  }
}