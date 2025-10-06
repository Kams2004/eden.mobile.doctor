class LoginRequest {
  final String username;
  final String password;
  final bool rememberMe;

  LoginRequest({
    required this.username,
    required this.password,
    required this.rememberMe,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'remember_me': rememberMe,
    };
  }
}

class Role {
  final int id;
  final String name;

  Role({
    required this.id,
    required this.name,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class UserData {
  final int id;
  final int doctorId;
  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final int? patientId;
  final String username;
  final List<Role> roles;

  UserData({
    required this.id,
    required this.doctorId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    this.patientId,
    required this.username,
    required this.roles,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      doctorId: json['doctor_id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      password: json['password'] ?? '',
      patientId: json['patient_id'],
      username: json['username'] ?? '',
      roles: (json['roles'] as List?)?.map((role) => Role.fromJson(role)).toList() ?? [],
    );
  }
}

class LoginResponse {
  final String accessToken;
  final UserData data;

  LoginResponse({
    required this.accessToken,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] ?? '',
      data: UserData.fromJson(json['data'] ?? {}),
    );
  }
}