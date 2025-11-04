import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/theme_service.dart';
import '../../../base_url/api_config.dart';
import '../../patient-widgets/widgets/patient_sidebar.dart';
import '../imagery_results_list/widgets/imagery_skeleton_loader.dart';
import '../../patient-widgets/widgets/professional_app_bar.dart';

class PrescriptionPage extends StatefulWidget {
  @override
  _PrescriptionPageState createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {
  List<Map<String, dynamic>> _prescriptions = [];
  List<Map<String, dynamic>> _filteredPrescriptions = [];
  bool _isLoading = true;
  String _selectedFilter = 'Tous';
  final AuthService _authService = AuthService();
  late ThemeService _themeService;

  @override
  void initState() {
    super.initState();
    _themeService = ThemeService();
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    try {
      final accessToken = StorageService.accessToken;
      if (accessToken != null) {
        final prescriptions = await _authService.getAllPrescriptions(accessToken);
        setState(() {
          _prescriptions = prescriptions;
          _applyFilter();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading prescriptions: $e');
    }
  }

  void _applyFilter() {
    setState(() {
      if (_selectedFilter == 'Tous') {
        _filteredPrescriptions = _prescriptions;
      } else if (_selectedFilter == 'Devis') {
        _filteredPrescriptions = _prescriptions.where((p) => p['demande_devis'] == true).toList();
      } else if (_selectedFilter == 'Pas de devis') {
        _filteredPrescriptions = _prescriptions.where((p) => p['demande_devis'] != true).toList();
      }
    });
  }

  Future<void> _deletePrescription(int prescriptionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer'),
        content: Text('Voulez-vous supprimer cette prescription?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final accessToken = StorageService.accessToken;
        if (accessToken != null) {
          await _authService.deletePrescription(prescriptionId, accessToken);
          _loadPrescriptions();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Prescription supprimée'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddPrescriptionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddPrescriptionBottomSheet(
        onPrescriptionAdded: _loadPrescriptions,
      ),
    );
  }

  void _showImagePreview(int prescriptionId) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(2.w),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 80.h,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  '${ApiConfig.baseUrl}/prescription/image/$prescriptionId',
                  fit: BoxFit.contain,
                  headers: {
                    'Authorization': 'Bearer ${StorageService.accessToken}',
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, size: 15.w, color: Colors.red),
                            SizedBox(height: 2.h),
                            Text('Impossible de charger l\'image', style: TextStyle(fontSize: 14.sp)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 2.h,
              right: 2.w,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 6.w,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Non disponible';
    try {
      DateTime date;
      if (dateString.contains('GMT')) {
        final parts = dateString.split(' ');
        if (parts.length >= 5) {
          final day = parts[1];
          final month = _getMonthNumber(parts[2]);
          final year = parts[3];
          final time = parts[4];
          final isoDate = '$year-${month.toString().padLeft(2, '0')}-${day.padLeft(2, '0')}T$time.000Z';
          date = DateTime.parse(isoDate);
        } else {
          throw FormatException('Invalid GMT date format');
        }
      } else {
        date = DateTime.parse(dateString);
      }
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'Date invalide';
    }
  }

  int _getMonthNumber(String monthName) {
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
    };
    return months[monthName] ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeService.isDarkMode ? Color(0xFF0F172A) : Colors.grey[50],
      drawer: Drawer(
        child: PatientSidebar(
          currentRoute: '/prescription',
          onLogout: () {},
        ),
      ),
      appBar: ProfessionalAppBar(
        title: 'Mes Prescriptions',
        subtitle: 'Gérez vos ordonnances',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: 5.w),
            onPressed: _loadPrescriptions,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: _themeService.isDarkMode ? Color(0xFF0F172A) : Colors.white,
              image: !_themeService.isDarkMode ? DecorationImage(
                image: AssetImage("assets/images/overlay2.jpeg"),
                fit: BoxFit.cover,
              ) : null,
            ),
          ),
          if (_themeService.isDarkMode)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E293B),
                  ],
                ),
              ),
            ),
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                color: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
                child: Row(
                  children: [
                    Text(
                      'Filtrer:', 
                      style: TextStyle(
                        fontSize: 14.sp, 
                        fontWeight: FontWeight.w600,
                        color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                      )
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['Tous', 'Devis', 'Pas de devis'].map((filter) {
                            final isSelected = _selectedFilter == filter;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                                _applyFilter();
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: 2.w),
                                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? Color(0xFF3B82F6) 
                                      : (_themeService.isDarkMode ? Color(0xFF374151) : Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected 
                                        ? Color(0xFF3B82F6) 
                                        : (_themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey[300]!),
                                  ),
                                ),
                                child: Text(
                                  filter,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected 
                                        ? Colors.white 
                                        : (_themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600]),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? ImagerySkeletonLoader(itemCount: 6)
                    : _filteredPrescriptions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long, size: 20.w, color: Colors.grey[400]),
                                SizedBox(height: 2.h),
                                Text(
                                  'Aucune prescription trouvée',
                                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(4.w),
                            itemCount: _filteredPrescriptions.length,
                            itemBuilder: (context, index) {
                              final prescription = _filteredPrescriptions[index];
                              return GestureDetector(
                                onTap: () => _showImagePreview(prescription['id']),
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 1.5.h),
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    color: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
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
                                                  child: Icon(Icons.receipt_long, color: Color(0xFF3B82F6), size: 5.w),
                                                ),
                                                SizedBox(width: 3.w),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        prescription['Sequence'] ?? 'N/A',
                                                        style: TextStyle(
                                                          fontSize: 14.sp,
                                                          fontWeight: FontWeight.bold,
                                                          color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                                                        ),
                                                      ),
                                                      Text(
                                                        _formatDate(prescription['Create_date']),
                                                        style: TextStyle(
                                                          fontSize: 13.sp,
                                                          color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                                                  decoration: BoxDecoration(
                                                    color: prescription['demande_devis'] == true ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    prescription['demande_devis'] == true ? 'Devis' : 'Pas de devis',
                                                    style: TextStyle(
                                                      fontSize: 11.sp,
                                                      color: prescription['demande_devis'] == true ? Colors.orange[700] : Colors.green[700],
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 2.w),
                                                IconButton(
                                                  onPressed: () => _deletePrescription(prescription['id']),
                                                  icon: Icon(Icons.delete_outline, color: Colors.red, size: 4.w),
                                                  padding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 1.h),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'Dr. ${prescription['NameDoctor'] ?? 'N/A'}',
                                                    style: TextStyle(
                                                      fontSize: 14.sp, 
                                                      fontWeight: FontWeight.w500,
                                                      color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'Ordre: ${prescription['OrdreDoctor'] ?? 'N/A'}',
                                                  style: TextStyle(
                                                    fontSize: 12.sp, 
                                                    color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (prescription['Description'] != null && prescription['Description'].toString().isNotEmpty) ...[
                                              SizedBox(height: 1.h),
                                              GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: Text('Description', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                                                      content: SingleChildScrollView(
                                                        child: Text(
                                                          prescription['Description'],
                                                          style: TextStyle(fontSize: 14.sp),
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context),
                                                          child: Text('Fermer', style: TextStyle(color: Color(0xFF3B82F6))),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  prescription['Description'],
                                                  style: TextStyle(
                                                    fontSize: 13.sp, 
                                                    color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 3.w),
                                      GestureDetector(
                                        onTap: () => _showImagePreview(prescription['id']),
                                        child: Container(
                                          width: 20.w,
                                          height: 20.w,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey[300]!),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              '${ApiConfig.baseUrl}/prescription/image/${prescription['id']}',
                                              fit: BoxFit.cover,
                                              headers: {
                                                'Authorization': 'Bearer ${StorageService.accessToken}',
                                              },
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[100],
                                                  child: Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey[400],
                                                    size: 8.w,
                                                  ),
                                                );
                                              },
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return Container(
                                                  color: Colors.grey[100],
                                                  child: Center(
                                                    child: CircularProgressIndicator(
                                                      color: Color(0xFF3B82F6),
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPrescriptionBottomSheet,
        backgroundColor: Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: Text('Ajouter Prescription'),
      ),
    );
  }
}

class AddPrescriptionBottomSheet extends StatefulWidget {
  final VoidCallback onPrescriptionAdded;

  const AddPrescriptionBottomSheet({Key? key, required this.onPrescriptionAdded}) : super(key: key);

  @override
  _AddPrescriptionBottomSheetState createState() => _AddPrescriptionBottomSheetState();
}

class _AddPrescriptionBottomSheetState extends State<AddPrescriptionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameDoctorController = TextEditingController();
  final _ordreDoctorController = TextEditingController();
  final _descriptionController = TextEditingController();
  late ThemeService _themeService;

  @override
  void initState() {
    super.initState();
    _themeService = ThemeService();
  }
  
  File? _selectedImage;
  bool _isLoading = false;
  bool _demandeDevis = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameDoctorController.dispose();
    _ordreDoctorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorDialog('Erreur lors de la sélection de l\'image: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorDialog('Erreur lors de la prise de photo: $e');
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Ajouter une image', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Color(0xFF3B82F6)),
                title: Text('Prendre une photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Color(0xFF3B82F6)),
                title: Text('Choisir depuis la galerie'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitPrescription() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      _showErrorDialog('Veuillez ajouter une image de l\'ordonnance');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final accessToken = StorageService.accessToken;
      if (accessToken == null) {
        throw Exception('Token d\'accès non trouvé');
      }

      final authService = AuthService();
      await authService.addPrescription(
        nameDoctor: _nameDoctorController.text.trim(),
        ordreDoctor: _ordreDoctorController.text.trim(),
        description: _descriptionController.text.trim(),
        demandeDevis: _demandeDevis,
        imageFile: _selectedImage!,
        accessToken: accessToken,
      );

      Navigator.pop(context);
      widget.onPrescriptionAdded();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Prescription ajoutée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showErrorDialog('Erreur lors de l\'envoi: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 6.w),
              SizedBox(width: 3.w),
              Text('Erreur', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.red)),
            ],
          ),
          content: Text(message, style: TextStyle(fontSize: 14.sp)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: 85.h,
        decoration: BoxDecoration(
          color: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: _themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: _themeService.isDarkMode ? Colors.white : Colors.black),
                  ),
                  Expanded(
                    child: Text(
                      'Nouvelle Prescription',
                      style: TextStyle(
                        fontSize: 16.sp, 
                        fontWeight: FontWeight.bold,
                        color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 12.w),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(6.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameDoctorController,
                        style: TextStyle(fontSize: 14.sp, color: _themeService.isDarkMode ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Nom du Médecin *',
                          labelStyle: TextStyle(fontSize: 14.sp, color: _themeService.isDarkMode ? Colors.white70 : Colors.black54),
                          hintText: 'Ex: Dr. Martin Dupont',
                          hintStyle: TextStyle(fontSize: 13.sp, color: _themeService.isDarkMode ? Colors.white38 : Colors.black38),
                          prefixIcon: Icon(Icons.person, color: Color(0xFF3B82F6)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: _themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFF3B82F6)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: _themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le nom du médecin est requis';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        controller: _ordreDoctorController,
                        style: TextStyle(fontSize: 14.sp, color: _themeService.isDarkMode ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Numéro d\'Ordre *',
                          labelStyle: TextStyle(fontSize: 14.sp, color: _themeService.isDarkMode ? Colors.white70 : Colors.black54),
                          hintText: 'Ex: 12345678',
                          hintStyle: TextStyle(fontSize: 13.sp, color: _themeService.isDarkMode ? Colors.white38 : Colors.black38),
                          prefixIcon: Icon(Icons.badge, color: Color(0xFF3B82F6)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: _themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFF3B82F6)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: _themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le numéro d\'ordre est requis';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        style: TextStyle(fontSize: 14.sp, color: _themeService.isDarkMode ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(fontSize: 14.sp, color: _themeService.isDarkMode ? Colors.white70 : Colors.black54),
                          hintText: 'Ajoutez des notes (optionnel)',
                          hintStyle: TextStyle(fontSize: 13.sp, color: _themeService.isDarkMode ? Colors.white38 : Colors.black38),
                          prefixIcon: Icon(Icons.description, color: Color(0xFF3B82F6)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: _themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFF3B82F6)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: _themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Checkbox(
                            value: _demandeDevis,
                            onChanged: (value) {
                              setState(() {
                                _demandeDevis = value ?? false;
                              });
                            },
                            activeColor: Color(0xFF3B82F6),
                          ),
                          Expanded(
                            child: Text(
                              'Demander un devis',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Photo de l\'Ordonnance *', 
                        style: TextStyle(
                          fontSize: 14.sp, 
                          fontWeight: FontWeight.w600,
                          color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                        )
                      ),
                      SizedBox(height: 1.h),
                      if (_selectedImage == null) ...[
                        GestureDetector(
                          onTap: _showImageSourceDialog,
                          child: Container(
                            width: double.infinity,
                            height: 15.h,
                            decoration: BoxDecoration(
                              color: Color(0xFF3B82F6).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xFF3B82F6).withOpacity(0.3)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 10.w, color: Color(0xFF3B82F6)),
                                SizedBox(height: 1.h),
                                Text('Ajouter une photo', style: TextStyle(fontSize: 12.sp, color: Color(0xFF3B82F6))),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          height: 15.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_selectedImage!, fit: BoxFit.cover),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _showImageSourceDialog,
                                icon: Icon(Icons.edit, size: 4.w),
                                label: Text('Changer'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Color(0xFF3B82F6),
                                  side: BorderSide(color: Color(0xFF3B82F6)),
                                ),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => setState(() => _selectedImage = null),
                                icon: Icon(Icons.delete, size: 4.w),
                                label: Text('Supprimer'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: BorderSide(color: Colors.red),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 2.h),
                      SizedBox(
                        width: double.infinity,
                        height: 6.h,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitPrescription,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 5.w,
                                      height: 5.w,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    ),
                                    SizedBox(width: 3.w),
                                    Text('Envoi en cours...', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                                  ],
                                )
                              : Text('Envoyer la Prescription', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}