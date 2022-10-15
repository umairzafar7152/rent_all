import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rent_all/paypal_payment.dart';

class ItemDescription extends StatelessWidget {
  ItemDescription(
      {Key key,
      @required this.itemId,
      @required this.category,
      @required this.lessorEmail,
      @required this.lessorUid})
      : super(key: key);
  final String itemId;
  final String category;
  final String lessorEmail;
  final String lessorUid;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Details',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Burbank',
        primaryColor: Color(0xFF0C0467),
      ),
      home: ItemDescriptionPage(
          title: 'Details Page',
          itemId: this.itemId,
          category: this.category,
          lessorEmail: this.lessorEmail,
          lessorUid: this.lessorUid),
    );
  }
}

class ItemDescriptionPage extends StatefulWidget {
  ItemDescriptionPage(
      {Key key,
      this.title,
      @required this.itemId,
      @required this.category,
      @required this.lessorEmail,
      @required this.lessorUid})
      : super(key: key);
  final String itemId;
  final String title;
  final String category;
  final String lessorEmail;
  final String lessorUid;

  @override
  _ItemDescriptionPageState createState() => _ItemDescriptionPageState();
}

class _ItemDescriptionPageState extends State<ItemDescriptionPage> {
  DocumentSnapshot _lessorSnapshot;
  bool _isLoading = false;
  List<String> _imgUrls = [];
  DocumentSnapshot _snapshot;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Map<String, dynamic> _dataToUpload;
  String _userEmail;
  String _description;
  String _requirements;
  String _lesseeMobile;

  String _startText;
  String _endText;
  int _numberOfDays;
  double _amountToPay;
  double _subAmount;

  int _current = 0;

