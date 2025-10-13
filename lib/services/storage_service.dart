class StorageService {
  static String? _accessToken;
  static int? _userId;
  static String? _userRole;
  static int? _doctorId;
  static String? _doctorName;
  static String? _doctorLastname;

  static void setLoginData({
    required String accessToken,
    required int userId,
    required String userRole,
  }) {
    _accessToken = accessToken;
    _userId = userId;
    _userRole = userRole;
  }

  static void setDoctorId(int doctorId) {
    _doctorId = doctorId;
  }

  static void setDoctorInfo(String name, String lastname) {
    _doctorName = name;
    _doctorLastname = lastname;
  }

  static String? get accessToken => _accessToken;
  static int? get userId => _userId;
  static String? get userRole => _userRole;
  static int? get doctorId => _doctorId;
  static String? get doctorName => _doctorName;
  static String? get doctorLastname => _doctorLastname;

  static void clearData() {
    _accessToken = null;
    _userId = null;
    _userRole = null;
    _doctorId = null;
    _doctorName = null;
    _doctorLastname = null;
  }

  static bool get isLoggedIn => _accessToken != null;
}