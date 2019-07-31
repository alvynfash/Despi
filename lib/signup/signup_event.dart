import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SignupEvent extends Equatable {
  SignupEvent([List props = const []]) : super(props);
}

class FormLoad extends SignupEvent {
  @override
  String toString() => 'FormLoad';
}

class UsernameChanged extends SignupEvent {
  final String username;

  UsernameChanged({@required this.username}) : super([username]);

  @override
  String toString() => 'UsernameChanged { username :$username }';
}

class PhoneChanged extends SignupEvent {
  final String phone;

  PhoneChanged({@required this.phone}) : super([phone]);

  @override
  String toString() => 'PhoneChanged { phone: $phone }';
}

class NextSignUpPressed extends SignupEvent {
   @override
  String toString() => 'NextSignUp Pressed';
}

class BackSignUpPressed extends SignupEvent {
   @override
  String toString() => 'BackSignUp Pressed';
}

class SignUpButtonPressed extends SignupEvent {
  final String userName;
  final String mobile;

  SignUpButtonPressed({
    @required this.userName,
    @required this.mobile,
  }) : super([userName, mobile]);

  @override
  String toString() =>
      'SignUpButton Pressed { userName: $userName, mobile: $mobile }';
}
