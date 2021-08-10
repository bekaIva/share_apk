import 'package:flutter/services.dart';

class NativeOperations {
  var eventChannel = EventChannel('com.bSoft.share_apk/appPremissionsStream');
  var platform = MethodChannel('com.bSoft.share_apk/packageChannel');
  Future<bool?> checkPermissionStatus() async {
    return await platform.invokeMethod<bool>(
      'getGrantStatus',
    );
  }

  Future<List<String>?> appPermissions(String packageName) async {
    var permissions = await platform
        .invokeMethod('appPremissions', {"packageName": packageName});
    if (permissions is List) {
      return List<String>.from((permissions as List<Object?>));
    }
    return null;
  }

  Future<void> openStore(String packageName) async {
    await platform
        .invokeMethod('launchPackageOnMarket', {"packageName": packageName});
  }
}
