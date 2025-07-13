import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:users/models/direction.dart';

class AppInfo extends Notifier<AppInfo> {
  Direction? userPickUpLocation, userDropOffLocation;
  int countTotalTrips = 0;

  // List <String> historyTripsKeyList = [];
  // List <TripHistoryModel> allTripsHistoryInformationList = [];
  void updatePickUpLocationAddress(Direction pickUpAddress) {
    userPickUpLocation = pickUpAddress;
    state = this;
  }

  void updateDropOffLocationAddress(Direction dropOffAddress) {
    userDropOffLocation = dropOffAddress;
    state = this;
  }

  @override
  AppInfo build() => this;
}

// Tạo provider cho AppInfo
final appInfoProvider = NotifierProvider<AppInfo, AppInfo>(() => AppInfo());