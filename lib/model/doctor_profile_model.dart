class DoctorProfile {
  final String? codeIdentification;
  final String? createdAt;
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
  final String? doctorPhone2;
  final String? modifiedAt;
  final String speciality;
  final bool doctorIsConfirmed;
  final int id;
  final int user;

  DoctorProfile({
    this.codeIdentification,
    this.createdAt,
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
    this.doctorPhone2,
    this.modifiedAt,
    required this.speciality,
    required this.doctorIsConfirmed,
    required this.id,
    required this.user,
  });

  factory DoctorProfile.fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      codeIdentification: json['CodeIdentification'],
      createdAt: json['CreatedAt'],
      doctorCNI: json['DoctorCNI'] ?? '',
      doctorDOB: json['DoctorDOB'] ?? '',
      doctorEmail: json['DoctorEmail'] ?? '',
      doctorFederationID: json['DoctorFederationID'] ?? '',
      doctorGender: json['DoctorGender'] ?? '',
      doctorLastname: json['DoctorLastname'] ?? '',
      doctorNO: json['DoctorNO'] ?? '',
      doctorName: json['DoctorName'] ?? '',
      doctorNat: json['DoctorNat'] ?? '',
      doctorPOB: json['DoctorPOB'] ?? '',
      doctorPhone: json['DoctorPhone'] ?? '',
      doctorPhone2: json['DoctorPhone2'],
      modifiedAt: json['ModifiedAt'],
      speciality: json['Speciality'] ?? '',
      doctorIsConfirmed: json['doctor_is_confirmed'] ?? false,
      id: json['id'] ?? 0,
      user: json['user'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
    };
  }
}