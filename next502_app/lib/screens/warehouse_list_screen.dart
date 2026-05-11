import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/warehouse_provider.dart';
import '../models/warehouse_model.dart';
import '../widgets/main_search_bar.dart';
import '../utils/image_url_helper.dart'; // ★ 이미지 헬퍼 추가

class WarehouseListScreen extends StatefulWidget {
  const WarehouseListScreen({super.key});

  @override
  State<WarehouseListScreen> createState() => _WarehouseListScreenState();
}

class _WarehouseListScreenState extends State<WarehouseListScreen> {
  String _selectedFilter = "전체";
  final List<String> _filters = ["전체", "보통", "야적", "냉동/냉장", "저장", "위험물"];
  String? _lastSearchQuery;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final String currentQuery = ModalRoute.of(context)?.settings.arguments as String? ?? "";

    if (_lastSearchQuery != currentQuery) {
      _lastSearchQuery = currentQuery;
      Future.microtask(() {
        context.read<WarehouseProvider>().fetchWarehouses(
            query: currentQuery,
            type: _selectedFilter
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String searchQuery = ModalRoute.of(context)?.settings.arguments as String? ?? "";
    final warehouseProvider = context.watch<WarehouseProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          // ★ 검색어가 없을 때는 '창고 전체 목록'으로 표시
          searchQuery.isEmpty ? "전체 창고 목록" : "'$searchQuery' 검색 결과",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const MainSearchBar(),

          // 필터 칩 영역
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filterName = _filters[index];
                final isSelected = _selectedFilter == filterName;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filterName),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() => _selectedFilter = filterName);
                        context.read<WarehouseProvider>().fetchWarehouses(
                          query: searchQuery,
                          type: filterName,
                        );
                      }
                    },
                    selectedColor: Colors.deepPurple,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 10),
          Expanded(
            child: _buildListContent(warehouseProvider, searchQuery),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent(WarehouseProvider provider, String query) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
    }

    if (provider.warehouses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text(
              _selectedFilter == "전체" ? "등록된 창고가 없습니다." : "$_selectedFilter 유형의 창고가 없습니다.",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchWarehouses(query: query, type: _selectedFilter),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: provider.warehouses.length,
        itemBuilder: (context, index) {
          final item = provider.warehouses[index];
          return _buildWarehouseItem(context, item);
        },
      ),
    );
  }

  Widget _buildWarehouseItem(BuildContext context, WarehouseModel item) {
    // ★ 이미지 URL 정규화 적용
    final String? imageUrl = normalizeImageUrl(item.repImageUrl) ??
        (item.imageUrls.isNotEmpty ? normalizeImageUrl(item.imageUrls[0]) : null);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/whInfo', arguments: item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
              child: imageUrl != null
                  ? Image.network(
                imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[100],
                    child: const Icon(Icons.broken_image, color: Colors.grey)
                ),
              )
                  : Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[100],
                  child: const Icon(Icons.warehouse, color: Colors.grey)
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(item.address, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _tag(item.storageType ?? "보통"),
                        const SizedBox(width: 5),
                        _tag("${item.totalArea.toInt()}평"),
                        const SizedBox(width: 5),
                        _tag(item.sizeRank), // 등급 정보 추가
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.05), borderRadius: BorderRadius.circular(5)),
      child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
    );
  }
}

