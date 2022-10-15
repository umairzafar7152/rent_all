import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:rent_all/item_description.dart';

class PostLocation extends StatelessWidget {
  PostLocation(
      {Key key,
      @required this.distance,
      @required this.category,
      @required this.lessorUid})
      : super(key: key);
  final String distance;
  final String category;
  final String lessorUid;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "$category Location",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Burbank',
        primaryColor: Color(0xFF0C0467),
      ),
      home: LocationPage(
          distance: this.distance,
          category: this.category,
          lessorUid: this.lessorUid),
    );
  }
}

class LocationPage extends StatefulWidget {
  LocationPage(
      {Key key,
      @required this.distance,
      @required this.category,
      @required this.lessorUid})
      : super(key: key);
  final String distance;
  final String category;
  final String lessorUid;

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  var _lat;
  var _long;
  bool _isLoading;
  bool _isOnline;

  List<QueryDocumentSnapshot> _snapshot;

  Set<Marker> _markers = HashSet<Marker>();
  GoogleMapController _mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    int index = 0;
    setState(() {
      if (_snapshot != null) {
        for (QueryDocumentSnapshot x1 in _snapshot) {
          double distanceInMeters = Geolocator.distanceBetween(
              _currentLocation.latitude,
              _currentLocation.longitude,
              x1.data()['lat'],
              x1.data()['long']);
          if (distanceInMeters <= (double.parse(widget.distance) * 1000)) {
            _markers.add(
              Marker(
                markerId: MarkerId("marker_$index"),
                position: LatLng(x1.data()['lat'], x1.data()['long']),
                infoWindow: InfoWindow(
                    title: "${x1.data()['item_name']}",
                    snippet: "${x1.data()['description']}",
                    onTap: () {
                      isConnected().then((value) {
                        if (value == false) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('No internet connection!'),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ItemDescription(
                                      itemId: x1.reference.id,
                                      category: widget.category,
                                      lessorEmail: x1.data()['email'],
                                      lessorUid: widget.lessorUid,
                                    )),
                          );
                        }
                      });
                    }),
              ),
            );
          }
          index++;
        }
      }
    });
  }

  @override
  void initState() {
    _isLoading = true;
    isConnected().then((value) {
      _isOnline = value;
      if (_isOnline) {
        getLocationPermissions().then((value) {
          if (value) {
            myCurrentLocation().then((value) {
              getDataOfItems().then((value) {
                setState(() {
                  _isLoading = false;
                });
              });
            });
          }
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double distanceInDouble = double.parse(widget.distance);
    print('$distanceInDouble');
    Set<Circle> circles = Set.from([
      Circle(
        circleId: CircleId("0"),
        center: _lat != null && _long != null ? LatLng(_lat, _long) : _center,
        radius: distanceInDouble * 1000,
        fillColor: Colors.blue.withOpacity(0.3),
        strokeWidth: 2,
        strokeColor: Colors.blue,
      )
    ]);
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.category} within ${widget.distance}km"),
        backgroundColor: Color(0xFF0C0467),
        brightness: Brightness.dark,
      ),
      body: _isLoading
          ? Center(
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0C0467)),
              ),
            )
          : (!_isLoading && !_isOnline)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons
                            .signal_cellular_connected_no_internet_4_bar_rounded,
                        size: 50,
                        color: Color(0xFF0C0467),
                      ),
                      Text(
                        'No internet connection',
                        style:
                            TextStyle(fontSize: 18, color: Color(0xFF0C0467)),
                      ),
                    ],
                  ),
                )
              : Stack(children: <Widget>[
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _lat != null && _long != null
                          ? LatLng(_lat, _long)
                          : _center,
                      zoom: 11.0,
                    ),
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: true,
                    myLocationEnabled: true,
                    markers: _markers,
                    circles: circles,
                  ),
                ]),
    );
  }

  LocationData _currentLocation;
  var location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  Future<bool> getLocationPermissions() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        Navigator.of(context, rootNavigator: true).pop(context);
        return false;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        Navigator.of(context, rootNavigator: true).pop(context);
        return false;
      }
    }
    return true;
  }

  Future<LocationData> myCurrentLocation() async {
    try {
      _currentLocation = await location.getLocation();
      print("locationLatitude: ${_currentLocation.latitude.toString()}");
      print("locationLongitude: ${_currentLocation.longitude.toString()}");
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        String error = 'Permission denied';
        print(error);
      }
      _currentLocation = null;
    }
    setState(() {
      if (_currentLocation != null) {
        _lat = _currentLocation.latitude;
        _long = _currentLocation.longitude;
      }
    });
    return _currentLocation;
  }

  Future<dynamic> getDataOfItems() async {
    String itemCategory = widget.category;
    String category;
    if (itemCategory == 'Equipments') {
      category = 'equipment';
    } else if (itemCategory == 'Tools') {
      category = 'tools';
    } else if (itemCategory == 'Electronics') {
      category = 'electronics';
    } else if (itemCategory == 'Furniture') {
      category = 'furniture';
    } else if (itemCategory == 'Sport Goods') {
      category = 'sport_goods';
    } else if (itemCategory == 'Appliances') {
      category = 'appliances';
    } else if (itemCategory == 'Outdoors') {
      category = 'Outdoors';
    } else if (itemCategory == 'Real Estate') {
      category = 'real_estate';
    } else if (itemCategory == 'Machinery') {
      category = 'machinery';
    } else if (itemCategory == 'Others') {
      category = 'other_items';
    }
    var collectionRef = FirebaseFirestore.instance.collection(category);
    QuerySnapshot querySnapshot = await collectionRef.get();
    _snapshot = querySnapshot.docs;
  }

  Future<bool> isConnected() async {
    var connected;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      connected = true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      connected = true;
    } else {
      connected = false;
    }
    return connected;
  }

  @override
  void dispose() {
    _isLoading = null;
    _snapshot = null;
    _mapController?.dispose();
    _markers.clear();
    super.dispose();
  }
}
