part of 'home_page_bloc.dart';

abstract class HomePageEvent {
  const HomePageEvent();
}

class HomePageSortEvent extends HomePageEvent {
  final SortingModel sortingModel;
  HomePageSortEvent({required this.sortingModel});
}

class HomePageEventLoad extends HomePageEvent {
  final bool includeSystemApps;
  HomePageEventLoad({required this.includeSystemApps});
}
