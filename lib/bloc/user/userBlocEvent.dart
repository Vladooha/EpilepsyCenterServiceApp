import 'package:frontend/model/user/user.dart';

abstract class UserBlocEvent {}

class RestoreSession extends UserBlocEvent {}

class SignUpUser extends UserBlocEvent {
  final User user;

  SignUpUser(this.user);
}

class LogInUser extends UserBlocEvent {
  final User user;

  LogInUser(this.user);
}