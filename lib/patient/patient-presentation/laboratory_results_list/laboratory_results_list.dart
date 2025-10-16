import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../patient-widgets/widgets/patient_sidebar.dart';
import '../laboratory_result_detail/laboratory_result_detail.dart';

class LaboratoryResultsList extends StatefulWidget {
  const LaboratoryResultsList({super.key});

  @override
  State<LaboratoryResultsList> createState() => _LaboratoryResultsListState();
}

class _LaboratoryResultsListState extends State<LaboratoryResultsList> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _laboratoryResults = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLaboratoryResults();
  }

  Future<void> _loadLaboratoryResults() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final authService = AuthService();
      final accessToken = StorageService.accessToken;
      
      if (accessToken == null) {
        throw Exception('Token d\'accès manquant');
      }
      
      final results = await authService.getLaboratoryResults(accessToken);
      
      setState(() {
        _laboratoryResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Non disponible';
    try {
      // Handle different date formats
      DateTime date;
      if (dateString.contains('GMT') || dateString.contains('UTC')) {
        date = DateTime.parse(dateString);
      } else if (dateString.contains('/')) {
        final parts = dateString.split('/');
        if (parts.length == 3) {
          date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        } else {
          return 'Format invalide';
        }
      } else {
        date = DateTime.parse(dateString);
      }
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'Non disponible';
    }
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LaboratoryResultDetail(),
                settings: RouteSettings(arguments: result),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.5.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF3B82F6).withOpacity(0.1),
                            Color(0xFF3B82F6).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.science_outlined,
                        color: Color(0xFF3B82F6),
                        size: 5.w,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result['test'] ?? result['name'] ?? 'Analyse de laboratoire',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Code: ${result['name'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
                      decoration: BoxDecoration(
                        color: result['state'] == 'validated' 
                            ? Colors.green.withOpacity(0.1) 
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        result['state'] == 'validated' ? 'Validé' : 'En cours',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: result['state'] == 'validated' 
                              ? Colors.green[700] 
                              : Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildInfoColumn('Patient', result['patient'] ?? 'N/A'),
                          _buildInfoColumn('Date', _formatDate(result['date_analysis'])),
                        ],
                      ),
                      SizedBox(height: 1.5.h),
                      Row(
                        children: [
                          _buildInfoColumn('Demandeur', result['requestor'] ?? 'N/A'),
                          _buildInfoColumn('Validé par', result['validated_by'] ?? 'N/A'),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF3B82F6),
                      size: 4.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Voir les détails',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
          currentRoute: '/laboratory-results-list',
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
          'Résultats de Laboratoire',
          style: TextStyle(
            color: Color(0xFF3B82F6),
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF3B82F6)),
            onPressed: _loadLaboratoryResults,
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
          // Container(
          //   color: Colors.white.withOpacity(0.85),
          // ),
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF3B82F6),
                  ),
                )
              : _error != null
                  ? Center(
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
                            onPressed: _loadLaboratoryResults,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Réessayer'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadLaboratoryResults,
                      color: Color(0xFF3B82F6),
                      child: _laboratoryResults.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.science_outlined,
                                    size: 15.w,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'Aucun résultat disponible',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    'Vos résultats de laboratoire apparaîtront ici.',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey[500],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(4.w),
                              itemCount: _laboratoryResults.length,
                              itemBuilder: (context, index) {
                                return _buildResultCard(_laboratoryResults[index]);
                              },
                            ),
                    ),
        ],
      ),
    );
  }
}