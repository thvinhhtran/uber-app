import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class YourTripsScreen extends StatelessWidget {
  const YourTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool darkTheme = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Lịch sử chuyến đi",
          style: TextStyle(
            color: darkTheme ? Colors.amber.shade400 : Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: darkTheme ? Colors.black : Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: darkTheme ? Colors.amber.shade400 : Colors.blue,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: user == null
          ? Center(
              child: Text(
                "Vui lòng đăng nhập để xem lịch sử chuyến đi!",
                style: TextStyle(
                  color: darkTheme ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('rideHistory')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Lỗi khi tải lịch sử: ${snapshot.error}",
                      style: TextStyle(
                        color: darkTheme ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "Không có lịch sử chuyến đi!",
                      style: TextStyle(
                        color: darkTheme ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final ride = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    final vehicle = ride['vehicle'] ?? 'Không xác định';
                    final fare = ride['fare']?.toStringAsFixed(0) ?? '0';
                    final pickup = ride['pickup'] ?? 'Không xác định';
                    final dropoff = ride['dropoff'] ?? 'Không xác định';
                    final distance = (ride['distance'] ?? 0) / 1000;
                    final timestamp = (ride['timestamp'] as Timestamp?)?.toDate();

                    return Card(
                      color: darkTheme ? Colors.grey.shade800 : Colors.white,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          vehicle,
                          style: TextStyle(
                            color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Giá: $fare VNĐ",
                              style: TextStyle(color: darkTheme ? Colors.white70 : Colors.black87),
                            ),
                            Text(
                              "Từ: $pickup",
                              style: TextStyle(color: darkTheme ? Colors.white70 : Colors.black87),
                            ),
                            Text(
                              "Đến: $dropoff",
                              style: TextStyle(color: darkTheme ? Colors.white70 : Colors.black87),
                            ),
                            Text(
                              "Khoảng cách: ${distance.toStringAsFixed(2)} km",
                              style: TextStyle(color: darkTheme ? Colors.white70 : Colors.black87),
                            ),
                            if (timestamp != null)
                              Text(
                                "Thời gian: ${DateFormat('dd/MM/yyyy HH:mm').format(timestamp)}",
                                style: TextStyle(color: darkTheme ? Colors.white70 : Colors.black87),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}