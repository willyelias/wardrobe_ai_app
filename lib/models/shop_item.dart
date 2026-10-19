class ShopItem {
  final String title;
  final String storeName;
  final String priceEstimate;
  final String searchQuery;
  final String directUrl;
  final String? imageUrl;
  final double matchScore; // e.g. 0.95 for 95% similar

  const ShopItem({
    required this.title,
    required this.storeName,
    required this.priceEstimate,
    required this.searchQuery,
    required this.directUrl,
    this.imageUrl,
    this.matchScore = 0.92,
  });
}
