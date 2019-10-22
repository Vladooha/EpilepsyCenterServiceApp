import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/service/login/loginService.dart';
import 'package:frontend/service/login/loginServiceImpl.dart';
import 'package:frontend/view/login/loginFormView.dart';
import 'package:get_it/get_it.dart';

class StartupShadowView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _setupIoC();

    LoginService loginService = GetIt.instance.get<LoginService>();
    if (loginService.isLogged()) {
      // TODO Add main view
      return null;
    } else {
      return MaterialApp(
        home: LoginFormView()
      );
    }
  }

  void _setupIoC() {
    var IoC = GetIt.instance;
    IoC.reset();

    IoC.registerSingleton<LoginService>(LoginServiceImpl(), signalsReady: true);
  }
}