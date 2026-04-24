import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

class WarehouseUsage extends StatelessWidget {
  final String warehouseName;
  final double usagePercent; // 0.0 ~ 1.0

  const WarehouseUsage({
    super.key,
    required this.warehouseName,
    required this.usagePercent,
  });

  // 사용률에 따른 상태 색상 결정 로직
  Color _getStatusColor(double rate) {
    if (rate >= 0.9) return Colors.red;        // 90% 이상: 위험
    if (rate >= 0.7) return Colors.orange;     // 70% 이상: 주의
    return Colors.green;                       // 그 외: 정상/여유
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = _getStatusColor(usagePercent);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          // 웨이브 볼 영역
          SizedBox(
            width: 100,
            height: 100,
            child: LiquidCircularProgressIndicator(
              value: usagePercent,
              valueColor: AlwaysStoppedAnimation(statusColor.withOpacity(0.6)),
              backgroundColor: Colors.white,
              borderColor: statusColor,
              borderWidth: 2.0,
              direction: Axis.vertical,
              center: Text(
                "${(usagePercent * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: usagePercent > 0.5 ? Colors.white : statusColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 25),
          // 정보 텍스트 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(warehouseName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      usagePercent >= 0.9 ? "공간 부족 (위험)" : (usagePercent >= 0.7 ? "사용량 높음" : "운영 여유"),
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text("현재 약 130평 이용 가능",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


