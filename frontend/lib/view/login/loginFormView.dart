import 'package:flutter/material.dart';
import 'package:frontend/service/login/loginService.dart';
import 'package:frontend/view/main/mainView.dart';
import 'package:get_it/get_it.dart';

class LoginFormView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginFormViewState();
}

class LoginFormViewState extends State<LoginFormView> {
  LoginService _loginService = GetIt.instance.get<LoginService>();

  final _formKey = GlobalKey<FormState>();
  var _context;

  TextFormField _loginTextField;
  TextFormField _passwordTextField;
  RaisedButton _loginButton;
  TextEditingController _loginTextFieldController;
  TextEditingController _passwordTextFieldController;
  void Function() _onLoginButtonPressedAction;

  LoginFormViewState() {
    _onLoginButtonPressedAction = null;

    this._loginTextField = TextFormField(
      controller: _loginTextFieldController,
      validator: _validateLoginTextField,
      style: TextStyle(
        fontSize: 19
      ),
      decoration: InputDecoration(
        labelText: "Логин",
        labelStyle: TextStyle(
          fontSize: 20
        ),
      ),
    );

    this._passwordTextField = TextFormField(
      controller: _passwordTextFieldController,
      validator: _validatePasswordTextField,
      obscureText: true,
      style: TextStyle(
          fontSize: 19
      ),
      decoration: InputDecoration(
          labelText: "Пароль",
          labelStyle: TextStyle(
            fontSize: 20
          ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
//    double parentWidth = MediaQuery.of(context).size.width;
//    double parentHeight = MediaQuery.of(context).size.height;

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
                height: 300,
                child: Form(
                    key: _formKey,
                    onChanged: _updateButtonActiveState,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            width: 192,
                            height: 81,
                            filterQuality: FilterQuality.high,
                            image: AssetImage('assets/image/logo_with_name_256x107.png')
                          ),
                          _loginTextField,
                          _passwordTextField,
                          _loginButton
                        ]
                    )
                )
            )
        ),
    );
  }

  void _updateButtonActiveState() {
    if (null == _onLoginButtonPressedAction
          && _formKey.currentState.validate()) {
      setState(() {
        print("Ok!");
       _onLoginButtonPressedAction = _onLoginButtonPressed;
      });
    } else if (null != _onLoginButtonPressedAction
          && !_formKey.currentState.validate()){
      setState(() {
        _onLoginButtonPressedAction = null;
      });
    }
  }

  void _onLoginButtonPressed() {
    if (_formKey.currentState.validate()) {
      String login = _loginTextFieldController.text;
      String password = _passwordTextFieldController.text;

      bool isLogged = _loginService.logIn(login, password);

      if (isLogged) {
        Navigator.push(
          this.context,
          MaterialPageRoute(builder: (context) => MainView()),
        );
      }
    }
  }

  String _validateLoginTextField(String login) {
    List<String> errors = _loginService.getLoginValidationErrors(login);
    if (errors.isEmpty) {
      return null;
    } else {
      return errors[0];
    }
  }

  String _validatePasswordTextField(String password) {
    List<String> errors = _loginService.getPasswordValidationErrors(password);
    if (errors.isEmpty) {
      return null;
    } else {
      return errors[0];
    }
  }
}