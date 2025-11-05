import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/theme_service.dart';

class PointsListWidget extends StatefulWidget {
  final Map<String, dynamic> pointsData;
  final String selectedFilter;
  final DateTimeRange? selectedDateRange;
  final ThemeService themeService;

  const PointsListWidget({
    Key? key,
    required this.pointsData,
    required this.selectedFilter,
    required this.selectedDateRange,
    required this.themeService,
  }) : super(key: key);

  @override
  State<PointsListWidget> createState() => _PointsListWidgetState();
}

class _PointsListWidgetState extends State<PointsListWidget> {
  Map<String, bool> expandedPatients = {};

  @override
  Widget build(BuildContext context) {
    final groupedPatients = _getGroupedPatients();

    if (groupedPatients.isEmpty) {
      return Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: widget.themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 15.w,
              color: widget.themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey[400],
            ),
            SizedBox(height: 2.h),
            Text(
              'Aucun élément trouvé',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: widget.themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Aucun point ne correspond aux filtres sélectionnés',
              style: TextStyle(
                fontSize: 12.sp,
                color: widget.themeService.isDarkMode ? Color(0xFF6B7280) : Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Patients (${groupedPatients.length})',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: widget.themeService.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 2.h),
        ...groupedPatients.entries.map((entry) => _buildPatientGroup(entry.key, entry.value)).toList(),
      ],
    );
  }

  Map<String, List<Map<String, dynamic>>> _getGroupedPatients() {
    List<Map<String, dynamic>> allItems = [];

    // Add prescription items
    final prescriptions = widget.pointsData['prescription']?['data_prescription'] as List? ?? [];
    for (var prescription in prescriptions) {
      allItems.add({
        ...prescription,
        'type': 'prescription',
      });
    }

    // Add realisation items
    final realisations = widget.pointsData['realisation']?['data_realisation'] as List? ?? [];
    for (var realisation in realisations) {
      allItems.add({
        ...realisation,
        'type': 'realisation',
      });
    }

    // Apply type filters
    List<Map<String, dynamic>> filteredItems;
    switch (widget.selectedFilter) {
      case 'prescription':
        filteredItems = allItems.where((item) => item['type'] == 'prescription').toList();
        break;
      case 'realisation':
        filteredItems = allItems.where((item) => item['type'] == 'realisation').toList();
        break;
      case 'validated':
        filteredItems = allItems.where((item) => item['Validé'] == true).toList();
        break;
      case 'pending':
        filteredItems = allItems.where((item) => item['Validé'] == false).toList();
        break;
      default:
        filteredItems = allItems;
    }

    // Apply date range filter
    if (widget.selectedDateRange != null) {
      filteredItems = filteredItems.where((item) {
        try {
          final itemDate = _parseItemDate(item['Date']);
          if (itemDate != null) {
            return itemDate.isAfter(widget.selectedDateRange!.start.subtract(Duration(days: 1))) &&
                   itemDate.isBefore(widget.selectedDateRange!.end.add(Duration(days: 1)));
          }
        } catch (e) {
          print('Error filtering by date: $e');
        }
        return false;
      }).toList();
    }

    // Group by patient
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in filteredItems) {
      final patientName = item['Patient'] ?? 'Patient inconnu';
      if (!grouped.containsKey(patientName)) {
        grouped[patientName] = [];
      }
      grouped[patientName]!.add(item);
    }

