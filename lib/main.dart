import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GoogleMapController? _controller;
  Position? currLocation;
  Stream<Position>? posStream;
  BitmapDescriptor? markerIcon;

  @override
  void initState() {
    super.initState();
    getMarkerIcon();
  }
  getMarkerIcon()async{
    markerIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(), "assets/images/logo.png");
    setState(() {

    });
  }

  Future<Position?> getCurrentLocation() async {
    /// checking location services enabled
    bool isServiceEnabled;
    isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      print("Location Services Disabled!!");
    } else {
      /// checking location permissions enabled
      var locPermission = await Geolocator.checkPermission();

      if (locPermission == LocationPermission.denied) {
        locPermission = await Geolocator.requestPermission();
        if (locPermission == LocationPermission.denied) {
          print("Location Permissions denied!!");
        } else if (locPermission == LocationPermission.deniedForever) {
          print("Location Permissions denied forever!!");
        } else {
          currLocation = await Geolocator.getCurrentPosition();
          print(
              "Your location: ${currLocation!.latitude}, ${currLocation!.longitude}");
        }
      } else {
        currLocation = await Geolocator.getCurrentPosition();
        posStream = Geolocator.getPositionStream(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            timeLimit: Duration(seconds: 10)
          )
        );

        print(
            "Your location: ${currLocation!.latitude}, ${currLocation!.longitude}");
      }
    }

    return currLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maps'),
      ),
      body: posStream!=null ? StreamBuilder(stream: posStream,
          builder: (_, snapshot){
        print(snapshot);

        if(snapshot.hasData){
          return GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (mController) async {
              _controller = mController;
              _controller!.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(
                      target: LatLng(snapshot!.data!.latitude, snapshot!.data!.longitude),
                      zoom: 19,
                      tilt: 56)));
            },
            onTap: (latlng) {},
            markers: {
              Marker(
                markerId: MarkerId('I\'m here'),
                icon: markerIcon ?? BitmapDescriptor.defaultMarker,
                position: LatLng(snapshot!.data!.latitude, snapshot!.data!.longitude)
              ),
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(26.2389, 73.0243),
              zoom: 14.4746,
            ),
          );
        }
        return Container(child: Center(child: Text('Hello'),),);
          }) : GoogleMap(
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        mapType: MapType.normal,
        onMapCreated: (mController) async {
          _controller = mController;
          var mPos = await getCurrentLocation();
          if (mPos != null) {
            _controller!.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: LatLng(mPos.latitude, mPos.longitude),
                    zoom: 19,
                    tilt: 56)));

            setState(() {});
          }
        },
        onTap: (latlng) {},
        markers: {
          Marker(
            markerId: MarkerId(currLocation != null ? 'I\'m here' : 'Jodhpur'),
            position: currLocation != null
                ? LatLng(currLocation!.latitude, currLocation!.longitude)
                : LatLng(26.2389, 73.0243),
          ),
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(26.2389, 73.0243),
          zoom: 14.4746,
        ),
      ),
    );
  }
}
