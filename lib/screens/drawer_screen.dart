import 'package:flutter/material.dart';
import 'package:users/Splashscreens/splashscreen.dart';
import 'package:users/global/global.dart';
import 'package:users/screens/profile_screen.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      child: Drawer(
        child: Padding(
          padding: EdgeInsets.fromLTRB(30, 50, 0, 20),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person, color: Colors.white),
                  ),

                  SizedBox(height: 20),
                  Text(
                    userModelCurrentInfo!.name!,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),

                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => ProfileScreen()),
                      );
                    },
                    child: Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  Text(
                    "Your trips",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  SizedBox(height: 15),

                  Text(
                    "Payment",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  SizedBox(height: 15),

                  Text(
                    "Notifications",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  SizedBox(height: 15),

                  Text(
                    "Promos",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  SizedBox(height: 15),

                  Text(
                    "Help",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  SizedBox(height: 15),

                  Text(
                    "Free trips",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  SizedBox(height: 15),
                ],
              ),
              GestureDetector(
                onTap: () {
                  firebaseAuth.signOut();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => Splashscreen()),
                  );
                },
                child: Text(
                  "logout",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
