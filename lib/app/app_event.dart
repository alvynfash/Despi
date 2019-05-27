import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AppEvent extends Equatable {
  AppEvent([List props = const []]) : super(props);
}

class AppNavigating extends AppEvent {
  @override
  String toString() => 'AppNavigating';
}

class AppStarted extends AppEvent {
  @override
  String toString() => 'AppStarted';
}

class AppOnboarded extends AppEvent {
  @override
  String toString() => 'AppOnboarded';
}

class AppSignedUp extends AppEvent {
  @override
  String toString() => 'AppSignedUp';
}

class LoggedOut extends AppEvent {
  @override
  String toString() => 'LoggedOut';
}
