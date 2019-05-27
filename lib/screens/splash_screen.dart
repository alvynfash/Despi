// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:despi/screens/utils/util.dart';

class SplashScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
        child: Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 4),
          decoration: appBoxDecoration(brushColor: Colors.red[500]),
          child: Column(
            children: <Widget>[
              _buildLogo(),
              _buildText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Stack(
      children: <Widget>[
        ClipOval(
          child: Container(
            height: 90,
            width: 90,
            color: Colors.black,
            child: Center(
              child: ClipOval(
                child: Container(
                  height: 70,
                  width: 70,
                  color: Colors.white,
                  child: Center(
                    child: ClipOval(
                      child: Container(
                        height: 45,
                        width: 45,
                        color: Colors.black,
                        child: Center(
                          child: ClipOval(
                            child: Container(
                              height: 20,
                              width: 20,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 90,
          width: 90,
          child: CircularProgressIndicator(
            backgroundColor: Colors.black,
            valueColor: AlwaysStoppedAnimation(Colors.white),
            strokeWidth: 2.5,
          ),
        ),
      ],
    );
    // return ClipOval(
    //   child: Container(
    //     height: 90,
    //     width: 90,
    //     color: Colors.black,
    //     child: Center(
    //       child: ClipOval(
    //         child: Container(
    //           height: 70,
    //           width: 70,
    //           color: Colors.white,
    //           child: Center(
    //             child: ClipOval(
    //               child: Container(
    //                 height: 45,
    //                 width: 45,
    //                 color: Colors.black,
    //                 child: Center(
    //                   child: ClipOval(
    //                     child: Container(
    //                       height: 20,
    //                       width: 20,
    //                       color: Colors.red,
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget _buildText() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Text(
            'DESPI',
            style: TextStyle(
                fontSize: 46,
                color: Colors.black87,
                fontWeight: FontWeight.w400),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Text(
            'PARIS CARS MULTISERVICES',
            style: TextStyle(
                fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
