class ExamResult {
  final int id;
  final String code;
  final String type;
  final String patientName;
  final String patientMatricule;
  final String receivedDate;
  final String status;
  final bool isEmailSent;

  ExamResult({
    required this.id,
    required this.code,
    required this.type,
    required this.patientName,
    required this.patientMatricule,
    required this.receivedDate,
    required this.status,
    required this.isEmailSent,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      type: json['type'] ?? 'Laboratoire',
      patientName: json['patient_name'] ?? '',
      patientMatricule: json['patient_matricule'] ?? '',
      receivedDate: json['received_date'] ?? '',
      status: json['status'] ?? '',
      isEmailSent: json['is_email_sent'] ?? false,
    );
  }
}

class ResultDetail {
  final int id;
  final String name;
  final String test;
  final String patient;
  final String matriculePatient;
  final String requestor;
  final String doneBy;
  final String validatedBy;
  final String dateRequested;
  final String dateAnalysis;
  final String doneDate;
  final String validationDate;
  final String analytesSummary;
  final String state;

  ResultDetail({
    required this.id,
    required this.name,
    required this.test,
    required this.patient,
    required this.matriculePatient,
    required this.requestor,
    required this.doneBy,
    required this.validatedBy,
    required this.dateRequested,
    required this.dateAnalysis,
    required this.doneDate,
    required this.validationDate,
    required this.analytesSummary,
    required this.state,
  });

  factory ResultDetail.fromJson(Map<String, dynamic> json) {
    return ResultDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      test: json['test'] ?? '',
      patient: json['patient'] ?? '',
      matriculePatient: json['matricule_patient'] ?? '',
      requestor: json['requestor'] ?? '',
      doneBy: json['done_by'] ?? '',
      validatedBy: json['validated_by'] ?? '',
      dateRequested: json['date_requested'] ?? '',
      dateAnalysis: json['date_analysis'] ?? '',
      doneDate: json['done_date'] ?? '',
      validationDate: json['validation_date'] ?? '',
      analytesSummary: json['analytes_summary'] ?? '',
      state: json['state'] ?? '',
    );
  }
}

class ResultsResponse {
  final List<ExamResult> results;

  ResultsResponse({required this.results});

  factory ResultsResponse.fromJson(dynamic json) {
    if (json is List) {
      return ResultsResponse(
        results: json.map((item) => ExamResult.fromJson(item)).toList(),
      );
    } else if (json is Map<String, dynamic> && json.containsKey('Message')) {
      return ResultsResponse(results: []);
    }
    return ResultsResponse(results: []);
  }
}