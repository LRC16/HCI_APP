import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String arbitraryTimeUser = '09:30 AM';
    String arbitraryTimePartner = '08:15 PM';

    return Scaffold(
      appBar: AppBar(
        title: Text("Homepage"),
        actions: [
          IconButton(icon: Icon(Icons.emoji_emotions), onPressed: () {/* Set Status */}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("User Time: $arbitraryTimeUser"),
                    Text("User Weather: Sunny, 20°C"), // Placeholder
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Partner Time: $arbitraryTimePartner"),
                    Text("Partner Weather: Cloudy, 18°C"), // Placeholder
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}