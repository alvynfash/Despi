import 'package:despi/blocs/bloc.dart';
import 'package:flutter/material.dart';
import 'package:despi/screens/utils/util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  static const _kDuration = const Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;
  List<Widget> _pages;

  @override
  void initState() {
    _pages = <Widget>[
      Container(
          // color: Colors.blue,
          ),
      Container(
          // color: Colors.red,
          ),
      Container(
          // color: Colors.green,
          ),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          PageView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            controller: _controller,
            itemCount: _pages.length,
            itemBuilder: (BuildContext context, int index) {
              return _pages[index];
            },
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Column(
              children: <Widget>[
                MaterialButton(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Skip To App',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  color: Colors.red.shade500,
                  onPressed: () => BlocProvider.of<AppBloc>(context)
                      .dispatch(AppOnboarded()),
                ),
                SizedBox(
                  height: 100,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Center(
                    child: DotsIndicator(
                      color: Colors.red.shade500,
                      controller: _controller,
                      itemCount: _pages.length,
                      onPageSelected: (int page) {
                        _controller.animateToPage(
                          page,
                          duration: _kDuration,
                          curve: _kCurve,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
