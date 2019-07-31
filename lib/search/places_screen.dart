import 'dart:async';

import 'package:despi/screens/utils/util.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter/material.dart';
import 'dart:math';

const kGoogleApiKey = "AIzaSyDeu9XNny5i6jXlgpLySg6iPlWZ-qZGGX4";

final searchScaffoldKey = GlobalKey<ScaffoldState>();

class PlacesScreen extends PlacesAutocompleteWidget {
  PlacesScreen()
      : super(
          apiKey: kGoogleApiKey,
          sessionToken: Uuid().generateV4(),
          language: "fr",
          components: [Component(Component.country, "fr")],
        );

  @override
  _PlacesScreenState createState() => _PlacesScreenState();
}

class _PlacesScreenState extends PlacesAutocompleteState {
  GoogleMapsPlaces _places;

  @override
  void initState() {
    _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.close,
          size: 35,
        ),
        onPressed: () {
          hideKeyboard();
          Navigator.of(context).pop();
        },
      ),
      backgroundColor: Colors.black,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          margin: const EdgeInsets.all(8),
          child: Container(
            child: AppBarPlacesAutoCompleteTextField(),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      ),
    );

    final body = PlacesAutocompleteResult(
      onTap: (p) => displayPrediction(context, p),
    );
    return Scaffold(
      appBar: appBar,
      body: Column(
        children: <Widget>[
          Expanded(
            child: body,
          ),
        ],
      ),
    );
  }

  @override
  void onResponseError(PlacesAutocompleteResponse response) {
    super.onResponseError(response);
    searchScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  // @override
  // void onResponse(PlacesAutocompleteResponse response) {
  //   super.onResponse(response);
  //   if (response != null && response.predictions.isNotEmpty) {
  //     searchScaffoldKey.currentState.showSnackBar(
  //       SnackBar(content: Text("Got answer")),
  //     );
  //   }
  // }

  Future<Null> displayPrediction(BuildContext context, Prediction p) async {
    if (p != null) {
      var detail = await _places.getDetailsByPlaceId(p.placeId);
      hideKeyboard();
      Navigator.of(context).pop(detail.result);
    }
  }
}

class Uuid {
  final Random _random = Random();

  String generateV4() {
    // Generate xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx / 8-4-4-4-12.
    final int special = 8 + _random.nextInt(4);

    return '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}-'
        '${_bitsDigits(16, 4)}-'
        '4${_bitsDigits(12, 3)}-'
        '${_printDigits(special, 1)}${_bitsDigits(12, 3)}-'
        '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}';
  }

  String _bitsDigits(int bitCount, int digitCount) =>
      _printDigits(_generateBits(bitCount), digitCount);

  int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);

  String _printDigits(int value, int count) =>
      value.toRadixString(16).padLeft(count, '0');
}
