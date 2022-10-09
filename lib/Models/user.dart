class User {
  String? password;
  Map<String, dynamic> access = {};

  User({required this.password, Map<String, bool>? newAccess}) {
    access.addEntries(newAccess!.entries);
  }

  User.fromJson(Map<String, dynamic> json) {
    password = json['password'];
    access = json['access'];
  }

  Map<String, dynamic>  toJson() {
    return {'password': password, 'access': access};
  }
}
