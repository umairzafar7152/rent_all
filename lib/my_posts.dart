import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rent_all/edit_post.dart';

class MyPosts extends StatelessWidget {
  MyPosts({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Posts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Burbank',
        primaryColor: Color(0xFF0C0467),
      ),
      home: MyPostsPage(),
    );
  }
}

class MyPostsPage extends StatefulWidget {
  MyPostsPage({
    Key key,
  }) : super(key: key);

  @override
  _MyPostsPageState createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  bool _isLoading;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<QueryDocumentSnapshot> _snapshot;
  String imageUrl1;
  String imageUrl2;
  String imageUrl3;
  String imageUrl4;
  String imageUrl5;


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
        title: Text('My Posts'),
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
    imageUrl1 = x1.data()['image1'];
    imageUrl2 = x1.data()['image2'];
    imageUrl3 = x1.data()['image3'];
    imageUrl4 = x1.data()['image4'];
    imageUrl5 = x1.data()['image5'];
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
                    Padding(
                      padding: const EdgeInsets.only(top: 3.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Rent per day (CAD): ',
                            style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF0C0467),
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            x1 != null
                                ? "${x1.data()['amount']}"
                                : 'Loading...',
                            style: TextStyle(
                                fontSize: 18, color: Color(0xFF0C0467)),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 3.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Category: ',
                            style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF0C0467),
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            x1 != null
                                ? "${capitalize(x1.reference.parent.id)}"
                                : 'Loading...',
                            style: TextStyle(
                                fontSize: 18, color: Color(0xFF0C0467)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      maxRadius: 18,
                      backgroundColor: Color(0xFF0C0467),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditPost(
                                      itemId: x1.id,
                                      category: x1.reference.parent.id,
                                    )),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 5),
                    CircleAvatar(
                      maxRadius: 18,
                      backgroundColor: Colors.red,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          if(imageUrl1!=null && imageUrl1!='')
                            FirebaseStorage.instance.refFromURL(imageUrl1).delete();
                          if(imageUrl2!=null && imageUrl2!='')
                            FirebaseStorage.instance.refFromURL(imageUrl2).delete();
                          if(imageUrl3!=null && imageUrl3!='')
                            FirebaseStorage.instance.refFromURL(imageUrl3).delete();
                          if(imageUrl4!=null && imageUrl4!='')
                            FirebaseStorage.instance.refFromURL(imageUrl4).delete();
                          if(imageUrl5!=null && imageUrl5!='')
                            FirebaseStorage.instance.refFromURL(imageUrl5).delete();
                          DocumentReference docReference = x1.reference;
                          // deletePendingRequests(docReference.id)
                          //     .then((value) async {
                          await docReference.delete().then((value) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyPosts()),
                            );
                          });
                          // });
                        },
                      ),
                    ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) => EditPost(itemId: x1.id, category: x1.reference.parent.id,)),
                    //     );
                    //   },
                    //   child: Icon(Icons.edit),
                    //   style: ButtonStyle(
                    //       foregroundColor:
                    //       MaterialStateProperty.all<Color>(Colors.white),
                    //       backgroundColor: MaterialStateProperty.all<Color>(
                    //           Color(0xFF0C0467)),
                    //       shape:
                    //       MaterialStateProperty.all<RoundedRectangleBorder>(
                    //           RoundedRectangleBorder(
                    //             borderRadius: const BorderRadius.all(
                    //               const Radius.circular(20.0),
                    //             ),
                    //           ))),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String getUserEmail() {
    final User user = _auth.currentUser;
    return user.email;
  }

  Future<dynamic> deletePendingRequests(String docId) async {
    QueryDocumentSnapshot snapshot;
    await FirebaseFirestore.instance
        .collection('pending_approvals')
        .where("item_id", isEqualTo: docId)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        snapshot = value.docs[0];
        snapshot.reference.delete();
      }
    });
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
  }

  @override
  void dispose() {
    _isLoading = false;
    _snapshot.clear();
    super.dispose();
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
