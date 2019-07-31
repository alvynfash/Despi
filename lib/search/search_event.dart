import 'package:despi/models/payment_option.dart';
import 'package:despi/models/vehicle_model.dart';
import 'package:despi/repos/user_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SearchEvent extends Equatable {
  SearchEvent([List props = const []]) : super(props);
}

class Load extends SearchEvent {
  final UserRepository userRepo;
  final Position initialPosition;
  final Placemark initialPlacemark;

  Load({this.userRepo, this.initialPosition, this.initialPlacemark})
      : super([userRepo, initialPosition, initialPlacemark]);

  @override
  String toString() => 'Load';
}

class DateChanged extends SearchEvent {
  final DateTime date;

  DateChanged({@required this.date}) : super([date]);

  @override
  String toString() => 'DateChanged { date :$date }';
}

class PositionChanged extends SearchEvent {
  final CameraPosition position;

  PositionChanged({@required this.position}) : super([position]);

  @override
  String toString() => 'PositionChanged { position :$position }';
}

class NextActionClicked extends SearchEvent {
  @override
  String toString() => 'NextAction clicked';
}

class BackActionClicked extends SearchEvent {
  @override
  String toString() => 'BackAction clicked';
}

class FindAddressClicked extends SearchEvent {
  @override
  String toString() => 'Address Clicked';
}

class AddressFound extends SearchEvent {
  final Placemark address;

  AddressFound({@required this.address}) : super([address]);

  @override
  String toString() => 'Address found :${address?.name}';
}

class AddressNotFound extends SearchEvent {
  @override
  String toString() => 'Address not found';
}

class ErrorShown extends SearchEvent {
  @override
  String toString() => 'Error shown';
}

class VehicleSelected extends SearchEvent {
  final Vehicle vehicle;

  VehicleSelected({@required this.vehicle}) : super([vehicle]);

  @override
  String toString() => 'Vehicle Selected :${vehicle?.name}';
}

class PaymentOptionSelected extends SearchEvent {
  final PaymentOption paymentOption;

  PaymentOptionSelected({@required this.paymentOption})
      : super([paymentOption]);

  @override
  String toString() => 'PaymentOption Selected :${paymentOption?.name}';
}