  @override
  void initState() {
    super.initState();
    _userEmail = getUserEmail();
    getDataOfItem(_userEmail).then((value) {
      getDataOfLessor(widget.lessorUid);
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      if (_snapshot != null) {
        _description = _snapshot.data()['description'];
        _requirements = _snapshot.data()['requirements'];
      }
      if (_snapshot != null) {
        if (_snapshot.data()['image1'] != '') {
          if (!_imgUrls.contains(_snapshot.data()['image1'])) {
            _imgUrls.add(_snapshot.data()['image1']);
          }
        }
        if (_snapshot.data()['image2'] != '') {
          if (!_imgUrls.contains(_snapshot.data()['image2'])) {
            _imgUrls.add(_snapshot.data()['image2']);
          }
        }
        if (_snapshot.data()['image3'] != '') {
          if (!_imgUrls.contains(_snapshot.data()['image3'])) {
            _imgUrls.add(_snapshot.data()['image3']);
          }
        }
        if (_snapshot.data()['image4'] != '') {
          if (!_imgUrls.contains(_snapshot.data()['image4'])) {
            _imgUrls.add(_snapshot.data()['image4']);
          }
        }
        if (_snapshot.data()['image5'] != '') {
          if (!_imgUrls.contains(_snapshot.data()['image5'])) {
            _imgUrls.add(_snapshot.data()['image5']);
          }
        }
      }
    });
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
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0C0467)),
              ),
            )
          : SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: CarouselSlider(
                            items: _imgUrls
                                .map(
                                  (String url) => GestureDetector(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (_) {
                                        return DetailScreen(imageUrl: url);
                                      }));
                                    },
                                    child: Container(
                                      // margin: EdgeInsets.all(6.0),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        image: DecorationImage(
                                          image: NetworkImage(url),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            options: CarouselOptions(
                                enlargeCenterPage: true,
                                aspectRatio: 2.0,
                                onPageChanged: (_index, reason) {
                                  setState(() {
                                    _current = _index;
                                  });
                                }),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _imgUrls.map((url) {
                            return Container(
                              width: 8.0,
                              height: 8.0,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 2.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _current == _imgUrls.indexOf(url)
                                    ? Color.fromRGBO(0, 0, 0, 0.9)
                                    : Color.fromRGBO(0, 0, 0, 0.4),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: RichText(
                        text: TextSpan(
                          text: 'Item Description: ',
                          style: TextStyle(
                              fontFamily: 'Burbank',
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Color(0xFF0C0467)),
                          children: <TextSpan>[
                            TextSpan(
                              text: "$_description",
                              style: TextStyle(
                                  fontFamily: 'Burbank',
                                  fontSize: 18,
                                  color: Color(0xFF0C0467),
                                  fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Divider(
                      color: Colors.black,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: RichText(
                        text: TextSpan(
                          text: 'Requirements: ',
                          style: TextStyle(
                              fontFamily: 'Burbank',
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Color(0xFF0C0467)),
                          children: <TextSpan>[
                            TextSpan(
                              text: "$_requirements",
                              style: TextStyle(
                                  fontFamily: 'Burbank',
                                  fontSize: 18,
                                  color: Color(0xFF0C0467),
                                  fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Divider(
                      color: Colors.black,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Center(
                      child: Text(
                        'Get the item on Rent...',
                        style: TextStyle(
                            fontSize: 22,
                            color: Color(0xFF0C0467),
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: DateTimePicker(
                        use24HourFormat: false,
                        // type: DateTimePickerType.dateTimeSeparate,
                        // dateMask: 'MMM dd, yyyy',
                        initialValue: '',
                        icon: Icon(Icons.event_available_rounded),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        dateLabelText: 'Start Date',
                        onChanged: (val) {
                          setState(() {
                            _startText = val;
                          });
                        },
                        validator: (val) {
                          print(val);
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: DateTimePicker(
                        initialValue: '',
                        icon: Icon(Icons.event_busy_rounded),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        dateLabelText: 'End Date',
                        onChanged: (val) {
                          setState(() {
                            _endText = val;
                          });
                        },
                        validator: (val) {
                          print(val);
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    customTextField('Mobile Number', 'number'),
                    SizedBox(
                      height: 40.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 25.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            'Rent',
                            style: TextStyle(
                                fontSize: 18, color: Color(0xFF0C0467)),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              isConnected().then((value) {
                                if (value == false) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('No internet connection!'),
                                    ),
                                  );
                                } else {
                                  if (_lesseeMobile == null ||
                                      _startText == null ||
                                      _endText == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Fill all fields...'),
                                      ),
                                    );
                                  } else if (DateTime.parse(_startText)
                                      .isAfter(DateTime.parse(_endText))) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Start date can't come after End date"),
                                      ),
                                    );
                                  } else {
                                    _numberOfDays = DateTime.parse(_endText)
                                        .difference(DateTime.parse(_startText))
                                        .inDays;
                                    _subAmount = _numberOfDays *
                                        double.parse(
                                            _snapshot.data()['amount']);
                                    _amountToPay = _subAmount.toDouble() +
                                        (_subAmount * 0.1);
                                    // _dataToUpload = {
                                    //   "start": DateTime.parse(_startText),
                                    //   "end": DateTime.parse(_endText),
                                    //   "item_id": widget.itemId,
                                    //   'item_name':
                                    //       _snapshot.data()['item_name'],
                                    //   "lessee_email": _userEmail,
                                    //   "lessee_mobile": _lesseeMobile,
                                    //   "lessor_email": widget.lessorEmail,
                                    //   "lessor_mobile":
                                    //       _lessorSnapshot['mobile'],
                                    //   "item_received": false,
                                    //   'amount': _amountToPay
                                    // };
                                    if (_userEmail ==
                                        _snapshot.data()['email']) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              "You can't get your own product on rent!"),
                                        ),
                                      );
                                    } else {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return itemAddedDialog();
                                        },
                                      );
                                    }
                                  }
                                }
                              });
                            },
                            child: Icon(Icons.arrow_forward_sharp),
                            style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Color(0xFF0C0467)),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(20.0),
                                  ),
                                ))),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget customTextField(String hintText, String textType) {
    TextInputType textInputType;
    if (textType == 'date') {
      textInputType = TextInputType.datetime;
    } else if (textType == 'number') {
      textInputType = TextInputType.number;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        onChanged: (value) {
          if (hintText == "Mobile Number") {
            setState(() {
              _lesseeMobile = value;
            });
          }
        },
        keyboardType: textInputType,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white70,
          labelText: hintText,
          border: OutlineInputBorder(
              // width: 0.0 produces a thin "hairline" border
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              borderSide: BorderSide(color: Colors.white24)
              //borderSide: const BorderSide(),
              ),
          contentPadding:
              EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
          hintText: hintText,
        ),
      ),
    );
  }

  Future<dynamic> getDataOfItem(String emailRequired) async {
    var localSnapshot;
    String itemCategory = widget.category;
    String _category;
    if (itemCategory == 'Equipments') {
      _category = 'equipment';
    } else if (itemCategory == 'Tools') {
      _category = 'tools';
    } else if (itemCategory == 'Electronics') {
      _category = 'electronics';
    } else if (itemCategory == 'Furniture') {
      _category = 'furniture';
    } else if (itemCategory == 'Sport Goods') {
      _category = 'sport_goods';
    } else if (itemCategory == 'Appliances') {
      _category = 'appliances';
    } else if (itemCategory == 'Outdoors') {
      _category = 'Outdoors';
    } else if (itemCategory == 'Real Estate') {
      _category = 'real_estate';
    } else if (itemCategory == 'Machinery') {
      _category = 'machinery';
    } else if (itemCategory == 'Others') {
      _category = 'other_items';
    }
    var docRef =
        FirebaseFirestore.instance.collection(_category).doc(widget.itemId);
    localSnapshot = await docRef.get();
    print('USER EMAIL IS: $emailRequired');
    print(
        "DATA CONTAINS requirements ${localSnapshot.data()['requirements'].toString()}");
    setState(() {
      _snapshot = localSnapshot;
    });
  }

  String getUserEmail() {
    final User user = _auth.currentUser;
    return user.email;
  }

  Future<DocumentSnapshot> getDataOfLessor(String userIdRequired) async {
    var docRef =
        FirebaseFirestore.instance.collection("users").doc(userIdRequired);
    await docRef.get().then((value) {
      setState(() {
        _lessorSnapshot = value;
      });
    });
    return _lessorSnapshot;
  }

  // void addDataToCloud(dataToUpload) {
  //   CollectionReference collectionReference =
  //       FirebaseFirestore.instance.collection('acquired_items');
  //   collectionReference.add(dataToUpload).then((value) {
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return itemAddedDialog();
  //       },
  //     );
  //     _newDataId = value.id;
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }).catchError((error, stackTrace) {
  //     print("FAILED TO ADD DATA: $error");
  //     print("STACKTRACE IS:  $stackTrace");
  //   });
  // }

  Widget itemAddedDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      title: Row(
        children: <Widget>[
          Icon(
            Icons.check_circle_outline_rounded,
            color: Colors.red,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Continue to payment?",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      insetPadding: EdgeInsets.all(10),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            "Subtotal: $_subAmount",
            // "You will be notified, once the item's owner approves your request!",
            style: TextStyle(color: Color(0xFF0C0467)),
          ),
          Text(
            "Admin Commission (10%): ${(_subAmount * 0.1).toStringAsFixed(2)}",
            // "You will be notified, once the item's owner approves your request!",
            style: TextStyle(color: Color(0xFF0C0467)),
          ),
          Text(
            "Total Amount to pay: $_amountToPay",
            // "You will be notified, once the item's owner approves your request!",
            style: TextStyle(color: Color(0xFF0C0467)),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text(
            'Pay Now',
            style: TextStyle(
                color: Colors.white, backgroundColor: Color(0xFF0C0467)),
          ),
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            setState(() {
              _isLoading = false;
            });
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => PaypalPaymentPage(
                  start: _startText,
                  end: _endText,
                  itemId: widget.itemId,
                  lesseeEmail: _userEmail,
                  lesseeMobile: _lesseeMobile,
                  lessorEmail: widget.lessorEmail,
                  lessorMobile: _lessorSnapshot['mobile'],
                  itemName: _snapshot.data()['item_name'],
                  amountToPay: _amountToPay,
                  onFinish: (number) async {
                    // payment done
                    print('order id: ' + number);
                  },
                ),
              ),
            );
          },
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            backgroundColor:
                MaterialStateProperty.all<Color>(Color(0xFF0C0467)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(20.0),
                ),
              ),
            ),
          ),
        )
      ],
    );
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
    super.dispose();
  }
}

class DetailScreen extends StatelessWidget {
  DetailScreen({Key key, @required this.imageUrl}) : super(key: key);
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onVerticalDragEnd: (_) {
          Navigator.pop(context);
        },
        child: Center(
          child: Image.network(
            imageUrl,
          ),
        ),
      ),
    );
  }
}
