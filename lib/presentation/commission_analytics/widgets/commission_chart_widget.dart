import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CommissionChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> chartData;
  final String chartType;
  final Function(String) onChartTypeChanged;

  const CommissionChartWidget({
    super.key,
    required this.chartData,
    required this.chartType,
    required this.onChartTypeChanged,
  });

  @override
  State<CommissionChartWidget> createState() => _CommissionChartWidgetState();
}

class _CommissionChartWidgetState extends State<CommissionChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartHeader(),
          SizedBox(height: 2.h),
          _buildChartTypeSelector(),
          SizedBox(height: 3.h),
          SizedBox(
            height: 30.h,
            child: _buildChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildChartHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Évolution des Commissions',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        GestureDetector(
          onTap: () => _showChartDetails(),
          child: CustomIconWidget(
            iconName: 'info_outline',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildChartTypeSelector() {
    final chartTypes = [
      {'key': 'earnings', 'label': 'Gains'},
      {'key': 'patients', 'label': 'Patients'},
      {'key': 'timing', 'label': 'Délais'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chartTypes.map((type) {
          final isSelected = widget.chartType == type['key'];
          return GestureDetector(
            onTap: () => widget.onChartTypeChanged(type['key'] as String),
            child: Container(
              margin: EdgeInsets.only(right: 2.w),
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primaryContainer
                    : AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Text(
                type['label'] as String,
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getHorizontalInterval(),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() < widget.chartData.length) {
                  return SideTitleWidget(
                    space: 8,
                    meta: meta,
                    child: Text(
                      widget.chartData[value.toInt()]['period'] as String,
                      style: AppTheme.lightTheme.textTheme.labelSmall,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _getHorizontalInterval(),
              reservedSize: 50,
              getTitlesWidget: (double value, TitleMeta meta) {
                return SideTitleWidget(
                  space: 8,
                  meta: meta,
                  child: Text(
                    _formatYAxisValue(value),
                    style: AppTheme.lightTheme.textTheme.labelSmall,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        minX: 0,
        maxX: (widget.chartData.length - 1).toDouble(),
        minY: 0,
        maxY: _getMaxY(),
        lineBarsData: [
          LineChartBarData(
            spots: _getSpots(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                AppTheme.lightTheme.colorScheme.primary,
                AppTheme.lightTheme.colorScheme.primary.withOpacity(0.7),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.lightTheme.colorScheme.primary
                      .withOpacity(0.3),
                  AppTheme.lightTheme.colorScheme.primary
                      .withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                return LineTooltipItem(
                  '${_formatTooltipValue(touchedSpot.y)}\n${widget.chartData[touchedSpot.x.toInt()]['period']}',
                  AppTheme.lightTheme.textTheme.labelSmall!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }


  List<FlSpot> _getSpots() {
    return widget.chartData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      double value = 0;

      switch (widget.chartType) {
        case 'earnings':
          value = (data['value'] as num).toDouble();
          break;
        case 'patients':
          value = (data['patients'] as num).toDouble();
          break;
        case 'timing':
          value = (data['timing'] as num).toDouble();
          break;
      }

      return FlSpot(index.toDouble(), value);
    }).toList();
  }

  double _getMaxY() {
    final spots = _getSpots();
    if (spots.isEmpty) return 100;

    final maxValue =
    spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    return (maxValue * 1.2).ceilToDouble();
  }

  double _getHorizontalInterval() {
    final maxY = _getMaxY();
    return maxY / 5;
  }

  String _formatYAxisValue(double value) {
    switch (widget.chartType) {
      case 'earnings':
        return '${(value / 1000).toStringAsFixed(0)}kfcfa';
      case 'patients':
        return value.toInt().toString();
      case 'timing':
        return '${value.toInt()}j';
      default:
        return value.toStringAsFixed(0);
    }
  }

  String _formatTooltipValue(double value) {
    switch (widget.chartType) {
      case 'earnings':
        return '${value.toStringAsFixed(0).replaceAll('.', ',')} fcfa';
      case 'patients':
        return '${value.toInt()} patients';
      case 'timing':
        return '${value.toInt()} jours';
      default:
        return value.toStringAsFixed(0);
    }
  }

  void _showChartDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Détails du Graphique',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: ListView.builder(
                itemCount: widget.chartData.length,
                itemBuilder: (context, index) {
                  final data = widget.chartData[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 1.h),
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primaryContainer
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data['period'] as String,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatTooltipValue(
                              (data['value'] as num).toDouble()),
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.primary,
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
      ),
    );
  }
}