import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SignupState extends Equatable {
  SignupState([List props = const []]) : super(props);
}

class SignupUninitialized extends SignupState {
  @override
  String toString() => 'Uninitialized';
}

class InitialSignupState extends SignupState {
    @override
  String toString() => 'SignUpitial';
}

class SignUpLoading extends SignupState {
  @override
  String toString() => 'SignUpLoading';
}

class SignUpSuccess extends SignupState {
  @override
  String toString() => 'SignUpSuccess';
}

class SignUpFailure extends SignupState {
  final String error;

  SignUpFailure({@required this.error}) : super([error]);

  @override
  String toString() => 'SignUpFailure { error: $error }';
}

