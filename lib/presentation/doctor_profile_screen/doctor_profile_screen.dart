import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../model/doctor_profile_model.dart';
import '../../model/doctor_update_model.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final _authService = AuthService();
  
  DoctorProfile? _doctorProfile;
  bool _isLoading = true;
  bool _isEditing = false;
  
  // Form controllers
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phone2Controller = TextEditingController();
  final _cniController = TextEditingController();
  final _federationIdController = TextEditingController();
  final _doctorNoController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _pobController = TextEditingController();
  final _specialityController = TextEditingController();
  
  String _selectedGender = 'M';
  DateTime? _selectedDOB;

  @override
  void initState() {
    super.initState();
    _loadDoctorProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _phone2Controller.dispose();
    _cniController.dispose();
    _federationIdController.dispose();
    _doctorNoController.dispose();
    _nationalityController.dispose();
    _pobController.dispose();
    _specialityController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctorProfile() async {
    try {
      final accessToken = StorageService.accessToken;
      final doctorId = StorageService.doctorId;
      
      if (accessToken == null || doctorId == null) {
        throw Exception('Token d\'accès ou ID docteur manquant');
      }
      
      final profile = await _authService.getDoctorProfile(doctorId, accessToken);
      setState(() {
        _doctorProfile = profile;
        _populateControllers();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
    }
  }

  void _populateControllers() {
    if (_doctorProfile != null) {
      _nameController.text = _doctorProfile!.doctorName;
      _lastnameController.text = _doctorProfile!.doctorLastname;
      _emailController.text = _doctorProfile!.doctorEmail;
      _phoneController.text = _doctorProfile!.doctorPhone;
      _phone2Controller.text = _doctorProfile!.doctorPhone2 ?? '';
      _cniController.text = _doctorProfile!.doctorCNI;
      _federationIdController.text = _doctorProfile!.doctorFederationID;
      _doctorNoController.text = _doctorProfile!.doctorNO;
      _nationalityController.text = _doctorProfile!.doctorNat;
      _pobController.text = _doctorProfile!.doctorPOB;
      _specialityController.text = _doctorProfile!.speciality;
      final gender = _doctorProfile!.doctorGender.toUpperCase();
      _selectedGender = (gender == 'M' || gender == 'F') ? gender : 'M';
      
      // Parse DOB from GMT format
      try {
        final dobString = _doctorProfile!.doctorDOB;
        if (dobString.contains('GMT')) {
          _selectedDOB = DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(dobString.replaceAll(' GMT', ''));
        } else {
          _selectedDOB = DateTime.parse(dobString);
        }
      } catch (e) {
        _selectedDOB = null;
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF3B82F6)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mon Profil',
          style: TextStyle(
            color: Color(0xFF3B82F6),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit, color: Color(0xFF3B82F6)),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing) ...[
            IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: () => setState(() => _isEditing = false),
            ),
            IconButton(
              icon: Icon(Icons.save, color: Colors.green),
              onPressed: _saveProfile,
            ),
          ],
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
            color: Colors.white.withOpacity(0.7),
          ),
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF3B82F6),
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    children: [
                      _buildProfileHeader(),
                      SizedBox(height: 3.h),
                      _buildPersonalInfo(),
                      SizedBox(height: 3.h),
                      _buildContactInfo(),
                      SizedBox(height: 3.h),
                      _buildProfessionalInfo(),
                      if (_isEditing) ...[
                        SizedBox(height: 3.h),
                        _buildSaveButton(),
                      ],
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      DateTime date;
      if (dateString.contains('GMT')) {
        date = DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(dateString.replaceAll(' GMT', ''));
      } else {
        date = DateTime.parse(dateString);
      }
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
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
            '${_doctorProfile?.doctorName ?? ''} ${_doctorProfile?.doctorLastname ?? ''}',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
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
              _doctorProfile?.speciality ?? 'Médecin',
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
        _buildEditableRow('Prénom', _nameController, _doctorProfile?.doctorName ?? ''),
        _buildEditableRow('Nom', _lastnameController, _doctorProfile?.doctorLastname ?? ''),
        _buildInfoRow('Date de naissance', _formatDate(_doctorProfile?.doctorDOB)),
        _buildEditableRow('Lieu de naissance', _pobController, _doctorProfile?.doctorPOB ?? ''),
        _buildEditableRow('Nationalité', _nationalityController, _doctorProfile?.doctorNat ?? ''),
        _buildEditableRow('CNI', _cniController, _doctorProfile?.doctorCNI ?? ''),
        _buildInfoRow('Genre', _doctorProfile?.doctorGender == 'M' ? 'Masculin' : 'Féminin'),
      ],
    );
  }

  Widget _buildContactInfo() {
    return _buildInfoCard(
      title: 'Informations de Contact',
      icon: Icons.contact_phone_outlined,
      children: [
        _buildEditableRow('Email', _emailController, _doctorProfile?.doctorEmail ?? ''),
        _buildEditableRow('Téléphone principal', _phoneController, _doctorProfile?.doctorPhone ?? ''),
        _buildEditableRow('Téléphone secondaire', _phone2Controller, _doctorProfile?.doctorPhone2 ?? ''),
      ],
    );
  }

  Widget _buildProfessionalInfo() {
    return _buildInfoCard(
      title: 'Informations Professionnelles',
      icon: Icons.medical_information_outlined,
      children: [
        _buildEditableRow('ID Fédération', _federationIdController, _doctorProfile?.doctorFederationID ?? ''),
        _buildEditableRow('Numéro Médecin', _doctorNoController, _doctorProfile?.doctorNO ?? ''),
        _buildEditableRow('Spécialité', _specialityController, _doctorProfile?.speciality ?? ''),
        _buildInfoRow('Statut', _doctorProfile?.doctorIsConfirmed == true ? 'Confirmé' : 'En attente'),
        _buildInfoRow('Date de création', _formatDate(_doctorProfile?.createdAt)),
        _buildInfoRow('Dernière modification', _formatDate(_doctorProfile?.modifiedAt)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                  color: Colors.black87,
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
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isNotEmpty ? value : 'Non renseigné',
              style: TextStyle(
                fontSize: 14.sp,
                color: value.isNotEmpty ? Colors.black87 : Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableRow(String label, TextEditingController controller, String value) {
    if (!_isEditing) {
      return _buildInfoRow(label, value);
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
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFF3B82F6)),
                ),
              ),
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
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
        onPressed: _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Sauvegarder les modifications',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }



  void _saveProfile() async {
    try {
      final accessToken = StorageService.accessToken;
      final doctorId = _doctorProfile?.id;
      
      if (accessToken == null || doctorId == null) {
        throw Exception('Token d\'accès ou ID docteur manquant');
      }
      
      final dobFormatted = _selectedDOB != null 
          ? DateFormat('EEE, dd MMM yyyy HH:mm:ss').format(_selectedDOB!) + ' GMT'
          : _doctorProfile?.doctorDOB ?? '';
      
      final updateRequest = DoctorUpdateRequest(
        codeIdentification: _doctorProfile?.codeIdentification ?? '',
        doctorCNI: _cniController.text,
        doctorDOB: dobFormatted,
        doctorEmail: _emailController.text,
        doctorFederationID: _federationIdController.text,
        doctorGender: _selectedGender.toLowerCase(),
        doctorLastname: _lastnameController.text,
        doctorNO: _doctorNoController.text,
        doctorName: _nameController.text,
        doctorNat: _nationalityController.text,
        doctorPOB: _pobController.text,
        doctorPhone: _phoneController.text,
        doctorPhone2: _phone2Controller.text,
        speciality: _specialityController.text,
      );
      
      await _authService.updateDoctorProfile(doctorId, updateRequest, accessToken);
      
      // Update local data with the values from form
      if (_doctorProfile != null) {
        _doctorProfile = DoctorProfile(
          id: _doctorProfile!.id,
          codeIdentification: _doctorProfile!.codeIdentification,
          createdAt: _doctorProfile!.createdAt,
          doctorCNI: _cniController.text,
          doctorDOB: dobFormatted,
          doctorEmail: _emailController.text,
          doctorFederationID: _federationIdController.text,
          doctorGender: _selectedGender.toLowerCase(),
          doctorLastname: _lastnameController.text,
          doctorNO: _doctorNoController.text,
          doctorName: _nameController.text,
          doctorNat: _nationalityController.text,
          doctorPOB: _pobController.text,
          doctorPhone: _phoneController.text,
          doctorPhone2: _phone2Controller.text,
          modifiedAt: DateTime.now().toString(),
          speciality: _specialityController.text,
          doctorIsConfirmed: _doctorProfile!.doctorIsConfirmed,
          user: _doctorProfile!.user,
        );
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil enregistré avec succès'),
          backgroundColor: AppTheme.successLight,
        ),
      );
      
      setState(() {
        _isEditing = false;
      });
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sauvegarde: ${e.toString()}'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
    }
  }
}