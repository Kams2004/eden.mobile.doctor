import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class MedicalDisclaimerWidget extends StatelessWidget {
  const MedicalDisclaimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_outlined,
                color: Colors.amber[700],
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Avis médical important',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Ces résultats doivent être interprétés par un professionnel de santé. En cas de question ou de préoccupation, consultez votre médecin.',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.amber[800],
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}