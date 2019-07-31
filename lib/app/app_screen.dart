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
        debugShowCheckedModeBanner: false,
        home: BlocListener(
          bloc: _authenticationBloc,
          listener: (context, AppState state) {
            switch (state.runtimeType) {
              case WaitingOnboarding:
                return navigateTo(context, onboardingScreenRoute);
              case Unauthenticated:
                return setAsMain(context, signupScreenRoute);
              case Authenticated:
                return setAsMain(context, searchScreenRoute);
            }
          },
          child: SplashScreen(),
        ),
        routes: <String, WidgetBuilder>{
          splashScreenRoute: (BuildContext context) => SplashScreen(),
          onboardingScreenRoute: (BuildContext context) => OnboardingScreen(),
          signupScreenRoute: (BuildContext context) => SignupScreen(),
          searchScreenRoute: (BuildContext context) => SearchScreen(),
          placesScreenRoute: (BuildContext context) => PlacesScreen(),
          // '/onboardingScreen': (BuildContext context) => OnboardingScreen(),
        },
        // onGenerateRoute: ,
        theme: ThemeData.light().copyWith(
          primaryColor: Colors.white,
          primaryColorDark: Colors.black,
          accentColor: Colors.red,
          // primaryColorLight: Colors.red[200],
          primaryTextTheme: ThemeData.light()
              .primaryTextTheme
              .copyWith(title: TextStyle(color: Colors.black.withOpacity(.7))),
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
