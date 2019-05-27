import 'package:despi/blocs/bloc.dart';
import 'package:despi/screens/utils/util.dart';
import 'package:despi/signup/bloc.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  SignupBloc _signupBloc;
  TextStyle _style;

  InputDecoration _deco;
  TextEditingController _usernameController;
  TextEditingController _mobileController;

  @override
  void initState() {
    _signupBloc = SignupBloc(BlocProvider.of<AppBloc>(context).userRepository);
    _usernameController = TextEditingController();
    _mobileController = TextEditingController();

    _style =
        TextStyle(fontFamily: 'Montserrat', fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold);
    _deco = InputDecoration(
      // fillColor: Colors.white,
      // filled: true,
      contentPadding: EdgeInsets.all(15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    );
    _signupBloc.dispatch(FormLoad());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener(
        bloc: _signupBloc,
        listener: (context, SignupState state) {
          switch (state.runtimeType) {
            case SignUpSuccess:
              // return navigateTo(context, OnboardingScreen());
              return;
            case SignUpFailure:
              Scaffold.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('SignUp Failure'), Icon(Icons.error)],
                    ),
                    backgroundColor: Colors.black,
                  ),
                );
          }
        },
        child: BlocBuilder(
          bloc: _signupBloc,
          builder: (context, SignupState state) {
            switch (state.runtimeType) {
              case SignUpLoading:
                return Container(
                  child: Center(
                    child: SpinKitRipple(
                      color: Colors.red.shade500,
                      size: 120,
                    ),
                  ),
                );
              default:
                return _buildForm(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: <Widget>[
              CurvedShape(),
              Padding(
                padding: const EdgeInsets.only(left: 32, top: 96, right: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Hello,',
                      style: TextStyle(fontSize: 35, color: Colors.black),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "What's your name ?",
                      style: TextStyle(fontSize: 32, color: Colors.black),
                    ),
                    SizedBox(height: 25),
                    TextField(
                      controller: _usernameController,
                      cursorColor: Colors.white,
                      textAlign: TextAlign.center,
                      maxLength: 15,
                      maxLengthEnforced: true,
                      style: _style,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(32),
          child: InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text("Next",
                    textAlign: TextAlign.center,
                    style: _style.copyWith(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Icon(
                  Icons.navigate_next,
                  color: Colors.red,
                ),
              ],
            ),
            
            onTap: () => _signupBloc.dispatch(
                  SignUpButtonPressed(
                    mobile: _mobileController.text,
                    userName: _usernameController.text,
                  ),
                ),
          ),
        ),
      ],
    );
  }
}