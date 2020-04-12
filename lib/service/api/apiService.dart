import 'dart:convert';

import 'package:frontend/model/common/errorContainer.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SessionStatus {
  loadingCache, invalid, correct 
}

abstract class JsonEntity {
  Map<String, dynamic> toJson();
}

class JsonEntityWrapper extends JsonEntity {
  final Map<String, dynamic> _map;

  JsonEntityWrapper(this._map);

  @override
  Map<String, dynamic> toJson() => _map;
}

class WebApiResponseHolder {
  static const int errorStatusCodeEdge = 400;
  static const int unauthorizedStatusCode = 403;
  
  final http.Response httpResponse;
  final bool hasResponse;
  final bool isSuccessful;
  final bool isAuthorized;
  final error;


  WebApiResponseHolder({
    this.httpResponse,
    this.hasResponse = false,
    this.isSuccessful = false,
    this.isAuthorized = false,
    this.error = "Unknown error"});

  factory WebApiResponseHolder.fromHttpResponse(http.Response response, {bool parseResult = true}) {
    bool isSuccessful = response.statusCode < errorStatusCodeEdge;
    bool isAuthorized = response.statusCode != unauthorizedStatusCode;

    return WebApiResponseHolder(
        httpResponse: response,
        hasResponse: true,
        isSuccessful: isSuccessful,
        isAuthorized: isAuthorized);
  }

  factory WebApiResponseHolder.httpError([dynamic error]) {
    if (error != null) {
      return WebApiResponseHolder(error: error);
    }

    return WebApiResponseHolder();
  }

  Map<String, dynamic> get json {
    if (hasResponse) {
      return jsonDecode(utf8.decode(httpResponse.bodyBytes));
    }

    return null;
  }

  ErrorContainer get errorContainer {
    if (hasResponse && !isSuccessful) {
      return ErrorContainer.fromJson(
          jsonDecode(utf8.decode(httpResponse.bodyBytes)));
    }

    return null;
  }
}

class WebApiService {
  static const timeoutMs = 5000;

  static const host = "192.168.1.104:8080";
  static const apiRoot = "/api";
  static const signUpPath = "/user/sign-up";
  static const logInPath = "/user/log-in";
  static const refreshTokenPath = "/user/refresh-token";
  
  static const tokenHeader = "token-holder";
  static const refreshTokenHeader = "refresh-token-holder";
  static const tokenTimestampHeader = "token-timestamp";
  
  static const unauthorizedError = "403 Unauthorized";
  static const noSessionError = "No session";
  
  static const contentTypeHeader = "Content-Type"; 
  static const contentTypeHeaderValue = "application/json; charset=UTF-8";
  
  static const int maxConnectionRetries = 5;

  SharedPreferences _preferences;

  BehaviorSubject<SessionStatus> _sessionStatusController;
  Stream<SessionStatus> get sessionStatusStream =>
      _sessionStatusController.stream;

  static WebApiService _webApiService;

  factory WebApiService() {
    if (_webApiService == null) {
      _webApiService = WebApiService._init();
    }

    return _webApiService;
  }

  String token;
  String refreshToken;
  int tokenTimestamp;

  WebApiService._init() {
    _sessionStatusController = BehaviorSubject<SessionStatus>();

    SharedPreferences.getInstance()
      .then((preferences) async {
        _preferences = preferences;

        try {
          refreshToken = await preferences.get(refreshTokenHeader);

          if (refreshToken != null) {
            _refreshToken();
          } else {
            _sessionStatusController.sink.add(SessionStatus.invalid);
          }
        } catch (error) {
          _sessionStatusController.sink.add(SessionStatus.invalid);
        }
      });
  }

  Future<WebApiResponseHolder> logIn(JsonEntity user, {bool isNewUser = false}) async {
    String path = isNewUser ? signUpPath : logInPath;
    var loginResponse = await post(path, user, checkAuth: false);

    print("LogIn reponse: ${loginResponse.httpResponse.statusCode}");

    if (loginResponse.isSuccessful) {
      _updateTokens(loginResponse.httpResponse);
    }

    return loginResponse;
  }

