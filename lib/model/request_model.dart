class RequestModel {
  final bool administration;
  final bool commission;
  final bool connection;
  final String email;
  final bool error;
  final String firstName;
  final String lastName;
  final String message;
  final bool revendicationExamen;
  final bool suggestion;

  RequestModel({
    required this.administration,
    required this.commission,
    required this.connection,
    required this.email,
    required this.error,
    required this.firstName,
    required this.lastName,
    required this.message,
    required this.revendicationExamen,
    required this.suggestion,
  });

  Map<String, dynamic> toJson() {
    return {
      'administration': administration,
      'commission': commission,
      'connection': connection,
      'email': email,
      'error': error,
      'first_name': firstName,
      'last_name': lastName,
      'message': message,
      'revendication_examen': revendicationExamen,
      'suggestion': suggestion,
    };
  }
}