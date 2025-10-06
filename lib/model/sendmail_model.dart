class SendMailRequest {
  final String federationId;

  SendMailRequest({required this.federationId});

  Map<String, dynamic> toJson() {
    return {
      'federation_id': federationId,
    };
  }
}

class SendMailResponse {
  final String message;
  final String userMail;
  final String username;

  SendMailResponse({
    required this.message,
    required this.userMail,
    required this.username,
  });

  factory SendMailResponse.fromJson(Map<String, dynamic> json) {
    return SendMailResponse(
      message: json['Message'],
      userMail: json['User_mail'],
      username: json['Username'],
    );
  }
}