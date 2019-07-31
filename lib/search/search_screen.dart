import 'dart:async';
import 'dart:ui';

import 'package:despi/blocs/bloc.dart';
import 'package:despi/screens/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  SearchBloc _searchBloc;
  bool isConnected = false;
  StreamSubscription<ConnectivityResult> _subscription;
  Completer<GoogleMapController> _mapCompleter = Completer();
  GoogleMapController _mapController;
  CameraPosition _cameraPosition;
  CameraUpdate _camUpdate;
  double _zoom;
  double initialZoom = 14.5;

  @override
  void initState() {
    _searchBloc = SearchBloc();
    _zoom = initialZoom;

    final _appBloc =
        BlocProvider.of<AppBloc>(context).currentState as Authenticated;
    _searchBloc.dispatch(Load(
      userRepo: _appBloc.userRepository,
      initialPosition: _appBloc.initialPosition,
      initialPlacemark: _appBloc.initialPlacemark,
    ));

    Connectivity()
        .checkConnectivity()
        .then((onValue) => {isConnected = onValue != ConnectivityResult.none});
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        isConnected = result != ConnectivityResult.none;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener(
        bloc: _searchBloc,
        listener: (context, SearchState state) async {
          if (state.showPlaces) {
            var result =
                await Navigator.of(context).pushNamed(placesScreenRoute);
            var place = result as PlaceDetails;

            if (place == null)
              _searchBloc.dispatch(AddressNotFound());
            else {
              {
                if (_mapCompleter.isCompleted) {
                  _mapController
                    ..moveCamera(CameraUpdate.newLatLngZoom(
                      LatLng(place?.geometry?.location?.lat,
                          place?.geometry?.location?.lng),
                      initialZoom,
                    ));
                }
                else
                {
                  await _mapCompleter.future.then((onValue) {
                  onValue.moveCamera(CameraUpdate.newLatLngZoom(
                    LatLng(place?.geometry?.location?.lat,
                        place?.geometry?.location?.lng),
                    initialZoom,
                  ));
                });
                }

                _searchBloc.dispatch(AddressFound(
                  address: Placemark(
                      name: place?.name,
                      position: Position(
                        latitude: place?.geometry?.location?.lat,
                        longitude: place?.geometry?.location?.lng,
                      )),
                ));
              }
            }
          }

          if (state.polies != null && state.polies.isNotEmpty) {
            var bounds = LatLngBounds(
              southwest: LatLng(
                state.pickUp.position.latitude <=
                        state.dropOff.position.latitude
                    ? state.pickUp.position.latitude
                    : state.dropOff.position.latitude,
                state.pickUp.position.longitude <=
                        state.dropOff.position.longitude
                    ? state.pickUp.position.longitude
                    : state.dropOff.position.longitude,
              ),
              northeast: LatLng(
                state.pickUp.position.latitude > state.dropOff.position.latitude
                    ? state.pickUp.position.latitude
                    : state.dropOff.position.latitude,
                state.pickUp.position.longitude >
                        state.dropOff.position.longitude
                    ? state.pickUp.position.longitude
                    : state.dropOff.position.longitude,
              ),
            );

            _camUpdate = CameraUpdate.newLatLngBounds(bounds, 50);
            _mapController.moveCamera(_camUpdate).then((void v) {
              check(_camUpdate, _mapController);
            });
          }

          if (state.showError != null && state.showError) {
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                defaultSnackBar(state.errorMessage),
              );

            _searchBloc.dispatch(ErrorShown());
          }
        },
        child: BlocBuilder(
          bloc: _searchBloc,
          builder: (context, SearchState state) {
            var scaffold = Scaffold(
              appBar: _buildAppBar(),
              body: _buildContent(),
            );
            return scaffold;
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchBloc.dispose();
    _subscription.cancel();
    super.dispose();
  }

  void check(CameraUpdate u, GoogleMapController c) async {
    c.moveCamera(u);
    _mapController.moveCamera(u);
    LatLngBounds l1 = await c.getVisibleRegion();
    LatLngBounds l2 = await c.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90)
      check(u, c);
  }

  Widget _buildAppBar() {
    return !_searchBloc.currentState.isBusy
        ? AppBar(
            leading: _searchBloc.currentState.canShowBack
                ? IconButton(
                    onPressed: () => _searchBloc.dispatch(BackActionClicked()),
                    icon: Icon(Icons.arrow_back_ios),
                  )
                : null,
            title: _searchBloc.currentState.state == SearchStates.confirmed
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        _searchBloc.currentState.viewHeader,
                        style: TextStyle(
                          color: _searchBloc.currentState.isHeaderDarkMode
                              ? Colors.white
                              : Theme.of(context).primaryTextTheme.title.color,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.check_circle),
                      ),
                    ],
                  )
                : Text(
                    _searchBloc.currentState.viewHeader,
                    style: TextStyle(
                      color: _searchBloc.currentState.isHeaderDarkMode
                          ? Colors.white
                          : Theme.of(context).primaryTextTheme.title.color,
                    ),
                  ),
            backgroundColor: _searchBloc.currentState.isHeaderDarkMode
                ? Colors.black
                : Colors.white,
          )
        : null;
  }

  Widget _buildContent() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                _searchBloc.currentState.isBusy
                    ? showInviewLoader()
                    : _buildSubContent(),
              ],
            ),
          ),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildSubContent() {
    List<Widget> contents = [];

    if (!isConnected) {
      contents.add(Container(
        height: 60,
        color: Colors.black.withOpacity(.75),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'No internet connection',
                style: TextStyle(
                    color: Colors.white.withOpacity(.85),
                    fontSize:
                        Theme.of(context).primaryTextTheme.subhead.fontSize),
              ),
              SizedBox(width: 10),
              Icon(
                Icons.error_outline,
                color: Colors.white.withOpacity(.85),
              ),
            ],
          ),
        ),
      ));
    }
    if (_searchBloc.currentState.isPreVehicleState) contents.add(_buildMap());

    switch (_searchBloc.currentState.state) {
      case SearchStates.pickUp:
      case SearchStates.dropOff:
        contents.add(_buildAddress());
        break;

      case SearchStates.selectVehicle:
        contents.add(_buildVehicleContainer());
        break;

      case SearchStates.confirmation:
        contents.add(_buildConfirmationContainer());
        break;

      case SearchStates.confirmed:
        contents.add(_buildConfirmedContainer());
        break;

      default:
        contents.add(emptyContainer());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: contents,
    );
  }

  Widget _buildMap() {
    return Expanded(
      child: AbsorbPointer(
        absorbing: !_searchBloc.currentState.isMapEnabled,
        child: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              polylines: _searchBloc.currentState.polies,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _searchBloc.currentState.initialPosition.latitude,
                  _searchBloc.currentState.initialPosition.longitude,
                ),
                zoom: _searchBloc.currentState.isPickupState
                    ? initialZoom
                    : _zoom,
              ),
              markers: _searchBloc.currentState.markers,
              onMapCreated: (GoogleMapController controller) {
                if (_mapController == null ||
                    _mapCompleter == null ||
                    !_mapCompleter.isCompleted) {
                  _mapController = controller;
                  _mapCompleter.complete(_mapController);
                }
              },
              onCameraMove: (position) {
                _cameraPosition = position;
              },
              onCameraIdle: () {
                _searchBloc
                    .dispatch(PositionChanged(position: _cameraPosition));
              },
              myLocationButtonEnabled: false,
              myLocationEnabled: false,
            ),
            Opacity(
              opacity: _searchBloc.currentState.isPreVehicleState ? 1 : 0,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 17.5),
                  child: Icon(
                    Icons.location_on,
                    size: 35,
                    color: Colors.black.withOpacity(.6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddress() {
    return InkWell(
      onTap: () => _searchBloc.dispatch(FindAddressClicked()),
      child: Container(
        color: Color(0xFFFFFAF0),
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
        child: Row(
          children: [
            Expanded(
              child: _searchBloc.currentState.selectedAddress == null ||
                      _searchBloc.currentState.selectedAddress.position == null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 30,
                          color: Colors.black.withOpacity(.65),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Entrer une adresse",
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black.withOpacity(.6),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _searchBloc.currentState.selectedAddressLine1 ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.black.withOpacity(.6),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          _searchBloc.currentState.selectedAddressLine2 ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(.75),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleContainer() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
        child: ListView.separated(
          itemCount: _searchBloc.currentState.vehicles.length,
          itemBuilder: (_, index) => vehicleCell(
                _,
                _searchBloc.currentState.vehicles[index],
                (selectedVehicle) => _searchBloc
                    .dispatch(VehicleSelected(vehicle: selectedVehicle)),
              ),
          separatorBuilder: (_, index) {
            return SizedBox(height: 16);
          },
        ),
      ),
    );
  }

  Widget _buildConfirmationContainer() {
    return Expanded(
      child: Stack(
        children: <Widget>[
          Image.asset(
            "assets/images/map.png",
            fit: BoxFit.fill,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 2,
              sigmaY: 2,
            ),
            child: Container(
              color: Colors.black.withOpacity(.65),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    vehicleCellWithDistance(
                      context,
                      _searchBloc.currentState.selectedVehicle,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: <Widget>[
                          Image.asset(
                            "assets/images/tofro.png",
                            height: 80,
                            width: 30,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              child: Column(
                                children: [
                                  confirmationAddress(
                                    line1: getAddyLine1(
                                        _searchBloc.currentState.pickUp),
                                    line2: getAddyLine2(
                                        _searchBloc.currentState.pickUp),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  confirmationAddress(
                                    line1: getAddyLine1(
                                        _searchBloc.currentState.dropOff),
                                    line2: getAddyLine2(
                                        _searchBloc.currentState.dropOff),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          paymentOptionCell(
                            context,
                            paymentOption:
                                _searchBloc.currentState.paymentOptions[0],
                            onTapped: (po) => _searchBloc.dispatch(
                                PaymentOptionSelected(paymentOption: po)),
                          ),
                          paymentOptionCell(
                            context,
                            paymentOption:
                                _searchBloc.currentState.paymentOptions[1],
                            onTapped: (po) => _searchBloc.dispatch(
                                PaymentOptionSelected(paymentOption: po)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 13.5),
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: defaultCornerRadius,
                        bottomRight: defaultCornerRadius,
                      ),
                      child: FlatButton(
                          color: Colors.black,
                          onPressed: () {
                            DatePicker.showDatePicker(
                              context,
                              showTitleActions: true,
                              minTime: DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                              ),
                              maxTime: DateTime(
                                DateTime.now().year + 1,
                                12,
                                31,
                              ),
                              onConfirm: (date) =>
                                  _searchBloc.dispatch(DateChanged(date: date)),
                              currentTime:
                                  _searchBloc.currentState.selectedDate,
                              locale: LocaleType.fr,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              _searchBloc.currentState.formattedDate,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmedContainer() {
    // return Material(
    //   elevation: 2,
    //   child: Padding(
    //     padding: const EdgeInsets.all(32),
    //     child: Column(
    //       children: [
    //         Text(
    //           "Details",
    //           style: TextStyle(
    //             color: Colors.black.withOpacity(.75),
    //             fontSize: Theme.of(context).primaryTextTheme.title.fontSize,
    //             fontWeight: FontWeight.bold,
    //           ),
    //         ),
    //         SizedBox(
    //           height: 10,
    //         ),
    //         confirmationDetail(context, "OrderId", "JP254RQ"),
    //         confirmationDetail(context, "Date", "25th of June, 2019"),
    //         confirmationDetail(
    //           context,
    //           "Car",
    //           _searchBloc.currentState.selectedVehicle.name,
    //         ),
    //         confirmationDetail(
    //           context,
    //           "Payment Method",
    //           _searchBloc.currentState.selectedPaymentOption.name,
    //         ),
    //         Padding(
    //           padding: const EdgeInsets.all(20),
    //           child: Column(
    //             children: <Widget>[
    //               Text(
    //                 "${_searchBloc.currentState.pickUp.name}",
    //                 textAlign: TextAlign.center,
    //                 style: TextStyle(
    //                   color: Colors.black.withOpacity(.65),
    //                   fontSize:
    //                       Theme.of(context).primaryTextTheme.subhead.fontSize,
    //                 ),
    //               ),
    //               Text(
    //                 "à",
    //                 textAlign: TextAlign.center,
    //                 style: TextStyle(
    //                   color: Colors.black.withOpacity(.65),
    //                   fontSize:
    //                       Theme.of(context).primaryTextTheme.subhead.fontSize,
    //                 ),
    //               ),
    //               Text(
    //                 "${_searchBloc.currentState.dropOff.name}",
    //                 textAlign: TextAlign.center,
    //                 style: TextStyle(
    //                   color: Colors.black.withOpacity(.65),
    //                   fontSize:
    //                       Theme.of(context).primaryTextTheme.subhead.fontSize,
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //         FloatingActionButton(
    //           onPressed: () => _searchBloc.dispatch(NextActionClicked()),
    //           backgroundColor: Colors.white,
    //           child: Icon(
    //             Icons.check_circle,
    //             size: 55,
    //             color: Colors.green,
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );

    return Expanded(
      child: Material(
        color: Colors.lightGreen,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 150),
          child: Center(
            child: Icon(
              Icons.check,
              size: 200,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return _searchBloc.currentState.isMainButtonHidden
        ? emptyContainer()
        : FlatButton(
            color: _searchBloc.currentState.isMainButtonDarkMode
                ? Colors.black
                : Theme.of(context).accentColor,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Text(
                _searchBloc.currentState.mainButtonText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            onPressed: () => _searchBloc.dispatch(NextActionClicked()),
          );
  }
}
