import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/theme_service.dart';
import '../../patient-widgets/widgets/patient_sidebar.dart';
import '../imagery_results_list/widgets/imagery_skeleton_loader.dart';
import '../../patient-widgets/widgets/professional_app_bar.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _invoices = [];
  String? _error;
  String _filterType = 'all';
  late ThemeService _themeService;

  @override
  void initState() {
    super.initState();
    _themeService = ThemeService();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final authService = AuthService();
      final accessToken = StorageService.accessToken;
      final patientId = StorageService.patientId;
      
      if (accessToken == null || patientId == null) {
        throw Exception('Données d\'authentification manquantes');
      }
      
      final invoices = await authService.getPatientInvoices(patientId, accessToken);
      
      setState(() {
        _invoices = invoices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredInvoices() {
    switch (_filterType) {
      case 'paid':
        return _invoices.where((i) => i['state'] == 'paid').toList();
      case 'unpaid':
        return _invoices.where((i) => i['state'] != 'paid').toList();
      default:
        return _invoices;
    }
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterType = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF3B82F6) : (_themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Color(0xFF3B82F6) : (_themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey[300]!),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : (_themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> invoice) {
    final isPaid = invoice['state'] == 'paid';
    final amount = double.tryParse(invoice['amount_to_pay']?.toString() ?? '0') ?? 0.0;
    
    return Container(
      margin: EdgeInsets.only(bottom: 3.w),
      decoration: BoxDecoration(
        color: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: isPaid ? const Color.fromARGB(255, 255, 255, 255).withOpacity(0.3) : Colors.orange.withOpacity(0.3),
          width: 1,
        ),
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
          onTap: () => _showInvoiceDetails(invoice),
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
                        color: isPaid ? Color(0xFF3B82F6).withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isPaid ? Icons.check_circle_outline : Icons.pending_outlined,
                        color: isPaid ? Color(0xFF3B82F6) : Colors.orange,
                        size: 5.w,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invoice['invoice_number'] ?? 'N/A',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Réf: ${invoice['reference'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${amount.toStringAsFixed(0)} FCFA',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: isPaid ? Color(0xFF3B82F6).withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isPaid ? 'Payée' : 'En attente',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: isPaid ? Color(0xFF3B82F6) : Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 4.w,
                      color: Colors.grey[500],
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      _formatInvoiceDate(invoice['date']),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: _themeService.isDarkMode ? Color(0xFF6B7280) : Colors.grey[400],
                      size: 4.w,
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

  void _showInvoiceDetails(Map<String, dynamic> invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
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
                  color: Color(0xFF3B82F6),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      color: Colors.white,
                      size: 6.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Détails de la facture',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: AuthService().getInvoiceProducts(invoice['invoice_number'] ?? '', StorageService.accessToken ?? ''),
                  builder: (context, snapshot) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Numéro de facture', invoice['invoice_number'] ?? 'N/A'),
                          _buildDetailRow('Référence', invoice['reference'] ?? 'N/A'),
                          _buildDetailRow('Date', _formatInvoiceDate(invoice['date'])),
                          _buildDetailRow('Statut', invoice['state'] == 'paid' ? 'Payée' : 'En attente'),
                          
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) ...[
                            Divider(height: 3.h),
                            Text(
                              'Produits/Services',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            ...snapshot.data!.map((product) => Container(
                              margin: EdgeInsets.only(bottom: 1.h),
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color: _themeService.isDarkMode ? Color(0xFF374151) : Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      product['product_name']?.toString().trim() ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                        color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Qté: ${product['quantity']?.toString() ?? '1'}',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                          ] else if (snapshot.connectionState == ConnectionState.waiting) ...[
                            Divider(height: 3.h),
                            Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF3B82F6),
                                strokeWidth: 2,
                              ),
                            ),
                          ],
                          
                          Divider(height: 3.h),
                          Text(
                            'Montants',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          _buildDetailRow('Montant HT', '${(invoice['untaxed_amount'] ?? 0).toStringAsFixed(0)} FCFA'),
                          _buildDetailRow('Montant assurance', '${invoice['montant_assurance'] ?? '0'} FCFA'),
                          _buildDetailRow('Montant patient', '${(invoice['montant_patient'] ?? 0).toStringAsFixed(0)} FCFA'),
                          Divider(height: 2.h),
                          Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Montant à payer',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  '${(double.tryParse(invoice['amount_to_pay']?.toString() ?? '0') ?? 0).toStringAsFixed(0)} FCFA',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3B82F6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 35.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: _themeService.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatInvoiceDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Non disponible';
    try {
      DateTime date;
      if (dateString.contains('GMT')) {
        final parts = dateString.split(' ');
        if (parts.length >= 5) {
          final day = parts[1];
          final month = _getMonthNumber(parts[2]);
          final year = parts[3];
          date = DateTime(int.parse(year), month, int.parse(day));
        } else {
          return 'Date invalide';
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
          currentRoute: '/patient-invoices',
          onLogout: _handleLogout,
        ),
      ),
      appBar: ProfessionalAppBar(
        title: 'Mes Factures',
        subtitle: 'Gestion des paiements',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: 5.w),
            onPressed: _loadInvoices,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!_themeService.isDarkMode)
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/overlay2.jpeg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (!_themeService.isDarkMode)
            Container(
              color: Colors.white.withOpacity(0.7),
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
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ImagerySkeletonLoader(itemCount: 6);
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
              onPressed: _loadInvoices,
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

    final filteredInvoices = _getFilteredInvoices();

    return Column(
      children: [
        // Filter section
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
                  color: _themeService.isDarkMode ? Colors.white : Colors.grey[700],
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Toutes', 'all'),
                      SizedBox(width: 2.w),
                      _buildFilterChip('Payées', 'paid'),
                      SizedBox(width: 2.w),
                      _buildFilterChip('En attente', 'unpaid'),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_invoices.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Invoices list
        Expanded(
          child: filteredInvoices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 15.w,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _filterType == 'all' ? 'Aucune facture' :
                        _filterType == 'paid' ? 'Aucune facture payée' : 'Aucune facture en attente',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadInvoices,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    itemCount: filteredInvoices.length,
                    itemBuilder: (context, index) {
                      return _buildInvoiceCard(filteredInvoices[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }
}