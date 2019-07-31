import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:despi/blocs/bloc.dart';
import 'package:despi/repos/repo.dart';
import 'package:despi/screens/utils/util.dart';
import 'package:despi/signup/signup_event.dart';
import 'package:despi/signup/signup_state.dart';
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

      case UsernameChanged:
        yield* _mapUsernameChangedToState((event as UsernameChanged).username);
        break;

      case PhoneChanged:
        yield* _mapPhoneChangedToState((event as PhoneChanged).phone);
        break;

      case NextSignUpPressed:
        yield* _mapNextSignUpPressedToState();
        break;

      case BackSignUpPressed:
        yield* _mapBackSignUpPressedToState();
        break;

      case SignUpButtonPressed:
        yield* _mapSignUpButtonPressedToState();
        break;
    }
  }

  Stream<SignupState> _mapFormLoadToState() async* {
    yield SignupInitialized();
  }

  Stream<SignupState> _mapUsernameChangedToState(String username) async* {
    yield currentState.copyWith(
      username: username,
      isNextActive: username.isNotEmpty,
      isFailure: false,
    );
  }

  Stream<SignupState> _mapPhoneChangedToState(String phone) async* {
    yield currentState.copyWith(
      phone: phone,
      isNextActive: phoneNumberValidator(phone),
      isPhoneValid: phoneNumberValidator(phone),
      isFailure: false,
    );
  }

  Stream<SignupState> _mapBackSignUpPressedToState() async* {
    yield currentState.copyWith(
        mode: SignUpModes.username,
        isNextActive: currentState.username.isNotEmpty);
  }

  Stream<SignupState> _mapNextSignUpPressedToState() async* {
    hideKeyboard();
    if (currentState.mode == SignUpModes.username) {
      if (currentState.username.isNotEmpty) {
        yield currentState.copyWith(
            mode: SignUpModes.phone,
            isNextActive: currentState.phone.isNotEmpty);
      } else
        yield currentState.copyWith(
            isFailure: true, failureMessage: "Username field is obligatory");
    } else if (currentState.mode == SignUpModes.phone) {
      if (currentState.phone.isNotEmpty &&
          phoneNumberValidator(currentState.phone)) {
        yield currentState.copyWith(isSubmitting: true);
        await Future.delayed(Duration(seconds: 2));
        await _userRepository.signUp(
          username: currentState.username,
          mobile: currentState.phone,
        );
        yield currentState.copyWith(isSuccess: true);
      } else
        yield currentState.copyWith(
            isFailure: true, failureMessage: "Phone field is obligatory");
    }
  }

  Stream<SignupState> _mapSignUpButtonPressedToState() async* {
    // yield SignUpLoading();
    // await Future.delayed(Duration(seconds: 2));
    // //Todo: Perform validation here
    // yield SignUpFailure(error: "Some error occured");

    // await _userRepository.signUp(username: username, mobile: mobile);
    //  _authenticationBloc.dispatch(AppStarted());
  }

  bool phoneNumberValidator(String value) {
    String patttern = r'(^(?:[+0-9])?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0 || !regExp.hasMatch(value)) return false;

    return true;
  }
}
