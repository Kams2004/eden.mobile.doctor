import 'package:flutter/material.dart';
import '../patient/patient-presentation/patient_dashboard/patient_dashboard.dart';
import '../patient/patient-presentation/patient_profile/patient_profile_screen.dart';
import '../presentation/commission_analytics/commission_analytics.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/role_selection_screen/role_selection_screen.dart';
import '../presentation/sendmail_screen/sendmail_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/dashboard/dashboard.dart';
import '../presentation/patient_list/patient_list.dart';
import '../presentation/doctor_profile_screen/doctor_profile_screen.dart';
import '../presentation/results_page/results_page.dart';
import '../presentation/request_page/request_page.dart';
import '../patient/patient-presentation/patient_notifications/patient_notifications.dart';
import '../patient/patient-presentation/exploration_results_list/exploration_results_list.dart';
import '../patient/patient-presentation/prescription/prescription_page.dart';
import '../patient/patient-presentation/laboratory_results_list/laboratory_results_list.dart';
import '../patient/patient-presentation/imagery_results_list/imagery_results_list.dart';
import '../patient/patient-presentation/patient_requests/patient_requests_list.dart';
import '../patient/patient-presentation/shared_results_list/shared_results_list.dart';
import '../patient/patient-presentation/invoices/invoices_page.dart';

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
  static const String patientProfile = '/patient-profile';
  static const String doctorProfile = '/doctor-profile';
  static const String results = '/results';
  static const String requestPage = '/request-page';
  static const String patientNotifications = '/patient-notifications-settings';
  static const String explorationResults = '/exploration-results';
  static const String prescription = '/prescription';
  static const String laboratoryResults = '/laboratory-results-list';
  static const String imageryResults = '/imagery-results-list';
  static const String patientRequests = '/patient-requests';
  static const String sharedResults = '/patient-resultats-partages';
  static const String patientInvoices = '/patient-invoices';

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
    patientProfile: (context) => const PatientProfileScreen(),
    doctorProfile: (context) => const DoctorProfileScreen(),
    results: (context) => const ResultsPage(),
    requestPage: (context) => const RequestPage(),
    patientNotifications: (context) => PatientNotifications(),
    explorationResults: (context) => ExplorationResultsList(),
    prescription: (context) => PrescriptionPage(),
    laboratoryResults: (context) => LaboratoryResultsList(),
    imageryResults: (context) => ImageryResultsList(),
    patientRequests: (context) => PatientRequestsList(),
    sharedResults: (context) => SharedResultsList(),
    patientInvoices: (context) => InvoicesPage(),
    // TODO: Add your other routes here
  };
}