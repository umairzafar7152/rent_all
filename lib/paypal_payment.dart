import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_all/paypal_services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaypalPaymentPage extends StatefulWidget {
  PaypalPaymentPage(
      {Key key,
      @required this.itemName,
      @required this.amountToPay,
      @required this.itemId,
      @required this.start,
      @required this.end,
      @required this.lesseeEmail,
      @required this.lesseeMobile,
      @required this.lessorEmail,
      @required this.lessorMobile,
      this.onFinish})
      : super(key: key);
  final String itemName;
  final double amountToPay;
  final String itemId;
  final Function onFinish;
  final String start;
  final String end;
  final String lesseeEmail;
  final String lesseeMobile;
  final String lessorEmail;
  final String lessorMobile;

  @override
  State<StatefulWidget> createState() {
    return PaypalPaymentPageState();
  }
}

class PaypalPaymentPageState extends State<PaypalPaymentPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _checkoutUrl;
  String _executeUrl;
  String _accessToken;
  PaypalServices _services = PaypalServices();
  double _amountToPayToSeller;
  Map<String, dynamic> _dataToUpload;

  Map<dynamic, dynamic> defaultCurrency = {
    "symbol": "CAD ",
    "decimalDigits": 2,
    "symbolBeforeTheNumber": true,
    "currency": "CAD"
  };

  // bool isEnableShipping = false;
  // bool isEnableAddress = false;

  String returnURL = 'return.example.com';
  String cancelURL = 'cancel.example.com';

  // item name, price and quantity
  String itemName;
  String itemPrice;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    itemName = widget.itemName;
    itemPrice = widget.amountToPay.toString();
    double totalAmount = widget.amountToPay;
    _amountToPayToSeller = totalAmount - (totalAmount * 0.1);

    Future.delayed(Duration.zero, () async {
      try {
        await _services.getAccessToken().then((value) {
          print("Access token done!");
          _accessToken = value;
          print('$_accessToken');
        });

        final transactions = getOrderParams();
        var res;
        await _services
            .createPaypalPayment(transactions, _accessToken)
            .then((value) {
          res = value;
          if (res != null) {
            print('Res not null');
            setState(() {
              _checkoutUrl = res["approvalUrl"];
              _executeUrl = res["executeUrl"];
            });
          }
        });
      } catch (e) {
        print('exception: ' + e.toString());
        final snackBar = SnackBar(
          content: Text(e.toString()),
          duration: Duration(seconds: 10),
          action: SnackBarAction(
            label: 'Close',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );
        ScaffoldMessenger.of(_scaffoldKey.currentContext)
            .showSnackBar(snackBar);
      }
    });
  }

  Map<String, dynamic> getOrderParams() {
    List items = [
      {
        "name": itemName,
        "quantity": quantity,
        "price": itemPrice,
        "currency": defaultCurrency["currency"]
      }
    ];

    // checkout invoice details
    String totalAmount = '${widget.amountToPay}';
    String subTotalAmount = '${widget.amountToPay}';
    String shippingCost = '0';
    int shippingDiscountCost = 0;

    Map<String, dynamic> temp = {
      "intent": "sale",
      "payer": {"payment_method": "paypal"},
      "transactions": [
        {
          "amount": {
            "total": totalAmount,
            "currency": defaultCurrency["currency"],
            "details": {
              "subtotal": subTotalAmount,
              "shipping": shippingCost,
              "shipping_discount": ((-1.0) * shippingDiscountCost).toString()
            }
          },
          "description": "The payment transaction description.",
          "payment_options": {
            "allowed_payment_method": "INSTANT_FUNDING_SOURCE"
          },
          "item_list": {
            "items": items,
          }
        }
      ],
      "note_to_payer": "Contact us for any questions on your order.",
      "redirect_urls": {"return_url": returnURL, "cancel_url": cancelURL}
    };
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    print(_checkoutUrl);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xFF0C0467), // status bar color
        brightness: Brightness.dark,
        leading: GestureDetector(
          child: Icon(Icons.arrow_back_ios),
          onTap: () => Navigator.pop(context),
        ),
      ),
      body: _checkoutUrl == null
          ? Center(
              child: LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0C0467)),
            ))
          : WebView(
              initialUrl: _checkoutUrl,
              javascriptMode: JavascriptMode.unrestricted,
              navigationDelegate: (NavigationRequest request) {
                if (request.url.contains(returnURL)) {
                  final uri = Uri.parse(request.url);
                  final payerID = uri.queryParameters['PayerID'];
                  if (payerID != null) {
                    _services
                        .executePayment(_executeUrl, payerID, _accessToken)
                        .then((id) {
                      _dataToUpload = {
                        "start": DateTime.parse(widget.start),
                        "end": DateTime.parse(widget.end),
                        "item_id": widget.itemId,
                        'item_name': widget.itemName,
                        "lessee_email": widget.lesseeEmail,
                        "lessee_mobile": widget.lesseeMobile,
                        "lessor_email": widget.lessorEmail,
                        "lessor_mobile": widget.lessorMobile,
                        "item_received": false,
                        'amount': widget.amountToPay,
                        "payment_id": id
                      };
                      CollectionReference collectionReference =
                          FirebaseFirestore.instance
                              .collection('acquired_items');
                      collectionReference.add(_dataToUpload).then((value) {
                        final transactions = getPayoutParams();
                        _services
                            .executePayout(_accessToken, transactions)
                            .then((value) {
                          print('PAYOUT_BATCH_ID-----||||||||$value');
                        });
                      });
                      widget.onFinish(id);
                    });
                  } else {
                    Navigator.of(context).pop();
                  }
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return paymentDoneDialog();
                    },
                  );
                  Navigator.of(context).pop();
                }
                if (request.url.contains(cancelURL)) {
                  Navigator.of(context).pop();
                }
                return NavigationDecision.navigate;
              },
            ),
    );
  }

  Map<String, dynamic> getPayoutParams() {
    Map<String, dynamic> temp = {
      "sender_batch_header": {
        "sender_batch_id": "Payouts_2021_01",
        "email_subject": "You have a payout from Rent All!",
        "email_message":
            "You have received a payout for renting your item '${widget.itemName}'! Thanks for using our service!"
      },
      "items": [
        {
          "recipient_type": "EMAIL",
          "amount": {
            "value": "$_amountToPayToSeller",
            "currency": defaultCurrency['currency']
          },
          "note": "Thanks for your patronage!",
          "sender_item_id": "${widget.itemId}",
          // "receiver": "sb-z6k4c5819676@business.example.com",
          "receiver": "${widget.lessorEmail}",
          "notification_language": "en-CA"
        },
      ]
    };
    return temp;
  }

  Widget paymentDoneDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      title: Row(
        children: <Widget>[
          Icon(
            Icons.reset_tv,
            color: Colors.red,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Payment done!",
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
            "Note: You can check your paid rent items in 'Acquired Items'",
            style: TextStyle(color: Color(0xFF0C0467)),
          )
        ],
      ),
    );
  }
}
