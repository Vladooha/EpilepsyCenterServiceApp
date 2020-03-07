import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/bloc/user/userBlocEvent.dart';
import 'package:frontend/bloc/user/userBlocState.dart';
import 'package:frontend/model/user/user.dart';
import 'package:frontend/model/user/userMetainfo.dart';
import 'package:frontend/model/user/userPrivate.dart';
import 'package:frontend/service/database/remoteStorageService.dart';
import 'package:frontend/service/database/remoteStorageServiceImpl.dart';
import 'package:frontend/service/ioc/abstractBloc.dart';
import 'package:frontend/service/ioc/blocContainerService.dart';
import 'package:frontend/service/validator/validatorService.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

enum UserActionsType {
  logIn,
  signUp,
  update,
  logOut
}

enum UserActionErrors {
  noConnection,
  incorrectEmailOrPassword,
  emailAlreadyInUse
}

class StreamException {}

class UserBloc extends AbstractBloc {
  static const String BLOC_NAME = "user-bloc";

  static const String USER_PUBLIC_PATH = "user-data-public";
  static const String USER_PRIVATE_PATH = "user-data-private";
  static const String USER_METAINFO_PATH = "user-metainfo";
  static const int TIMEOUT_MS = 3000;
  
  static ValidatorService validatorService = ValidatorService();

  @override
  String get name => BLOC_NAME;

  BehaviorSubject<UserBlocEvent> _eventListener;
  BehaviorSubject<UserActionResult> _userActionsController;
  BehaviorSubject<UserData> _userDataController;
  BehaviorSubject<UserData> _currentUserDataController;

  Sink<UserBlocEvent> get eventListener => _eventListener.sink;
  Stream<UserActionResult> get userActions =>
      _userActionsController.stream.asBroadcastStream();
  Stream<UserData> get userData =>
      _userDataController.stream.asBroadcastStream();
  UserData get lastUserData => _userDataController.value;
  Stream<UserData> get currentUserData =>
      _currentUserDataController.stream.asBroadcastStream();
  UserData get lastCurrentUserData => _currentUserDataController.value;

  User _cachedUser;

  User get cachedUser => _cachedUser;

  @override
  bool init() {
    print('[$BLOC_NAME]: init attemption...');

    if (super.init()) {
      print('[$BLOC_NAME]: init');

      _eventListener = BehaviorSubject<UserBlocEvent>();
      _userActionsController = BehaviorSubject<UserActionResult>();
      _userDataController = BehaviorSubject<UserData>();
      _currentUserDataController = BehaviorSubject<UserData>();

      _restoreSession();

      _eventListener.stream.listen(_eventToStateMapper);

      return true;
    }
    
    return false;
  }

  _eventToStateMapper(UserBlocEvent event) {
    if (event is UserAction) {
      print('[$BLOC_NAME]: Incoming event - ${event.runtimeType}');
      _processUserAction(event);
    } else if (event is GetUser) {
      print('[$BLOC_NAME]: Incoming event - ${event.runtimeType}, id: ${event.id}');
      _getUser(id: event.id);
    }
  }

  _processUserAction(UserAction action) {
    if (action != null && action.userActionType != null) {
      var actionType = action.userActionType;

      if (actionType == UserActionsType.signUp) {
        _signUp(action.email, action.password, action.user, avatar: action.avatar);
      } else if (actionType == UserActionsType.logIn) {
        _logIn(action.email, action.password);
      } else if (actionType == UserActionsType.update) {
        _updateUser(action.user);
      } else if (actionType == UserActionsType.logOut) {
        _logOut();
      }
    }
  }

  Future<User> _getUser({String id}) async {
    User user = await _getRemoteUser(id: id);

    if (user != null) {
      bool isCurrentUser = await _isCurrentUser(user.id);
      if (isCurrentUser) {
        user.privateInfo = await _getRemoteUserPrivate(id: id);
        user.metainfo = await _getRemoteUserMetainfo(id: id);
        user.firebaseUser = await FirebaseAuth.instance.currentUser();
      }

      _cacheUserIfNeeded(user);
      _sendUserData(user, isCurrentUser);
    } else {
      _sendUserData(null, false);
    }

    return user;
  }

  Future<User> _getRemoteUser({String id}) async {
    if (cachedUser != null || id != null) {
      return Firestore.instance
          .collection(USER_PUBLIC_PATH)
          .document(id ?? cachedUser.id)
          .get()
          .then((userSnapshot) => _mapSnapshotToUser(userSnapshot));
    }
  }

  Future<UserPrivate> _getRemoteUserPrivate({String id}) {
    if (cachedUser != null || id != null) {
      return Firestore.instance
          .collection(USER_PRIVATE_PATH)
          .document(id ?? cachedUser.id)
          .get()
          .then((snapshot) => _mapSnapshotToUserPrivate(snapshot));
    }
  }

