class RequestResponse {
  final int id;
  final String message;
  final String email;
  final String firstName;
  final String lastName;
  final bool administration;
  final bool commission;
  final bool connection;
  final bool error;
  final bool revendicationExamen;
  final bool suggestion;
  final String? status;
  final String? createdAt;

  RequestResponse({
    required this.id,
    required this.message,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.administration,
    required this.commission,
    required this.connection,
    required this.error,
    required this.revendicationExamen,
    required this.suggestion,
    this.status,
    this.createdAt,
  });

  factory RequestResponse.fromJson(Map<String, dynamic> json) {
    return RequestResponse(
      id: json['id'] ?? 0,
      message: json['message'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      administration: json['administration'] ?? false,
      commission: json['commission'] ?? false,
      connection: json['connection'] ?? false,
      error: json['error'] ?? false,
      revendicationExamen: json['revendication_examen'] ?? false,
      suggestion: json['suggestion'] ?? false,
      status: json['status'],
      createdAt: json['created_at'],
    );
  }

  String get requestType {
    if (commission) return 'Commission';
    if (connection) return 'Connexion';
    if (error) return 'Erreur Système';
    if (administration) return 'Administration';
    if (revendicationExamen) return 'Requête d\'état des patients';
    if (suggestion) return 'Suggestion';
    return 'Autre';
  }

  String get statusText {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'En Attente';
      case 'approved':
        return 'Approuvé';
      case 'rejected':
        return 'Rejeté';
      default:
        return 'En Attente';
    }
  }
}