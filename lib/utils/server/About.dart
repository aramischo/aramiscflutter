// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:http/http.dart' as http;

// Project imports:
import 'package:aramisc/utils/Utils.dart';
import 'package:aramisc/utils/apis/Apis.dart';
import 'package:aramisc/utils/model/AboutSchool.dart';
import 'package:aramisc/utils/model/InfixMap.dart';

class About {
  List<InfixMap> infixMap = [];
  // static String _token;

  Future<AboutData> fetchAboutServices(String token) async {
    final response = await http.get(Uri.parse(AramiscApi.about),
        headers: Utils.setHeader(token.toString()));

    // print(response.request.url);
    var jsonData = json.decode(response.body);

    var data = jsonData['data'];

    return AboutData.fromJson(data);

    // infixMap.add(InfixMap('Description', data['main_description']));
    // infixMap.add(InfixMap('Description', data['main_description']));
    // infixMap.add(InfixMap('Address', data['address']));
    // infixMap.add(InfixMap('Phone', data['phone']));
    // infixMap.add(InfixMap('Email', data['email']));
    // infixMap.add(InfixMap('School Code', data['school_code']));
    // infixMap.add(InfixMap('Session', data['session']));
    //
    // return infixMap;
  }

  static Future<int> phonePermission(token) async {
    final response = await http.get(Uri.parse(AramiscApi.currentPermission),
        headers: Utils.setHeader(token.toString()));
    var jsonData = json.decode(response.body);
    int no = jsonData['data']['phone_number_privacy'];
    return no;
  }
}
