import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:frontend/bloc/form/logIn/logInFormBloc.dart';
import 'package:frontend/bloc/user/userBloc.dart';
import 'package:frontend/bloc/user/userBlocEvent.dart';
import 'package:frontend/bloc/user/userBlocState.dart';
import 'package:frontend/model/common/errorContainer.dart';
import 'package:frontend/model/user/user.dart';
import 'package:frontend/service/ioc/blocContainerService.dart';
import 'package:frontend/view/screens/login/signUpView.dart';
import 'package:frontend/view/uiparts/inputFieldPart.dart';
import 'package:frontend/view/uiparts/popupPart.dart';

class LoginView extends StatelessWidget with InputFieldPart, PopupPart{
  final UserBloc userBloc =
    BlocContainerService.instance.getAndInit(UserBloc.BLOC_NAME);

  final LogInFormBloc logInFormBloc =
    BlocContainerService.instance.getAndInit(LogInFormBloc.BLOC_NAME);

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<UserBlocState>(
        stream: userBloc.states,
        initialData: UserLoading(),
        builder: (context, snapshot) {
          var data = snapshot.data;

          if (data is UserLoggedIn) {
            return Text("Authorized!");
          }

          if (data is UserUnauthorized) {
            _showWarning(context, data.errorContainer);
          }

          return _createLoginForm(context);
        },
      )
    );
  }

  Widget _createLoginForm(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _createLogo(),
          _createEmailField(),
          _createPasswordField(),
          _createLogInButton(context),
          _createSignUpButton(context)
        ],
      ),
    );
  }

  /// Widgets

  Widget _createLogo() {
    var image = AssetImage('assets/image/logo.png');

    return Image(
        filterQuality: FilterQuality.high,
        image: image
    );
  }
  
  Widget _createEmailField() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: createFormTextField(
          logInFormBloc.emailStream,
          logInFormBloc.checkEmail,
          "E-mail",
          icon: Icon(Icons.email),
          controller: emailController),
    );
  }

  Widget _createPasswordField() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: createFormTextField(
          logInFormBloc.passwordStream,
          logInFormBloc.checkPassword,
          "Пароль",
          icon: Icon(Icons.lock),
          controller: passwordController,
          obscure: true),
    );
  }

  Widget _createLogInButton(BuildContext context) {
    return StreamBuilder<bool>(
      initialData: false,
      stream: logInFormBloc.formValidity,
      builder: (context, snapshot) {
        bool isFormCorrect = snapshot.data == true;

        print("[LogIn form] Status: $isFormCorrect");

        return RaisedButton(
          child: Text(
              "Войти"
          ),
          onPressed: isFormCorrect ? _logIn : null,
        );
      },
    );
  }

  Widget _createSignUpButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Нет аккаунта?"),
        Padding(padding: EdgeInsets.only(left: 10.0)),
        FlatButton(
          child: Text(
            "Регистрация",
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                decoration: TextDecoration.underline
            ),
          ),
          onPressed: () => _signUp(context),
        )
      ],
    );
  }

  /// Logic
  _logIn() {
    userBloc.events.add(LogInUser(_getUser()));
  }
  
  _signUp(BuildContext context) {
    _cleanForm();
    _followRoute(RegistrationRoute(), context);
  }
  
  _cleanForm() {
    emailController.clear();
    passwordController.clear();
  }

  User _getUser() {
    return User(
      email: emailController.text,
      password: passwordController.text
    );
  }

  _showWarning(BuildContext context, ErrorContainer errorContainer) {
    _onWidgetBuilt(() {
      String error = errorContainer?.hasErrors == true
          ? errorContainer.errorList[0]
          : "Ошибка авторизации!";

      createWarningPopup(context, error);
    });
  }
  
  _followRoute(PageRoute pageRoute, BuildContext context) {
    _onWidgetBuilt(() =>
        Navigator
            .of(context)
            .pushAndRemoveUntil(pageRoute, (cond) => false));
  }

  _onWidgetBuilt(Function fun) {
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      fun.call();
    });
  }
}

class LoginRoute extends CupertinoPageRoute {
  LoginRoute() : super(builder: (BuildContext context) => LoginView());
}