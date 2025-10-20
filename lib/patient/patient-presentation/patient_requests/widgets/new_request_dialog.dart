import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/storage_service.dart';

class NewRequestDialog extends StatefulWidget {
  final VoidCallback onRequestSubmitted;
  final Map<String, dynamic>? existingRequest;

  const NewRequestDialog({super.key, required this.onRequestSubmitted, this.existingRequest});

  @override
  State<NewRequestDialog> createState() => _NewRequestDialogState();
}

class _NewRequestDialogState extends State<NewRequestDialog> {
  String? _selectedRequestType;
  String _selectedUrgency = 'Faible';
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingRequest != null) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final request = widget.existingRequest!;
    _messageController.text = request['message'] ?? '';
    
    if (request['revendication_examen'] == true) _selectedRequestType = 'Réclamation Examen';
    else if (request['patient_request_prix_examen'] == true) _selectedRequestType = 'Prix Examen';
    else if (request['connection'] == true) _selectedRequestType = 'Connexion';
    else if (request['patient_request_examen_out'] == true) _selectedRequestType = 'Examen Externe';
    else if (request['administration'] == true) _selectedRequestType = 'Autre Administration';
  }

  final Map<String, Map<String, dynamic>> _requestTypes = {
    'Connexion': {
      'description': 'Demander une assistance pour la connexion',
      'field': 'connection',
    },
    'Examen Externe': {
      'description': 'Demander un examen externe',
      'field': 'patient_request_examen_out',
    },
    'Autre Administration': {
      'description': 'Demander une assistance administrative',
      'field': 'administration',
    },
    'Prix Examen': {
      'description': 'Demander le prix d\'un examen',
      'field': 'patient_request_prix_examen',
    },
    'Réclamation Examen': {
      'description': 'Faire une réclamation pour un examen',
      'field': 'revendication_examen',
    },
  };

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_selectedRequestType == null || _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner un type et saisir un message'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authService = AuthService();
      final accessToken = StorageService.accessToken;
      
      if (accessToken == null) {
        throw Exception('Token d\'accès manquant');
      }

      // Get patient info from storage or use defaults
      final firstName = StorageService.patientName ?? 'Patient';
      final lastName = StorageService.patientLastname ?? '';
      final email = '';

      final requestData = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'message': _messageController.text.trim(),
        'administration': false,
        'commission': false,
        'connection': false,
        'error': false,
        'etat_patient': false,
        'patient_request_connexion': false,
        'patient_request_examen_out': null,
        'patient_request_other_administration': null,
        'patient_request_prix_examen': null,
        'revendication_examen': false,
        'suggestion': false,
      };

      // Set the selected request type to true
      final selectedField = _requestTypes[_selectedRequestType]!['field'];
      if (selectedField == 'patient_request_examen_out' || 
          selectedField == 'patient_request_prix_examen') {
        requestData[selectedField] = true;
      } else {
        requestData[selectedField] = true;
      }

      await authService.addPatientRequest(requestData, accessToken);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Requête soumise avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
      widget.onRequestSubmitted();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la soumission: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: 90.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
            ),
            child: Row(
              children: [
                Text(
                  widget.existingRequest != null ? 'Modifier Requête' : 'Nouvelle Requête',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Request Type Section
                  Text(
                    'Type de Requête',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  
                  // Request Type Options
                  ..._requestTypes.entries.map((entry) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 2.h),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedRequestType = entry.key;
                            // Auto-populate message with request type description
                            _messageController.text = entry.value['description'];
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedRequestType == entry.key 
                                  ? Color(0xFF3B82F6) 
                                  : Colors.grey[300]!,
                              width: _selectedRequestType == entry.key ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: _selectedRequestType == entry.key 
                                ? Color(0xFF3B82F6).withOpacity(0.05) 
                                : Colors.white,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 5.w,
                                height: 5.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _selectedRequestType == entry.key 
                                        ? Color(0xFF3B82F6) 
                                        : Colors.grey[400]!,
                                    width: 2,
                                  ),
                                  color: _selectedRequestType == entry.key 
                                      ? Color(0xFF3B82F6) 
                                      : Colors.white,
                                ),
                                child: _selectedRequestType == entry.key
                                    ? Icon(Icons.check, color: Colors.white, size: 3.w)
                                    : null,
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      entry.value['description'],
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Color(0xFF3B82F6),
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
                  }).toList(),
                  
                  SizedBox(height: 3.h),
                  
                  // Urgency Level
                  Text(
                    'Niveau d\'Urgence',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  
                  Row(
                    children: ['Faible', 'Moyen', 'Élevé'].map((urgency) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedUrgency = urgency;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 1.w),
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            decoration: BoxDecoration(
                              color: _selectedUrgency == urgency 
                                  ? Color(0xFF64748B) 
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              urgency,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _selectedUrgency == urgency 
                                    ? Colors.white 
                                    : Colors.grey[700],
                                fontWeight: FontWeight.w500,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  SizedBox(height: 3.h),
                  
                  // Message Section
                  Text(
                    'Détails Supplémentaires',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  
                  TextField(
                    controller: _messageController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Veuillez fournir des détails supplémentaires sur votre requête...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF3B82F6), width: 2),
                      ),
                      contentPadding: EdgeInsets.all(4.w),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Action Buttons
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Annuler',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitRequest,
                    icon: _isSubmitting 
                        ? SizedBox(
                            width: 4.w,
                            height: 4.w,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(Icons.send, size: 4.w),
                    label: Text(
                      _isSubmitting ? 'Envoi...' : 'Envoyer',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF64748B),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}