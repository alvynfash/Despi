import 'package:despi/blocs/bloc.dart';
import 'package:despi/screens/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:despi/screens/screen.dart';

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  AppBloc _authenticationBloc;

  @override
  void initState() {
    super.initState();
    _authenticationBloc = AppBloc();
    _authenticationBloc.dispatch(AppStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: _authenticationBloc,
      child: MaterialApp(
        home: BlocListener(
          bloc: _authenticationBloc,
          listener: (context, AppState state) {
            switch (state.runtimeType) {
              case WaitingOnboarding:
                return navigateTo(context, OnboardingScreen());
              case Unauthenticated:
                return navigateTo(context, SignupScreen());
              case Authenticated:
                return navigateTo(context, SignupScreen());
            }
          },
          child: SplashScreen(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _authenticationBloc.dispose();
    super.dispose();
  }
}
