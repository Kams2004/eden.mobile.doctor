import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeWidget extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const QRCodeWidget({
    super.key,
    required this.resultData,
  });

  @override
  Widget build(BuildContext context) {
    final qrData = 'EDEN_LAB_${resultData['name'] ?? 'UNKNOWN'}_${resultData['patient'] ?? 'PATIENT'}';
    
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.qr_code,
                color: Color(0xFF3B82F6),
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Code QR du Résultat',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 25.w,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),
          SizedBox(height: 1.5.h),
          Text(
            'Scannez pour accéder au résultat',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}