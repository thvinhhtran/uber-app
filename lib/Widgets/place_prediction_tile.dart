import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:users/Assisstants/request_assistants.dart';
import 'package:users/Widgets/progress_dialog.dart';
import 'package:users/global/global.dart';
import 'package:users/global/map_key.dart';
import 'package:users/infohandle/app_info.dart';
import 'package:users/models/direction.dart';
import 'package:users/models/predicated_place.dart';

class PlacePredictionTileDesign extends StatelessWidget {
  final PredicatedPlace? predicatedPlace;
  final WidgetRef ref;
  const PlacePredictionTileDesign({this.predicatedPlace, required this.ref, Key? key}) : super(key: key);

  Future<void> getPlaceDirectionDetails(
    String? placeId,
    BuildContext context,
  ) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Setting up Drop Off, Please wait...",
      ),
    );

    String placeDirectionUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var response = await RequestAssistants.receiveRequest(placeDirectionUrl);

    Navigator.pop(context); // Đóng ProgressDialog

    if (response != "Error Occurred, Failed. No Response.") {
      Direction userDropOffLocation = Direction();
      userDropOffLocation.locationName = response["result"]["name"];
      userDropOffLocation.locationId = placeId;
      userDropOffLocation.locationLatitude =
          response["result"]["geometry"]["location"]["lat"];
      userDropOffLocation.locationLongitude =
          response["result"]["geometry"]["location"]["lng"];

      // Cập nhật địa chỉ Drop Off trong AppInfo
      ref.read(appInfoProvider.notifier).updateDropOffLocationAddress(userDropOffLocation);
      Navigator.pop(context, "obtainDirection");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error occurred, Failed to get Place Details.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return ElevatedButton(
      onPressed: () {
        getPlaceDirectionDetails(predicatedPlace!.place_id, context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: darkTheme ? Colors.black : Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              Icons.add_location,
              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    predicatedPlace!.main_text!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                    ),
                  ),
                  Text(
                    predicatedPlace!.secondary_text!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}