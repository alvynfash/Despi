import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:despi/repos/repo.dart';
import 'package:geolocator/geolocator.dart';

import 'bloc.dart';

class AppBloc extends Bloc<AppEvent, AppState> {

  AppBloc() : userRepository = UserRepository();
  UserRepository userRepository;
  String _displayName;
  Position _initialPosition;
  Placemark _initialPlacemark;

  @override
  AppState get initialState => Uninitialized();

  @override
  Stream<AppState> mapEventToState(
    AppEvent event,
  ) async* {
    switch (event.runtimeType) {
      case AppStarted:
        yield* _mapAppStartedToState();
        break;
      case AppOnboarded:
        yield* _mapAppOnboardedToState();
        break;
      case AppSignedUp:
        yield* _mapAppSignedUpToState();
        break;
      case LoggedOut:
        yield* _mapLoggedOutToState();
        break;
    }
  }

  Stream<AppState> _mapAppStartedToState() async* {
    final isSignedIn = await userRepository.isSignedIn();
    if (!isSignedIn) {
      yield WaitingOnboarding();
      return;
    }

    try {
      _initialPosition = await Geolocator().getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);

      var reversePosition =
          await Geolocator().placemarkFromPosition(_initialPosition);
      _initialPlacemark = reversePosition.first;
    } catch (e) {} finally {
      _displayName = await userRepository.getUser();
      yield _displayName.isNotEmpty
          ? Authenticated(
              userRepository: userRepository,
              initialPosition: _initialPosition,
              initialPlacemark: _initialPlacemark)
          : WaitingOnboarding();
    }
  }

  Stream<AppState> _mapAppOnboardedToState() async* {
    yield Unauthenticated();
  }

  Stream<AppState> _mapAppSignedUpToState() async* {
    try {
      _initialPosition = await Geolocator().getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);

      var reversePosition =
          await Geolocator().placemarkFromPosition(_initialPosition);
      _initialPlacemark = reversePosition.first;
    } catch (e) {} finally {
      // _displayName = await _userRepository.getUser();
      yield Authenticated(
          userRepository: userRepository,
          initialPosition: _initialPosition,
          initialPlacemark: _initialPlacemark);
    }
  }

  Stream<AppState> _mapLoggedOutToState() async* {
    yield Unauthenticated();
    userRepository.signOut();
  }
}
