import 'dart:math';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum AppSizeResult { ok, permissionRequired }

class PackageInfo extends ChangeNotifier {
  final Application application;
  bool sizePermissionGranted;
  int _appSize;
  int _cacheSize;
  int _dataSize;

  int get appSize => _appSize;
  int get cacheSize => _cacheSize;
  int get dataSize => _dataSize;

  int get totalSize => _appSize + cacheSize + _dataSize;

  String get totalSizeFormated => _formatBytes(totalSize, 2);
  String get appSizeFormated => _formatBytes(appSize, 2);
  String get cacheSizeFormated => _formatBytes(cacheSize, 2);
  String get dataSizeFormated => _formatBytes(dataSize, 2);

  var platform = MethodChannel('com.bSoft.share_apk/packageChannel');
  PackageInfo({required this.application, required this.sizePermissionGranted})
      : this._appSize = 0,
        this._cacheSize = 0,
        this._dataSize = 0 {
    if (sizePermissionGranted) {
      updateSize();
    }
  }

  Future<void> updateSize() async {
    var res = await platform
        .invokeMethod('appSize', {"packageName": application.packageName});
    _appSize = res['app Size'];
    _cacheSize = res['cache Size'];
    _dataSize = res['data Size'];
    notifyListeners();
  }

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }
}
