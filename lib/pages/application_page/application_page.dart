import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:share_apk/constants/constants.dart';
import 'package:share_apk/models/package_info.dart';
import 'package:share_apk/repositories/native_operations.dart';
import 'package:share_apk/widgets/application_widget.dart';

class ApplicationPage extends StatefulWidget {
  final PackageInfo packageInfo;
  const ApplicationPage({required this.packageInfo, Key? key})
      : super(key: key);

  @override
  _ApplicationPageState createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage>
    with WidgetsBindingObserver {
  final ValueNotifier<bool> showBaner = ValueNotifier(false);
  BannerAd? myBanner;
  Future<void> load() async {
    myBanner = BannerAd(
      adUnitId: adUnit,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (Ad ad) => showBaner.value = true,
        // Called when an ad request failed.
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          showBaner.value = false;
          ad.dispose();
          Future.delayed(Duration(seconds: 2)).then((value) {
            if (mounted) load();
          });
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) {
          showBaner.value = true;
        },
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) {},
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) {},
      ),
    );
    myBanner!.load();
  }

  @override
  void didChangeDependencies() {
    if (!widget.packageInfo.sizePermissionGranted) {
      context.read<NativeOperations>().checkPermissionStatus().then((value) {
        if (value ?? false) {
          widget.packageInfo.sizePermissionGranted = value!;
          widget.packageInfo.updateSize();
        }
      });
    }
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    load();
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!widget.packageInfo.sizePermissionGranted) {
        context.read<NativeOperations>().checkPermissionStatus().then((value) {
          if (value ?? false) {
            widget.packageInfo.sizePermissionGranted = value!;
            widget.packageInfo.updateSize();
          }
        });
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    myBanner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.packageInfo.application.appName),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: showBaner,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 8,
              ),
              Consumer<PackageInfo>(
                builder: (context, value, child) => ApplicationWidget(
                  inApplicationList: false,
                  packageInfo: widget.packageInfo,
                ),
              ),
              Expanded(
                child: FutureBuilder<List<String>?>(
                  future: context.read<NativeOperations>().appPermissions(
                      widget.packageInfo.application.packageName),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        return LinearProgressIndicator();
                    }

                    if (snapshot.data != null) {
                      return Theme(
                        data: ThemeData(
                          accentColor: kTitleColor,
                          unselectedWidgetColor: kDarkTitleColor,
                          iconTheme: IconThemeData(color: kDarkTitleColor),
                          textTheme: TextTheme(
                            subtitle1: TextStyle(color: kDarkTitleColor),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: ExpansionTile(
                            title: Text('Permissions'),
                            children: snapshot.data!
                                .map((e) => Padding(
                                      padding: const EdgeInsets.only(
                                          left: 14, right: 14, bottom: 2),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          e,
                                          style:
                                              TextStyle(color: kDarkTitleColor),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      );
                    }
                    return SizedBox();
                  },
                ),
              )
            ],
          ),
          builder: (context, value, child) {
            return Column(
              children: [
                Expanded(child: child!),
                if (value && myBanner != null)
                  Container(
                    width: myBanner!.size.width.toDouble(),
                    height: myBanner!.size.height.toDouble(),
                    child: AdWidget(
                      ad: myBanner!,
                    ),
                  )
              ],
            );
          },
        ),
      ),
    );
  }
}