  Future<UserMetainfo> _getRemoteUserMetainfo({String id}) {
    if (cachedUser != null || id != null) {
      return Firestore.instance
          .collection(USER_METAINFO_PATH)
          .document(id ?? cachedUser.id)
          .get()
          .then((snapshot) => _mapSnapshotToUserMetainfo(snapshot));
    }
  }

  _signUp(String email, String password, User user, {File avatar}) {
    UserActionsType action = UserActionsType.signUp;
    _sendActionLoading(action);

    bool isValidEmail =
      validatorService.isFieldValid(ValidatableFields.email, email);
    bool isValidPassword =
      validatorService.isFieldValid(ValidatableFields.password, password);

    if (isValidEmail && isValidPassword && user != null) {
        _signUpFirebaseUser(
            email,
            password,
            mainAction: action)
          .then((firebaseUser) =>
            _logInFirebaseUser(
              email,
              password,
              mainAction: action))
          .then((firebaseUser) {
            _updateRemoteUser(
              user,
              refreshId: firebaseUser.uid,
              mainAction: action);

            return user;
          })
          .then((user) {
            _sendUserData(user, true);

            return user;
          })
          .then((user) async {
            if (avatar != null) {
              var remoteStorage = GetIt.instance.get<RemoteStorageService>();
              String fileName = "avatar";
              await remoteStorage.uploadFile(avatar, fileName: fileName);
              String avatarUrl = await remoteStorage.getFileUrl(fileName);

              user.avatarUrl = avatarUrl;
            }

            return user;
          })
          .then((user) {
            _updateRemoteUser(
                user,
                refreshId: user.id,
                mainAction: action);

            return user;
          })
          .then((user) {
            user.updateAvatar();
            _sendUserData(user, true);

            return user;
          })
          .then((nothing) => _sendActionSuccess(UserActionsType.signUp));
    } else {
      _sendActionError(
          UserActionsType.signUp,
          errorList: [UserActionErrors.incorrectEmailOrPassword]);
    }
  }

  _logIn(String email, String password) {
    UserActionsType action = UserActionsType.logIn;
    _sendActionLoading(action);

    bool isValidEmail =
      validatorService.isFieldValid(ValidatableFields.email, email);
    bool isValidPassword =
      validatorService.isFieldValid(ValidatableFields.password, password);

    if (isValidEmail && isValidPassword) {
      _logInFirebaseUser(
          email,
          password,
          mainAction: action)
        .then((firebaseUser) => _getUser(id: firebaseUser.uid))
        .then((nothing) => _sendActionSuccess(action));
    } else {
      _sendActionError(
          action,
          errorList: [UserActionErrors.incorrectEmailOrPassword]);
    }
  }

  _updateUser(User user) {
    UserActionsType action = UserActionsType.update;
    _sendActionLoading(action);

    if (user != null) {
      _updateRemoteUser(
          user,
          mainAction: action)
      .then((nothing) => _sendActionSuccess(action));
    } else {
      _sendActionError(action);
    }
  }

  _logOut() {
    BlocContainerService.instance.dispose(BLOC_NAME);
  }

