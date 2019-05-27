export 'app_box_decoration.dart';
export 'dots_indicator.dart';
export 'curved_shape.dart';

import 'package:flutter/material.dart';

Future navigateTo(BuildContext context, Widget screen) async {
  return Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => screen,
  ));
}
