import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/theme_service.dart';
import '../../patient-widgets/widgets/patient_sidebar.dart';
import '../../patient-widgets/widgets/professional_app_bar.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({Key? key}) : super(key: key);

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  Map<String, dynamic>? _patientData;
  String? _error;
  final ThemeService _themeService = ThemeService();
  
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadPatientProfile();
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _initializeControllers() {
    if (_patientData != null) {
      _controllers['PatientName'] = TextEditingController(text: _patientData!['PatientName'] ?? '');
      _controllers['PatientLastname'] = TextEditingController(text: _patientData!['PatientLastname'] ?? '');
      _controllers['PatientEmail'] = TextEditingController(text: _patientData!['PatientEmail'] ?? '');
      _controllers['PatientPhone'] = TextEditingController(text: _patientData!['PatientPhone'] ?? '');
      _controllers['PatientPhone2'] = TextEditingController(text: _patientData!['PatientPhone2'] ?? '');
      _controllers['PatientPOB'] = TextEditingController(text: _patientData!['PatientPOB'] ?? '');
      _controllers['PatientNat'] = TextEditingController(text: _patientData!['PatientNat'] ?? '');
      _controllers['PatientCNI'] = TextEditingController(text: _patientData!['PatientCNI'] ?? '');
      _controllers['PatientFederationID'] = TextEditingController(text: _patientData!['PatientFederationID'] ?? '');
    }
  }

  Future<void> _loadPatientProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final patientId = StorageService.patientId;
      final accessToken = StorageService.accessToken;

      if (patientId == null || accessToken == null) {
        throw Exception('Données d\'authentification manquantes');
      }

      final authService = AuthService();
      final response = await authService.getPatientProfile(patientId, accessToken);
      
      setState(() {
        _patientData = response;
        _isLoading = false;
      });
      _initializeControllers();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _handleLogout() {
    StorageService.clearData();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login-screen',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeService.isDarkMode ? Color(0xFF0F172A) : Colors.grey[50],
      drawer: Drawer(
        child: PatientSidebar(
          currentRoute: '/patient-profile',
          onLogout: _handleLogout,
        ),
      ),
      appBar: ProfessionalAppBar(
        title: 'Mon Profil',
        subtitle: 'Informations personnelles',
        showBackButton: false,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit, color: Colors.white, size: 5.w),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing) ...[
            IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 5.w),
              onPressed: () => setState(() => _isEditing = false),
            ),
            IconButton(
              icon: Icon(Icons.save, color: Colors.white, size: 5.w),
              onPressed: _saveProfile,
            ),
          ],
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: 5.w),
            onPressed: _loadPatientProfile,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/overlay2.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: _themeService.isDarkMode ? Color(0xFF0F172A).withOpacity(0.85) : Colors.white.withOpacity(0.85),
            ),
          ),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3B82F6),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 15.w,
              color: Colors.red,
            ),
            SizedBox(height: 2.h),
            Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 1.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: _loadPatientProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3B82F6),
                foregroundColor: Colors.white,
              ),
              child: Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            _buildProfileHeader(),
            SizedBox(height: 3.h),
            _buildPersonalInfo(),
            SizedBox(height: 3.h),
            _buildContactInfo(),
            SizedBox(height: 3.h),
            _buildMedicalInfo(),
            if (_isEditing) ...[
              SizedBox(height: 3.h),
              _buildSaveButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _themeService.isDarkMode ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 12.w,
            backgroundColor: Color(0xFF3B82F6),
            child: Icon(
              Icons.person,
              size: 12.w,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            '${_patientData?['PatientName'] ?? ''} ${_patientData?['PatientLastname'] ?? ''}',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: _themeService.isDarkMode ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Patient',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return _buildInfoCard(
      title: 'Informations Personnelles',
      icon: Icons.person_outline,
      children: [
        _buildEditableRow('Prénom', 'PatientName'),
        _buildEditableRow('Nom', 'PatientLastname'),
        _buildInfoRow('Date de naissance', _formatDate(_patientData?['PatientDOB'])),
        _buildEditableRow('Lieu de naissance', 'PatientPOB'),
        _buildEditableRow('Nationalité', 'PatientNat'),
        _buildEditableRow('CNI', 'PatientCNI'),
        _buildEditableRow('ID Fédération', 'PatientFederationID'),
      ],
    );
  }

  Widget _buildContactInfo() {
    return _buildInfoCard(
      title: 'Informations de Contact',
      icon: Icons.contact_phone_outlined,
      children: [
        _buildEditableRow('Email', 'PatientEmail'),
        _buildEditableRow('Téléphone principal', 'PatientPhone'),
        _buildEditableRow('Téléphone secondaire', 'PatientPhone2'),
      ],
    );
  }

  Widget _buildMedicalInfo() {
    return _buildInfoCard(
      title: 'Informations Médicales',
      icon: Icons.medical_information_outlined,
      children: [
        _buildInfoRow('Statut', _patientData?['patient_is_confirmed'] == true ? 'Confirmé' : 'En attente'),
        _buildInfoRow('Date de création', _formatDate(_patientData?['CreatedAt'])),
        _buildInfoRow('Dernière modification', _formatDate(_patientData?['ModifiedAt'])),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _themeService.isDarkMode ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Color(0xFF3B82F6),
                  size: 6.w,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isNotEmpty ? value : 'Non renseigné',
              style: TextStyle(
                fontSize: 14.sp,
                color: value.isNotEmpty ? (_themeService.isDarkMode ? Colors.white : Colors.black87) : (_themeService.isDarkMode ? Color(0xFF6B7280) : Colors.grey[400]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableRow(String label, String field) {
    if (!_isEditing) {
      return _buildInfoRow(label, _patientData?[field] ?? '');
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: _controllers[field],
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFF3B82F6)),
                ),
              ),
              style: TextStyle(
                fontSize: 14.sp,
                color: _themeService.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSaving
            ? SizedBox(
                height: 5.w,
                width: 5.w,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Sauvegarder les modifications',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isSaving = true);

      final patientId = StorageService.patientId;
      final accessToken = StorageService.accessToken;

      if (patientId == null || accessToken == null) {
        throw Exception('Données d\'authentification manquantes');
      }

      final updateData = <String, dynamic>{};
      _controllers.forEach((key, controller) {
        updateData[key] = controller.text;
      });

      final authService = AuthService();
      await authService.updatePatientProfile(patientId, updateData, accessToken);

      await _loadPatientProfile();
      setState(() => _isEditing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil mis à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}