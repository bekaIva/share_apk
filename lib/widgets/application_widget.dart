import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:device_apps/device_apps.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_apk/constants/constants.dart';
import 'package:share_apk/models/package_info.dart';
import 'package:share_apk/pages/application_page/application_page.dart';
import 'package:share_apk/repositories/native_operations.dart';
import 'package:share_apk/widgets/size_widget.dart';
import 'package:share_plus/share_plus.dart';

enum ApplicationPopupAction {
  extractApk,
  shareApk,
  launchApp,
  openSettings,
  openStore
}

class ApplicationWidget extends StatefulWidget {
  final bool inApplicationList;
  final PackageInfo packageInfo;
  const ApplicationWidget(
      {required this.packageInfo, required this.inApplicationList, Key? key})
      : super(key: key);

  @override
  _ApplicationWidgetState createState() => _ApplicationWidgetState();
}

class _ApplicationWidgetState extends State<ApplicationWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Container(
        decoration: BoxDecoration(
            color: kDarkBackgroundColor,
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
            boxShadow: [
              BoxShadow(
                  offset: Offset(2, 2),
                  blurRadius: 8,
                  spreadRadius: .1,
                  color: Colors.black.withOpacity(.6)),
              BoxShadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  spreadRadius: 0,
                  color: Colors.black.withOpacity(.2))
            ]),
        child: Stack(
          children: [
            Positioned(
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            widget.packageInfo.application.systemApp
                                ? kRed
                                : kBlue,
                            widget.packageInfo.application.systemApp
                                ? kRed
                                : kBlue,
                            Colors.transparent
                          ],
                          stops: [0, 0.2, 0.8, 1],
                          end: Alignment.topCenter),
                      boxShadow: [
                        BoxShadow(
                            color: (widget.packageInfo.application.systemApp
                                    ? kRed
                                    : kBlue)
                                .withOpacity(.4),
                            offset: Offset(10, 0),
                            spreadRadius: 1,
                            blurRadius: 30),
                        BoxShadow(
                            color: (widget.packageInfo.application.systemApp
                                    ? kRed
                                    : kBlue)
                                .withOpacity(.1),
                            offset: Offset(10, 0),
                            spreadRadius: 1,
                            blurRadius: 25),
                      ]),
                )),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (widget.packageInfo.application
                              is ApplicationWithIcon)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Hero(
                                tag: widget.packageInfo.application.apkFilePath,
                                child: Image.memory(
                                  (widget.packageInfo.application
                                          as ApplicationWithIcon)
                                      .icon,
                                  width: 32,
                                  height: 32,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(
                                    height: 14,
                                  ),
                                  SelectableText(
                                    widget.packageInfo.application.appName,
                                    style: TextStyle(
                                        color: kTitleColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SelectableText(
                                    widget.packageInfo.application.packageName,
                                    style: TextStyle(
                                      color: kDarkTitleColor,
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Version code: ',
                                        style: TextStyle(
                                            color: kDarkTitleColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Expanded(
                                        child: SelectableText(
                                          widget.packageInfo.application
                                              .versionCode
                                              .toString(),
                                          style:
                                              TextStyle(color: kDarkTitleColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Version name: ',
                                        style: TextStyle(
                                            color: kDarkTitleColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Expanded(
                                        child: SelectableText(
                                          widget.packageInfo.application
                                                  .versionName ??
                                              '',
                                          style:
                                              TextStyle(color: kDarkTitleColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (widget
                                          .packageInfo.application.systemApp &&
                                      !widget.inApplicationList)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Application Type: ',
                                          style: TextStyle(
                                              color: kDarkTitleColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Expanded(
                                          child: SelectableText(
                                            'System',
                                            style: TextStyle(color: kRed),
                                          ),
                                        ),
                                      ],
                                    ),
                                  SizedBox(height: 8)
                                ],
                              ),
                            ),
                            PopupMenuButton<ApplicationPopupAction>(
                              icon: Icon(
                                Icons.more_vert,
                                color: kAccentColor,
                              ),
                              onSelected: (value) async {
                                switch (value) {
                                  case ApplicationPopupAction.extractApk:
                                    var permissionStatus =
                                        await Permission.storage.status;
                                    if (!permissionStatus.isGranted) {
                                      await Permission.storage.request();
                                    }
                                    permissionStatus =
                                        await Permission.storage.status;
                                    if (permissionStatus.isGranted) {
                                      File apkFile = File(widget
                                          .packageInfo.application.apkFilePath);
                                      var docPath = await AndroidPathProvider
                                              .documentsPath +
                                          '/${basename(widget.packageInfo.application.apkFilePath)}';
                                      await apkFile.copy(docPath);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  'File saved to: $docPath')));
                                    }
                                    break;
                                  case ApplicationPopupAction.shareApk:
                                    Share.shareFiles([
                                      widget
                                          .packageInfo.application.apkFilePath,
                                    ],
                                        text: widget
                                            .packageInfo.application.appName);
                                    break;
                                  case ApplicationPopupAction.launchApp:
                                    widget.packageInfo.application.openApp();
                                    break;
                                  case ApplicationPopupAction.openSettings:
                                    widget.packageInfo.application
                                        .openSettingsScreen();
                                    // TODO: Handle this case.
                                    break;
                                  case ApplicationPopupAction.openStore:
                                    {
                                      context
                                          .read<NativeOperations>()
                                          .openStore(widget.packageInfo
                                              .application.packageName);
                                      break;
                                    }
                                }
                              },
                              itemBuilder: (context) {
                                return ApplicationPopupAction.values
                                    .map((e) =>
                                        PopupMenuItem<ApplicationPopupAction>(
                                            value: e,
                                            child: Text(
                                              EnumToString.convertToString(e,
                                                  camelCase: true),
                                              style: TextStyle(
                                                  color: kDarkTitleColor),
                                            )))
                                    .toList();
                              },
                            ),
                            SizedBox(
                              width: 4,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ChangeNotifierProvider.value(
                        value: widget.packageInfo,
                        child: Flexible(
                          fit: FlexFit.loose,
                          child: SizeWidget(
                            inApplicationList: widget.inApplicationList,
                          ),
                        ),
                      ),
                      if (widget.inApplicationList)
                        Expanded(
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: TextButton(
                                child: Icon(Icons.navigate_next),
                                style: TextButton.styleFrom(
                                    minimumSize: Size(1, 1),
                                    shape: CircleBorder(),
                                    primary: kAccentColor),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        ChangeNotifierProvider.value(
                                      value: widget.packageInfo,
                                      child: ApplicationPage(
                                          packageInfo: widget.packageInfo),
                                    ),
                                  ));
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
