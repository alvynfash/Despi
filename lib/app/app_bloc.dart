import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:despi/repos/repo.dart';

import 'bloc.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final UserRepository userRepository;

  AppBloc() : userRepository = UserRepository();

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
    await Future.delayed(Duration(seconds: 2));
    final isSignedIn = await userRepository.isSignedIn();
    if (!isSignedIn) {
      yield WaitingOnboarding();
      return;
    }

    final user = await userRepository.getUser();
    yield user.isNotEmpty ? Authenticated(user) : WaitingOnboarding();
  }

  Stream<AppState> _mapAppOnboardedToState() async* {
    yield Unauthenticated();
  }

  Stream<AppState> _mapAppSignedUpToState() async* {
    //   String username, String mobile) async* {
    // await _userRepository.signUp(username: username, mobile: mobile);
    yield Authenticated(await userRepository.getUser());
  }

  Stream<AppState> _mapLoggedOutToState() async* {
    yield Unauthenticated();
    userRepository.signOut();
  }
}
