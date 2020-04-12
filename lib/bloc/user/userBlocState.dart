import 'package:frontend/model/common/errorContainer.dart';
import 'package:frontend/model/user/user.dart';

abstract class UserBlocState {}

class UserLoading extends UserBlocState {}

class UserLoggedIn extends UserBlocState {
  final User user;

  UserLoggedIn(this.user);
}

class UserUnauthorized extends UserBlocState {
  ErrorContainer errorContainer;

  UserUnauthorized.fromErrorContainer(this.errorContainer);

  UserUnauthorized(error) {
    if (error is ErrorContainer) {
      errorContainer = error;
    } else {
      errorContainer = ErrorContainer(errorList: [error.toString()]);
    }
  }
}