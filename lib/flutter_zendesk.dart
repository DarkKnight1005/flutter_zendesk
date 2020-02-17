import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FlutterZendesk {
  static const MethodChannel _channel = const MethodChannel('flutter_zendesk');

  static Future<String> initiateZendesk({@required Map<String, dynamic> params}) async {
    return await _channel.invokeMethod('initiate', params);
  }

  static Future<String> openHelpCenter({@required Map<String, dynamic> params}) async {
    return await _channel.invokeMethod('help', params);
  }

  static Future<String> openRequests({@required Map<String, dynamic> params}) async {
    return await _channel.invokeMethod('feedback', params);
  }
}
