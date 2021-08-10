import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:share_apk/constants/constants.dart';
import 'package:share_apk/models/sorting_model.dart';

class SortingDialog extends StatefulWidget {
  final SortingModel? selectedSortingModel;
  const SortingDialog({this.selectedSortingModel, Key? key}) : super(key: key);

  @override
  _SortingDialogState createState() => _SortingDialogState();
}

class _SortingDialogState extends State<SortingDialog> {
  @override
  Widget build(BuildContext context) {
    return ListView(
        shrinkWrap: true,
        children: SortBy.values
            .map((e) => TextButton(
                style: TextButton.styleFrom(primary: kDarkTitleColor),
                onPressed: () {
                  Navigator.of(context).pop(SortingModel(
                      sortMethod: widget.selectedSortingModel?.sortBy == e &&
                              widget.selectedSortingModel?.sortMethod ==
                                  SortMethod.ascending
                          ? SortMethod.descending
                          : SortMethod.ascending,
                      sortBy: e));
                },
                child: Text(EnumToString.convertToString(e, camelCase: true))))
            .toList());
  }
}
