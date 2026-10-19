import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../models/clothing_item.dart';
import '../../models/shop_item.dart';
import '../../services/shop_search_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/clothing_image_view.dart';

class ShopSimilarDialog extends StatefulWidget {
  final ClothingItem item;

  const ShopSimilarDialog({
    super.key,
    required this.item,
  });

  static Future<void> show(BuildContext context, ClothingItem item) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShopSimilarDialog(item: item),
    );
  }

  @override
  State<ShopSimilarDialog> createState() => _ShopSimilarDialogState();
}

class _ShopSimilarDialogState extends State<ShopSimilarDialog> {
  late TextEditingController _searchCtrl;
  late List<ShopItem> _similarItems;
  final ShopSearchService _shopService = ShopSearchService.instance;

  @override
  void initState() {
    super.initState();
    final defaultQuery = '${widget.item.name} ${widget.item.color}';
    _searchCtrl = TextEditingController(text: defaultQuery.trim());
    _similarItems = _shopService.getSimilarShopItems(widget.item);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _searchGlobal(String query, [String? store]) async {
    final success = await _shopService.openStoreSearch(
      query: query.trim().isEmpty ? widget.item.name : query.trim(),
      preferredStore: store,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o navegador para esta busca.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.shopping_bag_outlined,
                            size: 18,
                            color: AppColors.primaryBlack,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SHOP THE LOOK',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Peças Similares em Lojas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Item preview pill
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: ClothingImageView(
                        imagePath: widget.item.imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                        Text(
                          '${widget.item.category.displayName} • ${widget.item.color}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar por nome, corte ou marca...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                  onPressed: () => _searchGlobal(_searchCtrl.text),
                ),
                filled: true,
                fillColor: AppColors.pureWhite,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
              ),
              onSubmitted: (val) => _searchGlobal(val),
            ),
          ),

          // Store Quick Pills
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildStorePill('Google Shopping', 'google_shopping', Icons.shopping_basket_outlined),
                _buildStorePill('Zara', 'zara', null),
                _buildStorePill('Lojas Renner', 'renner', null),
                _buildStorePill('C&A', 'c&a', null),
                _buildStorePill('Farfetch', 'farfetch', null),
                _buildStorePill('Shein', 'shein', null),
                _buildStorePill('Amazon', 'amazon', null),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Similar recommendations list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _similarItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final shopItem = _similarItems[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.storefront_outlined,
                            size: 22,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  shopItem.storeName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accentBronze,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${(shopItem.matchScore * 100).toInt()}% similar',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              shopItem.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlack,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Preço médio: ${shopItem.priceEstimate}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.open_in_new_rounded,
                          size: 20,
                          color: AppColors.primaryBlack,
                        ),
                        onPressed: () => _searchGlobal(
                          shopItem.searchQuery,
                          shopItem.storeName,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorePill(String label, String storeKey, IconData? icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: icon != null
            ? Icon(icon, size: 16, color: AppColors.primaryBlack)
            : null,
        label: Text(label),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryBlack,
        ),
        backgroundColor: AppColors.pureWhite,
        side: const BorderSide(color: AppColors.cardBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () => _searchGlobal(_searchCtrl.text, storeKey),
      ),
    );
  }
}
