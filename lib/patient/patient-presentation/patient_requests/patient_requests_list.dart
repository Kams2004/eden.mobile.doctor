import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../patient-widgets/widgets/patient_sidebar.dart';
import 'widgets/request_card.dart';
import 'widgets/new_request_dialog.dart';

class PatientRequestsList extends StatefulWidget {
  const PatientRequestsList({super.key});

  @override
  State<PatientRequestsList> createState() => _PatientRequestsListState();
}

class _PatientRequestsListState extends State<PatientRequestsList> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _filteredRequests = [];
  String _searchQuery = '';
  String _selectedStatus = 'Tous les Statuts';
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final authService = AuthService();
      final accessToken = StorageService.accessToken;
      final userId = StorageService.userId;
      
      if (accessToken == null || userId == null) {
        throw Exception('Données d\'authentification manquantes');
      }
      
      final requests = await authService.getPatientRequests(userId, accessToken);
      
      setState(() {
        _requests = requests;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> results = List.from(_requests);

    if (_searchQuery.isNotEmpty) {
      results = results.where((request) {
        final searchLower = _searchQuery.toLowerCase();
        return (request['message'] as String? ?? '').toLowerCase().contains(searchLower);
      }).toList();
    }

    if (_selectedStatus != 'Tous les Statuts') {
      results = results.where((request) {
        final isValid = request['valide'] == true;
        return _selectedStatus == 'Validé' ? isValid : !isValid;
      }).toList();
    }

    setState(() {
      _filteredRequests = results;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _onStatusChanged(String? status) {
    setState(() {
      _selectedStatus = status ?? 'Tous les Statuts';
    });
    _applyFilters();
  }

  void _showNewRequestDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NewRequestDialog(
        onRequestSubmitted: _loadRequests,
      ),
    );
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
      backgroundColor: Colors.grey[50],
      drawer: Drawer(
        child: PatientSidebar(
          currentRoute: '/patient-requests',
          onLogout: _handleLogout,
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Color(0xFF3B82F6)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Mes Requêtes Médicales',
          style: TextStyle(
            color: Color(0xFF3B82F6),
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),

      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildRequestsList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Rechercher des requêtes...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 5.w),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                  ),
                  items: ['Tous les Statuts', 'En Attente', 'Validé']
                      .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                      .toList(),
                  onChanged: _onStatusChanged,
                ),
              ),
              SizedBox(width: 3.w),
              ElevatedButton.icon(
                onPressed: _showNewRequestDialog,
                icon: Icon(Icons.add, size: 4.w),
                label: Text(
                  'Nouvelle',
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF64748B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 15.w, color: Colors.red),
            SizedBox(height: 2.h),
            Text('Erreur de chargement', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.red)),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: _loadRequests,
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF3B82F6), foregroundColor: Colors.white),
              child: Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_filteredRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.request_page_outlined, size: 15.w, color: Colors.grey[400]),
            SizedBox(height: 2.h),
            Text(
              _searchQuery.isNotEmpty ? 'Aucune requête trouvée' : 'Aucune requête',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.grey[600]),
            ),
            SizedBox(height: 1.h),
            Text(
              _searchQuery.isNotEmpty 
                  ? 'Essayez de modifier votre recherche'
                  : 'Vos requêtes médicales apparaîtront ici',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: _filteredRequests.length,
        itemBuilder: (context, index) {
          return RequestCard(
            request: _filteredRequests[index],
            onRequestUpdated: _loadRequests,
          );
        },
      ),
    );
  }
}