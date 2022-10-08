class User {
  String? login;
  String? password;
  Map<String, dynamic> access = {};

  User({required this.login, required this.password, Map<String, bool>? newAccess}) {
    access.addEntries(newAccess!.entries);
  }

  User.fromJson(Map<String, dynamic> json) {
    login = json['login'];
    password = json['password'];
    access = json['access'];
  }

  Map<String, dynamic>  toJson() {
    return {'login': login, 'password': password, 'access': access};
  }
}
