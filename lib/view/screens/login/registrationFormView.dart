import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/bloc/user/userBloc.dart';
import 'package:frontend/bloc/user/userBlocEvent.dart';
import 'package:frontend/bloc/user/userBlocState.dart';
import 'package:frontend/model/user/user.dart';
import 'package:frontend/model/user/userPrivate.dart';
import 'package:frontend/service/database/remoteStorageService.dart';
import 'package:frontend/service/database/remoteStorageServiceImpl.dart';
import 'package:frontend/service/ioc/blocContainerService.dart';
import 'package:frontend/service/validator/validatorService.dart';
import 'package:frontend/view/screens/calculator/calculatorView.dart';
import 'package:frontend/view/screens/chat/chatListView.dart';
import 'package:frontend/view/uiparts/popupPart.dart';
import 'package:frontend/view/uiparts/inputFieldPart.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';

import 'loginFormView.dart';

class RegistrationFormView extends StatefulWidget {
  final UserBloc userBloc = BlocContainerService.instance.getAndInit(UserBloc.BLOC_NAME);
  
  final ValidatorService validatorService = ValidatorService();
  final RemoteStorageService remoteStorageService = GetIt.instance.get<RemoteStorageService>();

  @override
  State<StatefulWidget> createState() => RegistrationFormViewState();
}

class RegistrationFormViewState extends State<RegistrationFormView> with InputFieldPart, PopupPart {
  final _formKey = GlobalKey<FormState>();

  Widget _loginTextField;
  Widget _emailTextField;
  Widget _passwordTextField;
  Widget _passwordCheckTextField;

  Widget _avatarImagePicker;
  Widget _nameTextField;
  Widget _surnameTextField;
  Widget _phoneTextField;

  Widget _registrationButton;
  Widget _loginButton;

  TextEditingController _loginTextFieldController;
  TextEditingController _emailTextFieldController;
  TextEditingController _passwordTextFieldController;
  TextEditingController _passwordCheckTextFieldController;

  static const int MAX_AVATAR_SIZE = 10 * 1024 * 1024; 
  File avatarFile;
  StreamController<File> avatarStreamController = BehaviorSubject<File>();
  TextEditingController _nameTextFieldController;
  TextEditingController _surnameTextFieldController;
  TextEditingController _phoneTextFieldController;

  void Function() _onRegButtonPressedAction;
  
  RegistrationFormViewState() {
    _loginTextFieldController = TextEditingController();
    _emailTextFieldController = TextEditingController();
    _passwordTextFieldController = TextEditingController();
    _passwordCheckTextFieldController = TextEditingController();

    _nameTextFieldController = TextEditingController();
    _surnameTextFieldController = TextEditingController();
    _phoneTextFieldController = TextEditingController();
  }

