import 'package:flutter/material.dart';
import '../patient/patient-presentation/patient_dashboard/patient_dashboard.dart';
import '../presentation/commission_analytics/commission_analytics.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/role_selection_screen/role_selection_screen.dart';
import '../presentation/sendmail_screen/sendmail_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/dashboard/dashboard.dart';
import '../presentation/patient_list/patient_list.dart';

class AppRoutes {
  // TODO: Add your routes here

  static const String initial = '/';
  static const String commissionAnalytics = '/commission-analytics';
  static const String splash = '/splash-screen';
  static const String roleSelection = '/role-selection';
  static const String sendMail = '/sendmail-screen';
  static const String login = '/login-screen';
  static const String dashboard = '/dashboard';
  static const String patientList = '/patient-list';
  static const String patientDashboard = '/patient-dashboard';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    commissionAnalytics: (context) => const CommissionAnalytics(),
    splash: (context) => const SplashScreen(),
    roleSelection: (context) => const RoleSelectionScreen(),
    sendMail: (context) => const SendMailScreen(),
    login: (context) => const LoginScreen(),
    dashboard: (context) => const Dashboard(),
    patientList: (context) => const PatientList(),
    patientDashboard: (context) => const PatientDashboard(),
    // TODO: Add your other routes here
  };
}