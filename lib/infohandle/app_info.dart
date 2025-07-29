import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:users/models/direction.dart';
import 'package:users/models/user_model.dart';
import 'package:users/models/vehicle.dart';

class AppInfo extends Notifier<AppInfo> {
 Direction? userPickUpLocation;
  Direction? userDropOffLocation;
  Vehicle? selectedVehicle;
  double? selectedFare;
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

  void updateSelectedVehicle(Vehicle vehicle, double fare) {
    selectedVehicle = vehicle;
    selectedFare = fare;
    countTotalTrips += 1;
    state = this;
  }

  @override
  AppInfo build() => this;
}

// Tạo provider cho AppInfo
final appInfoProvider = NotifierProvider<AppInfo, AppInfo>(() => AppInfo());

final userProvider = StateProvider<UserModel?>((ref) => null);