  Future<FirebaseUser> _signUpFirebaseUser(String email, String password, {UserActionsType mainAction}) {
    print('[$BLOC_NAME]: FiresignUp with $email $password');

    return FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: email,
          password: password)
        .catchError((error) {
//          print('[$BLOC_NAME]: Firebase SignUp error - ${error.runtimeType}');
//
//          _sendActionLoading(mainAction ?? UserActionsType.signUp);
//
//          throw StreamException();
        }, test: _streamErrorTest)
        .then((authResult) => authResult.user)
        .catchError((error) {
          print('[$BLOC_NAME]: SignUp error - ${error.runtimeType}');

          _sendActionError(
              mainAction ?? UserActionsType.signUp,
              errorList: [UserActionErrors.emailAlreadyInUse]);

          throw error;
        }, test: _streamErrorTest);
  }

  Future<FirebaseUser> _logInFirebaseUser(String email, String password, {UserActionsType mainAction}) {
    print('[$BLOC_NAME]: FireLogIn with $email $password');

    return FirebaseAuth.instance
        .signInWithEmailAndPassword(
          email: email,
          password: password)
        .catchError((error) {
//          print('[$BLOC_NAME]: Firebase SignUp error - ${error.runtimeType}');
//
//          _sendActionLoading(mainAction ?? UserActionsType.signUp);
//
//          throw StreamException();
        }, test: _streamErrorTest)
        .then((authResult) => authResult.user)
        .catchError((error) {
          print('[$BLOC_NAME]: LogIn error - ${error.runtimeType}');

          _sendActionError(mainAction ?? UserActionsType.logIn);

          throw error;
        }, test: _streamErrorTest);
  }

  _sendActionLoading(UserActionsType action) {
    print('[$BLOC_NAME]: Sending loading action - $action');

    _userActionsController.sink.add(Loading(action));
  }

  _sendActionError(UserActionsType action, {List<UserActionErrors> errorList}) {
    print('[$BLOC_NAME]: Sending error action - $action');

    _userActionsController.sink.add(
        Error(
            action,
            errorList: errorList
        )
    );
  }
  
  _sendActionSuccess(UserActionsType action) {
    print('[$BLOC_NAME]: Sending success action - $action');

    _userActionsController.sink.add(Success(action));
  }

  _sendUserData(User user, bool isCurrentUser) {
    print('[$BLOC_NAME]: Sending user - ${user?.id}, isCurrentUser - $isCurrentUser');

    _userDataController.sink.add(UserData(user, isCurrentUser));
    if (isCurrentUser) {
      _cachedUser = user;
      _currentUserDataController.sink.add(UserData(user, isCurrentUser));
    }
  }
  
  Future<void> _updateRemoteUser(User user, {String refreshId, UserActionsType mainAction}) async {
    print('[$BLOC_NAME]: FireUpdate with $refreshId');

    if (refreshId != null) {
      user.id = refreshId;
      user.privateInfo = user.privateInfo ?? UserPrivate(refreshId);
      user.privateInfo.id = refreshId;
    }

    var userPublicInfoRef = Firestore.instance
        .collection(USER_PUBLIC_PATH)
        .document(user.id);

    var userPrivateInfoRef = Firestore.instance
        .collection(USER_PRIVATE_PATH)
        .document(user.id);

    Map<String, dynamic> userInfo =
    _mapUserToSnapshot(user);

    Map<String, dynamic> userPrivateInfo =
    _mapUserPrivateToSnapshot(user.privateInfo);

    var batch = Firestore.instance.batch();
    batch.setData(userPublicInfoRef, userInfo);
    batch.setData(userPrivateInfoRef, userPrivateInfo);
    return batch.commit()
        .then((nothing) => _cacheUserIfNeeded(user))
        .catchError((error) {
          print('[$BLOC_NAME]: Update profile error - ${error.runtimeType}');

          _sendActionError(mainAction ?? UserActionsType.update);

          throw error;
        });
  }
  
  _cacheUserIfNeeded(User user) async {
    if (_cachedUser == null || await _isCurrentUser(user.id)) {
      _cachedUser = user;
    }
  }

  _clearUserCache() {
    _cachedUser = null;
  }

  Future<bool> _isCurrentUser(id) async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();

    return firebaseUser != null && firebaseUser.uid == id;
  }

  Future<bool> _isSessionExists() async {
    return (cachedUser != null) || (await _restoreSession());
  }

  Future<bool> _restoreSession() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();

    String id = null;
    if (firebaseUser != null) {
      print('[$BLOC_NAME]: Restored session - ${firebaseUser.uid}');

      id = firebaseUser.uid;
    }

    return _getUser(id: id)
        .then((user) => user != null);
  }

  @override
  bool dispose() {
    print('[$BLOC_NAME]: dispose attemption...');

    if (super.dispose()) {
      print('[$BLOC_NAME]: dispose');

      _eventListener.close();
      _userActionsController.close();
      _userDataController.close();
      
      _clearUserCache();
      FirebaseAuth.instance.signOut();
      
      return true;
    }
    
    return false;
  }

  bool _streamErrorTest(error) {
    return !(error is StreamException);
  }

  User _mapSnapshotToUser(DocumentSnapshot snapshot, { UserPrivate privateInfo }) {
    if (snapshot.exists) {
      return User(
          snapshot.data['id'],
          name:         snapshot.data['name'],
          surname:      snapshot.data['surname'],
          roles:        List<String>.from(snapshot.data['roles']),
          avatarUrl:    snapshot.data['avatarUrl'],
          privateInfo:  privateInfo
      );
    }

    return null;
  }

  UserPrivate _mapSnapshotToUserPrivate(DocumentSnapshot snapshot) {
    if (snapshot != null && snapshot.exists) {
      return UserPrivate(
          snapshot.data['id'],
          email: snapshot.data['email'],
          phone: snapshot.data['phone']
      );
    }

    return null;
  }

  UserMetainfo _mapSnapshotToUserMetainfo(DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      return UserMetainfo(
          id: snapshot.documentID,
          chats: List<String>.from(snapshot.data['chats'])
      );
    }

    return null;
  }

  Map<String, dynamic> _mapUserToSnapshot(User user) {
    if (user != null) {
      return {
        "id":         user.id,
        "name":       user.name,
        "surname":    user.surname,
        "roles":      user.roles,
        "avatarUrl":  user.avatarUrl
      };
    }

    return null;
  }

  Map<String, dynamic> _mapUserPrivateToSnapshot(UserPrivate user) {
    if (user != null) {
      return {
        "id":       user.id,
        "email":    user.email,
        "phone":    user.phone
      };
    }

    return null;
  }
}