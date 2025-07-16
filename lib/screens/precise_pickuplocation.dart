import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:users/Assisstants/assistants_method.dart';
import 'package:users/global/map_key.dart';
import 'package:users/infohandle/app_info.dart';
import 'package:users/models/direction.dart';

class PrecisePickupScreen extends ConsumerStatefulWidget {
  const PrecisePickupScreen({super.key});

  @override
  ConsumerState<PrecisePickupScreen> createState() =>
      _PrecisePickupScreenState();
}

class _PrecisePickupScreenState extends ConsumerState<PrecisePickupScreen> {
  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? _address;

  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;

  Position? userCurrentPosition;
  double bottomPaddingOfMap = 0;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(10.7769, 106.7009), // Hồ Chí Minh
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  locateUserPosition() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    userCurrentPosition = position;
    LatLng latLngPosition = LatLng(
      userCurrentPosition!.latitude,
      userCurrentPosition!.longitude,
    );
    CameraPosition cameraPosition = CameraPosition(
      target: latLngPosition,
      zoom: 14,
    );

    newGoogleMapController!.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );

    String humanReadableAddress =
        await AssistantsMethod.searchAddressForGeographicCoordinates(
          userCurrentPosition!,
          ref,
        );
  }

  getAddressFromLatLng() async {
    try {
      GeoData data = await Geocoder2.getDataFromCoordinates(
        latitude: pickLocation!.latitude,
        longitude: pickLocation!.longitude,
        googleMapApiKey: mapKey,
      );
      setState(() {
        Direction userPickUpAddress = Direction();
        userPickUpAddress.locationLatitude = pickLocation!.latitude;
        userPickUpAddress.locationLongitude = pickLocation!.longitude;
        userPickUpAddress.locationName = data.address;
        ref
            .read(appInfoProvider.notifier)
            .updatePickUpLocationAddress(userPickUpAddress); // dùng Riverpod
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              setState(() {
                bottomPaddingOfMap = 100; 
              });

              locateUserPosition();
            },
            onCameraMove: (CameraPosition position) {
              if (pickLocation != position!.target) {
                setState(() {
                  pickLocation = position.target;
                });
              }
            },
            onCameraIdle: () {
              getAddressFromLatLng();
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding:  EdgeInsets.only(top: 60.0, bottom: bottomPaddingOfMap),
              child: Image.asset(
                "images/assets/picks.png",
                height: 45,
                width: 45,
              ),
            ),
          ),

          Positioned(
            top: 40,
            right: 20,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(20),
              child: Text(
                ref.watch(appInfoProvider).userPickUpLocation != null
                    ? '${(ref.watch(appInfoProvider).userPickUpLocation!.locationName ?? '').substring(0, 24)}...'
                    : "Not Getting address",
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: ElevatedButton(
                onPressed: (){
                  Navigator.pop(context);

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.blue,
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                child: Text("Set Current Location"),
              )
            ),
          )

        ],
      ),
    );
  }
}
