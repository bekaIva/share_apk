import 'package:equatable/equatable.dart';

enum SortBy { size, name, installDate, updateDate, type }
enum SortMethod { ascending, descending }

class SortingModel extends Equatable {
  final SortBy sortBy;
  final SortMethod sortMethod;
  const SortingModel({required this.sortMethod, required this.sortBy});
  @override
  // TODO: implement props
  List<Object?> get props => [sortBy, sortMethod];
}
