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
  final PageController _pageController = PageController();
  final _authService = AuthService();
  
  DoctorProfile? _doctorProfile;
  bool _isLoading = true;
  bool _isEditing = false;
  int _currentPage = 0;
  
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
    _pageController.dispose();
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

  void _nextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDOB ?? DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDOB = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage("assets/images/overlay2.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // White overlay for readability
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white.withOpacity(.70),
          ),
          Column(
            children: [
              // AppBar
              SafeArea(
                child: AppBar(
                  title: Text(
                    'Profil Médecin',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  actions: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = !_isEditing;
                        });
                      },
                      icon: CustomIconWidget(
                        iconName: _isEditing ? 'close' : 'edit',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              // Body content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          // Circular page indicator
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildCircularPageIndicator(0),
                                SizedBox(width: 4.w),
                                _buildCircularPageIndicator(1),
                              ],
                            ),
                          ),
                          
                          // Form pages
                          Expanded(
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              children: [
                                _buildPersonalInfoPage(),
                                _buildProfessionalInfoPage(),
                              ],
                            ),
                          ),
                          
                          // Save button (only show when editing)
                          if (_isEditing)
                            Container(
                              padding: EdgeInsets.all(4.w),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                                    padding: EdgeInsets.symmetric(vertical: 2.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Enregistrer',
                                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularPageIndicator(int pageIndex) {
    return Container(
      width: 3.w,
      height: 3.w,
      decoration: BoxDecoration(
        color: _currentPage == pageIndex
            ? AppTheme.lightTheme.colorScheme.primary
            : AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations Personnelles',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 3.h),
          
          // Name
          _buildTextField(
            controller: _nameController,
            label: 'Prénom',
            icon: 'person',
          ),
          SizedBox(height: 2.h),
          
          // Lastname
          _buildTextField(
            controller: _lastnameController,
            label: 'Nom',
            icon: 'person',
          ),
          SizedBox(height: 2.h),
          
          // Email
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: 'email',
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 2.h),
          
          // Phone numbers row
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _phoneController,
                  label: 'Téléphone',
                  icon: 'phone',
                  keyboardType: TextInputType.phone,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildTextField(
                  controller: _phone2Controller,
                  label: 'Téléphone 2',
                  icon: 'phone',
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          
          // CNI
          _buildTextField(
            controller: _cniController,
            label: 'CNI',
            icon: 'badge',
          ),
          SizedBox(height: 2.h),
          
          // Gender
          _buildGenderDropdown(),
          SizedBox(height: 2.h),
          
          // Date of Birth
          _buildDateField(),
          SizedBox(height: 2.h),
          
          // Nationality
          _buildTextField(
            controller: _nationalityController,
            label: 'Nationalité',
            icon: 'flag',
          ),
          SizedBox(height: 2.h),
          
          // Place of Birth
          _buildTextField(
            controller: _pobController,
            label: 'Lieu de naissance',
            icon: 'location_on',
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations Professionnelles',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 3.h),
          
          // Federation ID and Doctor Number row
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _federationIdController,
                  label: 'ID Fédération',
                  icon: 'badge',
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildTextField(
                  controller: _doctorNoController,
                  label: 'Numéro Médecin',
                  icon: 'numbers',
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          
          // Speciality
          _buildTextField(
            controller: _specialityController,
            label: 'Spécialité',
            icon: 'medical_services',
          ),
          SizedBox(height: 3.h),
          
          // Status card
          if (_doctorProfile != null)
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: _doctorProfile!.doctorIsConfirmed
                    ? AppTheme.successLight.withOpacity(0.1)
                    : AppTheme.warningLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _doctorProfile!.doctorIsConfirmed
                      ? AppTheme.successLight
                      : AppTheme.warningLight,
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: _doctorProfile!.doctorIsConfirmed ? 'verified' : 'pending',
                    color: _doctorProfile!.doctorIsConfirmed
                        ? AppTheme.successLight
                        : AppTheme.warningLight,
                    size: 24,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statut du Compte',
                          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _doctorProfile!.doctorIsConfirmed
                              ? 'Compte confirmé et vérifié'
                              : 'En attente de confirmation',
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.primary,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.primary,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.primary,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.5),
            width: 1,
          ),
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: icon,
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 5.w,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Genre',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.primary,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.primary,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.primary,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.5),
            width: 1,
          ),
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: 'person',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 5.w,
          ),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'M', child: Text('Masculin')),
        DropdownMenuItem(value: 'F', child: Text('Féminin')),
      ],
      onChanged: _isEditing ? (value) {
        setState(() {
          _selectedGender = value!;
        });
      } : null,
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _isEditing ? _selectDate : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date de naissance',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppTheme.lightTheme.colorScheme.primary,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppTheme.lightTheme.colorScheme.primary,
              width: 1,
            ),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'calendar_today',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 5.w,
            ),
          ),
        ),
        child: Text(
          _selectedDOB != null
              ? '${_selectedDOB!.day}/${_selectedDOB!.month}/${_selectedDOB!.year}'
              : 'Sélectionner une date',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
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