part of 'home_page_bloc.dart';

abstract class HomePageState {
  const HomePageState();
}

class HomePageStateInitial extends HomePageState {}

class HomePageStateLoading extends HomePageStateLoaded {
  HomePageStateLoading({
    required List<PackageInfo> packages,
  }) : super(
          packages: packages,
        );
}

class HomePageStateLoaded extends HomePageState {
  final List<PackageInfo> packages;
  HomePageStateLoaded({
    required this.packages,
  });
}

class HomePageStateError extends HomePageState {
  final Object error;
  final StackTrace stackTrace;
  HomePageStateError({required this.error, required this.stackTrace});
}
