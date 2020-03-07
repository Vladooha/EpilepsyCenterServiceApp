import 'dart:math';

import 'package:frontend/bloc/user/userBloc.dart';
import 'package:frontend/model/user/user.dart';
import 'package:frontend/model/user/userMetainfo.dart';

abstract class UserBlocState {}


abstract class UserActionResult extends UserBlocState {
  final UserActionsType userActions;

  UserActionResult(this.userActions);
}

class Success extends UserActionResult {
  int rand;

  Success(UserActionsType userActions) : super(userActions) {
    rand = Random().nextInt(100000);
  }
}

class Error extends UserActionResult {
  List<UserActionErrors> errorList;

  Error(UserActionsType userActions, {this.errorList = const []}) : super(userActions);
}

class Loading extends UserActionResult {
  Loading(UserActionsType userActions) : super(userActions);
}


class UserData {
  final User user;
  final bool isCurrentUser;

  UserData(this.user, this.isCurrentUser);
}