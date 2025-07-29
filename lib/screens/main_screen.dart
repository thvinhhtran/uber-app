import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:users/Assisstants/assistants_method.dart';
import 'package:users/Widgets/progress_dialog.dart';
import 'package:users/global/global.dart';
import 'package:users/global/map_key.dart';
import 'package:users/infohandle/app_info.dart';
import 'package:users/models/direction.dart';
import 'package:users/screens/drawer_screen.dart';
import 'package:users/screens/precise_pickuplocation.dart';
import 'package:users/screens/search_places.dart';
import 'package:users/themeprovider/theme_provider.dart';
import 'package:users/models/vehicle.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  LatLng? pickLocation = const LatLng(10.7769, 106.7009); // TP. Hồ Chí Minh
  loc.Location location = loc.Location();
  String? _address;

  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(10.7769, 106.7009), // TP. Hồ Chí Minh
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  double searchLocationContainerHeight = 220;
  double waitingResponsefromDriverContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;

  Position? userCurrentPosition;
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

  Future<bool> checkIfLocationPermissionAllowed() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng bật dịch vụ định vị trong cài đặt thiết bị.'),
          action: SnackBarAction(
            label: 'Mở Cài đặt',
            onPressed: () async {
              await Geolocator.openLocationSettings();
            },
          ),
          duration: Duration(seconds: 5),
        ),
      );
      return false;
    }

    _locationPermission = await Geolocator.checkPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
      if (_locationPermission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Quyền định vị bị từ chối. Vui lòng cấp quyền để sử dụng ứng dụng.',
            ),
            action: SnackBarAction(
              label: 'Mở Cài đặt',
              onPressed: () async {
                await Geolocator.openAppSettings();
              },
            ),
            duration: Duration(seconds: 5),
          ),
        );
        return false;
      }
    }

    if (_locationPermission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Quyền định vị bị từ chối vĩnh viễn. Vui lòng cấp quyền trong cài đặt.',
          ),
          action: SnackBarAction(
            label: 'Mở Cài đặt',
            onPressed: () async {
              await Geolocator.openAppSettings();
            },
          ),
          duration: Duration(seconds: 5),
        ),
      );
      return false;
    }

    return true;
  }

  locateUserPosition() async {
    bool isLocationAllowed = await checkIfLocationPermissionAllowed();
    if (!isLocationAllowed) {
      LatLng defaultPosition = LatLng(10.7769, 106.7009);
      CameraPosition cameraPosition = CameraPosition(
        target: defaultPosition,
        zoom: 14,
      );
      if (newGoogleMapController != null) {
        newGoogleMapController!.animateCamera(
          CameraUpdate.newCameraPosition(cameraPosition),
        );
        try {
          GeoData data = await Geocoder2.getDataFromCoordinates(
            latitude: defaultPosition.latitude,
            longitude: defaultPosition.longitude,
            googleMapApiKey: mapKey,
          );
          Direction userPickUpAddress = Direction()
            ..locationLatitude = defaultPosition.latitude
            ..locationLongitude = defaultPosition.longitude
            ..locationName = data.address;
          ref
              .read(appInfoProvider.notifier)
              .updatePickUpLocationAddress(userPickUpAddress);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể lấy địa chỉ mặc định: $e')),
          );
        }
      }
      return;
    }

    try {
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
      if (newGoogleMapController != null) {
        newGoogleMapController!.animateCamera(
          CameraUpdate.newCameraPosition(cameraPosition),
        );
        String humanReadableAddress =
            await AssistantsMethod.searchAddressForGeographicCoordinates(
              userCurrentPosition!,
              ref,
            );
        print("This is your address: $humanReadableAddress");
        Direction userPickUpAddress = Direction()
          ..locationLatitude = position.latitude
          ..locationLongitude = position.longitude
          ..locationName = humanReadableAddress;
        ref
            .read(appInfoProvider.notifier)
            .updatePickUpLocationAddress(userPickUpAddress);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể lấy vị trí: $e')));
      LatLng defaultPosition = LatLng(10.7769, 106.7009);
      CameraPosition cameraPosition = CameraPosition(
        target: defaultPosition,
        zoom: 14,
      );
      if (newGoogleMapController != null) {
        newGoogleMapController!.animateCamera(
          CameraUpdate.newCameraPosition(cameraPosition),
        );
        try {
          GeoData data = await Geocoder2.getDataFromCoordinates(
            latitude: defaultPosition.latitude,
            longitude: defaultPosition.longitude,
            googleMapApiKey: mapKey,
          );
          Direction userPickUpAddress = Direction()
            ..locationLatitude = defaultPosition.latitude
            ..locationLongitude = defaultPosition.longitude
            ..locationName = data.address;
          ref
              .read(appInfoProvider.notifier)
              .updatePickUpLocationAddress(userPickUpAddress);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể lấy địa chỉ mặc định: $e')),
          );
        }
      }
    }

    setState(() {
      userName = userModelCurrentInfo?.name ?? "User Name";
      userEmail = userModelCurrentInfo?.email ?? "";
    });
  }

  Future<void> drawPolylineFromOriginToDestination(bool darkTheme) async {
    var originPosition = ref.read(appInfoProvider).userPickUpLocation;
    var destinationPosition = ref.read(appInfoProvider).userDropOffLocation;

    if (originPosition == null || destinationPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn điểm đón và điểm đến.')),
      );
      return;
    }

    var originLatLng = LatLng(
      originPosition.locationLatitude!,
      originPosition.locationLongitude!,
    );
    var destinationLatLng = LatLng(
      destinationPosition.locationLatitude!,
      destinationPosition.locationLongitude!,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(message: "Vui lòng đợi..."),
    );

    var directionDetailsInfo =
        await AssistantsMethod.obtainOriginToDestinationDirectionDetails(
          originLatLng,
          destinationLatLng,
        );

    Navigator.pop(context);

    if (directionDetailsInfo == null ||
        directionDetailsInfo.e_points == null ||
        directionDetailsInfo.e_points!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không tìm thấy tuyến đường phù hợp!")),
      );
      return;
    }

    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodePolylinePointsResultList = pPoints.decodePolyline(
      directionDetailsInfo.e_points!,
    );

    pLineCoordinatedList.clear();
    if (decodePolylinePointsResultList.isNotEmpty) {
      decodePolylinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoordinatedList.add(
          LatLng(pointLatLng.latitude, pointLatLng.longitude),
        );
      });
    }

    polyLineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: darkTheme ? Colors.amberAccent : Colors.blue,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinatedList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 4,
      );
      polyLineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: destinationLatLng,
        northeast: originLatLng,
      );
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else {
      boundsLatLng = LatLngBounds(
        southwest: originLatLng,
        northeast: destinationLatLng,
      );
    }

    newGoogleMapController?.animateCamera(
      CameraUpdate.newLatLngBounds(boundsLatLng, 70),
    );

    Marker originMarker = Marker(
      markerId: MarkerId("originId"),
      infoWindow: InfoWindow(
        title: originPosition.locationName,
        snippet: "Origin",
      ),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationId"),
      infoWindow: InfoWindow(
        title: destinationPosition.locationName,
        snippet: "Destination",
      ),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      makersSet.add(originMarker);
      makersSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: CircleId("originId"),
      fillColor: Colors.green,
      center: originLatLng,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId("destinationId"),
      fillColor: Colors.red,
      center: destinationLatLng,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
    );

    setState(() {
      circlesSet.add(originCircle);
      circlesSet.add(destinationCircle);
    });
  }

  // Hàm lưu lịch sử đặt xe vào Firestore
  Future<void> _saveRideHistoryToFirestore(Vehicle vehicle, double fare) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Vui lòng đăng nhập để lưu thông tin!")),
        );
        return;
      }

      final appInfo = ref.read(appInfoProvider);
      print(
        "Lưu lịch sử: vehicle=${vehicle.name}, fare=$fare, "
        "pickup=${appInfo.userPickUpLocation?.locationName}, "
        "dropoff=${appInfo.userDropOffLocation?.locationName}, "
        "distance=${tripDirectionDetailsInfo?.distance_value?.toDouble() ?? 0}",
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('rideHistory')
          .add({
            'vehicle': vehicle.name,
            'fare': fare,
            'pickup':
                appInfo.userPickUpLocation?.locationName ?? "Không xác định",
            'dropoff':
                appInfo.userDropOffLocation?.locationName ?? "Không xác định",
            'distance':
                tripDirectionDetailsInfo?.distance_value?.toDouble() ?? 0,
            'timestamp': FieldValue.serverTimestamp(),
          });

      print("Đã lưu lịch sử đặt xe vào Firestore!");
    } catch (e) {
      print("Lỗi khi lưu lịch sử: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi lưu lịch sử đặt xe: $e")));
    }
  }

  final List<Vehicle> vehicleTypes = [
    Vehicle(
      name: "Xe máy",
      iconPath:
          "assets/icons/motorcycle.png", // Giả định bạn có file icon trong assets
      basePrice: 20000,
      pricePerKm: 7000,
    ),
    Vehicle(
      name: "Xe 4 chỗ",
      iconPath: "assets/icons/car_4_seater.png",
      basePrice: 50000,
      pricePerKm: 12000,
    ),
    Vehicle(
      name: "Xe 7 chỗ",
      iconPath: "assets/icons/car_7_seater.png",
      basePrice: 70000,
      pricePerKm: 15000,
    ),
  ];

  // Hàm hiển thị dialog danh sách xe
  void _showVehicleSelectionDialog() {
    bool darkTheme = Theme.of(context).brightness == Brightness.dark;
    double distanceInMeters =
        tripDirectionDetailsInfo?.distance_value?.toDouble() ?? 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Chọn loại xe",
            style: TextStyle(
              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: vehicleTypes.length,
              itemBuilder: (context, index) {
                final vehicle = vehicleTypes[index];
                final fare = vehicle
                    .calculateFare(distanceInMeters)
                    .toStringAsFixed(0);
                return ListTile(
                  leading: Image.asset(
                    vehicle.iconPath,
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.directions_car,
                      color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                    ),
                  ),
                  title: Text(
                    vehicle.name,
                    style: TextStyle(
                      color: darkTheme ? Colors.white : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    "Giá ước tính: $fare VNĐ\n(Đã bao gồm ${vehicle.basePrice.toStringAsFixed(0)} VNĐ cơ bản + ${vehicle.pricePerKm.toStringAsFixed(0)} VNĐ/km)",
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Bạn đã chọn ${vehicle.name} với giá $fare VNĐ",
                        ),
                      ),
                    );
                    // TODO: Thêm logic để gửi yêu cầu đặt xe với loại xe được chọn
                    // Gọi hàm lưu lịch sử chuyến đi
                    _saveRideHistoryToFirestore(vehicle, double.parse(fare));
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Hủy",
                style: TextStyle(
                  color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed().then((isAllowed) {
      if (isAllowed && _controllerGoogleMap.isCompleted) {
        locateUserPosition();
      } else {
        _controllerGoogleMap.future.then((_) => locateUserPosition());
      }
    });
  }

  @override
  void dispose() {
    newGoogleMapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = Theme.of(context).brightness == Brightness.dark;
    final appInfo = ref.watch(appInfoProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldState,
        drawer: DrawerScreen(),
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
              padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;
                setState(() {
                  bottomPaddingOfMap = 300;
                });
              },
            ),
            Positioned(
              top: 50,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  _scaffoldState.currentState!.openDrawer();
                },
                child: CircleAvatar(
                  backgroundColor: darkTheme
                      ? Colors.amber.shade400
                      : Colors.white,
                  child: Icon(
                    Icons.menu,
                    color: darkTheme ? Colors.black : Colors.lightBlue,
                  ),
                ),
              ),
            ),
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
                                                ? appInfo
                                                              .userPickUpLocation!
                                                              .locationName!
                                                              .length >
                                                          24
                                                      ? "${appInfo.userPickUpLocation!.locationName!.substring(0, 24)}..."
                                                      : appInfo
                                                            .userPickUpLocation!
                                                            .locationName!
                                                : "Đang tải địa chỉ...",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5),
                                Divider(
                                  height: 1,
                                  thickness: 2,
                                  color: darkTheme
                                      ? Colors.amber.shade700
                                      : Colors.blue,
                                ),
                                SizedBox(height: 5),
                                Padding(
                                  padding: EdgeInsets.all(5),
                                  child: GestureDetector(
                                    onTap: () async {
                                      var responsefromSearchScreen =
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SearchPlaceScreen(),
                                            ),
                                          );
                                      if (responsefromSearchScreen ==
                                          "obtainDirection") {
                                        setState(() {
                                          openNavigationDrawer = false;
                                        });
                                        await drawPolylineFromOriginToDestination(
                                          darkTheme,
                                        );
                                      }
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
                                              appInfo.userDropOffLocation !=
                                                      null
                                                  ? appInfo
                                                        .userDropOffLocation!
                                                        .locationName!
                                                  : "Bạn muốn đi đâu?",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PrecisePickupScreen(),
                              ),
                            );
                            setState(() {});
                          },
                          child: Text(
                            "Change pick up",
                            style: TextStyle(
                              color: darkTheme ? Colors.black : Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkTheme
                                ? Colors.amber.shade400
                                : Colors.blue,
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            if (ref.read(appInfoProvider).userDropOffLocation !=
                                null) {
                              _showVehicleSelectionDialog(); // Hiển thị dialog chọn loại xe
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Vui lòng chọn điểm đến trước!",
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            "Request a ride",
                            style: TextStyle(
                              color: darkTheme ? Colors.black : Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkTheme
                                ? Colors.amber.shade400
                                : Colors.blue,
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
