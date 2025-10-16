import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class QRCodeWidget extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const QRCodeWidget({
    super.key,
    required this.resultData,
  });

  @override
  Widget build(BuildContext context) {
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
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Code QR du Résultat',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_2,
                  size: 20.w,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 1.h),
                Text(
                  'QR Code',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Scannez ce code pour accéder rapidement à ce résultat',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            'Code: ${resultData['name'] ?? 'N/A'}',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[500],
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}