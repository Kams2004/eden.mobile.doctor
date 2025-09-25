import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../patient-core/core/app_export.dart';
import '../../patient-widgets/widgets/custom_icon_widget.dart';
import './widgets/examination_card_widget.dart';
import './widgets/prescription_header_widget.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/status_indicator_widget.dart';

class PrescriptionResults extends StatefulWidget {
  const PrescriptionResults({super.key});

  @override
  State<PrescriptionResults> createState() => _PrescriptionResultsState();
}

class _PrescriptionResultsState extends State<PrescriptionResults>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? _prescriptionPath;

  // Mock prescription data
  final Map<String, dynamic> _prescriptionData = {
    'scanDate': '28/08/2025 15:23',
    'validationStatus': 'pending', // pending, validated, clarification_needed
    'medications': [
      {
        'name': 'Doliprane 500mg',
        'dosage': '1 comprimé 3 fois par jour',
        'duration': '7 jours',
      },
      {
        'name': 'Amoxicilline 1g',
        'dosage': '1 comprimé matin et soir',
        'duration': '10 jours',
      },
    ],
    'examinations': [
      {
        'id': 1,
        'name': 'Prise de sang complète',
        'type': 'laboratory',
        'icon': 'science',
        'description': 'Analyse sanguine complète avec NFS, VS, CRP',
        'urgency': 'high',
        'estimatedDuration': '15 min',
        'preparation': 'À jeun depuis 12h',
        'price': '45-65€',
        'insuranceCoverage': '70%',
        'availableSlots': [
          {'date': '29/08/2025', 'time': '08:30', 'available': true},
          {'date': '29/08/2025', 'time': '09:15', 'available': true},
          {'date': '30/08/2025', 'time': '08:00', 'available': true},
        ],
      },
      {
        'id': 2,
        'name': 'ECG',
        'type': 'functional',
        'icon': 'monitor_heart',
        'description': 'Électrocardiogramme au repos',
        'urgency': 'medium',
        'estimatedDuration': '20 min',
        'preparation': 'Aucune préparation spéciale',
        'price': '25-35€',
        'insuranceCoverage': '70%',
        'availableSlots': [
          {'date': '29/08/2025', 'time': '14:30', 'available': true},
          {'date': '30/08/2025', 'time': '10:45', 'available': false},
          {'date': '31/08/2025', 'time': '09:30', 'available': true},
        ],
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get prescription path from arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _prescriptionPath = args;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'En cours de validation';
      case 'validated':
        return 'Validée';
      case 'clarification_needed':
        return 'Clarification requise';
      default:
        return 'Statut inconnu';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'validated':
        return Colors.green;
      case 'clarification_needed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _bookAllExaminations() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réserver tous les examens'),
        content: const Text(
          'Voulez-vous réserver tous les examens de votre prescription ?\n\n'
          'Les créneaux les plus proches seront automatiquement sélectionnés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showBookingConfirmation('Tous les examens');
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _selectSpecificTests() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Container(
          height: 70.h,
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              Container(
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Sélectionner les examens',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: ListView.builder(
                  itemCount: _prescriptionData['examinations'].length,
                  itemBuilder: (context, index) {
                    final exam = _prescriptionData['examinations'][index];
                    return CheckboxListTile(
                      title: Text(exam['name']),
                      subtitle: Text(
                          '${exam['price']} • ${exam['estimatedDuration']}'),
                      value: true,
                      onChanged: (value) {
                        // Handle selection
                      },
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showBookingConfirmation('Examens sélectionnés');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 6.h),
                ),
                child: const Text('Réserver la sélection'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _contactForClarification() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'support_agent',
              color: Theme.of(context).colorScheme.primary,
              size: 6.w,
            ),
            SizedBox(width: 2.w),
            const Text('Demander une clarification'),
          ],
        ),
        content: const Text(
          'Notre équipe médicale va examiner votre prescription et vous contacter '
          'pour clarifier les points nécessaires.\n\n'
          'Vous recevrez une notification dès que la validation sera terminée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showClarificationRequested();
            },
            child: const Text('Demander'),
          ),
        ],
      ),
    );
  }

  void _showBookingConfirmation(String examType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$examType réservé(s) avec succès !'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Voir',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to appointments
          },
        ),
      ),
    );
  }

  void _showClarificationRequested() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Demande de clarification envoyée. Vous serez contacté sous 24h.'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface.withValues(alpha: 0.95),
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: colorScheme.onSurface,
            size: 6.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Résultats Prescription',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            margin: EdgeInsets.only(right: 4.w),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'EDEN',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(text: 'Examens'),
            Tab(text: 'Tarifs'),
            Tab(text: 'Disponibilité'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Prescription Header
          PrescriptionHeaderWidget(
            scanDate: _prescriptionData['scanDate'],
            medications: _prescriptionData['medications'],
            validationStatus: _prescriptionData['validationStatus'],
          ),

          // Status Indicator
          StatusIndicatorWidget(
            status: _prescriptionData['validationStatus'],
            statusText: _getStatusText(_prescriptionData['validationStatus']),
            statusColor: _getStatusColor(_prescriptionData['validationStatus']),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Examinations Tab
                _buildExaminationsTab(),
                // Pricing Tab
                _buildPricingTab(),
                // Availability Tab
                _buildAvailabilityTab(),
              ],
            ),
          ),

          // Quick Actions
          QuickActionsWidget(
            onBookAll: _bookAllExaminations,
            onSelectSpecific: _selectSpecificTests,
            onContactClarification: _contactForClarification,
          ),
        ],
      ),
    );
  }

  Widget _buildExaminationsTab() {
    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: _prescriptionData['examinations'].length,
      itemBuilder: (context, index) {
        final examination = _prescriptionData['examinations'][index];
        return ExaminationCardWidget(
          examination: examination,
          onBook: () => _bookExamination(examination),
        );
      },
    );
  }

  Widget _buildPricingTab() {
    return ListView(
      padding: EdgeInsets.all(4.w),
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimation des coûts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 2.h),
                ..._prescriptionData['examinations'].map<Widget>((exam) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    child: Row(
                      children: [
                        Expanded(child: Text(exam['name'])),
                        Text(
                          exam['price'],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const Divider(),
                Row(
                  children: [
                    const Expanded(child: Text('Prise en charge')),
                    Text(
                      '70%',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityTab() {
    return ListView(
      padding: EdgeInsets.all(4.w),
      children: [
        ..._prescriptionData['examinations'].map<Widget>((exam) {
          return Card(
            margin: EdgeInsets.only(bottom: 2.h),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam['name'],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 2.h),
                  ...exam['availableSlots'].map<Widget>((slot) {
                    final isAvailable = slot['available'];
                    return Container(
                      margin: EdgeInsets.only(bottom: 1.h),
                      child: ListTile(
                        leading: CustomIconWidget(
                          iconName: 'schedule',
                          color: isAvailable ? Colors.green : Colors.grey,
                          size: 5.w,
                        ),
                        title: Text('${slot['date']} à ${slot['time']}'),
                        trailing: isAvailable
                            ? ElevatedButton(
                                onPressed: () => _bookSlot(exam, slot),
                                child: const Text('Réserver'),
                              )
                            : Text(
                                'Complet',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  void _bookExamination(Map<String, dynamic> examination) {
    _showBookingConfirmation(examination['name']);
  }

  void _bookSlot(Map<String, dynamic> exam, Map<String, dynamic> slot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer le rendez-vous'),
        content: Text(
          'Réserver ${exam['name']} le ${slot['date']} à ${slot['time']} ?\n\n'
          'Durée: ${exam['estimatedDuration']}\n'
          'Tarif: ${exam['price']}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showBookingConfirmation('${exam['name']} le ${slot['date']}');
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}
