import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:despi/repos/repo.dart';
import 'package:meta/meta.dart';
import '../bloc.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository _userRepository;

  AuthenticationBloc() : _userRepository = UserRepository();

  @override
  AuthenticationState get initialState => Uninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    } else if (event is SignedUp) {
      yield* _mapSignedUpToState();
    } else if (event is LoggedOut) {
      yield* _mapLoggedOutToState();
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    await Future.delayed(Duration(seconds: 2));
    final isSignedIn = await _userRepository.isSignedIn();
    if (isSignedIn) {
      final user = await _userRepository.getUser();
      yield Authenticated(user);
    } else {
      yield Unauthenticated();
    }
  }

  Stream<AuthenticationState> _mapSignedUpToState() async* {
    await _userRepository.signUp();
    yield Authenticated(await _userRepository.getUser());
  }

  Stream<AuthenticationState> _mapLoggedOutToState() async* {
    yield Unauthenticated();
    _userRepository.signOut();
  }
}
