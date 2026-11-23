import 'user_model.dart';

class LoginRequestModel {
  final String email;
  final String password;

  const LoginRequestModel({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email.trim(),
        'password': password,
      };
}

class RegisterRequestModel {
  final String email;
  final String password;
  final String displayName;

  const RegisterRequestModel({
    required this.email,
    required this.password,
    required this.displayName,
  });

  Map<String, dynamic> toJson() => {
        'email': email.trim(),
        'password': password,
        'displayName': displayName.trim(),
      };
}

class AuthResponseModel {
  final UserModel user;
  final String token;

  const AuthResponseModel({
    required this.user,
    required this.token,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json),
      token: (json['token'] ?? '').toString(),
    );
  }
}
