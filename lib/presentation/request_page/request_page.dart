import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../model/request_model.dart';
import '../../model/request_response_model.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({Key? key}) : super(key: key);

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> with TickerProviderStateMixin {
  String selectedRequestType = '';
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  bool isSubmitting = false;
  bool isLoadingRequests = true;
  List<RequestResponse> allRequests = [];
  List<RequestResponse> filteredRequests = [];
  String selectedStatus = 'Statuts';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadRequests();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    try {
      setState(() {
        isLoadingRequests = true;
      });

      final doctorId = StorageService.doctorId;
      final accessToken = StorageService.accessToken;
      if (doctorId != null && accessToken != null) {
        final authService = AuthService();
        final requests = await authService.getRequests(doctorId, accessToken);
        
        setState(() {
          allRequests = requests;
          filteredRequests = requests;
          isLoadingRequests = false;
        });
      } else {
        setState(() {
          allRequests = [];
          filteredRequests = [];
          isLoadingRequests = false;
        });
      }
    } catch (e) {
      print('Error loading requests: $e');
      setState(() {
        allRequests = [];
        filteredRequests = [];
        isLoadingRequests = false;
      });
    }
  }

  void _filterRequests() {
    setState(() {
      filteredRequests = allRequests.where((request) {
        final matchesSearch = searchController.text.isEmpty ||
            request.message.toLowerCase().contains(searchController.text.toLowerCase()) ||
            request.requestType.toLowerCase().contains(searchController.text.toLowerCase());
        
        final matchesStatus = selectedStatus == 'Statuts' ||
            request.statusText == selectedStatus;
        
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar:
       AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
       child: IconButton(
  onPressed: () {
    Navigator.popAndPushNamed(context, '/dashboard');
  },
  icon: Icon(
    Icons.arrow_back_ios_new,
    color: Color(0xFF334155),
    size: 20,
  ),
),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.support_agent,
                color: Colors.white,
                size: 24,
              ),
            ),
            SizedBox(width: 3.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Centre de Requêtes',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Gestion des demandes',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Submit Request Section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.add_task,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nouvelle Requête',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Sélectionnez le type de demande',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    Padding(
                      padding: EdgeInsets.all(3.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Request Types
                          Column(
                            children: [
                              _buildProfessionalRequestTypeCard(
                                Icons.medical_information_outlined,
                                'Requête d\'état des patients',
                                'Demander un état ou un suivi spécifique concernant un ou plusieurs patients',
                                Color(0xFF10B981),
                                selectedRequestType == 'revendication_examen',
                                () => setState(() => selectedRequestType = 'revendication_examen'),
                              ),
                              SizedBox(height: 3.w),
                              _buildProfessionalRequestTypeCard(
                                Icons.error_outline,
                                'Erreur Système',
                                'Signaler une erreur technique ou un dysfonctionnement du système',
                                Color(0xFFEF4444),
                                selectedRequestType == 'error',
                                () => setState(() => selectedRequestType = 'error'),
                              ),
                              SizedBox(height: 3.w),
                              _buildProfessionalRequestTypeCard(
                                Icons.lightbulb_outline,
                                'Suggestion d\'amélioration',
                                'Proposer une amélioration ou une nouvelle fonctionnalité pour le système',
                                Color(0xFFF59E0B),
                                selectedRequestType == 'suggestion',
                                () => setState(() => selectedRequestType = 'suggestion'),
                              ),
                            ],
                          ),

                          SizedBox(height: 6.w),

                          // Details Section
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.description_outlined,
                                      color: Color(0xFF3B82F6),
                                      size: 20,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      'Détails de la Requête',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 3.w),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: detailsController,
                                    maxLines: 6,
                                    decoration: InputDecoration(
                                      hintText: 'Décrivez votre requête en détail...\n\nVeuillez inclure toutes les informations pertinentes pour nous aider à traiter votre demande efficacement.',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 14.sp,
                                        height: 1.5,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(4.w),
                                    ),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Color(0xFF334155),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 6.w),

                          // Submit Button
                          Container(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: selectedRequestType.isNotEmpty && detailsController.text.isNotEmpty && !isSubmitting
                                  ? _submitRequest
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: Color(0xFFE2E8F0),
                              ),
                              child: isSubmitting
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(width: 3.w),
                                        Text(
                                          'Envoi en cours...',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.send_rounded, size: 20),
                                        SizedBox(width: 2.w),
                                        Text(
                                          'Envoyer la Requête',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 6.w),

              // Sent Requests Section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.history,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Historique des Requêtes',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${filteredRequests.length} requête(s) trouvée(s)',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(3.w),
                      child: Column(
                        children: [
                          // Search and Filter Row
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: searchController,
                                    onChanged: (_) => _filterRequests(),
                                    decoration: InputDecoration(
                                      hintText: 'Rechercher des requêtes...',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 14.sp,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: Color(0xFF64748B),
                                        size: 20,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.w),
                                    ),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.w),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedStatus,
                                      isExpanded: true,
                                      icon: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Color(0xFF64748B),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedStatus = value!;
                                        });
                                        _filterRequests();
                                      },
                                      items: ['Statuts', 'En Attente', 'Approuvé', 'Rejeté']
                                          .map((status) => DropdownMenuItem(
                                                value: status,
                                                child: Text(
                                                  status,
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    color: Color(0xFF334155),
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 4.w),

                          // Requests List
                          isLoadingRequests
                              ? Container(
                                  height: 20.h,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          color: Color(0xFF3B82F6),
                                        ),
                                        SizedBox(height: 3.w),
                                        Text(
                                          'Chargement des requêtes...',
                                          style: TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : filteredRequests.isEmpty
                                  ? Container(
                                      height: 20.h,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(4.w),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF1F5F9),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Icon(
                                                Icons.inbox_outlined,
                                                size: 48,
                                                color: Color(0xFF94A3B8),
                                              ),
                                            ),
                                            SizedBox(height: 4.w),
                                            Text(
                                              'Aucune requête trouvée',
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF475569),
                                              ),
                                            ),
                                            SizedBox(height: 2.w),
                                            Text(
                                              'Vos requêtes apparaîtront ici',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Color(0xFF94A3B8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        ...filteredRequests.map((request) => _buildProfessionalRequestCard(request)),
                                      ],
                                    ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalRequestTypeCard(IconData icon, String title, String description, Color accentColor, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.05) : Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accentColor : Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isSelected ? accentColor.withOpacity(0.1) : Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? accentColor : Color(0xFF64748B),
                size: 24,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? accentColor : Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 1.w),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Color(0xFF64748B),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalRequestCard(RequestResponse request) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.w),
      decoration: BoxDecoration(
        color: Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: _getRequestTypeColor(request.requestType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getRequestTypeIcon(request.requestType),
                    color: _getRequestTypeColor(request.requestType),
                    size: 20,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.requestType,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      if (request.createdAt != null)
                        Text(
                          'Envoyé le ${_formatDate(request.createdAt!)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Color(0xFF64748B),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.statusText).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getStatusColor(request.statusText),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        request.statusText,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _getStatusColor(request.statusText),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            child: Text(
              request.message,
              style: TextStyle(
                fontSize: 14.sp,
                color: Color(0xFF475569),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRequestTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'revendication_examen':
      case 'requête d\'état des patients':
        return Icons.medical_information_outlined;
      case 'error':
      case 'erreur système':
        return Icons.error_outline;
      case 'suggestion':
        return Icons.lightbulb_outline;
      default:
        return Icons.help_outline;
    }
  }

  Color _getRequestTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'revendication_examen':
      case 'requête d\'état des patients':
        return Color(0xFF10B981);
      case 'error':
      case 'erreur système':
        return Color(0xFFEF4444);
      case 'suggestion':
        return Color(0xFFF59E0B);
      default:
        return Color(0xFF6B7280);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approuvé':
        return Color(0xFF10B981);
      case 'en attente':
        return Color(0xFFF59E0B);
      case 'rejeté':
        return Color(0xFFEF4444);
      default:
        return Color(0xFF6B7280);
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _submitRequest() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      final accessToken = StorageService.accessToken;
      final doctorId = StorageService.doctorId;
      
      if (accessToken == null || doctorId == null) {
        throw Exception('Données d\'authentification manquantes');
      }

      final authService = AuthService();
      final doctorProfile = await authService.getDoctorProfile(doctorId, accessToken);
      
      final request = RequestModel(
        administration: selectedRequestType == 'administration',
        commission: selectedRequestType == 'commission',
        connection: selectedRequestType == 'connection',
        email: doctorProfile.doctorEmail,
        error: selectedRequestType == 'error',
        firstName: doctorProfile.doctorName,
        lastName: doctorProfile.doctorLastname,
        message: detailsController.text,
        revendicationExamen: selectedRequestType == 'revendication_examen',
        suggestion: selectedRequestType == 'suggestion',
      );

      await authService.submitRequest(request);
      
      setState(() {
        selectedRequestType = '';
        detailsController.clear();
      });
      
      await _loadRequests();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 3.w),
              Text(
                'Requête envoyée avec succès',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(4.w),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Erreur lors de l\'envoi: $e',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(4.w),
        ),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }
}