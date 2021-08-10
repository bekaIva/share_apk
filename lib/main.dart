import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_apk/repositories/native_operations.dart';

import 'constants/constants.dart';
import 'pages/home_page/blocs/home_page_bloc.dart';
import 'pages/home_page/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(ShareApk());
}

class ShareApk extends StatelessWidget {
  const ShareApk({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider(
            create: (context) => NativeOperations(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            appBarTheme: AppBarTheme(
                backgroundColor: kBackgroundColor,
                backwardsCompatibility: false, // 1
                systemOverlayStyle: SystemUiOverlayStyle.light,
                elevation: 0),
            scaffoldBackgroundColor: kBackgroundColor,
            accentColor: kAccentColor,
          ),
          home: BlocProvider(
            create: (context) => HomePageBloc(
                nativeOperations: context.read<NativeOperations>()),
            child: HomePage(),
          ),
        ));
  }
}
