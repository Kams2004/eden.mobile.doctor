class StorageService {
  static String? _accessToken;
  static int? _userId;
  static String? _userRole;
  static int? _doctorId;

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

  static String? get accessToken => _accessToken;
  static int? get userId => _userId;
  static String? get userRole => _userRole;
  static int? get doctorId => _doctorId;

  static void clearData() {
    _accessToken = null;
    _userId = null;
    _userRole = null;
    _doctorId = null;
  }

  static bool get isLoggedIn => _accessToken != null;
}