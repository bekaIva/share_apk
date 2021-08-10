import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_apk/constants/constants.dart';
import 'package:share_apk/models/package_info.dart';

class SizeWidget extends StatefulWidget {
  final bool inApplicationList;
  const SizeWidget({required this.inApplicationList, Key? key})
      : super(key: key);

  @override
  _SizeWidgetState createState() => _SizeWidgetState();
}

class _SizeWidgetState extends State<SizeWidget> {
  var platform = MethodChannel('com.bSoft.share_apk/packageChannel');
  @override
  Widget build(BuildContext context) {
    return Consumer<PackageInfo>(
      builder: (context, packageInfo, child) {
        if (packageInfo.sizePermissionGranted == true) {
          if (widget.inApplicationList) {
            return Text(
              packageInfo.totalSizeFormated,
              style: TextStyle(color: kTitleColor),
            );
          } else {
            return Theme(
              data: ThemeData(
                accentColor: kTitleColor,
                unselectedWidgetColor: kAccentColor,
                iconTheme: IconThemeData(color: kDarkTitleColor),
                textTheme: TextTheme(
                  subtitle1: TextStyle(color: kDarkTitleColor),
                ),
              ),
              child: ExpansionTile(
                title: Text(
                  packageInfo.totalSizeFormated,
                ),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'App size: ',
                            style: TextStyle(
                                color: kDarkTitleColor,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Cache size: ',
                            style: TextStyle(
                                color: kDarkTitleColor,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Data size: ',
                            style: TextStyle(
                                color: kDarkTitleColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            packageInfo.appSizeFormated,
                            style: TextStyle(color: kDarkTitleColor),
                          ),
                          Text(
                            packageInfo.cacheSizeFormated,
                            style: TextStyle(color: kDarkTitleColor),
                          ),
                          Text(
                            packageInfo.dataSizeFormated,
                            style: TextStyle(color: kDarkTitleColor),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        } else {
          return TextButton(
              style: TextButton.styleFrom(
                  minimumSize: Size(1, 1), shape: CircleBorder()),
              onPressed: () async {
                var proceed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Permission required'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text('Cancel')),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text('Continue'))
                    ],
                    content: Text(
                        'To get the size of the app, permission to access usage data is required, click "Continue" to allow'),
                  ),
                );
                if (proceed ?? false) {
                  await platform.invokeMethod(
                    'requestUsageAccessPermission',
                  );
                }
              },
              child: Icon(Icons.info_rounded));
        }
      },
    );
  }
}
