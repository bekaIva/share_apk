import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:share_apk/constants/constants.dart';
import 'package:share_apk/models/package_info.dart';
import 'package:share_apk/models/sorting_model.dart';
import 'package:share_apk/repositories/native_operations.dart';
import 'package:share_apk/widgets/application_widget.dart';
import 'package:share_apk/widgets/sorting_dialog.dart';

import 'blocs/home_page_bloc.dart';
import 'search_delegate/search_delegate.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  HomePageBloc? _bloc;
  ValueNotifier<bool> includeSystemApps = ValueNotifier(false);
  final ValueNotifier<bool> showBaner = ValueNotifier(false);
  BannerAd? myBanner;
  @override
  void didChangeDependencies() {
    _bloc = context.read<HomePageBloc>();
    if (context.read<HomePageBloc>().state is HomePageStateInitial) {
      context
          .read<HomePageBloc>()
          .add(HomePageEventLoad(includeSystemApps: includeSystemApps.value));
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
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    myBanner?.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (context.read<HomePageBloc>().state is HomePageStateLoaded) {
        var state = context.read<HomePageBloc>().state as HomePageStateLoaded;
        var isPermissionGranted =
            await context.read<NativeOperations>().checkPermissionStatus();
        if ((isPermissionGranted ?? false) &&
            state.packages.any((element) => !element.sizePermissionGranted)) {
          context.read<HomePageBloc>().add(
              HomePageEventLoad(includeSystemApps: includeSystemApps.value));
        }
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomePageBloc, HomePageState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text('Apk Share'),
          actions: [
            if (state is HomePageStateLoaded)
              IconButton(
                  onPressed: () async {
                    var previousSortingModel =
                        context.read<HomePageBloc>().sortingModel;
                    var sortingModel = await showDialog<SortingModel>(
                      context: context,
                      builder: (context) => Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          child: SortingDialog(
                            selectedSortingModel: previousSortingModel,
                          )),
                    );
                    if (sortingModel != null) {
                      context
                          .read<HomePageBloc>()
                          .add(HomePageSortEvent(sortingModel: sortingModel));
                    }
                  },
                  icon: Icon(Icons.sort)),
            PopupMenuButton(
              child: Icon(Icons.filter_list),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: includeSystemApps,
                      builder: (context, value, child) => CheckboxListTile(
                        title: Text('Include system apps'),
                        value: includeSystemApps.value,
                        onChanged: (value) {
                          if (value != null) {
                            includeSystemApps.value = value;
                            _bloc?.add(HomePageEventLoad(
                                includeSystemApps: includeSystemApps.value));
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                  )
                ];
              },
            ),
            if (state is HomePageStateLoaded)
              IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                        context: context,
                        delegate: HomeSearchDelegate(packages: state.packages));
                  }),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<HomePageBloc>().add(HomePageEventLoad(
                  includeSystemApps: includeSystemApps.value));
            },
            child: ValueListenableBuilder<bool>(
              child: HomePageContent(
                state: state,
              ),
              valueListenable: showBaner,
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
        ),
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  final HomePageState state;
  HomePageContent({required this.state});

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.state is HomePageStateLoaded)
          ApplicationsList(
            packages: (widget.state as HomePageStateLoaded).packages,
          ),
        if (widget.state is HomePageStateLoading)
          Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}

class ApplicationsList extends StatelessWidget {
  final List<PackageInfo> packages;
  const ApplicationsList({required this.packages, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [kBackgroundColor, Colors.transparent],
        ).createShader(Rect.fromLTRB(0, 0, 0, 2));
      },
      blendMode: BlendMode.dstIn,
      child: ListView.separated(
          itemBuilder: (context, index) => index == 0
              ? SizedBox(
                  height: 4,
                )
              : ApplicationWidget(
                  packageInfo: packages[index - 1],
                  inApplicationList: true,
                ),
          separatorBuilder: (context, index) => Divider(),
          itemCount: packages.length + 1),
    );
  }
}