  Future<WebApiResponseHolder> get(
      String contextPath,
      {
        Map<String, String> params,
        Map<String, String> customHeaders = const {},
        bool checkAuth = true
      }) async {
    var apiUrl = Uri.http(host, apiRoot + contextPath, params);
    var requestFunc = () {
      var headers = _createHeaders(checkAuth: checkAuth);
      headers.addAll(customHeaders);
      return http.get(
          apiUrl,
          headers: headers)
        .then((response) => WebApiResponseHolder.fromHttpResponse(response))
        .timeout(Duration(milliseconds: timeoutMs))
        .catchError((error) => WebApiResponseHolder.httpError(error));
    };
    
    return _doRepeatableRequest(requestFunc, checkAuth: checkAuth);
  }

  Future<WebApiResponseHolder> post(
      String contextPath,
      JsonEntity body,
      {
        Map<String, String> customHeaders = const {},
        bool checkAuth = true
      }) async {
    var apiUrl = Uri.http(host, apiRoot + contextPath);
    var requestFunc = () {
      var headers = _createHeaders(withContent: true, checkAuth: checkAuth);
      headers.addAll(customHeaders);
      return http.post(
          apiUrl,
          headers: headers,
          body: jsonEncode(body.toJson()))
        .then((response) => WebApiResponseHolder.fromHttpResponse(response))
        .timeout(Duration(milliseconds: timeoutMs))
        .catchError((error) => WebApiResponseHolder.httpError(error));
    };

    return _doRepeatableRequest(requestFunc, checkAuth: checkAuth);
  }

  Map<String, String> _createHeaders({bool withContent = false, bool checkAuth = true}) {
    var headers = <String, String> {};

    if (withContent) {
      headers[contentTypeHeader] = contentTypeHeaderValue;
    }

    if (checkAuth) {
      headers[tokenHeader] = token;
    }

    return headers;
  }

  Future<WebApiResponseHolder> _doRepeatableRequest(
      Future<WebApiResponseHolder> Function() requestFunc,
      {bool checkAuth = true}) async {
    WebApiResponseHolder response;
    for (int retryNum = 0; retryNum < maxConnectionRetries; retryNum++) {
      print("Repeatable request start...");
      response = await requestFunc.call();
      print("Repeatable request end");

      if (response.hasResponse) {
        if (checkAuth && !response.isAuthorized) {
          WebApiResponseHolder refreshResponse = await _refreshToken();

          if (refreshResponse.isSuccessful) {
            retryNum = 0;
            continue;
          } else {
            return refreshResponse;
          }
        }

        break;
      }
    }

    return response;
  }
  
  Future<WebApiResponseHolder> _refreshToken() async {
    WebApiResponseHolder refreshResponse = await _requestTokenRefresh();

    if (refreshResponse.isSuccessful) {
      _sessionStatusController.sink.add(SessionStatus.correct);
      
      _updateTokens(refreshResponse.httpResponse);
    } else {
      _sessionStatusController.sink.add(SessionStatus.invalid);
    }

    return refreshResponse;
  }
  
  Future<WebApiResponseHolder> _requestTokenRefresh() async {
    if (refreshToken != null) {
      var headers = {refreshTokenHeader: refreshToken};
      
      return get(refreshTokenPath, checkAuth: false, customHeaders: headers);
    } else {
      return WebApiResponseHolder.httpError(noSessionError);
    }
  }
  
  _updateTokens(http.Response response) {
    String tokenTimestampStr = response.headers[tokenTimestampHeader];
    var newTokenTimestamp = int.parse(tokenTimestampStr);

    if (tokenTimestamp == null || tokenTimestamp < newTokenTimestamp) {
      token = response.headers[tokenHeader];
      refreshToken = response.headers[refreshTokenHeader];
      tokenTimestamp = newTokenTimestamp;

      _preferences.setString(refreshTokenHeader, refreshToken);
    }
  }
}