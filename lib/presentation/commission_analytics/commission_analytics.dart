import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/analytics_cards_widget.dart';
import './widgets/commission_chart_widget.dart';
import './widgets/commission_summary_card_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/period_selector_widget.dart';

class CommissionAnalytics extends StatefulWidget {
  const CommissionAnalytics({super.key});

  @override
  State<CommissionAnalytics> createState() => _CommissionAnalyticsState();
}

class _CommissionAnalyticsState extends State<CommissionAnalytics> {
  String _selectedPeriod = 'Mensuel';
  String _selectedChartType = 'earnings';
  Map<String, dynamic> _currentFilters = {
    'startDate': null,
    'endDate': null,
    'examinationTypes': <String>[],
    'paymentStatuses': <String>[],
  };
  bool _isLoading = false;
  DateTime _lastUpdated = DateTime.now();

  // Mock data for commission analytics
  final List<Map<String, dynamic>> _mockChartData = [
    {
      'period': 'Jan',
      'value': 12500.0,
      'patients': 45,
      'timing': 7,
    },
    {
      'period': 'Fév',
      'value': 15200.0,
      'patients': 52,
      'timing': 6,
    },
    {
      'period': 'Mar',
      'value': 18750.0,
      'patients': 68,
      'timing': 5,
    },
    {
      'period': 'Avr',
      'value': 16800.0,
      'patients': 61,
      'timing': 8,
    },
    {
      'period': 'Mai',
      'value': 21300.0,
      'patients': 74,
      'timing': 4,
    },
    {
      'period': 'Jun',
      'value': 19650.0,
      'patients': 69,
      'timing': 6,
    },
  ];

  final Map<String, dynamic> _mockAnalyticsData = {
    'averageCommissionPerPatient': 285.50,
    'averageCommissionTrend': 12.5,
    'paymentStatusBreakdown': {
      'billed': 156,
      'billedAmount': 44280.0,
      'unbilled': 23,
      'unbilledAmount': 6555.0,
      'pending': 12,
      'pendingAmount': 3420.0,
    },
    'topPerformingExaminations': [
      {
        'type': 'IRM Cérébrale',
        'count': 45,
        'totalCommission': 13500.0,
        'percentage': 85.0,
      },
      {
        'type': 'Scanner Thoracique',
        'count': 38,
        'totalCommission': 11400.0,
        'percentage': 72.0,
      },
      {
        'type': 'Échographie Abdominale',
        'count': 52,
        'totalCommission': 10400.0,
        'percentage': 65.0,
      },
      {
        'type': 'Mammographie',
        'count': 29,
        'totalCommission': 8700.0,
        'percentage': 55.0,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingState() : _buildContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Analyse des Commissions',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _showFilterBottomSheet,
          icon: CustomIconWidget(
            iconName: 'filter_list',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        IconButton(
          onPressed: _exportReport,
          icon: CustomIconWidget(
            iconName: 'file_download',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          Text(
            'Chargement des données...',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 1.h),
            PeriodSelectorWidget(
              selectedPeriod: _selectedPeriod,
              onPeriodChanged: _onPeriodChanged,
              onDatePickerTap: _showCustomDatePicker,
            ),
            CommissionSummaryCardWidget(
              totalCommission: _calculateTotalCommission(),
              percentageChange: _calculatePercentageChange(),
              period: _selectedPeriod,
            ),
            CommissionChartWidget(
              chartData: _getFilteredChartData(),
              chartType: _selectedChartType,
              onChartTypeChanged: _onChartTypeChanged,
            ),
            SizedBox(height: 2.h),
            AnalyticsCardsWidget(
              analyticsData: _mockAnalyticsData,
            ),
            SizedBox(height: 2.h),
            _buildLastUpdatedInfo(),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdatedInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primaryContainer
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'update',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Text(
            'Dernière mise à jour: ${_formatDateTime(_lastUpdated)}',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
    });
    _refreshData();
  }

  void _onChartTypeChanged(String chartType) {
    setState(() {
      _selectedChartType = chartType;
    });
  }

  void _showCustomDatePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
      locale: const Locale('fr', 'FR'),
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
        _currentFilters['startDate'] = picked.start;
        _currentFilters['endDate'] = picked.end;
      });
      _refreshData();
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        currentFilters: _currentFilters,
        onFiltersApplied: _onFiltersApplied,
      ),
    );
  }

  void _onFiltersApplied(Map<String, dynamic> filters) {
    setState(() {
      _currentFilters = filters;
    });
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _lastUpdated = DateTime.now();
    });
  }

  void _exportReport() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            SizedBox(height: 2.h),
            Text(
              'Génération du rapport...',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );

    // Simulate report generation
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CustomIconWidget(
                iconName: 'check_circle',
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text('Rapport exporté avec succès'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  double _calculateTotalCommission() {
    return _getFilteredChartData()
        .map((data) => data['value'] as double)
        .fold(0.0, (sum, value) => sum + value);
  }

  double _calculatePercentageChange() {
    final data = _getFilteredChartData();
    if (data.length < 2) return 0.0;

    final current = data.last['value'] as double;
    final previous = data[data.length - 2]['value'] as double;

    return ((current - previous) / previous) * 100;
  }

  List<Map<String, dynamic>> _getFilteredChartData() {
    // Apply filters to chart data
    List<Map<String, dynamic>> filteredData = List.from(_mockChartData);

    // Apply date range filter if set
    if (_currentFilters['startDate'] != null &&
        _currentFilters['endDate'] != null) {
      // In a real app, this would filter based on actual dates
      // For demo purposes, we'll return the same data
    }

    // Apply other filters as needed
    return filteredData;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} à ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
