import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AcquiredItems extends StatelessWidget {
  AcquiredItems({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acquired Items',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Burbank',
        primaryColor: Color(0xFF0C0467),
      ),
      home: AcquiredItemsPage(),
    );
  }
}

class AcquiredItemsPage extends StatefulWidget {
  AcquiredItemsPage({
    Key key,
  }) : super(key: key);

  @override
  _AcquiredItemsPageState createState() => _AcquiredItemsPageState();
}

class _AcquiredItemsPageState extends State<AcquiredItemsPage> {
  bool _isLoading;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<QueryDocumentSnapshot> _snapshot;

  @override
  void initState() {
    _isLoading = true;
    getDataOfItems(getUserEmail()).then((value) {
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0C0467), // status bar color
        brightness: Brightness.dark,
        title: Text('Acquired Items'),
      ),
      body: _snapshot?.length == 0
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
                      itemCount: _snapshot.length,
                    ),
            ),
    );
  }

  Widget _buildRequestList(BuildContext context, int index) {
    return itemCard(index, _snapshot[index]);
  }

  Widget itemCard(int index, QueryDocumentSnapshot x1) {
    Timestamp t1 = x1.data()['start'];
    Timestamp t2 = x1.data()['end'];
    DateTime from = t1.toDate();
    DateTime to = t2.toDate();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RichText(
              text: TextSpan(
                text: 'Item Name: ',
                style: TextStyle(
                    fontFamily: 'Burbank',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF0C0467)),
                children: <TextSpan>[
                  TextSpan(
                    text: x1 != null
                        ? "${capitalize(x1.data()['item_name'])}"
                        : 'Loading...',
                    style: TextStyle(
                        fontFamily: 'Burbank',
                        fontWeight: FontWeight.w300,
                        fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: RichText(
                text: TextSpan(
                  text: 'Amount Paid (CAD): ',
                  style: TextStyle(
                      fontFamily: 'Burbank',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF0C0467)),
                  children: <TextSpan>[
                    TextSpan(
                      text:
                          x1 != null ? "${x1.data()['amount']}" : 'Loading...',
                      style: TextStyle(
                          fontFamily: 'Burbank',
                          fontWeight: FontWeight.w300,
                          fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: RichText(
                text: TextSpan(
                  text: 'Owner Email: ',
                  style: TextStyle(
                      fontFamily: 'Burbank',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF0C0467)),
                  children: <TextSpan>[
                    TextSpan(
                      text: x1 != null
                          ? "${x1.data()['lessor_email']}"
                          : 'Loading...',
                      style: TextStyle(
                          fontFamily: 'Burbank',
                          fontWeight: FontWeight.w300,
                          fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: RichText(
                text: TextSpan(
                  text: 'Owner Mobile: ',
                  style: TextStyle(
                      fontFamily: 'Burbank',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF0C0467)),
                  children: <TextSpan>[
                    TextSpan(
                      text: x1 != null
                          ? "${x1.data()['lessor_mobile']}"
                          : 'Loading...',
                      style: TextStyle(
                          fontFamily: 'Burbank',
                          fontWeight: FontWeight.w300,
                          fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: RichText(
                text: TextSpan(
                  text: 'Payment ID: ',
                  style: TextStyle(
                      fontFamily: 'Burbank',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF0C0467)),
                  children: <TextSpan>[
                    TextSpan(
                      text: x1 != null
                          ? "${x1.data()['payment_id']}"
                          : 'Loading...',
                      style: TextStyle(
                          fontFamily: 'Burbank',
                          fontWeight: FontWeight.w300,
                          fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: RichText(
                text: TextSpan(
                  text: 'From: ',
                  style: TextStyle(
                      fontFamily: 'Burbank',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF0C0467)),
                  children: <TextSpan>[
                    TextSpan(
                      text: x1 != null ? "${from.toString()}" : 'Loading...',
                      style: TextStyle(
                          fontFamily: 'Burbank',
                          fontWeight: FontWeight.w300,
                          fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: RichText(
                text: TextSpan(
                  text: 'To: ',
                  style: TextStyle(
                      fontFamily: 'Burbank',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF0C0467)),
                  children: <TextSpan>[
                    TextSpan(
                      text: x1 != null ? "${to.toString()}" : 'Loading...',
                      style: TextStyle(
                          fontFamily: 'Burbank',
                          fontWeight: FontWeight.w300,
                          fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            (x1.data()['item_received']!=null&&x1.data()['item_received']!=true)?receiveOption(x1):SizedBox(height: 0.0,)
          ],
        ),
      ),
    );
  }

  Widget receiveOption(QueryDocumentSnapshot x1) {
    return Column(
      children: <Widget>[
        Divider(
          color: Colors.black,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Have you received the item for rent?',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0C0467))),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10.0, vertical: 5.0),
              child: ElevatedButton(
                onPressed: () {
                  isConnected().then((value) {
                    if (value == false) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('No internet connection!'),
                        ),
                      );
                    } else {
                      setState(() {
                        _isLoading = true;
                      });
                      CollectionReference collectionReference =
                      FirebaseFirestore.instance
                          .collection('acquired_items');
                      collectionReference
                          .doc(x1.reference.id)
                          .update({'item_received': true});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Item approved!'),
                        ),
                      );
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                              super.widget));
                    }
                  });
                },
                child: Text(
                  'Yes',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                style: ButtonStyle(
                    foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xFF0C0467)),
                    shape:
                    MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(20.0),
                          ),
                        ))),
              ),
            ),
          ],
        )
      ],
    );
  }

  String getUserEmail() {
    final User user = _auth.currentUser;
    return user.email;
  }

  Future<dynamic> getDataOfItems(String emailRequired) async {
    List<QueryDocumentSnapshot> localSnapshot = [];
    await FirebaseFirestore.instance
        .collection("acquired_items")
        .where("lessee_email", isEqualTo: emailRequired)
        .get()
        .then((value) {
      localSnapshot.addAll(value.docs);
    });
    _snapshot = localSnapshot;
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
    super.dispose();
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
