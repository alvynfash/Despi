import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AppState extends Equatable {
  AppState([List props = const []]) : super(props);
}

class Uninitialized extends AppState {
  @override
  String toString() => 'Uninitialized';
}

class Navigating extends AppState {
  @override
  String toString() => 'Navigating';
}

class WaitingOnboarding extends AppState {
  @override
  String toString() => 'WaitingOnboarding';
}

class Authenticated extends AppState {
  final String displayName;

  Authenticated(this.displayName) : super([displayName]);

  @override
  String toString() => 'Authenticated { displayName: $displayName }';
}

class Unauthenticated extends AppState {
  @override
  String toString() => 'Unauthenticated';
}
