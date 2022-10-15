class User {
  String? password;
  bool? disabled = false;
  Map<String, dynamic> access = {};

  User({required this.password, Map<String, bool>? newAccess, this.disabled}) {
    access.addEntries(newAccess!.entries);
  }

  User.fromJson(Map<String, dynamic> json) {
    password = json['password'];
    access = json['access'];
    disabled = json['disabled'];
  }

  Map<String, dynamic>  toJson() {
    return {'password': password, 'access': access, 'disabled': disabled};
  }

  @override
  String toString() {
    return 'User(password: $password; access: $access; disabled?: $disabled)';
  }
}
