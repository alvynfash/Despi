import 'package:despi/blocs/bloc.dart';
import 'package:despi/models/payment_option.dart';
import 'package:despi/models/vehicle_model.dart';
import 'package:despi/screens/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

enum SearchStates {
  uninitialised,
  pickUp,
  dropOff,
  selectVehicle,
  confirmation,
  confirmed,
}

final k = Placemark(position: Position(latitude: 0, longitude: 0));
const double rate = 1;
final uuid = new Uuid();

class SearchState extends BaseState {
  SearchStates state = SearchStates.uninitialised;

  bool get isPickupState => state == SearchStates.pickUp;
  bool get isDropOffState => state == SearchStates.dropOff;
  bool get canShowBack =>
      state != SearchStates.pickUp && state != SearchStates.confirmed;
  bool get isPreVehicleState => state.index < SearchStates.selectVehicle.index;
  bool get isMainButtonHidden =>
      state == SearchStates.selectVehicle || state == SearchStates.confirmed;
  bool get isConfirmationState => state == SearchStates.confirmation;
  bool get isMapEnabled => isPreVehicleState;

  List<SearchStates> darkModeHeadersList = <SearchStates>[
    SearchStates.dropOff,
    SearchStates.selectVehicle,
    SearchStates.confirmation,
    SearchStates.confirmed,
  ];

  bool get isHeaderDarkMode => darkModeHeadersList.contains(state);

  List<SearchStates> darkModeMainButtonList = <SearchStates>[
    // SearchStates.confirmation,
  ];

  bool get isMainButtonDarkMode => darkModeMainButtonList.contains(state);

  String get viewHeader {
    switch (state) {
      case SearchStates.pickUp:
        return "Point de départ";
      case SearchStates.dropOff:
        return "Point d'arrivée";
      case SearchStates.selectVehicle:
        return "Sélectionner la voiture";
      case SearchStates.confirmation:
        return "Confirmer";
      case SearchStates.confirmed:
        return "Commande envoyée";
      default:
        return "";
    }
  }

  String get mainButtonText {
    switch (state) {
      case SearchStates.uninitialised:
        return "Chargement...";
      case SearchStates.pickUp:
        return "Confirmer le point de départ";
      case SearchStates.dropOff:
        return "Confirmer Point d'arrivée";
      case SearchStates.selectVehicle:
        return "Confirmer une voiture";
      case SearchStates.confirmation:
        return "Commander chez DESPi";
      default:
        return "";
    }
  }

  Position initialPosition;

  Placemark pickUp = k;
  Placemark dropOff = k;
  Placemark selectedAddress = k;

  String get selectedAddressLine1 {
    var addyInUse = state == SearchStates.pickUp ? pickUp : dropOff;
    return addyInUse == null ? "" : getAddyLine1(addyInUse);
  }

  String get selectedAddressLine2 {
    var addyInUse = state == SearchStates.pickUp ? pickUp : dropOff;
    return addyInUse == null ? "" : getAddyLine2(addyInUse);
  }

  bool showPlaces = false;

  bool showPickUpMarker = false;
  bool showDropOffpMarker = false;
  double distance = 0;

