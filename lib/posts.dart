import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:rent_all/item_description.dart';
import 'package:rent_all/post_location.dart';

class Posts extends StatelessWidget {
  Posts({Key key, @required this.category, @required this.distance})
      : super(key: key);
  final String distance;
  final String category;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Posts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Burbank',
        primaryColor: Color(0xFF0C0467),
      ),
      home: PostsPage(
        category: this.category,
        distance: this.distance,
      ),
    );
  }
}

class PostsPage extends StatefulWidget {
  PostsPage({Key key, @required this.category, @required this.distance})
      : super(key: key);
  final String distance;
  final String category;

  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  List<QueryDocumentSnapshot> _snapshot;
  List<QueryDocumentSnapshot> _newSnapshot;
  List<QueryDocumentSnapshot> _acquiresSnapshot;
  bool _isLoading;
  bool _isOnline;
  final String imageIconUrl =
      'https://firebasestorage.googleapis.com/v0/b/rent-all-deb4b.appspot.com/o/image_icon.jpg?alt=media&token=b323bd21-a916-4e8d-b04f-55bb260fcc8c';

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
                getSnapshotsToDisplay().then((value) {
                  setState(() {
                    _isLoading = false;
                  });
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0C0467), // status bar color
        brightness: Brightness.dark,
        title: Text(
          "${widget.category} within ${widget.distance}km",
        ),
      ),
      body: _newSnapshot?.length == 0
          ? Center(
              child: Text(
                'No item found...',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF0C0467),
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Container(
              padding: EdgeInsets.all(10),
              child: _isLoading
                  ? Center(
                      child: LinearProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF0C0467)),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshPosts,
                      child: ListView.builder(
                        itemBuilder: _buildRequestList,
                        itemCount: _newSnapshot.length,
                      ),
                    ),
            ),
    );
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _isLoading = true;
    });
    isConnected().then((value) {
      _isOnline = value;
      if (_isOnline) {
        getLocationPermissions().then((value) {
          if (value) {
            myCurrentLocation().then((value) {
              getDataOfItems().then((value) {
                getSnapshotsToDisplay().then((value) {
                  setState(() {
                    _isLoading = false;
                  });
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
  }

  Future<dynamic> getSnapshotsToDisplay() async {
    _newSnapshot = [];
    for (QueryDocumentSnapshot s in _snapshot) {
      double distanceInMeters = Geolocator.distanceBetween(
          _currentLocation.latitude,
          _currentLocation.longitude,
          s.data()['lat'],
          s.data()['long']);
      double setDistance = double.parse(widget.distance) * 1000;
      if (distanceInMeters <= setDistance) {
        if (_acquiresSnapshot.length != 0) {
          for (QueryDocumentSnapshot s1 in _acquiresSnapshot) {
            if (s1.data()['item_id'] != s.id) {
              _newSnapshot.add(s);
            }
          }
        } else {
          _newSnapshot = _snapshot;
        }
      }
    }
  }

  Widget _buildRequestList(BuildContext context, int index) {
    return itemCard(index, _newSnapshot[index]);
  }

  Widget itemCard(int index, QueryDocumentSnapshot x1) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Image.network(
            x1?.data()['image1'] != '' ? x1.data()['image1'] : imageIconUrl,
            fit: BoxFit.cover,
            height: 200,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Item Name: ',
                          style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF0C0467),
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          x1 != null
                              ? "${x1.data()['item_name']}"
                              : 'Loading...',
                          style:
                              TextStyle(fontSize: 18, color: Color(0xFF0C0467)),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Rent per day (CAD): ',
                          style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF0C0467),
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          x1 != null ? "${x1.data()['amount']}" : 'Loading...',
                          style:
                              TextStyle(fontSize: 18, color: Color(0xFF0C0467)),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      maxRadius: 18,
                      backgroundColor: Colors.red,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.location_pin,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PostLocation(
                                      distance: widget.distance,
                                      category: widget.category,
                                      lessorUid: x1.data()['lessor_uid'],
                                    )),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 5),
                    CircleAvatar(
                      maxRadius: 18,
                      backgroundColor: Colors.red,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.description,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ItemDescription(
                                    itemId: x1.reference.id,
                                    category: widget.category,
                                    lessorEmail: x1.data()['email'],
                                    lessorUid: x1.data()['lessor_uid'])),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
    await collectionRef.get().then((value) async {
      _snapshot = value.docs;
    });
    var acquiresRef = FirebaseFirestore.instance.collection('acquired_items');
    await acquiresRef.get().then((value) {
      _acquiresSnapshot = value.docs;
    });
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
    return _currentLocation;
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
    _isLoading = false;
    _snapshot.clear();
    _acquiresSnapshot.clear();
    _newSnapshot.clear();
    super.dispose();
  }
}

// ElevatedButton(
// onPressed: () {
// Navigator.push(
// context,
// MaterialPageRoute(
// builder: (context) => PostLocation(
// distance: widget.distance,
// category: widget.category)),
// );
// },
// child: Icon(Icons.location_pin),
// // Text(
// //   'LOCATION',
// //   style: TextStyle(
// //     fontSize: 18,
// //   ),
// // ),
// style: ButtonStyle(
// foregroundColor:
// MaterialStateProperty.all<Color>(Colors.white),
// backgroundColor:
// MaterialStateProperty.all<Color>(Color(0xFF0C0467)),
// shape:
// MaterialStateProperty.all<RoundedRectangleBorder>(
// RoundedRectangleBorder(
// borderRadius: const BorderRadius.all(
// const Radius.circular(20.0),
// ),
// ))),
// ),
