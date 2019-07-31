// import 'dart:async';
// import 'dart:convert';

// import 'package:despi/models/steps.dart';
// import 'package:http/http.dart' as http;

// class NetworkUtil {
//   final bASE_URL = "https://maps.googleapis.com/maps/api/directions/json?";

//   final JsonDecoder _decoder = new JsonDecoder();

//   Future<dynamic> get(String url) {
//     return http.get(bASE_URL + url).then((http.Response response) {
//       String res = response.body;
//       int statusCode = response.statusCode;
//       print("API Response: " + res);
//       if (statusCode < 200 || statusCode > 400 || json == null) {
//         res = "{\"status\":" +
//             statusCode.toString() +
//             ",\"message\":\"error\",\"response\":" +
//             res +
//             "}";
//         throw new Exception(res);
//       }

//       List<Steps> steps;
//       try {
//         steps =
//             parseSteps(_decoder.convert(res)["routes"][0]["legs"][0]["steps"]);
//       } catch (e) {
//         throw new Exception(res);
//       }

//       return steps;
//     });
//   }

//   List<Steps> parseSteps(final responseBody) {
//     var list =
//         responseBody.map<Steps>((json) => new Steps.fromJson(json)).toList();

//     return list;
//   }
// }