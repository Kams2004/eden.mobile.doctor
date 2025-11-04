import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class MedicalDisclaimerWidget extends StatelessWidget {
  const MedicalDisclaimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E293B) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF4B5563) : Colors.grey[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF94A3B8) : Colors.grey[700],
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Avis médical important',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Text(
            'Ces résultats doivent être interprétés par un professionnel de santé qualifié. En cas de question ou de préoccupation concernant ces résultats, veuillez consulter votre médecin traitant.',
            style: TextStyle(
              fontSize: 13.sp,
              color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF94A3B8) : Colors.grey[700],
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Ce document ne constitue pas un diagnostic médical et ne remplace pas une consultation médicale.',
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF6B7280) : Colors.grey[600],
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}