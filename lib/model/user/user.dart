import 'package:frontend/service/api/apiService.dart';

class User implements JsonEntity {
  String id;
  String email;
  String password;
  String name;
  String surname;
  List<String> roles = [];
  String phone;

  User(
    {
      this.id,
      this.email,
      this.password,
      this.name,
      this.surname,
      this.roles,
      this.phone
    });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'surname': surname,
      'roles': roles,
      'phone': phone
    };

    json.removeWhere((key, value) => value == null);

    return json;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id:       json['id'],
      email:    json['email'],
      password: json['password'],
      name:     json['name'],
      surname:  json['surname'],
      roles:    json['roles'],
      phone:    json['phone']
    );
  }
}