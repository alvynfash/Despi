import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:despi/blocs/bloc.dart';
import 'package:despi/repos/repo.dart';
import 'package:despi/signup/signup_event.dart';
import 'bloc.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  UserRepository _userRepository;

  SignupBloc(this._userRepository);

  @override
  SignupState get initialState => SignupUninitialized();

  @override
  Stream<SignupState> mapEventToState(
    SignupEvent event,
  ) async* {
    switch (event.runtimeType) {
      case FormLoad:
        yield* _mapFormLoadToState();
        break;

      case SignUpButtonPressed:
        var derivedEvent = event as SignUpButtonPressed;
        yield* _mapSignUpButtonPressedToState(
            derivedEvent.userName, derivedEvent.mobile);
        break;
    }
  }

  Stream<SignupState> _mapFormLoadToState() async* {
    yield InitialSignupState();
  }

  Stream<SignupState> _mapSignUpButtonPressedToState(
      String username, String mobile) async* {
    yield SignUpLoading();
    await Future.delayed(Duration(seconds: 2));
    //Todo: Perform validation here
    yield SignUpFailure(error: "Some error occured");

    // await _userRepository.signUp(username: username, mobile: mobile);
    //  _authenticationBloc.dispatch(AppStarted());
  }
}
