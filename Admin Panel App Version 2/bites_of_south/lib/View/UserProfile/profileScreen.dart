import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                    'assets/placeholder.png'), // Replace with your profile image asset
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Name:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'John Doe', // Replace with the user's name
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Email:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'john.doe@example.com', // Replace with the user's email
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Phone:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '+1234567890', // Replace with the user's phone number
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Add your logout functionality here
                },
                child: Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
