import 'package:flutter/material.dart';

class MySlideDuration extends PageRouteBuilder {
  Widget widget;
  MySlideDuration({this.widget})
      : super(
            pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondAnimation) {
              return widget;
            },

      transitionDuration: Duration(seconds: 2),

            transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondAnimation, Widget child) {
              final curve = CurvedAnimation(parent: animation, curve: Curves.decelerate);
              Animation<Offset> customAnimation = Tween<Offset>(begin: Offset(1.0, 1.0), end: Offset(0.0, 0.0)).animate(animation);
              Animation<Offset> customAnimation2 = Tween<Offset>(begin: Offset(1.0, 1.0), end: Offset(0.0, 0.0)).animate(curve);

              return SlideTransition(position: customAnimation2, child: child,);
            });
}

class MySlideDuration2 extends PageRouteBuilder {
  Widget widget;
  MySlideDuration2({this.widget})
      : super(
            pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondAnimation) {
              return widget;
            },

      transitionDuration: Duration(seconds: 2),

            transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondAnimation, Widget child) {
              final curve = CurvedAnimation(parent: animation, curve: Curves.decelerate);
              Animation<Offset> customAnimation2 = Tween<Offset>(begin: Offset(0, 1.0), end: Offset(0.0, 0.0)).animate(curve);

              return SlideTransition(position: customAnimation2, child: child,);
            });
}
