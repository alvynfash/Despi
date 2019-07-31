export 'app_box_decoration.dart';
export 'dots_indicator.dart';
export 'curved_shape.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:despi/models/payment_option.dart';
import 'package:despi/models/steps.dart';
import 'package:despi/models/vehicle_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const String splashScreenRoute = "/splashScreen";
const String onboardingScreenRoute = "/onboardingScreen";
const String signupScreenRoute = "/signupScreen";
const String searchScreenRoute = "/searchScreen";
const String placesScreenRoute = "/placesScreen";

const Radius defaultCornerRadius = Radius.circular(8);

Future navigateTo(BuildContext context, String routeName, {Object args}) async {
  return Navigator.of(context).pushNamed(routeName, arguments: args);
}

Future setAsMain(BuildContext context, String routeName, {Object args}) async {
  return Navigator.pushReplacementNamed(context, routeName, arguments: args);
}

Widget showInviewLoader() {
  return Center(
    child: SpinKitRipple(
      color: Colors.red.shade500,
      size: 120,
    ),
  );
}

Container emptyContainer() {
  return Container(height: 0);
}

Widget paymentOptionCell(
  BuildContext context, {
  PaymentOption paymentOption,
  void Function(PaymentOption) onTapped,
}) {
  return InkWell(
    onTap: () => onTapped(paymentOption),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    child: Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.fromLTRB(30, 7.5, 30, 7.5),
        child: Row(
          children: <Widget>[
            paymentOption.isSelected
                ? paymentOption.altIcon
                : paymentOption.icon,
            SizedBox(width: 10),
            Text(
              paymentOption.name,
              style: TextStyle(
                fontSize: paymentOption.isSelected
                    ? Theme.of(context).primaryTextTheme.subhead.fontSize
                    : Theme.of(context).primaryTextTheme.subhead.fontSize,
                fontWeight: paymentOption.isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ListTile vehicleCell(
//   BuildContext context,
//   Vehicle vehicle,
//   void Function(Vehicle) onTapped,
// ) {
//   return ListTile(
//     onTap: () => onTapped(vehicle),
//     leading: CircleAvatar(
//       radius: 27.5,
//       backgroundColor: Colors.black,
//       child: vehicle.image,
//     ),
//     title: Text(
//       vehicle.name,
//       style: TextStyle(
//           color: Colors.black.withOpacity(.9),
//           fontSize: Theme.of(context).primaryTextTheme.title.fontSize),
//     ),
//     subtitle: Text(
//       vehicle.description,
//       style: TextStyle(
//           color: Colors.black.withOpacity(.65),
//           fontSize: Theme.of(context).primaryTextTheme.subtitle.fontSize),
//     ),
//     trailing: Text(
//       vehicle.finalPriceFormatted,
//       style: TextStyle(
//           color: Colors.black.withOpacity(.85),
//           fontSize: Theme.of(context).primaryTextTheme.title.fontSize),
//     ),
//   );
// }

Widget vehicleCell(
  BuildContext context,
  Vehicle vehicle,
  void Function(Vehicle) onTapped,
) {
  return InkWell(
    onTap: () => onTapped(vehicle),
    child: Container(
      child: ClipRRect(
        borderRadius: BorderRadius.all(defaultCornerRadius),
        child: Container(
          height: 200,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                left: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(defaultCornerRadius),
                  child: Image.asset(
                    vehicle.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Container(
                  color: Colors.black.withOpacity(.65),
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            vehicle.name,
                            style: TextStyle(
                                color: Colors.white.withOpacity(.9),
                                fontSize: Theme.of(context)
                                    .primaryTextTheme
                                    .title
                                    .fontSize),
                          ),
                          Text(
                            vehicle.description,
                            style: TextStyle(
                                color: Colors.white.withOpacity(.75),
                                fontWeight: FontWeight.bold,
                                fontSize: Theme.of(context)
                                    .primaryTextTheme
                                    .subtitle
                                    .fontSize),
                          ),
                        ],
                      ),
                      Text(
                        vehicle.finalPriceFormatted,
                        style: TextStyle(
                            color: Colors.white.withOpacity(.85),
                            fontSize: Theme.of(context)
                                .primaryTextTheme
                                .title
                                .fontSize),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget vehicleCellWithDistance(
  BuildContext context,
  Vehicle vehicle,
) {
  return Container(
    child: Container(
      height: 200,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            left: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: defaultCornerRadius,
                topRight: defaultCornerRadius,
              ),
              child: Image.asset(
                vehicle.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Container(
              color: Colors.black.withOpacity(.65),
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        vehicle.name,
                        style: TextStyle(
                            color: Colors.white.withOpacity(.9),
                            fontSize: Theme.of(context)
                                .primaryTextTheme
                                .title
                                .fontSize),
                      ),
                      SizedBox(height: 10),
                      Text(
                        vehicle.finalBaseFareFormatted,
                        style: TextStyle(
                            color: Colors.white.withOpacity(.75),
                            fontWeight: FontWeight.bold,
                            fontSize: Theme.of(context)
                                .primaryTextTheme
                                .subtitle
                                .fontSize),
                      ),
                      SizedBox(height: 2.5),
                      Text(
                        vehicle.finalDistanceFormatted,
                        style: TextStyle(
                            color: Colors.white.withOpacity(.75),
                            fontWeight: FontWeight.bold,
                            fontSize: Theme.of(context)
                                .primaryTextTheme
                                .subtitle
                                .fontSize),
                      ),
                    ],
                  ),
                  Text(
                    vehicle.finalPriceFormatted,
                    style: TextStyle(
                        color: Colors.white.withOpacity(.85),
                        fontSize:
                            Theme.of(context).primaryTextTheme.title.fontSize),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget confirmationDetail(
  BuildContext context,
  String key,
  String value,
) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      "$key : $value",
      style: TextStyle(
        color: Colors.black.withOpacity(.65),
        fontSize: Theme.of(context).primaryTextTheme.subhead.fontSize,
      ),
    ),
  );
}

Future<Set<Polyline>> getDirectionPolies(
    Position location, Position destination) async {
  Polyline polie;
  var innerPolies = Set<Polyline>();
  const kGoogleApiKey = "AIzaSyDeu9XNny5i6jXlgpLySg6iPlWZ-qZGGX4";
  final baseUrl = "https://maps.googleapis.com/maps/api/directions/json?";
  final JsonDecoder _decoder = new JsonDecoder();

  var url = "origin=" +
      location.latitude.toString() +
      "," +
      location.longitude.toString() +
      "&destination=" +
      destination.latitude.toString() +
      "," +
      destination.longitude.toString() +
      "&key=$kGoogleApiKey";

  try {
    var response = await http.get(baseUrl + url);

    String res = response.body;

    if (response.statusCode < 200 ||
        response.statusCode > 400 ||
        json == null) {
      res = "{\"status\":" +
          response.statusCode.toString() +
          ",\"message\":\"error\",\"response\":" +
          res +
          "}";

      return innerPolies;
    }
    List<Steps> rr =
        parseSteps(_decoder.convert(res)["routes"][0]["legs"][0]["steps"]);

    List<LatLng> ccc = new List();
    for (final i in rr) {
      ccc.add(LatLng(i.startLocation.lat, i.startLocation.lng));
      ccc.add(LatLng(i.endLocation.lat, i.endLocation.lng));
    }
    polie = new Polyline(
      points: ccc,
      width: 2,
      color: Colors.black,
      polylineId: PolylineId("t"),
    );

    innerPolies.add(polie);

    return innerPolies;
  } catch (e) {
    return innerPolies;
  }

  // List<LatLng> ccc = new List();

  // ccc.add(LatLng(location.latitude, location.longitude));
  // ccc.add(LatLng(destination.latitude, destination.longitude));

  // polie = new Polyline(
  //   points: ccc,
  //   width: 2,
  //   color: Colors.black,
  //   polylineId: PolylineId("route"),
  // );

  // innerPolies.add(polie);
  // return innerPolies;
}

List<Steps> parseSteps(final responseBody) {
  var list =
      responseBody.map<Steps>((json) => new Steps.fromJson(json)).toList();

  return list;
}

Widget confirmationAddress({String line1, String line2}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Text(
        line1,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 15.75,
          color: Colors.black.withOpacity(.6),
        ),
      ),
      SizedBox(
        height: 4,
      ),
      Text(
        line2,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14.75,
          fontWeight: FontWeight.bold,
          color: Colors.black.withOpacity(.75),
        ),
      ),
    ],
  );
}

String getAddyLine1(Placemark addyInUse) => addyInUse?.name ?? "Erreur";
String getAddyLine2(Placemark addyInUse){
 var postCode = addyInUse?.postalCode;
 var locality = addyInUse?.locality;

 if (postCode == null || locality == null)
  return "Impossible de récupérer l'emplacement";
 else
    return "${addyInUse?.postalCode}, ${addyInUse?.locality}";
}

void hideKeyboard() => SystemChannels.textInput.invokeMethod('TextInput.hide');

SnackBar defaultSnackBar(String errorMessage) {
  return SnackBar(
    duration: Duration(milliseconds: 650),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            errorMessage,
            style: TextStyle(fontSize: 14.75),
          ),
        ),
        Icon(Icons.error)
      ],
    ),
    backgroundColor: Colors.black,
  );
}
