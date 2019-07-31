import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:despi/models/payment_option.dart';
import 'package:despi/models/vehicle_model.dart';
import 'package:despi/repos/user_repository.dart';
import 'package:despi/screens/utils/util.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import './bloc.dart';
import 'package:dio/dio.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  int transitionTime = 550;
  var client = Dio();
  UserRepository _userRepository;

  @override
  SearchState get initialState => SearchUninitialized();

  @override
  Stream<SearchState> mapEventToState(
    SearchEvent event,
  ) async* {
    switch (event.runtimeType) {
      case Load:
        var subEvent = event as Load;
        yield* _mapLoadToState(subEvent.userRepo, subEvent.initialPosition,
            subEvent.initialPlacemark);
        break;

      case NextActionClicked:
        yield* _mapNextActionToState();
        break;

      case BackActionClicked:
        yield* _mapBackActionToState();
        break;

      case FindAddressClicked:
        yield* _mapFindAddressTappedToState();
        break;

      case AddressFound:
        var subEvent = event as AddressFound;
        yield* _mapAddressFoundToState(subEvent.address);
        break;

      case AddressNotFound:
        yield* _mapAddressNotFoundToState();
        break;

      case ErrorShown:
        yield* _mapErrorShownToState();
        break;

      case PositionChanged:
        var subEvent = event as PositionChanged;
        yield* _mapPositionChangedToState(subEvent.position);
        break;

      case VehicleSelected:
        var subEvent = event as VehicleSelected;
        yield* _mapVehicleSelectedToState(subEvent.vehicle);
        break;

      case PaymentOptionSelected:
        var subEvent = event as PaymentOptionSelected;
        yield* _mapPaymentOptionSelectedToState(subEvent.paymentOption);
        break;

      case DateChanged:
        var subEvent = event as DateChanged;
        yield* _mapDateChangedToState(subEvent.date);
        break;
    }
  }

  Stream<SearchState> _mapLoadToState(
    UserRepository userRepository,
    Position initialPosition,
    Placemark initialPlacemark,
  ) async* {
    if (initialPosition != null) {
      _userRepository = userRepository;
      yield SearchInitialized().copyWith(
        initialPosition: initialPosition,
        pickUp: initialPlacemark,
        selectedAddress: initialPlacemark,
      );
    } else {
      yield currentState.copyWith(
        showError: true,
        errorMessage: "Problème de localisation",
      );
    }
  }

  Stream<SearchState> _mapNextActionToState() async* {
    if (currentState.selectedAddress == null) {
      yield currentState.copyWith(
        showError: true,
        errorMessage: "L'adresse est obligatoire pour continuer",
      );
      return;
    }

    switch (currentState.state) {
      case SearchStates.pickUp:
        if (currentState.pickUp.position.latitude == 0 &&
            currentState.pickUp.position.latitude == 0) {
              yield currentState.copyWith(
            showError: true,
            errorMessage: "Impossible de récupérer l'emplacement",
          );
        } else {
          yield currentState.copyWith(
              state: SearchStates.dropOff,
              showPickUpMarker: true,
              showDropOffpMarker: false,
              selectedAddress: currentState.selectedAddress,
              dropOff: currentState.selectedAddress,
              isBusy: false);
        }
        break;

      case SearchStates.dropOff:

       if (currentState.pickUp.position.latitude == 0 &&
            currentState.pickUp.position.latitude == 0) {
              yield currentState.copyWith(
            showError: true,
            errorMessage: "Impossible de récupérer l'emplacement",
          );

          return;
        } 
        final polies = await getDirectionPolies(
            currentState.pickUp.position, currentState.dropOff.position);
        final pickupPosition = currentState.pickUp.position;
        final dropOffPosition = currentState.dropOff.position;

        final distance = await Geolocator().distanceBetween(
          pickupPosition.latitude,
          pickupPosition.longitude,
          dropOffPosition.latitude,
          dropOffPosition.longitude,
        );

        currentState.vehicles
            .forEach((vehicle) => vehicle.proposedDistance = distance);
        yield currentState.copyWith(
            state: SearchStates.selectVehicle,
            showPickUpMarker: true,
            showDropOffpMarker: true,
            distance: distance,
            polies: polies,
            vehicles: currentState.vehicles,
            isBusy: false);
        break;

      case SearchStates.selectVehicle:
        yield currentState.copyWith(
          state: SearchStates.confirmation,
          isBusy: false,
        );
        break;

      case SearchStates.confirmation:
        yield currentState.copyWith(isBusy: true);

        try {
          if (currentState.selectedPaymentOption == null) {
            yield currentState.copyWith(isBusy: false);
            yield currentState.copyWith(
              showError: true,
              errorMessage: "Veuillez choisir un moyen de paiement",
            );
          } else {
            var orderPayload = currentState.getMap();
            var userename = await _userRepository.getUser();
            var mobile = await _userRepository.getMobile();
            orderPayload.addAll({
              "user": {"username": "$userename", "mobile": "$mobile"}
            });

            await Firestore.instance.collection('Orders').add(orderPayload);

            var notifPayload = {
              "app_id": "a8514677-3f82-4be2-8905-264075768dd4",
              "included_segments": ["All"],
              "contents": {
                "en":
                    "$userename ($mobile) vient de commander un '${currentState.selectedVehicle.name}' à ${currentState.selectedVehicle.finalPriceFormatted} et a choisi '${currentState.selectedPaymentOption.name}' comme mode de paiement"
              },
              "headings": {"en": "Nouvelle commande"},
            };

            var response = await client.post(
              "https://onesignal.com/api/v1/notifications",
              data: notifPayload,
              options: Options(
                headers: {
                  "Authorization":
                      "Basic MDQwYmI5NzktYjYyMC00MWQxLWI3M2YtNDhjNzBlMTZmMGJj",
                  "Content-Type": "application/json",
                },
              ),
            );

            print(response.data);
            if (response.statusCode == 200) {
              //Show confiremd anim(green)
              yield currentState.copyWith(
                state: SearchStates.confirmed,
                isBusy: false,
              );

              await Future.delayed(Duration(milliseconds: transitionTime * 2));

              //restart search mode
              yield SearchInitialized().copyWith(
                initialPosition: currentState.initialPosition,
                pickUp: currentState.pickUp,
                selectedAddress: currentState.pickUp,
                selectedDate: DateTime.now(),
              );
            } else {
              throw Exception();
            }
          }
        } catch (e) {
          yield currentState.copyWith(isBusy: false);
          await Future.delayed(Duration(milliseconds: transitionTime * 2));
          yield currentState.copyWith(
            showError: true,
            errorMessage: "Impossible de terminer la réservation",
          );
        }
        break;

      default:
        break;
    }
  }

  Stream<SearchState> _mapBackActionToState() async* {
    switch (currentState.state) {
      case SearchStates.uninitialised:
      case SearchStates.pickUp:
        break;

      case SearchStates.dropOff:
        yield currentState.copyWith(
            state: SearchStates.pickUp,
            selectedAddress: currentState.pickUp,
            showPickUpMarker: false,
            showDropOffpMarker: false,
            isBusy: false);
        break;

      case SearchStates.selectVehicle:
        yield currentState.copyWith(
            state: SearchStates.dropOff,
            showPickUpMarker: true,
            showDropOffpMarker: false,
            polies: Set<Polyline>(),
            isBusy: false);
        break;

      case SearchStates.confirmation:
        yield currentState.copyWith(
          state: SearchStates.selectVehicle,
          selectedPaymentOption: null,
          isBusy: false,
        );
        break;

      case SearchStates.confirmed:
        yield currentState.copyWith(
            state: SearchStates.confirmation, isBusy: false);
        break;
    }
  }

  Stream<SearchState> _mapFindAddressTappedToState() async* {
    yield currentState.copyWith(showPlaces: true);
  }

  Stream<SearchState> _mapAddressFoundToState(Placemark address) async* {
    if (currentState.isPickupState) {
      yield currentState.copyWith(
        showPlaces: false,
        // pickUp: address,
        // selectedAddress: address,
        initialPosition: address.position,
        isBusy: false,
      );
    } else if (currentState.isDropOffState) {
      yield currentState.copyWith(
        showPlaces: false,
        // dropOff: address,
        // selectedAddress: address,
        isBusy: false,
      );
    }
  }

  Stream<SearchState> _mapAddressNotFoundToState() async* {
    yield currentState.copyWith(showPlaces: false);
  }

  Stream<SearchState> _mapErrorShownToState() async* {
    yield currentState.copyWith(
      showError: false,
      errorMessage: "",
      isBusy: false,
    );
  }

  Stream<SearchState> _mapPositionChangedToState(
      CameraPosition position) async* {
    var transformedPosition = position.target;
    var reversePosition = await Geolocator().placemarkFromPosition(Position(
        latitude: transformedPosition.latitude,
        longitude: transformedPosition.longitude));

    if (currentState.isPickupState) {
      yield currentState.copyWith(
        pickUp: reversePosition?.first,
        selectedAddress: reversePosition?.first,
      );
    } else if (currentState.isDropOffState) {
      yield currentState.copyWith(
        dropOff: reversePosition?.first,
        selectedAddress: reversePosition?.first,
      );
    }
  }

  Stream<SearchState> _mapVehicleSelectedToState(Vehicle vehicle) async* {
    yield currentState.copyWith(isBusy: true);
    await Future.delayed(Duration(milliseconds: transitionTime));

    yield currentState.copyWith(
      state: SearchStates.confirmation,
      selectedVehicle: vehicle,
      isBusy: false,
    );
  }

  Stream<SearchState> _mapPaymentOptionSelectedToState(
      PaymentOption paymentOption) async* {
    yield currentState.copyWith(selectedPaymentOption: paymentOption);
  }

  Stream<SearchState> _mapDateChangedToState(DateTime date) async* {
    yield currentState.copyWith(selectedDate: date);
  }
}
