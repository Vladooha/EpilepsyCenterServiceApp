import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:frontend/bloc/user/userBloc.dart';
import 'package:frontend/bloc/user/userBlocEvent.dart';
import 'package:frontend/bloc/user/userBlocState.dart';
import 'package:frontend/service/ioc/blocContainerService.dart';
import 'package:frontend/service/validator/validatorService.dart';
import 'package:frontend/view/screens/calculator/calculatorView.dart';
import 'package:frontend/view/screens/chat/chatListView.dart';
import 'package:frontend/view/screens/login/registrationFormView.dart';
import 'package:frontend/view/screens/splash/splashAnimationView.dart';
import 'package:frontend/view/uiparts/inputFieldPart.dart';
import 'package:frontend/view/uiparts/popupPart.dart';

class LoginFormView extends StatefulWidget {
  final ValidatorService validatorService = ValidatorService();

  final UserBloc userBloc =
    BlocContainerService.instance.getAndInit(UserBloc.BLOC_NAME);

  @override
  State<StatefulWidget> createState() => LoginFormViewState();
}

class LoginFormViewState extends State<LoginFormView> with InputFieldPart, PopupPart {
  int rand;

  final _formKey = GlobalKey<FormState>();

  Widget _emailTextField;
  Widget _passwordTextField;
  
  Widget _loginButton;
  Widget _regButton;

  TextEditingController _emailTextFieldController;
  TextEditingController _passwordTextFieldController;
  void Function() _onLoginButtonPressedAction;

  bool _canShowWarning = true;

  LoginFormViewState() {
    rand = Random().nextInt(9999999);

    _emailTextFieldController = TextEditingController();
    _passwordTextFieldController = TextEditingController();
  }

  @override
  initState() {
    super.initState();

    _emailTextField = createInputTextField(
        "E-mail",
        _emailTextFieldController,
        widget.validatorService.getEmailValidationErrors
    );

    _passwordTextField = createInputTextField(
        "Пароль",
        _passwordTextFieldController,
        widget.validatorService.getPasswordValidationErrors,
        isPassword: true
    );


    _regButton = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
            "Нет аккаунта?"
        ),
        SizedBox(
          width: 5,
        ),
        FlatButton(
            child: Text(
              "Зарегистрироваться",
              style: TextStyle(
                  color: Colors.blueAccent,
                  decoration: TextDecoration.underline
              ),
            ),
            onPressed: _onRegButtonPressedAction
        )
      ],
    );

    _onLoginButtonPressedAction = null;
  }

  @override
  Widget build(BuildContext context) {
    // Should be updated for enabling\disabling
    this._loginButton = RaisedButton(
      child: Text(
          "Войти"
      ),
      onPressed: _onLoginButtonPressedAction,
    );

    return Scaffold(
        body: Center(
            child: SizedBox(
                width: 350,
                height: 350,
                child: StreamBuilder(
                  initialData: widget.userBloc.lastUserData,
                  stream: widget.userBloc.userActions,
                  builder: (context, snapshot) {
                    if (snapshot.hasData
                        && snapshot.data is UserActionResult
                        && snapshot.data.userActions == UserActionsType.logIn) {

                      var response = snapshot.data;

                      print("${response.runtimeType} ${response.toString()}");

                      if (response is Success) {
                        print('Success login - ${response.rand}, $rand');

                        _whenWidgetBuilt(() =>
                            Navigator
                              .of(context)
                              .pushAndRemoveUntil(CalculatorViewRoute(), (cond) => false));
                      }

                      if (response is Loading) {
//                        _sendLogin();

                        return SplashAnimationView();
                      }

                      if (response is Error) {
                        if (_canShowWarning) {
                          String errorText = response.errorList != null
                              ? response.errorList[0].toString()
                              : "Неизвестная ошибка!";
                          _whenWidgetBuilt(() {
                            _cleanFields();

                            createWarningPopup(context, errorText);
                            _updateButtonActiveState();
                          });

                          _canShowWarning = false;
                        }
                      }
                    }

                    return _createLoginForm();
                  },
                )
            )
        )
    );
  }

  Widget _createLoginForm() {
    return Form(
        key: _formKey,
        onChanged: _updateButtonActiveState,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                  width: 256 * 0.5,
                  height: 107 * 0.5,
                  filterQuality: FilterQuality.high,
                  image: AssetImage('assets/image/logo.png')
              ),
              _emailTextField,
              _passwordTextField,
              _loginButton,
              _regButton
            ]
        )
    );
  }

  _sendLogin() {
    widget.userBloc.eventListener.add(
        UserAction(
            UserActionsType.logIn,
            email: _emailTextFieldController.text,
            password: _passwordTextFieldController.text
        ));
  }

  _cleanFields() {
    setState(() {
      _emailTextFieldController.text = "";
      _passwordTextFieldController.text = "";
    });
  }

  _updateButtonActiveState() {
    if (null == _onLoginButtonPressedAction
          && _formKey.currentState.validate()) {
      setState(() {
       _onLoginButtonPressedAction = _onLoginButtonPressed;
      });
    } else if (!_formKey.currentState.validate()) {
      setState(() {
        _onLoginButtonPressedAction = null;
      });
    }
  }

  void _onLoginButtonPressed() async {
    if (_formKey.currentState.validate()) {
      _canShowWarning = true;

      _sendLogin();
    }
  }

  void _onRegButtonPressedAction() {
    Navigator
        .of(context)
        .push(RegistrationFormRoute());
  }

  void _whenWidgetBuilt(Function fun) {
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      fun.call();
    });
  }
}

class LoginFormRoute extends CupertinoPageRoute {
  LoginFormRoute() : super(builder: (BuildContext context) => LoginFormView());
}