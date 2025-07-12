import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:users/Assisstants/assistants_method.dart';
import 'package:users/global/global.dart';
import 'package:users/global/map_key.dart';
import 'package:users/infohandle/app_info.dart';
import 'package:users/models/direction.dart';
import 'package:users/themeprovider/theme_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? _address;

  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  double searchLocationContainerHeight = 220;
  double waitingResponsefromDriverContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;

  Position? userCurrentPosition;
  var geoLocatoion = AboutDialog();
  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoordinatedList = [];
  Set<Polyline> polyLineSet = {};
  Set<Marker> makersSet = {};
  Set<Circle> circlesSet = {};
  String userName = "User Name";
  String userEmail = "";
  bool openNavigationDrawer = true;
  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyIcon;

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
          ref, // truyền ref thay vì context
        );
    print("This is your address: " + humanReadableAddress);

    userName = userModelCurrentInfo!.name!;
    userEmail = userModelCurrentInfo!.email!;

    // initializeGeoFireListener();

    // AssistantsMethod.readTripKeysForOnlineUser(context);
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
        ref.read(appInfoProvider.notifier)
            .updatePickUpLocationAddress(userPickUpAddress); // dùng Riverpod
      });
    } catch (e) {
      print(e);
    }
  }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.checkPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
    if (_locationPermission == null) {
      loc.Location().requestPermission();
    }
    locateUserPosition();
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = Theme.of(context).brightness == Brightness.dark;

    // Lấy state từ Riverpod
    final appInfo = ref.watch(appInfoProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              initialCameraPosition: _kGooglePlex,
              polylines: polyLineSet,
              markers: makersSet,
              circles: circlesSet,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;
                setState(() {});
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
                padding: const EdgeInsets.only(bottom: 35.0),
                child: Image.asset(
                  "images/assets/picks.png",
                  height: 45,
                  width: 45,
                ),
              ),
            ),

            //ui for search location
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: darkTheme ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),

                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: darkTheme
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: darkTheme
                                            ? Colors.amber.shade400
                                            : Colors.blue,
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "From",
                                            style: TextStyle(
                                              color: darkTheme
                                                  ? Colors.amber.shade400
                                                  : Colors.blue,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            appInfo.userPickUpLocation != null
                                                ? (appInfo.userPickUpLocation!.locationName ?? "")
                                                      .substring(0, 24) + "..."
                                                : "Not Getting address",
                                                style: TextStyle(
                                                  color:Colors.grey,
                                                  fontSize: 14,
                                                ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 5),

                                Divider(
                                  height: 1,
                                  thickness: 2,
                                  color: darkTheme ? Colors.amber.shade700 : Colors.blue,
                                ),

                                SizedBox(height: 5),

                                Padding(
                                  padding: EdgeInsets.all(5),
                                  child: GestureDetector(
                                    onTap: () {

                                    },
                                    child: Row(
                                        children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: darkTheme
                                            ? Colors.amber.shade400
                                            : Colors.blue,
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "To",
                                            style: TextStyle(
                                              color: darkTheme
                                                  ? Colors.amber.shade400
                                                  : Colors.blue,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            appInfo.userDropOffLocation != null
                                                ? (appInfo.userDropOffLocation!.locationName ?? "")
                                                      .substring(0, 24) + "..."
                                                : "Where to?",
                                                style: TextStyle(
                                                  color:Colors.grey,
                                                  fontSize: 14,
                                                ),
                                          )
                                        ],
                                      ),
                                    ],
                                    )
                                  )
                                )

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Positioned(
            //   top:40,
            //   right: 20,
            //   left: 20,
            //   child: Container(
            //     decoration: BoxDecoration(
            //       border: Border.all(color: Colors.black),
            //       color: Colors.white,
            //     ),
            //     padding: const EdgeInsets.all(20),
            //     child: Text(Provider.of<AppInfo>(context).userPickUpLocation != null
            //     ? (Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0,24) + "..."
            //     : "Not Getting address",
            //     overflow: TextOverflow.visible, softWrap: true,
            //     ),
            //   )
            // )
          ],
        ),
      ),
    );
  }
}