  @override
  initState() {
    super.initState();

    _loginTextField = createInputTextField(
        "Логин",
        _loginTextFieldController,
        widget.validatorService.getLoginValidationErrors,
        isRequired: true);

    _passwordTextField = createInputTextField(
        "Пароль",
        _passwordTextFieldController,
        widget.validatorService.getPasswordValidationErrors,
        isRequired: true,
        isPassword: true);

    List<String> Function(String) _passwordComparator = (value) {
      if (_passwordTextFieldController.text != value) {
        return ["Пароли должны совпадать"];
      } else {
        return widget.validatorService.getPasswordValidationErrors(value);
      }
    };

    _passwordCheckTextField = createInputTextField(
        "Повторите пароль",
        _passwordCheckTextFieldController,
        _passwordComparator,
        isRequired: true,
        isPassword: true);

    _emailTextField = createInputTextField(
        "E-mail",
        _emailTextFieldController,
        widget.validatorService.getEmailValidationErrors,
        isRequired: true);

    _nameTextField = createInputTextField(
        "Имя",
        _nameTextFieldController,
        widget.validatorService.getNameValidationErrors,
        isRequired: true);

    _surnameTextField = createInputTextField(
        "Фамилия",
        _surnameTextFieldController,
        widget.validatorService.getSurnameValidationErrors,
        isRequired: true);

    _phoneTextField = createInputTextField(
        "Телефон",
        _phoneTextFieldController,
        widget.validatorService.getPhoneValidationErrors);

    _onRegButtonPressedAction = null;

    _loginButton = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
            "Уже есть аккаунт?"
        ),
        SizedBox(
          width: 5,
        ),
        FlatButton(
            child: Text(
              "Авторизоваться",
              style: TextStyle(
                  color: Colors.blueAccent,
                  decoration: TextDecoration.underline
              ),
            ),
            onPressed: _onLoginButtonPressed
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Should be updated for enabling\disabling
    _registrationButton = RaisedButton(
        child: Text(
          "Зарегистрироваться"
        ),
        onPressed: _onRegButtonPressedAction
    );

    // Should be updated for avatar picture repaint
    _avatarImagePicker = GestureDetector(
      child: StreamBuilder<File>(
        stream: avatarStreamController.stream.asBroadcastStream(),
        builder: (context, snapshot) {
          avatarFile = snapshot.hasData && !snapshot.hasError
            ? snapshot.data
            : null;

          return CircleAvatar(
            backgroundColor: Colors.grey[200],
            radius: 110,
            child: Container(
                width: avatarFile == null ? 24 : 110,
                height: avatarFile == null ? 24 : 110,
                decoration: BoxDecoration(
                    shape: BoxShape.circle
                ),
                child: ClipOval(
                  child: avatarFile == null
                      ? Image.asset(
                      'assets/image/photo.png',
                      filterQuality: FilterQuality.high)
                      : Image.file(avatarFile, fit: BoxFit.cover),
                )
            ),
          );
        },
      ),
      onTap: _getImage,
    );

    return Scaffold(
      body: Center(
          child: SizedBox(
              width: 350,
              height: 800,
              child: StreamBuilder(
                stream: widget.userBloc.userActions,
                builder: (context, snapshot) {
                  if (snapshot.hasData
                      && snapshot.data is UserActionResult
                      && snapshot.data.userActions == UserActionsType.signUp) {
                    var response = snapshot.data;

                    if (response is Success) {
                      _whenWidgetBuilt(() =>
                          Navigator
                            .of(context)
                            .push(CalculatorViewRoute()));
                    }

                    if (response is Error) {
                      String errorText = response.errorList != null
                          ? response.errorList[0]
                          : "Неизвестная ошибка!";
                      _whenWidgetBuilt(() => createWarningPopup(context, errorText));
                    }

                    if (response is Loading) {
                      //return CircularProgressIndicator();
                      _whenWidgetBuilt(() => createLoadingPopup(context, true));
                    }
                  }

                  return _createSignUpForm();
                }
              )
          )
      ),
    );
  }

  Widget _createSignUpForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 40),
      child: Form(
          key: _formKey,
          onChanged: _updateButtonActiveState,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Регистрация:",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                _loginTextField,
                _emailTextField,
                _passwordTextField,
                _passwordCheckTextField,
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: _avatarImagePicker,
                        flex: 1,),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: _nameTextField,
                              flex: 5,
                            ),
                            Expanded(
                                child: _surnameTextField,
                                flex: 5
                            )
                          ],
                        ),
                        flex: 2,
                      )
                    ],
                  ),
                ),
                _phoneTextField,
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _registrationButton
                  ],
                ),
                _loginButton
              ]
          )
      ),
    );
  }
  
  void _updateButtonActiveState() {
    if (null == _onRegButtonPressedAction
        && _formKey.currentState.validate()) {
      setState(() {
        _onRegButtonPressedAction = _onRegButtonPressed;
      });
    } else if (null != _onRegButtonPressedAction
        && !_formKey.currentState.validate()){
      setState(() {
        _onRegButtonPressedAction = null;
      });
    }
  }

  void _onRegButtonPressed() async {
    if (_formKey.currentState.validate()) {
      String email = _emailTextFieldController.text;
      String password = _passwordTextFieldController.text;

      UserPrivate loginPrivateData = UserPrivate(
          null,
          login: _loginTextFieldController.text,
          email: _emailTextFieldController.text,
          phone: _phoneTextFieldController.text
      );

      User user = User(
        null,
        name: _nameTextFieldController.text,
        surname: _surnameTextFieldController.text,
        avatarUrl: null,
        roles: ['patient'],
        privateInfo: loginPrivateData
      );

      widget.userBloc.eventListener.add(
          UserAction(
            UserActionsType.signUp,
            email: email,
            password: password,
            user: user,
            avatar: avatarFile
          ));
    }
  }

  void _onLoginButtonPressed() {
    Navigator
        .of(context)
        .push(LoginFormRoute());
  }

  void _getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    print('${image.path}');
    int length = await image.length();
    if (length > MAX_AVATAR_SIZE) {
      Fluttertoast.showToast(
          msg: "Размер не должен превышать 10 мб",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0
      );
    } else {
      avatarStreamController.sink.add(image);
    }
  }

  void _whenWidgetBuilt(Function fun) {
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      fun.call();
    });
  }
}

class RegistrationFormRoute extends CupertinoPageRoute {
  RegistrationFormRoute() : super(builder: (BuildContext context) => RegistrationFormView());
}