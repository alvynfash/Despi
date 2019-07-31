import 'package:despi/blocs/bloc.dart';
import 'package:despi/screens/utils/util.dart';
import 'package:despi/signup/bloc.dart';
import 'package:despi/signup/signup_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  SignupBloc _signupBloc;
  TextStyle _responseStyle;
  TextStyle _questionStyle;

  TextEditingController _usernameController;
  TextEditingController _mobileController;

  double backButtonWidth = 1;

  @override
  void initState() {
    _signupBloc = SignupBloc(BlocProvider.of<AppBloc>(context).userRepository);
    _usernameController = TextEditingController();
    _mobileController = TextEditingController();

    _questionStyle = TextStyle(fontSize: 28, color: Colors.black);
    _responseStyle = TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 32,
        color: Colors.white,
        fontWeight: FontWeight.bold);

    _signupBloc.dispatch(FormLoad());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener(
        bloc: _signupBloc,
        listener: (context, SignupState state) async {
          await Future.delayed(Duration(milliseconds: 250));
          if (state.mode != SignUpModes.username) {
            setState(() {
              backButtonWidth = 65;
            });
          } else {
            setState(() {
              backButtonWidth = 1;
            });
          }

          if (state.isSuccess) {
            // return navigateTo(context, OnboardingScreen());
            BlocProvider.of<AppBloc>(context).dispatch(AppSignedUp());
          } else if (state.isFailure) {
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                defaultSnackBar(_signupBloc.currentState.failureMessage),
              );
          }
        },
        child: BlocBuilder(
          bloc: _signupBloc,
          builder: (context, SignupState state) {
            return Scaffold(
                body: (state.isBusy || state.isSubmitting)
                    ? Container(
                        child: showInviewLoader(),
                      )
                    : _buildForm(context));
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _signupBloc.dispose();
    super.dispose();
  }

  Widget _buildForm(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: <Widget>[
                CurvedShape(),
                // Padding(
                //   padding: const EdgeInsets.only(left: 0, top: 0, right: 32),
                //   child: InkWell(
                //     onTap: () => _signupBloc.dispatch(BackSignUpPressed()),
                Container(
                  child: _signupBloc.currentState.mode != SignUpModes.username
                      ? AnimatedContainer(
                          height: 65,
                          width: backButtonWidth,
                          duration: Duration(milliseconds: 250),
                          curve: Curves.fastOutSlowIn,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(0),
                                bottomRight: Radius.circular(35),
                                topRight: Radius.circular(30)),
                          ),
                          child: Stack(
                            children: <Widget>[
                              Center(
                                child: Icon(
                                  Icons.arrow_back,
                                  size: 30,
                                  color: Colors.red,
                                ),
                              ),
                              InkWell(
                                  onTap: () => _signupBloc
                                      .dispatch(BackSignUpPressed())),
                            ],
                          ),
                        )
                      : Container(
                          height: 0,
                          width: 0,
                        ),
                  // ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 32, top: 85, right: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        _signupBloc.currentState.mode == SignUpModes.username
                            ? _buildUsernameForm(context)
                            : _buildPhoneForm(context),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 12),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FlatButton(
                splashColor: Colors.white.withOpacity(.8),
                highlightColor: Colors.transparent,
                onPressed: () => _signupBloc.dispatch(NextSignUpPressed()),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text("Next",
                        // textAlign: TextAlign.center,
                        style: _responseStyle.copyWith(
                            color: _signupBloc.currentState.isNextActive
                                ? Colors.red
                                : Colors.grey,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    Icon(
                      Icons.navigate_next,
                      color: _signupBloc.currentState.isNextActive
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildUsernameForm(BuildContext context) {
    return <Widget>[
      Text(
        'Hello,',
        style: _questionStyle,
      ),
      SizedBox(height: 15),
      Text(
        "What's your name ?",
        style: _questionStyle,
      ),
      SizedBox(height: 25),
      Padding(
        padding: const EdgeInsets.only(right: 64),
        child: TextField(
          controller: _usernameController,
          keyboardType: TextInputType.emailAddress,
          cursorColor: Colors.white,
          maxLength: 15,
          maxLengthEnforced: true,
          style: _responseStyle,
          onChanged: (text) {
            _signupBloc.dispatch(UsernameChanged(username: text));
          },
        ),
      ),
    ];
  }

  List<Widget> _buildPhoneForm(BuildContext context) {
    return <Widget>[
      Text(
        'And,',
        style: _questionStyle,
      ),
      SizedBox(height: 15),
      Text(
        "What number can we reach you on ?",
        style: _questionStyle,
      ),
      SizedBox(height: 25),
      Padding(
        padding: const EdgeInsets.only(right: 64),
        child: TextField(
          controller: _mobileController,
          keyboardType: TextInputType.phone,
          cursorColor: Colors.white,
          // maxLength: 10,
          // maxLengthEnforced: true,
          style: _responseStyle,
          onChanged: (text) => _signupBloc.dispatch(PhoneChanged(phone: text)),
        ),
      ),
    ];
  }
}
