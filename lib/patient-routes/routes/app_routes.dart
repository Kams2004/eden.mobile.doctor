import 'package:flutter/material.dart';

import '../../patient/patient-presentation/imagery_result_detail/imagery_result_detail.dart';
import '../../patient/patient-presentation/imagery_results_list/imagery_results_list.dart';
import '../../patient/patient-presentation/laboratory_result_detail/laboratory_result_detail.dart';
import '../../patient/patient-presentation/laboratory_results_list/laboratory_results_list.dart';
import '../../patient/patient-presentation/patient_dashboard/patient_dashboard.dart';
import '../../patient/patient-presentation/splash_screen/splash_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String patientDashboard = '/patient-dashboard';
  static const String laboratoryResultsList = '/laboratory-results-list';
  static const String imageryResultsList = '/imagery-results-list';
  static const String laboratoryResultDetail = '/laboratory-result-detail';
  static const String imageryResultDetail = '/imagery-result-detail';
  static const String prescriptionScanner = '/prescription-scanner';
  static const String prescriptionResults = '/prescription-results';
  static Map<String, WidgetBuilder> routes = {

  };
}
