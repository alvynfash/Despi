import 'package:despi/repos/repo.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
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
  final UserRepository userRepository;
  final Position initialPosition;
  final Placemark initialPlacemark;

  Authenticated({this.userRepository, this.initialPosition, this.initialPlacemark})
      : super([userRepository, initialPosition, initialPlacemark]);

  @override
  String toString() {
    return '''Authenticated {
    displinitialPositionayName: $initialPosition, 
    initialPlacemark: $initialPlacemark, 
    }''';
  }
}

class Unauthenticated extends AppState {
  @override
  String toString() => 'Unauthenticated';
}
