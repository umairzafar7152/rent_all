import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Approvals extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Approvals',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Burbank',
        primaryColor: Color(0xFF0C0467),
      ),
      home: ApprovalsPage(title: 'Pending Approvals'),
    );
  }
}

class ApprovalsPage extends StatefulWidget {
  ApprovalsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ApprovalsPageState createState() => _ApprovalsPageState();
}

class _ApprovalsPageState extends State<ApprovalsPage> {
  // GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // PaypalServices _services = PaypalServices();
  // String _accessToken;
  Map<dynamic, dynamic> defaultCurrency = {
    "symbol": "CAD ",
    "decimalDigits": 2,
    "symbolBeforeTheNumber": true,
    "currency": "CAD"
  };

  // String _approvedItemId;
  List<QueryDocumentSnapshot> _snapshot;
  List<QueryDocumentSnapshot> _newSnapshot = [];
  DocumentSnapshot _userSnapshot;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<Map<String, dynamic>> requests = [];
  String _userEmail;
  String _uId;
  bool _isLoading;
  bool _isOnline;
  // double _amountToPay;

  @override
  void initState() {
    _isLoading = true;
    _userEmail = getUserEmail();
    isConnected().then((value) {
      _isOnline = value;
      if (_isOnline) {
        getDataOfItems(_userEmail).then((value) {
          getDataOfUser(_uId).then((value) {
            getSnapshotsToDisplay();
            setState(() {
              _isLoading = false;
            });
          });
        });

        // Future.delayed(Duration.zero, () async {
        //   try {
        //     await _services.getAccessToken().then((value) {
        //       print("Access token done!");
        //       _accessToken = value;
        //       print('$_accessToken');
        //     });
        //   } catch (e) {
        //     print('exception: ' + e.toString());
        //     final snackBar = SnackBar(
        //       content: Text(e.toString()),
        //       duration: Duration(seconds: 10),
        //       action: SnackBarAction(
        //         label: 'Close',
        //         onPressed: () {
        //           // Some code to undo the change.
        //         },
        //       ),
        //     );
        //     ScaffoldMessenger.of(_scaffoldKey.currentContext)
        //         .showSnackBar(snackBar);
        //   }
        // });
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
          widget.title,
        ),
      ),
      body: _isLoading
          ? Center(
        child: LinearProgressIndicator(
          valueColor:
          AlwaysStoppedAnimation<Color>(Color(0xFF0C0467)),
        ),
      ):_newSnapshot?.length == 0
          ? Center(
              child: Text(
                'No pending approval...',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF0C0467),
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Container(
              padding: EdgeInsets.all(10),
              child: ListView.builder(
                      itemBuilder: _buildRequestList,
                      itemCount: _newSnapshot.length,
                    ),
            ),
    );
  }

  Widget _buildRequestList(BuildContext context, int index) {
    return itemCard(index, _newSnapshot[index]);
  }

  void getSnapshotsToDisplay() {
    for (QueryDocumentSnapshot s in _snapshot) {
      final Timestamp t1 = s.data()['end'];
      // show only those posts that have past end date so that owner gets paid after he gets his product back...
      final endDate = t1.toDate();
      if (endDate.isBefore(DateTime.now())) {
        _newSnapshot.add(s);
      }
    }
  }

  Widget itemCard(int index, QueryDocumentSnapshot x1) {
    return Container(
      height: 190,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'Item: ',
                    style: TextStyle(fontSize: 16, color: Color(0xFF0C0467), fontWeight: FontWeight.w900),
                  ),
                  Text(
                    x1 != null ? "${x1.data()['item_name']}" : "Bulldozer",
                    style: TextStyle(fontSize: 14, color: Color(0xFF0C0467)),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Text(
                    'Client Email: ',
                    style: TextStyle(fontSize: 16, color: Color(0xFF0C0467), fontWeight: FontWeight.w900),
                  ),
                  Text(
                    x1 != null ? "${x1.data()['lessee_email']}" : 'ABC',
                    style: TextStyle(fontSize: 14, color: Color(0xFF0C0467)),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Text(
                    'Client Mobile: ',
                    style: TextStyle(fontSize: 16, color: Color(0xFF0C0467), fontWeight: FontWeight.w900),
                  ),
                  Text(
                    x1 != null
                        ? "${x1.data()['lessee_mobile']}"
                        : '3452********',
                    style: TextStyle(fontSize: 14, color: Color(0xFF0C0467)),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Text(
                    'My Paypal Email: ',
                    style: TextStyle(fontSize: 16, color: Color(0xFF0C0467), fontWeight: FontWeight.w900),
                  ),
                  Text(
                    x1 != null
                        ? "${_userSnapshot['paypal_email']}"
                        : 'xyz********.com',
                    style: TextStyle(fontSize: 14, color: Color(0xFF0C0467)),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Text(
                    'Start: ',
                    style: TextStyle(fontSize: 16, color: Color(0xFF0C0467), fontWeight: FontWeight.w900),
                  ),
                  Text(
                    x1 != null
                        ? "${(x1.data()['start'] as Timestamp).toDate()}"
                        : "${DateTime.parse('15 july 2021')}",
                    style: TextStyle(fontSize: 14, color: Color(0xFF0C0467)),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Text(
                    'End: ',
                    style: TextStyle(fontSize: 16, color: Color(0xFF0C0467), fontWeight: FontWeight.w900),
                  ),
                  Text(
                    x1 != null
                        ? "${(x1.data()['end'] as Timestamp).toDate()}"
                        : "20 july 2021",
                    style: TextStyle(fontSize: 14, color: Color(0xFF0C0467)),
                  ),
                ],
              ),
              Divider(color: Colors.black,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Have you got your item back?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0C0467)
                    )
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
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
                            Map<String, dynamic> dataToUpload = x1.data();
                            dataToUpload['approval_time'] = DateTime.now();
                            addDataToCloud(dataToUpload, x1).then((value) {
                              setState(() {
                                _isLoading = false;
                              });
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
                              // Navigator.pop(context);
                              // Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Approvals()));
                            });
                            // Map<String, dynamic> dataToUpdate = {
                            //   "payout_batch_id": value
                            // };
                            // CollectionReference collectionReference =
                            // FirebaseFirestore.instance.collection('approved_items');
                            // collectionReference.doc(_approvedItemId).update(dataToUpdate);
                            // execute payout
                            // if(x1.data()['item_received']!=null && x1.data()['item_received']==true) {
                            //   final transactions = getPayoutParams(x1);
                            //   _services.executePayout(_accessToken, transactions).then((value) {
                            //
                            //   });
                            // } else {
                            //   Fluttertoast.showToast(
                            //       msg: "Lessee didn't received the item so you can't be paid!",
                            //       toastLength: Toast.LENGTH_LONG,
                            //       gravity: ToastGravity.BOTTOM,
                            //       timeInSecForIosWeb: 1,
                            //       backgroundColor: Colors.red,
                            //       textColor: Colors.white,
                            //       fontSize: 14.0
                            //   );
                            // }
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
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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
          ),
        ),
      ),
    );
  }



  // Map<String, dynamic> getPayoutParams(QueryDocumentSnapshot t1) {
  //   double totalAmount = t1.data()['amount'];
  //   _amountToPay = totalAmount-(totalAmount*0.1);
  //   Map<String, dynamic> temp = {
  //     "sender_batch_header": {
  //       "sender_batch_id": "Payouts_2021_01",
  //       "email_subject": "You have a payout from Rent All!",
  //       "email_message": "You have received a payout for renting your item '${t1.data()['item_name']}'! Thanks for using our service!"
  //     },
  //     "items": [
  //       {
  //         "recipient_type": "EMAIL",
  //         "amount": {
  //           "value": "$_amountToPay",
  //           "currency": defaultCurrency['currency']
  //         },
  //         "note": "Thanks for your patronage!",
  //         "sender_item_id": "${t1.data()['item_id']}",
  //         "receiver": "${t1.data()['lessee_email']}",
  //         // "alternate_notification_method": {
  //         //   "phone": {
  //         //     "country_code": "91",
  //         //     "national_number": "9999988888"
  //         //   }
  //         // },
  //         "notification_language": "en-CA"
  //       },
  //     ]
  //   };
  //   return temp;
  // }

  Future<void> addDataToCloud(
      Map<String, dynamic> dataToUpload, QueryDocumentSnapshot x2) async {
    setState(() {
      _isLoading = true;
    });
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('approved_items');
    collectionReference.add(dataToUpload).then((value) {
      // _approvedItemId = value.id;
    }).catchError((error, stackTrace) {
      print("FAILED TO ADD DATA: $error");
      print("STACKTRACE IS:  $stackTrace");
    });
    // deleting data from pending approvals
    FirebaseFirestore.instance.collection('acquired_items').doc(x2.id).delete();
  }

  Future<dynamic> getDataOfItems(String emailRequired) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("acquired_items")
        .where("lessor_email", isEqualTo: emailRequired)
        .get();
    _snapshot = querySnapshot.docs;
    setState(() {
      _isLoading = false;
    });
  }

  String getUserEmail() {
    final User user = _auth.currentUser;
    _uId = user.uid;
    return user.email;
  }

  Future<DocumentSnapshot> getDataOfUser(String userIdRequired) async {
    var docRef =
        FirebaseFirestore.instance.collection("users").doc(userIdRequired);
    await docRef.get().then((value) {
      setState(() {
        _userSnapshot = value;
      });
    });
    return _userSnapshot;
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
    super.dispose();
  }
}
