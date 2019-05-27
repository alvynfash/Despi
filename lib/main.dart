import 'package:bloc/bloc.dart';
import 'package:despi/screens/screen.dart';
import 'package:flutter/material.dart';
import 'blocs/simple_bloc_delegate.dart';


void main() {
  BlocSupervisor().delegate = SimpleBlocDelegate();
  runApp(
    Directionality(
      textDirection: TextDirection.ltr,
      child: MyApp(),
    ),
  );
}

