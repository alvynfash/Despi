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

class SignUpButtonPressed extends SignupEvent {
  final String userName;
  final String mobile;

  SignUpButtonPressed({
    @required this.userName,
    @required this.mobile,
  }) : super([userName, mobile]);

  @override
  String toString() =>
      'SignUpButtonPressed { userName: $userName, mobile: $mobile }';
}
