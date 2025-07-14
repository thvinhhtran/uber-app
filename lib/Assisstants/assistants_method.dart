import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:users/Assisstants/request_assistants.dart';
import 'package:users/global/global.dart';
import 'package:users/global/map_key.dart';
import 'package:users/infohandle/app_info.dart';
import 'package:users/models/direction.dart';
import 'package:users/models/direction_details_info.dart';
import 'package:users/models/user_model.dart';

class AssistantsMethod {
  static void readCurrentOnlineUserInfo() async {
    currentUser = firebaseAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentUser!.uid);

    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }

  static Future<String> searchAddressForGeographicCoordinates(
    Position position,
    WidgetRef ref, // Sử dụng ref thay vì context
  ) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";

    var requestResponse = await RequestAssistants.receiveRequest(apiUrl);

    if(requestResponse != "Error Occurred, Failed. No Response.") {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      Direction userPickUpAddress = Direction();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      ref.read(appInfoProvider.notifier)
          .updatePickUpLocationAddress(userPickUpAddress);
    }

    return humanReadableAddress;
  }


  static Future<DirectionDetailsInfo?> obtainOriginToDestinationDirectionDetails(
    LatLng originPosition,
    LatLng destinationPosition,
  ) async {
    String urlOriginToDestinationDirectionDetails =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";

    var response = await RequestAssistants.receiveRequest(urlOriginToDestinationDirectionDetails);

    // In response ra console để debug
    print("Directions API response: $response");

    // Kiểm tra response hợp lệ và có route
    if (response == null ||
        response == "Error Occurred, Failed. No Response." ||
        response["routes"] == null ||
        (response["routes"] as List).isEmpty) {
      return null;
    }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points = response["routes"][0]["overview_polyline"]["points"];
    directionDetailsInfo.distance_text = response["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value = response["routes"][0]["legs"][0]["distance"]["value"];
    directionDetailsInfo.duration_text = response["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value = response["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }
}