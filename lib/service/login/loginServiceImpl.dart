import 'package:frontend/service/login/loginService.dart';
import 'package:get_it/get_it.dart';

class LoginServiceImpl implements LoginService {
  LoginServiceImpl() {
    //GetIt.instance.signalReady(this);
  }

  @override
  bool isLogged() {
    return false;
  }

  @override
  bool register(String login, String password) {
    // TODO: implement register
    return null;
  }

  @override
  bool logIn(String login, String password) {
    // TODO: implement login
    return true;
  }

  @override
  bool isValidLogin(String login) {
    return getLoginValidationErrors(login).isEmpty;
  }

  @override
  bool isValidPassword(String password) {
    return getPasswordValidationErrors(password).isEmpty;
  }

  @override
  List<String> getLoginValidationErrors(String login) {
    List<String> errors = [];

    if (login.length < 5) {
      errors.add("Минимальная длина логина - 5 символов");
    }

    if (login.length > 15) {
      errors.add("Максимальная длина логина - 15 символов");
    }

    RegExp latinSymbAndDigits = RegExp(r"^[A-Za-z0-9]{5,15}$");
    if (!latinSymbAndDigits.hasMatch(login)) {
      errors.add("Логин должен состоять из ланитских символов и цифр");
    }

    return errors;
  }

  @override
  List<String> getPasswordValidationErrors(String password) {
    List<String> errors = [];

    if (password.length < 8) {
      errors.add("Минимальная длина пароля - 8 символов");
    }

    if (password.length > 20) {
      errors.add("Максимальная длина пароля - 20 символов");
    }

    RegExp notAllowedSymbols = RegExp(r'[^A-Za-z\d!.]+');
    if (notAllowedSymbols.hasMatch(password)) {
      errors.add("Пароль может состоять из латинских букв, цифр, '!' и '.'");
    }

    RegExp minimumLetterAndDigitAmount = RegExp(r".*[A-Z]+.*[0-9]+.*|.*[0-9]+.*[A-Z]+.*$");
    if (!minimumLetterAndDigitAmount.hasMatch(password)) {
      errors.add("Пароль должен содержать хотя бы одну заглавную букву и цифру");
    }

    return errors;
  }
}