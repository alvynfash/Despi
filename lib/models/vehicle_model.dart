class Vehicle {
  String name;
  String description;
  double rate;
  double baseFare = 4.25;
  double proposedDistance = 0;
  String get finalDistanceFormatted =>
      "Distance total : ${proposedDistance.round()} m";

  String get finalBaseFareFormatted => "Tarif de base : € ${baseFare.toStringAsFixed(2)}";

  double get finalPrice =>
      double.parse(((rate * proposedDistance) + baseFare).toStringAsFixed(2));

  String get finalPriceFormatted => "€$finalPrice";

  String image;
}
