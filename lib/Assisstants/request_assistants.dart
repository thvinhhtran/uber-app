import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestAssistants {
  static Future<dynamic> receiveRequest(String url) async {
    http.Response httpResponse = await http.get(Uri.parse(url));

    try {
      if (httpResponse.statusCode == 200) {
        String responseData = httpResponse.body;
        var decodeData = jsonDecode(responseData);
        return decodeData;
      } else {
        return "Error: ${httpResponse.statusCode}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}