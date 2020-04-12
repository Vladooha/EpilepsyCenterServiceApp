import 'package:frontend/bloc/form/abstractFormValidatorBloc.dart';
import 'package:rxdart/rxdart.dart';

enum LogInField {
  email,
  password
}

class LogInFormBloc extends AbstractFormValidatorBloc {
  static const BLOC_NAME = "log-in-form-bloc";

  @override
  String get name => BLOC_NAME;

  BehaviorSubject<String> emailController;
  BehaviorSubject<String> passwordController;

  Stream<String> get emailStream => emailController.stream
      .transform(createTransformer(validateEmail))
      .asBroadcastStream();
  Stream<String> get passwordStream => passwordController.stream
      .transform(createTransformer(validatePassword))
      .asBroadcastStream();


  Function(String email) get checkEmail => emailController.sink.add;
  Function(String password) get checkPassword => passwordController.sink.add;

  @override
  List<Stream> get formFieldStreamList => [
    emailStream,
    passwordStream
  ];

  /// BLoC state management

  @override
  bool init() {
    if (super.init()) {
      emailController = BehaviorSubject<String>();
      passwordController = BehaviorSubject<String>();

      return true;
    }

    return false;
  }

  @override
  bool dispose() {
    if (super.dispose()) {
      emailController.close();
      passwordController.close();

      return true;
    }

    return false;
  }

  /// Validators

  List<String> validateEmail(String email) {
    List<String> errors = [];

    if (email.length > 35) {
      errors.add("Максимальная длина 35 символов");
    }

    RegExp allowedSymbols = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!allowedSymbols.hasMatch(email)) {
      errors.add("Должен содержать '@' и '.'");
    }

    return errors;
  }

  List<String> validatePassword(String password) {
    List<String> errors = [];

    if (password.length < 8) {
      errors.add("Минимальная длина 8 символов");
    }

    if (password.length > 20) {
      errors.add("Максимальная длина 20 символов");
    }

    RegExp notAllowedSymbols = RegExp(r'[^A-Za-z\d!.]+');
    if (notAllowedSymbols.hasMatch(password)) {
      errors.add("Должен состоять из латинских букв, цифр, '!' и '.'");
    }

    RegExp minimumLetterAndDigitAmount = RegExp(r".*[A-Z]+.*[0-9]+.*|.*[0-9]+.*[A-Z]+.*$");
    if (!minimumLetterAndDigitAmount.hasMatch(password)) {
      errors.add("Должен содержать хотя бы одну загл. букву и цифру");
    }

    return errors;
  }
}