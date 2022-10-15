import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyRentItems extends StatelessWidget {
  MyRentItems({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Rent Items',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Burbank',
        primaryColor: Color(0xFF0C0467),
      ),
      home: MyRentItemsPage(),
    );
  }
}

class MyRentItemsPage extends StatefulWidget {
  MyRentItemsPage({
    Key key,
  }) : super(key: key);

  @override
  _MyRentItemsPageState createState() => _MyRentItemsPageState();
}

class _MyRentItemsPageState extends State<MyRentItemsPage> {
  bool _isLoading;
  bool _isOnline;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<QueryDocumentSnapshot> _snapshot;
  List<QueryDocumentSnapshot> _newSnapshot;
  List<QueryDocumentSnapshot> _newAcquiresSnapshot;
  List<QueryDocumentSnapshot> _acquiresSnapshot;
  String imageUrl1;
  String imageUrl2;
  String imageUrl3;
  String imageUrl4;
  String imageUrl5;


  @override
  void initState() {
    _isLoading = true;
    isConnected().then((value) {
      _isOnline = value;
      if (_isOnline) {
        getDataOfItems(getUserEmail()).then((value) {
          getSnapshotsToDisplay().then((value) {
            setState(() {
              _isLoading = false;
            });
          });
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
        title: Text('My Rent Items'),
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
            : ListView.builder(
          itemBuilder: _buildRequestList,
          itemCount: _newSnapshot.length,
        ),
      ),
    );
  }

  Future<dynamic> getSnapshotsToDisplay() async {
    _newSnapshot = [];
    _newAcquiresSnapshot = [];
    for (QueryDocumentSnapshot s in _snapshot) {
        for (QueryDocumentSnapshot s1 in _acquiresSnapshot) {
          if (s1.data()['item_id'] == s.id) {
            _newSnapshot.add(s);
            _newAcquiresSnapshot.add(s1);
          }
        }
    }
  }

  Widget _buildRequestList(BuildContext context, int index) {
    return itemCard(index, _newSnapshot[index], _newAcquiresSnapshot[index]);
  }

  Widget itemCard(int index, QueryDocumentSnapshot x1, QueryDocumentSnapshot x2) {
    imageUrl1 = x1.data()['image1'];
    imageUrl2 = x1.data()['image2'];
    imageUrl3 = x1.data()['image3'];
    imageUrl4 = x1.data()['image4'];
    imageUrl5 = x1.data()['image5'];
    Timestamp t1 = x2.data()['start'];
    Timestamp t2 = x2.data()['end'];
    DateTime startDate = t1.toDate();
    DateTime endDate = t2.toDate();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Image.network(
            x1?.data()['image1'],
            fit: BoxFit.cover,
            height: 200,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
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
                              ? "${capitalize(x1.data()['item_name'])}"
                              : 'Loading...',
                          style:
                          TextStyle(fontSize: 18, color: Color(0xFF0C0467)),
                        ),
                      ],
                    ),
                    itemTextWidget('Rent per day (CAD): ', x1.data()['amount']),
                    itemTextWidget('Category: ', x1.reference.parent.id),
                    itemTextWidget('Rent Amount: ', x2.data()['amount'].toString()),
                    itemTextWidget('From: ', startDate.toString()),
                    itemTextWidget('To: ', endDate.toString()),
                    itemTextWidget('Lessee Email: ', x2.data()['lessee_email']),
                    itemTextWidget('Lessee Mobile: ', x2.data()['lessee_mobile'])
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget itemTextWidget(String itemNameText, String textToDisplay) {
    return Padding(
      padding: const EdgeInsets.only(top: 3.0),
      child: Row(
        children: <Widget>[
          Text(
            itemNameText,
            style: TextStyle(
                fontSize: 16,
                color: Color(0xFF0C0467),
                fontWeight: FontWeight.w900),
          ),
          Text(
            textToDisplay,
            style: TextStyle(
                fontSize: 16, color: Color(0xFF0C0467)),
          ),
        ],
      ),
    );
  }

  String getUserEmail() {
    final User user = _auth.currentUser;
    return user.email;
  }

  Future<dynamic> getDataOfItems(String emailRequired) async {
    List<String> categories = [
      'equipment',
      'tools',
      'electronics',
      'furniture',
      'sport_goods',
      'appliances',
      'Outdoors',
      'real_estate',
      'machinery',
      'other_items'
    ];
    List<QueryDocumentSnapshot> localSnapshot = [];
    for (String c in categories) {
      await FirebaseFirestore.instance
          .collection(c)
          .where("email", isEqualTo: emailRequired)
          .get()
          .then((value) {
        localSnapshot.addAll(value.docs);
      });
    }
    _snapshot = localSnapshot;
    var acquiresRef = FirebaseFirestore.instance.collection('acquired_items');
    await acquiresRef.get().then((value) {
      // if(value.docs.length!=0)
        _acquiresSnapshot = value.docs;
    });
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

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
