class DoctorUpdateRequest {
  final String codeIdentification;
  final String doctorCNI;
  final String doctorDOB;
  final String doctorEmail;
  final String doctorFederationID;
  final String doctorGender;
  final String doctorLastname;
  final String doctorNO;
  final String doctorName;
  final String doctorNat;
  final String doctorPOB;
  final String doctorPhone;
  final String doctorPhone2;
  final String speciality;

  DoctorUpdateRequest({
    required this.codeIdentification,
    required this.doctorCNI,
    required this.doctorDOB,
    required this.doctorEmail,
    required this.doctorFederationID,
    required this.doctorGender,
    required this.doctorLastname,
    required this.doctorNO,
    required this.doctorName,
    required this.doctorNat,
    required this.doctorPOB,
    required this.doctorPhone,
    required this.doctorPhone2,
    required this.speciality,
  });

  Map<String, dynamic> toJson() {
    return {
      'Doctor': {
        'CodeIdentification': codeIdentification,
        'DoctorCNI': doctorCNI,
        'DoctorDOB': doctorDOB,
        'DoctorEmail': doctorEmail,
        'DoctorFederationID': doctorFederationID,
        'DoctorGender': doctorGender,
        'DoctorLastname': doctorLastname,
        'DoctorNO': doctorNO,
        'DoctorName': doctorName,
        'DoctorNat': doctorNat,
        'DoctorPOB': doctorPOB,
        'DoctorPhone': doctorPhone,
        'DoctorPhone2': doctorPhone2,
        'Speciality': speciality,
      }
    };
  }
}