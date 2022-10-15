import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert' as convert;
import 'package:http_auth/http_auth.dart';

class PaypalServices {

  // String domain = "https://api.sandbox.paypal.com"; // for sandbox mode
 String domain = "https://api.paypal.com"; // for production mode

  // change clientId and secret with your own, provided by paypal
  String clientId = 'Ae9il8EESzZJYrnUdgGpdv779Gw8EzpkghCCKo3ubig8piNwGdgMRYMYfhQDjiLUIpnhIiSVZah_-cvL';
  String secret = 'EG5EQ-WJ5yiutm7AcMS_UqOboQ5OozltsncootCGDa-8dL7sEW9Fdi2JS_VxcIhHl1ePAintn513c95_';
  // String clientId = 'Aehynn-5MTlzyfg9xWHPWf5m1UJWmAa9ssu0wxYp3CYr8opv-smlf59qZ3e8r8v73X72bDikKPMVeBZQ';
  // String secret = 'EChw3ID1UEwk8mnUThDM7EeJzxU5P3sKwqf6DUQt_XUevyh60HU_dFMRArHjq2bTkvE6yVgPSi3CTAST';

  // for getting the access token from Paypal
  Future<String> getAccessToken() async {
    try {
      var client = BasicAuthClient(clientId, secret);
      var response = await client.post(Uri.parse('$domain/v1/oauth2/token?grant_type=client_credentials'));
      if (response.statusCode == 200) {
        final body = convert.jsonDecode(response.body);
        return body["access_token"];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // for creating the payment request with Paypal
  Future<Map<String, String>> createPaypalPayment(
      transactions, accessToken) async {
    try {
      var response = await http.post(Uri.parse("$domain/v1/payments/payment"),
          body: convert.jsonEncode(transactions),
          headers: {
            "content-type": "application/json",
            'Authorization': 'Bearer ' + accessToken
          });

      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 201) {
        if (body["links"] != null && body["links"].length > 0) {
          List links = body["links"];

          String executeUrl = "";
          String approvalUrl = "";
          final item = links.firstWhere((o) => o["rel"] == "approval_url",
              orElse: () => null);
          if (item != null) {
            approvalUrl = item["href"];
          }
          final item1 = links.firstWhere((o) => o["rel"] == "execute",
              orElse: () => null);
          if (item1 != null) {
            executeUrl = item1["href"];
          }
          return {"executeUrl": executeUrl, "approvalUrl": approvalUrl};
        }
        return null;
      } else {
        throw Exception(body["message"]);
      }
    } catch (e) {
      rethrow;
    }
  }

  // for executing the payment transaction
  Future<String> executePayment(url, payerId, accessToken) async {
    try {
      var response = await http.post(Uri.parse(url),
          body: convert.jsonEncode({"payer_id": payerId}),
          headers: {
            "content-type": "application/json",
            'Authorization': 'Bearer ' + accessToken
          },);

      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "Payment done!\nPayment ID: ${body["id"]}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 14.0
        );
        return body["id"];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> executePayout(accessToken, transactions) async {
    try {
      var response = await http.post(Uri.parse('$domain/v1/payments/payouts'),
        body: convert.jsonEncode(transactions),
        headers: {
          "content-type": "application/json",
          'Authorization': 'Bearer ' + accessToken
        },);

      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 201) {
        // Fluttertoast.showToast(
        //     msg: "You are payed out!\nPayout Batch ID: ${body["payout_batch_id "]}",
        //     toastLength: Toast.LENGTH_SHORT,
        //     gravity: ToastGravity.BOTTOM,
        //     timeInSecForIosWeb: 1,
        //     backgroundColor: Colors.red,
        //     textColor: Colors.white,
        //     fontSize: 14.0
        // );
        print("PAYOUT_BATCH_ID: ${response.statusCode}");
        return body["payout_batch_id "];
      }
      print("RESPONSE BODY: ${body['payout_batch_id']}");
      return null;
    } catch (e) {
      rethrow;
    }
  }
}