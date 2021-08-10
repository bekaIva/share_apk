import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/services.dart';
import 'package:share_apk/models/package_info.dart';
import 'package:share_apk/models/sorting_model.dart';
import 'package:share_apk/repositories/native_operations.dart';

part 'home_page_event.dart';
part 'home_page_state.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  NativeOperations nativeOperations;

  SortingModel? sortingModel;
  FutureCancellation? _cancellation;
  List<PackageInfo> _packages = [];
  HomePageBloc({required this.nativeOperations}) : super(HomePageStateInitial());

  @override
  Stream<HomePageState> mapEventToState(
    HomePageEvent event,
  ) async* {
    if (event is HomePageEventLoad) {
      _cancellation?.cancel();
      _cancellation = FutureCancellation();
      yield* homePageLoad(event, _cancellation!);
    }
    if (event is HomePageSortEvent) {
      sortingModel = event.sortingModel;
      yield* _sort();
    }
  }

  Stream<HomePageState> homePageLoad(
      HomePageEventLoad event, FutureCancellation cancellation) async* {
    if (cancellation.isCanceled) return;
    yield HomePageStateLoading(
      packages: _packages,
    );
    var res = await DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        includeSystemApps: event.includeSystemApps,
        onlyAppsWithLaunchIntent: false);
    if (cancellation.isCanceled) return;
    var isGranted = await nativeOperations.checkPermissionStatus();
    _packages = res
        .map((e) => PackageInfo(
            application: e, sizePermissionGranted: isGranted ?? false))
        .toList();
    yield HomePageStateLoaded(
      packages: _packages,
    );
  }



  Stream<HomePageState> _sort() async* {
    if (sortingModel != null) {
      switch (sortingModel!.sortBy) {
        case SortBy.size:
          _packages.sort((a, b) => a.totalSize.compareTo(b.totalSize));
          if (sortingModel!.sortMethod == SortMethod.descending)
            _packages = _packages.reversed.toList();
          break;
        case SortBy.name:
          _packages.sort(
              (a, b) => a.application.appName.compareTo(b.application.appName));
          if (sortingModel!.sortMethod == SortMethod.descending)
            _packages = _packages.reversed.toList();
          break;
        case SortBy.installDate:
          _packages.sort((a, b) => a.application.installTimeMillis
              .compareTo(b.application.installTimeMillis));
          if (sortingModel!.sortMethod == SortMethod.descending)
            _packages = _packages.reversed.toList();
          break;
        case SortBy.updateDate:
          _packages.sort((a, b) => a.application.updateTimeMillis
              .compareTo(b.application.updateTimeMillis));
          if (sortingModel!.sortMethod == SortMethod.descending)
            _packages = _packages.reversed.toList();
          break;
        case SortBy.type:
          _packages.sort((a, b) => b.application.systemApp ? 1 : -1);
          if (sortingModel!.sortMethod == SortMethod.descending)
            _packages = _packages.reversed.toList();
          break;
      }
    }
    yield HomePageStateLoaded(
      packages: _packages,
    );
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    emit(HomePageStateError(error: error, stackTrace: stackTrace));
    super.onError(error, stackTrace);
  }
}

class FutureCancellation {
  bool isCanceled = false;
  void cancel() {
    isCanceled = true;
  }
}
