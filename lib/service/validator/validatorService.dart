//class ValidatorService {
//  bool isFieldValid(ValidatableFields fieldType, dynamic fieldValue) {
//    var errorList = checkFieldForErrors(fieldType, fieldValue);
//
//    return containsError(errorList);
//  }
//
////  List<String> checkFieldForErrors(ValidatableFields fieldType, dynamic fieldValue) {
////    if (fieldType != null && fieldValue != null) {
////      List<String> errorList = [];
////
////      if (fieldType == ValidatableFields.login) {
////        errorList = getLoginValidationErrors(fieldValue as String);
////      } else if (fieldType == ValidatableFields.email) {
////        errorList = getEmailValidationErrors(fieldValue as String);
////      } else if (fieldType == ValidatableFields.password) {
////        errorList = getPasswordValidationErrors(fieldValue as String);
////      } else if (fieldType == ValidatableFields.name) {
////        errorList = getNameValidationErrors(fieldValue as String);
////      } else if (fieldType == ValidatableFields.surname) {
////        errorList = getSurnameValidationErrors(fieldValue as String);
////      } else if (fieldType == ValidatableFields.phone) {
////        errorList = getPhoneValidationErrors(fieldValue as String);
////      }
////
////      return errorList;
////    }
////
////    return null;
////  }
////
////  bool containsError(List<String> errorList) {
////    if (errorList != null && errorList.isEmpty) {
////      return true;
////    }
////
////    return false;
////  }
////
////  List<String> getLoginValidationErrors(String login) {
////    List<String> errors = [];
////
////    if (login.length < 5) {
////      errors.add("Минимальная длина логина 5 символов");
////    }
////
////    if (login.length > 15) {
////      errors.add("Максимальная длина логина 15 символов");
////    }
////
////    RegExp latinSymbAndDigits = RegExp(r"^[A-Za-z0-9]{5,15}$");
////    if (!latinSymbAndDigits.hasMatch(login)) {
////      errors.add("Логин должен состоять из латинских символов и цифр");
////    }
////
////    return errors;
////  }
////
////  List<String> getPasswordValidationErrors(String password) {
////    List<String> errors = [];
////
////    if (password.length < 8) {
////      errors.add("Минимальная длина 8 символов");
////    }
////
////    if (password.length > 20) {
////      errors.add("Максимальная длина 20 символов");
////    }
////
////    RegExp notAllowedSymbols = RegExp(r'[^A-Za-z\d!.]+');
////    if (notAllowedSymbols.hasMatch(password)) {
////      errors.add("Должен состоять из латинских букв, цифр, '!' и '.'");
////    }
////
////    RegExp minimumLetterAndDigitAmount = RegExp(r".*[A-Z]+.*[0-9]+.*|.*[0-9]+.*[A-Z]+.*$");
////    if (!minimumLetterAndDigitAmount.hasMatch(password)) {
////      errors.add("Должен содержать хотя бы одну загл. букву и цифру");
////    }
////
////    return errors;
////  }
////
////  List<String> getEmailValidationErrors(String email) {
////    List<String> errors = [];
////
////    if (email.length > 35) {
////      errors.add("Максимальная длина 35 символов");
////    }
////
////    RegExp allowedSymbols = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
////    if (!allowedSymbols.hasMatch(email)) {
////      errors.add("Должен содержать '@' и '.'");
////    }
////
////    return errors;
////  }
////
////  List<String> getNameValidationErrors(String name) {
////    List<String> errors = [];
////
////    if (name.length < 1) {
////      errors.add("Введите имя");
////    }
////
////    if (name.length > 25) {
////      errors.add("Максимальная длина 25 символов");
////    }
////
////    RegExp allowedSymbols = RegExp(r'^[a-zA-Zа-яА-ЯёЁ]{1,25}$');
////    if (!allowedSymbols.hasMatch(name)) {
////      errors.add("Может состоять из букв латинского и русского алфавитов");
////    }
////
////    return errors;
////  }
////
////  List<String> getSurnameValidationErrors(String surname) {
////    List<String> errors = [];
////
////    if (surname.length < 1) {
////      errors.add("Введите фамилию");
////    }
////
////    if (surname.length > 25) {
////      errors.add("Максимальная длина 25 символов");
////    }
////
////    RegExp allowedSymbols = RegExp(r'^[a-zA-Zа-яА-ЯёЁ]{1,25}$');
////    if (!allowedSymbols.hasMatch(surname)) {
////      errors.add("Может состоять из букв латинского и русского алфавитов");
////    }
////
////    return errors;
////  }
////
////  List<String> getPhoneValidationErrors(String phone) {
////    List<String> errors = [];
////
////    RegExp allowedNumbers = RegExp(r'^[+0-9][0-9]{11}$');
////    if (phone != "" && !allowedNumbers.hasMatch(phone)) {
////      errors.add("Должен состоять из 11 или 12 цифр");
////    }
////
////    return errors;
////  }
//}