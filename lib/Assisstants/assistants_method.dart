import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:users/Assisstants/request_assistants.dart';
import 'package:users/global/global.dart';
import 'package:users/global/map_key.dart';
import 'package:users/models/direction.dart';
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
    context,
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

       



    }

    return humanReadableAddress;

  }
}
