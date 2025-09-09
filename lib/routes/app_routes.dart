import 'package:flutter/material.dart';
import '../presentation/commission_analytics/commission_analytics.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/role_selection_screen/role_selection_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/dashboard/dashboard.dart';
import '../presentation/patient_list/patient_list.dart';

class AppRoutes {
  // TODO: Add your routes here

  static const String initial = '/';
  static const String commissionAnalytics = '/commission-analytics';
  static const String splash = '/splash-screen';
  static const String roleSelection = '/role-selection';
  static const String login = '/login-screen';
  static const String dashboard = '/dashboard';
  static const String patientList = '/patient-list';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    commissionAnalytics: (context) => const CommissionAnalytics(),
    splash: (context) => const SplashScreen(),
    roleSelection: (context) => const RoleSelectionScreen(),
    login: (context) => const LoginScreen(),
    dashboard: (context) => const Dashboard(),
    patientList: (context) => const PatientList(),
    // TODO: Add your other routes here
  };
}