    return grouped;
  }

  Widget _buildPatientGroup(String patientName, List<Map<String, dynamic>> items) {
    final isExpanded = expandedPatients[patientName] ?? false;
    final totalAmount = items.fold<double>(0, (sum, item) => sum + (double.tryParse(item['Montant']?.toString() ?? '0') ?? 0));
    
    return Container(
      margin: EdgeInsets.only(bottom: 3.w),
      decoration: BoxDecoration(
        color: widget.themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                expandedPatients[patientName] = !isExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.person,
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
                          patientName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: widget.themeService.isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          '${items.length} examen${items.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: widget.themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${totalAmount.toString()} FCFA',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: widget.themeService.isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: widget.themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(
              color: widget.themeService.isDarkMode ? Color(0xFF374151) : Colors.grey[200],
              height: 1,
            ),
            ...items.map((item) => _buildPointItem(item)).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildPointItem(Map<String, dynamic> item) {
    final isPrescription = item['type'] == 'prescription';
    final isValidated = item['Validé'] == true;
    final amount = double.tryParse(item['Montant']?.toString() ?? '0') ?? 0.0;

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: isPrescription 
                      ? Color(0xFF10B981).withOpacity(0.1)
                      : Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isPrescription ? Icons.receipt_long : Icons.medical_services,
                  color: isPrescription ? Color(0xFF10B981) : Color(0xFF8B5CF6),
                  size: 4.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPrescription ? 'Prescription' : 'Réalisation',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: isPrescription ? Color(0xFF10B981) : Color(0xFF8B5CF6),
                      ),
                    ),
                    Text(
                      item['Examen'] ?? 'Examen non spécifié',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: widget.themeService.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${amount.toString()} FCFA',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: widget.themeService.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: isValidated 
                          ? Color(0xFF10B981).withOpacity(0.1)
                          : Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isValidated ? 'Facturé' : 'Non facturé',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: isValidated ? Color(0xFF10B981) : Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 4.w,
                color: widget.themeService.isDarkMode ? Color(0xFF6B7280) : Colors.grey[500],
              ),
              SizedBox(width: 2.w),
              Text(
                _formatDate(item['Date']),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: widget.themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                ),
              ),
              Spacer(),
              if (item['Produit'] != null) ...[
                Icon(
                  Icons.label,
                  size: 4.w,
                  color: widget.themeService.isDarkMode ? Color(0xFF6B7280) : Colors.grey[500],
                ),
                SizedBox(width: 1.w),
                Flexible(
                  child: Text(
                    item['Produit'],
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: widget.themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Date inconnue';
    try {
      DateTime date;
      
      // Handle RFC 2822 format: "Wed, 22 Oct 2025 00:00:00 GMT"
      if (dateString.contains(',') && (dateString.contains('GMT') || dateString.contains('Jan') || dateString.contains('Feb') || dateString.contains('Mar') || dateString.contains('Apr') || dateString.contains('May') || dateString.contains('Jun') || dateString.contains('Jul') || dateString.contains('Aug') || dateString.contains('Sep') || dateString.contains('Oct') || dateString.contains('Nov') || dateString.contains('Dec'))) {
        date = _parseRFC2822Date(dateString);
      } else if (dateString.contains('T')) {
        // ISO format: "2025-08-21T00:00:00.000Z"
        date = DateTime.parse(dateString);
      } else if (dateString.contains('/')) {
        // Format: "21/08/2025" or "08/21/2025"
        final parts = dateString.split('/');
        if (parts.length == 3) {
          date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        } else {
          throw FormatException('Invalid date format');
        }
      } else if (dateString.contains('-')) {
        // Format: "2025-08-21"
        date = DateTime.parse(dateString);
      } else {
        // Try direct parsing
        date = DateTime.parse(dateString);
      }
      
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      print('Date parsing error for "$dateString": $e');
      return 'Date invalide';
    }
  }

  DateTime _parseRFC2822Date(String dateString) {
    // Parse "Wed, 22 Oct 2025 00:00:00 GMT" format
    final monthMap = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
    };
    
    try {
      // Remove GMT and comma, then split by spaces
      final cleaned = dateString.replaceAll('GMT', '').replaceAll(',', '').trim();
      final parts = cleaned.split(' ').where((part) => part.isNotEmpty).toList();
      
      if (parts.length >= 4) {
        // parts[0] = "Wed", parts[1] = "22", parts[2] = "Oct", parts[3] = "2025"
        final day = int.parse(parts[1]);
        final monthStr = parts[2];
        final year = int.parse(parts[3]);
        final month = monthMap[monthStr];
        
        if (month != null) {
          return DateTime(year, month, day);
        }
      }
    } catch (e) {
      print('Error parsing RFC2822 parts: $e');
    }
    
    throw FormatException('Unable to parse RFC2822 date: $dateString');
  }

  DateTime? _parseItemDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      DateTime date;
      
      // Handle RFC 2822 format: "Wed, 22 Oct 2025 00:00:00 GMT"
      if (dateString.contains(',') && (dateString.contains('GMT') || dateString.contains('Jan') || dateString.contains('Feb') || dateString.contains('Mar') || dateString.contains('Apr') || dateString.contains('May') || dateString.contains('Jun') || dateString.contains('Jul') || dateString.contains('Aug') || dateString.contains('Sep') || dateString.contains('Oct') || dateString.contains('Nov') || dateString.contains('Dec'))) {
        date = _parseRFC2822Date(dateString);
      } else if (dateString.contains('T')) {
        // ISO format: "2025-08-21T00:00:00.000Z"
        date = DateTime.parse(dateString);
      } else if (dateString.contains('/')) {
        // Format: "21/08/2025" or "08/21/2025"
        final parts = dateString.split('/');
        if (parts.length == 3) {
          date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        } else {
          throw FormatException('Invalid date format');
        }
      } else if (dateString.contains('-')) {
        // Format: "2025-08-21"
        date = DateTime.parse(dateString);
      } else {
        // Try direct parsing
        date = DateTime.parse(dateString);
      }
      
      return date;
    } catch (e) {
      return null;
    }
  }
}