import 'package:frontend/bloc/form/abstractFormValidatorBloc.dart';
import 'package:frontend/bloc/form/logIn/logInFormBloc.dart';
import 'package:frontend/service/ioc/blocContainerService.dart';
import 'package:rxdart/rxdart.dart';

class SignUpFormBloc extends AbstractFormValidatorBloc {
  static const BLOC_NAME = "sign-up-form-bloc";

  @override
  String get name => BLOC_NAME;

  @override
  List<String> get dependencyNames => [LogInFormBloc.BLOC_NAME];

  LogInFormBloc logInFormBloc =
    BlocContainerService.instance.getAndInit(LogInFormBloc.BLOC_NAME);

  BehaviorSubject<String> emailController;
  BehaviorSubject<String> passwordController;
  BehaviorSubject<String> passwordRepeatController;

  BehaviorSubject<String> nameController;
  BehaviorSubject<String> surnameController;
  BehaviorSubject<String> phoneController;


  Stream<String> get emailStream => emailController.stream
      .transform(createTransformer(validateEmail))
      .asBroadcastStream();
  Stream<String> get passwordStream => passwordController.stream
      .transform(createTransformer(validatePassword))
      .asBroadcastStream();
  Stream<String> get passwordRepeatStream => passwordRepeatController.stream
      .transform(createTransformer(validatePasswordRepeat))
      .asBroadcastStream();

  Stream<String> get nameStream => nameController.stream
      .transform(createTransformer(validateName))
      .asBroadcastStream();
  Stream<String> get surnameStream => surnameController.stream
      .transform(createTransformer(validateSurname))
      .asBroadcastStream();
  Stream<String> get phoneStream => phoneController.stream
      .transform(createTransformer(validatePhone))
      .asBroadcastStream();


  Function(String email) get checkEmail => emailController.sink.add;
  Function(String password) get checkPassword => passwordController.sink.add;
  Function(String password) get checkPasswordRepeat => passwordRepeatController.sink.add;

  Function(String name) get checkName => nameController.sink.add;
  Function(String surname) get checkSurname => surnameController.sink.add;
  Function(String phone) get checkPhone => phoneController.sink.add;

  @override
  List<Stream> get formFieldStreamList => [
    emailStream, passwordStream, passwordRepeatStream,
    nameStream, surnameStream, phoneStream
  ];

  /// BLoC state management

  @override
  bool init() {
    if (super.init()) {
      emailController = BehaviorSubject<String>();
      passwordController = BehaviorSubject<String>();
      passwordRepeatController = BehaviorSubject<String>();

      nameController = BehaviorSubject<String>();
      surnameController = BehaviorSubject<String>();
      phoneController = BehaviorSubject<String>();

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

  List<String> validateEmail(String email) =>
      logInFormBloc.validateEmail(email);

  List<String> validatePassword(String password) =>
      logInFormBloc.validatePassword(password);

  List<String> validatePasswordRepeat(String passwordRepeat) {
    List<String> errors = logInFormBloc.validatePassword(passwordRepeat) ?? [];

    if (passwordController.stream.value != passwordRepeat) {
      errors.add("Пароли не совпадают");
    }

    return errors;
  }


  List<String> validateName(String name) {
    List<String> errors = [];

    if (name.length < 1) {
      errors.add("Введите имя");
    }

    if (name.length > 25) {
      errors.add("Максимальная длина 25 символов");
    }

    RegExp allowedSymbols = RegExp(r'^[a-zA-Zа-яА-ЯёЁ]{1,25}$');
    if (!allowedSymbols.hasMatch(name)) {
      errors.add("Может состоять из букв латинского и русского алфавитов");
    }

    return errors;
  }

  List<String> validateSurname(String surname) {
    List<String> errors = [];

    if (surname.length < 1) {
      errors.add("Введите фамилию");
    }

    if (surname.length > 25) {
      errors.add("Максимальная длина 25 символов");
    }

    RegExp allowedSymbols = RegExp(r'^[a-zA-Zа-яА-ЯёЁ]{1,25}$');
    if (!allowedSymbols.hasMatch(surname)) {
      errors.add("Может состоять из букв латинского и русского алфавитов");
    }

    return errors;
  }

  List<String> validatePhone(String phone) {
    print("[PHONE validator] Value: $phone");

    if (phone == null || phone == "") {
      return [];
    }

    List<String> errors = [];

    RegExp allowedNumbers = RegExp(r'^[+0-9][0-9]{11}$');
    if (!allowedNumbers.hasMatch(phone)) {
      errors.add("Должен состоять из 11 или 12 цифр");
    }

    return errors;
  }
}