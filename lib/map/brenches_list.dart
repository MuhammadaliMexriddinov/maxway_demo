import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'api/api.dart';
import 'branch_model.dart';
import 'map/app_lat_long.dart';
import 'map/location_service.dart';

class BranchesListScreen extends StatefulWidget {
  const BranchesListScreen({Key? key}) : super(key: key);

  @override
  State<BranchesListScreen> createState() => _BranchesListScreenState();
}

class _BranchesListScreenState extends State<BranchesListScreen> {
  late MaxWayBranch _response;
  var branches = <Branch>[];
  final mapControllerCompleter = Completer<YandexMapController>();
  final List<MapObject> mapObjects = [];
  bool progress = false;
  var selectedBranch = 0;
  @override
  void initState() {
    super.initState();
    _initPermission().ignore();
    getData();
  }

  Future<void> getData() async {
    _response = await   MapApi().getItems();
    branches = _response.pageProps.branches.branches;
    await setMarkers(branches);
    _moveToCurrentLocation(AppLatLong(
        lat: branches.first.location.lat, long: branches.first.location.long));
    progress = true;
    setState(() {});
  }

  Future<void> _initPermission() async {
    if (!await LocationService().checkPermission()) {
      await LocationService().requestPermission();
    }
    await _fetchCurrentLocation();
  }
  Future<void> _fetchCurrentLocation() async {
    AppLatLong location;
    const defLocation = MoscowLocation();
    try {
      location = await LocationService().getCurrentLocation();
    } catch (_) {
      location = defLocation;
    }
    // _moveToCurrentLocation(location);
  }
  Future<void> setMarkers(List<Branch> branches) async {
    for (var element in branches) {
      mapObjects.add(PlacemarkMapObject(
          mapId: MapObjectId(element.id),
          icon: PlacemarkIcon.single(PlacemarkIconStyle(
              scale: 0.4,
              image: BitmapDescriptor.fromAssetImage(
                  "assets/images/max_way_logo.png")
          )),
          point: Point(
              latitude: element.location.lat,
              longitude: element.location.long)));
    }
    setState(() {});
  }
  Future<void> _moveToCurrentLocation(
      AppLatLong appLatLong,
      ) async {
    (await mapControllerCompleter.future).moveCamera(
      animation: const MapAnimation(type: MapAnimationType.linear, duration: 1),
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: appLatLong.lat,
            longitude: appLatLong.long,
          ),
          zoom: 15,
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MawWay Map"),
      ),
      body: YandexMap(
        onMapCreated: (controller) {
          mapControllerCompleter.complete(controller);
        },
        zoomGesturesEnabled: true,
        mapObjects: mapObjects,
      ),
    );
  }
}
