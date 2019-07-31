import 'package:bloc/bloc.dart';
import 'package:despi/screens/screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'blocs/simple_bloc_delegate.dart';

void main() {
  BlocSupervisor().delegate = SimpleBlocDelegate();
  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  Intl.defaultLocale = 'fr';
  initializeDateFormatting();
  runApp(MyApp());
}
