import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../patient-widgets/widgets/patient_sidebar.dart';
import 'widgets/exploration_card.dart';
import 'widgets/exploration_empty_state.dart';

class ExplorationResultsList extends StatefulWidget {
  const ExplorationResultsList({super.key});

  @override
  State<ExplorationResultsList> createState() => _ExplorationResultsListState();
}

class _ExplorationResultsListState extends State<ExplorationResultsList> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _explorationResults = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExplorationResults();
  }

  Future<void> _loadExplorationResults() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final authService = AuthService();
      final accessToken = StorageService.accessToken;
      
      if (accessToken == null) {
        throw Exception('Données d\'authentification manquantes');
      }
      
      final results = await authService.getExplorationResults(accessToken);
      
      setState(() {
        _explorationResults = results;
        _isLoading = false;
      });
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
      backgroundColor: Colors.grey[50],
      drawer: Drawer(
        child: PatientSidebar(
          currentRoute: '/exploration-results',
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
          'Résultats d\'Exploration',
          style: TextStyle(
            color: Color(0xFF3B82F6),
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF3B82F6)),
            onPressed: _loadExplorationResults,
          ),
        ],
      ),
      body: _buildResultsList(),
    );
  }

  Widget _buildResultsList() {
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
            Text(
              _error!,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: _loadExplorationResults,
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

    if (_explorationResults.isEmpty) {
      return ExplorationEmptyState(
        onRefresh: _loadExplorationResults,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadExplorationResults,
      child: ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: _explorationResults.length,
        itemBuilder: (context, index) {
          return ExplorationCard(
            exploration: _explorationResults[index],
          );
        },
      ),
    );
  }
}