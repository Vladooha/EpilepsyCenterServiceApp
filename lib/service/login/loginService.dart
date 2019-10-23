abstract class LoginService {
  bool isLogged();
  bool logIn(String login, String password);
  bool register(String login, String password);
  bool isValidLogin(String login);
  bool isValidPassword(String password);
  List<String> getLoginValidationErrors(String login);
  List<String> getPasswordValidationErrors(String password);
}