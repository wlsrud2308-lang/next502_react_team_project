import 'package:flutter/material.dart';

class WarehouseUsage extends StatelessWidget {
  final String warehouseName;
  final double usageRate; // 0.0 ~ 1.0 (예: 0.85)
  final int totalSpace;   // 전체 평수
  final int usedSpace;    // 사용 중인 평수

  const WarehouseUsage({
    super.key,
    this.warehouseName = "제1 물류창고",
    this.usageRate = 0.85,
    this.totalSpace = 200,
    this.usedSpace = 170,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 헤더 (이름 및 상세 버튼)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                warehouseName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 20),

          // 2. 중앙 사용률 바 (Progress Bar)
          Stack(
            children: [
              // 배경 바
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // 실제 사용량 바 (애니메이션 효과를 주면 더 좋습니다)
              FractionallySizedBox(
                widthFactor: usageRate,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.deepPurple, Colors.purpleAccent],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // 3. 하단 상세 수치
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("사용 가능", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text("${totalSpace - usedSpace}평",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("현재 사용률", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text("${(usageRate * 100).toInt()}%",
                      style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
