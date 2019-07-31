import 'package:despi/blocs/bloc.dart';

enum SignUpModes {
  username,
  phone,
}

class SignupState extends BaseState {
  
  String username = "";
  String phone = "";
  bool isUsernameValid = true;
  bool isPhoneValid = true;
  bool get isFormValid => isUsernameValid && isPhoneValid;
  bool isSubmitting = false;
  bool isSuccess = false;
  bool isFailure = false;
  String failureMessage ="";
  bool isNextActive = false;
  SignUpModes mode = SignUpModes.username;

  SignupState(){
    isBusy = false;
  }

  SignupState copyWith(
      {
      String username,
      String phone,
      bool isUsernameValid,
      bool isPhoneValid,
      bool isSubmitting,
      bool isSuccess,
      bool isFailure,
      String failureMessage,
      bool isNextActive,
      SignUpModes mode}) {
    return SignupState()
      ..username = username ?? this.username
      ..phone = phone ?? this.phone
      ..isUsernameValid = isUsernameValid ?? this.isUsernameValid
      ..isPhoneValid = isPhoneValid ?? this.isPhoneValid
      ..isSubmitting = isSubmitting ?? this.isSubmitting
      ..isSuccess = isSuccess ?? this.isSuccess
      ..isFailure = isFailure ?? this.isFailure
      ..failureMessage = failureMessage ?? this.failureMessage
      ..isNextActive = isNextActive ?? this.isNextActive
      ..mode = mode ?? this.mode;
  }

  @override
  String toString() {
    return '''SignupState {
      username: $username,
      phone: $phone,
      isUsernameValid: $isUsernameValid,
      isPhoneValid: $isPhoneValid,
      isSubmitting: $isSubmitting,
      isSuccess: $isSuccess,
      isFailure: $isFailure,
    }''';
  }
}

class SignupUninitialized extends SignupState {
  SignupUninitialized() {
    isBusy = true;
  }

  @override
  String toString() => 'Uninitialized';
}

class SignupInitialized extends SignupState {
  SignupInitialized() {
    isBusy = false;
  }

  @override
  String toString() => 'Initialized';
}
