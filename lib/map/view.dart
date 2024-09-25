import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:permission_handler/permission_handler.dart';
import 'package:default_track_app/factory.dart';

Future<BitmapDescriptor> createCustomMarkerIcon() async {
  final PictureRecorder pictureRecorder = PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);

  // Load the image
  final ByteData imageData = await rootBundle
      .load('assets/map_marker.png');
  final Uint8List imageBytes = imageData.buffer.asUint8List();
  final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
  final ui.FrameInfo frameInfo = await codec.getNextFrame();
  final ui.Image image = frameInfo.image;

  // Draw the image onto the canvas
  canvas.drawImage(image, Offset(0.0, 0.0), Paint());

  // Convert canvas to image
  final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
        image.width,
        image.height,
      );

  final ByteData? byteData =
      await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List uint8List = byteData!.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(uint8List);
}

Future<List<Marker>> loadMarkers(
    void Function(Marker) zoomInOnMarker,
    void Function(Map<String, dynamic>, LatLng) showInfoBox,
    BuildContext context) async {
  final String response = await rootBundle.loadString(
      jsonLocation);
  final data = json.decode(response);

  List<Marker> markers = [];
  for (var item in data) {
    BitmapDescriptor customIcon = await createCustomMarkerIcon();
    Marker marker = Marker(
      markerId: MarkerId(item['name']),
      position: LatLng(item['lon'].toDouble(), item['lat'].toDouble()),
      icon: customIcon,
      onTap: () {
        Marker marker = Marker(
            markerId: MarkerId(item['name']),
            position: LatLng(item['lat'].toDouble(), item['lon'].toDouble()));
        zoomInOnMarker(marker);
        showInfoBox(item, marker.position);
      },
    );
    markers.add(marker);
  }

  return markers;
}

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  PlatformMapController? mapController;
  Map<String, dynamic>? selectedData;
  LatLng? selectedPosition;
  MapType _currentMapType = MapType.satellite;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    loadMarkers(zoomInOnMarker, showInfoBox, context).then((loadedMarkers) {
      setState(() {
        markers = loadedMarkers;
      });
    });
  }

  Future<void> requestLocationPermission() async {
    PermissionStatus status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      print("Location permission granted");
    } else {
      print("Location permission denied");
    }
  }

  List<Marker> markers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          markers.isNotEmpty
              ? PlatformMap(
                  initialCameraPosition: initialCameraPosition,
                  onMapCreated: (controller) {
                    mapController = controller;
                  },
                  mapType: _currentMapType,
                  markers: Set<Marker>.from(markers),
                  myLocationEnabled: true,
                )
              : const Center(child: CircularProgressIndicator()),
          if (selectedData != null && selectedPosition != null)
            Positioned(
              bottom: 50,
              left: 10,
              right: 10,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 5),
                ),
                child: Card(
                  color: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                selectedData!['name'].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  selectedData = null;
                                  selectedPosition = null;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 1),
                        Text('${selectedData!['description']}'),
                        SizedBox(height: 20),
                        if (selectedData!['img_link'] != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 3),
                              ),
                              child: Image.asset(
                                selectedData!['img_link'],
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 60,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.zoom_out_map_outlined, size: 40.0),
                    onPressed: () => resetCamera(),
                    color: const Color.fromARGB(255, 0, 0, 0),
                    tooltip: 'Reset Zoom',
                  ),
                  IconButton(
                    icon: const Icon(Icons.map, size: 40.0),
                    onPressed: () => toggleMapType(),
                    color: const Color.fromARGB(255, 0, 0, 0),
                    tooltip: 'Change Map Type',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void zoomInOnMarker(Marker marker) {
    mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: marker.position,
        zoom: 20.0,
        tilt: 40.0,
        bearing: 294.0,
      ),
    ));
  }

  void resetCamera() {
    mapController
        ?.animateCamera(CameraUpdate.newCameraPosition(initialCameraPosition));
  }

  void showInfoBox(Map<String, dynamic> data, LatLng position) {
    resetCamera();
    setState(() {
      selectedData = data;
      selectedPosition = position;
    });
  }

  void toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }
}
