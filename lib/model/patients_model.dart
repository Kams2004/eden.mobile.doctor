class PatientExam {
  final String patientName;
  final String examType;
  final double amount;
  final String date;

  PatientExam({
    required this.patientName,
    required this.examType,
    required this.amount,
    required this.date,
  });

  factory PatientExam.fromJson(Map<String, dynamic> json) {
    final entry = json.entries.first;
    final patientName = entry.key;
    final examData = entry.value as List;
    
    return PatientExam(
      patientName: patientName,
      examType: examData.isNotEmpty ? examData[0]?.toString() ?? '' : '',
      amount: examData.length > 1 ? (examData[1] as num?)?.toDouble() ?? 0.0 : 0.0,
      date: examData.length > 2 ? examData[2]?.toString() ?? '' : '',
    );
  }
}

class PatientsResponse {
  final double commission;
  final List<PatientExam> dataPatients;

  PatientsResponse({
    required this.commission,
    required this.dataPatients,
  });

  factory PatientsResponse.fromJson(Map<String, dynamic> json) {
    return PatientsResponse(
      commission: (json['commission'] as num?)?.toDouble() ?? 0.0,
      dataPatients: (json['data_patients'] as List?)
          ?.map((item) => PatientExam.fromJson(item))
          .toList() ?? [],
    );
  }
}