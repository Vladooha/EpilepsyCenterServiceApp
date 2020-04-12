import 'dart:async';

import 'package:frontend/bloc/user/userBlocEvent.dart';
import 'package:frontend/bloc/user/userBlocState.dart';
import 'package:frontend/model/common/errorContainer.dart';
import 'package:frontend/model/user/user.dart';
import 'package:frontend/service/api/apiService.dart';
import 'package:frontend/service/ioc/abstractBloc.dart';
import 'package:rxdart/rxdart.dart';

class UserBloc extends AbstractBloc {
  static const BLOC_NAME = "user-bloc";

  @override
  String get name => BLOC_NAME;

  WebApiService webApiService;

  StreamController<UserBlocEvent> _eventController;
  StreamController<UserBlocState> _stateController;

  Sink<UserBlocEvent> get events => _eventController.sink;
  Stream<UserBlocState> get states => _stateController.stream.asBroadcastStream();

  @override
  bool init() {
    if (super.init()) {
      webApiService = WebApiService();

      _eventController = StreamController<UserBlocEvent>();
      _stateController = StreamController<UserBlocState>.broadcast();

      _eventController.stream.listen(_eventListener);

      return true;
    }

    return false;
  }

  _eventListener(UserBlocEvent event) {
    _stateController.sink.add(UserLoading());

    if (event is RestoreSession) {
      _restoreSession();
    } else if (event is LogInUser) {
      _logIn(event);
    } else if (event is SignUpUser) {
      _signUp(event);
    }
  }
  
  _restoreSession() async {
    _sendLoading();

    SessionStatus status = await webApiService.sessionStatusStream
        .lastWhere(
            (status) => [SessionStatus.correct, SessionStatus.invalid].contains(status));

    if (status == SessionStatus.correct) {
      print("Obtaining user...");
      webApiService.get("/user")
          .then(_parseUser)
          .then(_sendUser)
          .catchError(_sendError);
    } else if (status == SessionStatus.invalid) {
      _sendError("No session");
    }
  }



  /// Event processors

  _logIn(LogInUser event) {
    _sendLoading();

    webApiService.logIn(event.user)
        .then(_parseUser)
        .then(_sendUser)
        .catchError(_sendError);
  }

  _signUp(SignUpUser event) {
    _sendLoading();

    webApiService.logIn(event.user, isNewUser: true)
        .then(_parseUser)
        .then(_sendUser)
        .catchError(_sendError);
  }

  /// Helpers

  _parseUser(WebApiResponseHolder response) {
    if (response.isSuccessful) {
      return User.fromJson(response.json);
    } else {
      throw ErrorContainer.fromJson(response.json);
    }
  }

  _sendLoading() => _stateController.sink.add(UserLoading());

  _sendUser(user) => _stateController.sink.add(UserLoggedIn(user));

  _sendError(error) => _stateController.sink.add(UserUnauthorized(error));

  @override
  bool dispose() {
    if (super.dispose()) {
      _eventController.close();
      _stateController.close();

      return true;
    }

    return false;
  }
}