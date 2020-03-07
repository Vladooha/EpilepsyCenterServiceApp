import 'dart:io';

import 'package:frontend/bloc/user/userBloc.dart';
import 'package:frontend/model/user/user.dart';

abstract class UserBlocEvent {}

class UserAction extends UserBlocEvent {
  final UserActionsType userActionType;
  final String email;
  final String password;
  final User user;
  // TODO: Remove
  final File avatar;

  UserAction(this.userActionType, {this.email, this.password, this.user, this.avatar});
}

class GetUser extends UserBlocEvent {
  final String id;
  
  GetUser({this.id});
}