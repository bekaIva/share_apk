import 'package:flutter/material.dart';
import 'package:share_apk/constants/constants.dart';
import 'package:share_apk/models/package_info.dart';
import 'package:share_apk/pages/home_page/home_page.dart';

class HomeSearchDelegate extends SearchDelegate {
  final List<PackageInfo> packages;
  HomeSearchDelegate({required this.packages});
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
        primaryIconTheme: IconThemeData(
          color: Colors.white,
        ),
        textSelectionTheme: TextSelectionThemeData(cursorColor: kAccentColor),
        inputDecorationTheme: InputDecorationTheme(
            hintStyle: Theme.of(context)
                .textTheme
                .headline6
                ?.copyWith(fontSize: 16, color: Colors.white),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: kAccentColor))),
        textTheme: TextTheme(headline6: TextStyle(color: Colors.white)));
  }

  @override
  Widget buildResults(BuildContext context) {
    var searchResult = packages
        .where((element) => element.application.appName.contains(query))
        .toList();
    return ApplicationsList(packages: searchResult);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var searchResult = packages
        .where((element) => element.application.appName
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
    return ApplicationsList(packages: searchResult);
  }
}
