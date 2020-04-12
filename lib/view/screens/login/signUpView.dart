import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/bloc/form/signUp/signUpFormBloc.dart';
import 'package:frontend/bloc/user/userBloc.dart';
import 'package:frontend/bloc/user/userBlocEvent.dart';
import 'package:frontend/bloc/user/userBlocState.dart';
import 'package:frontend/model/user/user.dart';
import 'package:frontend/service/ioc/blocContainerService.dart';
import 'package:frontend/view/screens/login/loginView.dart';
import 'package:frontend/view/uiparts/inputFieldPart.dart';

class SignUpView extends StatelessWidget with InputFieldPart {
  final UserBloc userBloc =
    BlocContainerService.instance.getAndInit(UserBloc.BLOC_NAME);

  final SignUpFormBloc signUpFormBloc =
    BlocContainerService.instance.getAndInit(SignUpFormBloc.BLOC_NAME);

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordRepeatController = TextEditingController();

  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<UserBlocState>(
        stream: userBloc.states,
        initialData: UserLoading(),
        builder: (context, snapshot) {
          var data = snapshot.data;

          print("[SignUp menu] Event: ${data.runtimeType}");

          if (data is UserLoggedIn) {
            return Text("Authorized!");
          }

          return _createRegistrationForm(context);
        },
      )
    );
  }

  /// Widgets

  Widget _createRegistrationForm(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _createEmailField(),
            _createPasswordField(),
            _createPasswordRepeatField(),
            Padding(padding: EdgeInsets.only(top: 16.0)),
            _createNameField(),
            _createSurnameField(),
            _createPhoneField(),
            Padding(padding: EdgeInsets.only(top: 16.0)),
            _createSignUpButton(context),
            _createLogInButton(context)
          ],
        ),
      ),
    );
  }

  Widget _createEmailField() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: createFormTextField(
          signUpFormBloc.emailStream,
          signUpFormBloc.checkEmail,
          "E-mail",
          icon: Icon(Icons.email),
          controller: emailController),
    );
  }

  Widget _createPasswordField() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: createFormTextField(
          signUpFormBloc.passwordStream,
          signUpFormBloc.checkPassword,
          "Пароль",
          icon: Icon(Icons.lock),
          controller: passwordController,
          obscure: true),
    );
  }

  Widget _createPasswordRepeatField() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: createFormTextField(
          signUpFormBloc.passwordRepeatStream,
          signUpFormBloc.checkPasswordRepeat,
          "Повторите пароль",
          icon: Icon(Icons.lock),
          controller: passwordRepeatController,
          obscure: true),
    );
  }


  Widget _createNameField() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: createFormTextField(
          signUpFormBloc.nameStream,
          signUpFormBloc.checkName,
          "Имя",
          icon: Icon(Icons.person),
          controller: nameController),
    );
  }

  Widget _createSurnameField() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: createFormTextField(
          signUpFormBloc.surnameStream,
          signUpFormBloc.checkSurname,
          "Фамилия",
          icon: Icon(Icons.person_outline),
          controller: surnameController),
    );
  }

  Widget _createPhoneField() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: createFormTextField(
          signUpFormBloc.phoneStream,
          signUpFormBloc.checkPhone,
          "Телефон",
          icon: Icon(Icons.phone_iphone),
          controller: phoneController),
    );
  }

  Widget _createSignUpButton(BuildContext context) {
    return StreamBuilder<bool>(
      initialData: false,
      stream: signUpFormBloc.formValidity,
      builder: (context, snapshot) {
        bool isFormValid = snapshot.data == true;

        return RaisedButton(
          child: Text(
              "Зарегистрироваться"
          ),
          onPressed: isFormValid ? _signUp : null,
        );
      },
    );
  }

  Widget _createLogInButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Есть аккаунт?"),
        Padding(padding: EdgeInsets.only(left: 10.0)),
        FlatButton(
          child: Text(
            "Войти",
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                decoration: TextDecoration.underline
            ),
          ),
          //onPressed: _onRegButtonPressedAction,
          onPressed: () => _logIn(context),
        )
      ],
    );
  }

  /// Logic

  _signUp() {
    userBloc.events.add(SignUpUser(_getuser()));
  }
  
  _logIn(BuildContext context) {
    _clearForm();
    _followRoute(LoginRoute(), context);
  }

  _clearForm() {
    emailController.clear();
    passwordController.clear();
    passwordRepeatController.clear();

    nameController.clear();
    surnameController.clear();
    phoneController.clear();
  }

  User _getuser() {
    return User(
      email: emailController.text,
      password: passwordController.text,
      name: nameController.text,
      surname: surnameController.text
    );
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

class RegistrationRoute extends CupertinoPageRoute {
  RegistrationRoute() : super(builder: (BuildContext context) => SignUpView());
}