  Set<Marker> get markers {
    var innermarkers = Set<Marker>();

    if (pickUp.position != k.position && showPickUpMarker) {
      var pickUpMarker = Marker(
        markerId: MarkerId('pickUpMarker'),
        position: LatLng(pickUp.position.latitude, pickUp.position.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      );
      innermarkers?.add(pickUpMarker);
    }

    if (dropOff.position != k.position && showDropOffpMarker) {
      var dropOffMarker = Marker(
        markerId: MarkerId('dropOffMarker'),
        position: LatLng(dropOff.position.latitude, dropOff.position.longitude),
        icon: BitmapDescriptor.fromAsset('assets/images/end.png'),
      );
      innermarkers?.add(dropOffMarker);
    }

    return innermarkers;
  }

  Set<Polyline> polies;

  List<Vehicle> vehicles = <Vehicle>[
    Vehicle()
      ..name = "Simple"
      ..rate = .02
      ..description = "une description à discuter"
      ..image = "assets/images/brownCar.jpg",
    Vehicle()
      ..name = "Classic"
      ..baseFare = 6
      ..rate = .03
      ..description = "une description à discuter"
      ..image = "assets/images/redCar.jpg",
    Vehicle()
      ..name = "Luxury 1"
      ..baseFare = 7.5
      ..rate = .04
      ..description = "une description à discuter"
      ..image = "assets/images/whiteCar.jpg",
    Vehicle()
      ..name = "Luxury 2"
      ..baseFare = 9
      ..rate = .05
      ..description = "une description à discuter"
      ..image = "assets/images/blackCar.jpg",
  ];

  Vehicle selectedVehicle;

  List<PaymentOption> get paymentOptions {
    return [
      PaymentOption()
        ..name = "Espèces"
        ..isSelected = selectedPaymentOption != null &&
            selectedPaymentOption.name == "Espèces"
        ..icon = Image.asset(
          "assets/images/cash.png",
          width: 27.5,
          height: 27.5,
        )
        ..altIcon = Image.asset(
          "assets/images/cash.png",
          width: 35,
          height: 35,
        ),
      PaymentOption()
        ..name = "CB"
        ..isSelected = selectedPaymentOption != null &&
            selectedPaymentOption.name == "CB"
        ..icon = Image.asset(
          "assets/images/card.png",
          width: 27.5,
          height: 27.5,
        )
        ..altIcon = Image.asset(
          "assets/images/card.png",
          width: 35,
          height: 35,
        ),
    ];
  }

  PaymentOption selectedPaymentOption;

  DateTime selectedDate = DateTime.now();

  String get formattedDate => toBeginningOfSentenceCase(new DateFormat.yMMMMEEEEd().format(selectedDate));

  SearchState();

  SearchState copyWith({
    bool isBusy,
    bool showError,
    String errorMessage,
    SearchStates state,
    Placemark pickUp,
    Placemark dropOff,
    Placemark selectedAddress,
    bool showPlaces,
    Position initialPosition,
    bool showPickUpMarker,
    bool showDropOffpMarker,
    double distance,
    Set<Polyline> polies,
    List<Vehicle> vehicles,
    Vehicle selectedVehicle,
    PaymentOption selectedPaymentOption,
    DateTime selectedDate,
  }) {
    return SearchState()
      ..isBusy = isBusy ?? this.isBusy
      ..showError = showError ?? this.showError
      ..errorMessage = errorMessage ?? this.errorMessage
      ..state = state ?? this.state
      ..pickUp = pickUp ?? this.pickUp
      ..dropOff = dropOff ?? this.dropOff
      ..selectedAddress = selectedAddress ?? this.selectedAddress
      ..showPlaces = showPlaces ?? this.showPlaces
      ..initialPosition = initialPosition ?? this.initialPosition
      ..showPickUpMarker = showPickUpMarker ?? this.showPickUpMarker
      ..showDropOffpMarker = showDropOffpMarker ?? this.showDropOffpMarker
      ..distance = distance ?? this.distance
      ..polies = polies ?? this.polies
      ..vehicles = vehicles ?? this.vehicles
      ..selectedVehicle = selectedVehicle ?? this.selectedVehicle
      ..selectedPaymentOption =
          selectedPaymentOption ?? this.selectedPaymentOption
      ..selectedDate = selectedDate ?? this.selectedDate;
  }

  Map<String, Object> getMap() {
    return {
      "pickUp": "${pickUp?.name}",
      "dropOff": "${dropOff?.name}",
      "vehicle": "${selectedVehicle?.name}",
      "payment": "${selectedPaymentOption?.name}",
      "date": "$selectedDate",
      "price": "${selectedVehicle.finalPrice}",
      "orderId": uuid.v1(),
    };
  }

  // @override
  // String toString() {
  //   return '''SearchState {
  //     state: $state,
  //     pickUp: ${pickUp?.name},
  //     dropOff: ${dropOff?.name},
  //     showPlaces: $showPlaces,
  //     showError: $showError,
  //     errorMessage: $errorMessage,
  //     initialPosition: $initialPosition,
  //     selectedVehicle: ${selectedVehicle?.name},
  //     selectedPaymentOption: ${selectedPaymentOption?.name},
  //   }''';
  // }
}

class SearchUninitialized extends SearchState {
  SearchUninitialized() {
    isBusy = true;
  }

  @override
  String toString() => 'Uninitialized';
}

class SearchInitialized extends SearchState {
  SearchInitialized() {
    isBusy = false;
    state = SearchStates.pickUp;
    showError = false;
    errorMessage = "";
  }

  @override
  String toString() => 'Initialized';
}
