import 'package:url_launcher/url_launcher.dart';
import '../models/category.dart';
import '../models/clothing_item.dart';
import '../models/shop_item.dart';

class ShopSearchService {
  ShopSearchService._();
  static final ShopSearchService instance = ShopSearchService._();

  /// Abre busca no Google Shopping ou em loja específica
  Future<bool> openStoreSearch({
    required String query,
    String? preferredStore,
  }) async {
    final encoded = Uri.encodeComponent(query);
    String urlStr;

    switch (preferredStore?.toLowerCase()) {
      case 'zara':
        urlStr = 'https://www.zara.com/br/pt/search?searchTerm=$encoded';
        break;
      case 'renner':
        urlStr = 'https://www.lojasrenner.com.br/b?Ntt=$encoded';
        break;
      case 'c&a':
      case 'cea':
        urlStr = 'https://www.cea.com.br/busca?ft=$encoded';
        break;
      case 'shein':
        urlStr = 'https://br.shein.com/pdsearch/$encoded';
        break;
      case 'farfetch':
        urlStr = 'https://www.farfetch.com/br/shopping/men/search/items.aspx?q=$encoded';
        break;
      case 'amazon':
        urlStr = 'https://www.amazon.com.br/s?k=$encoded&i=fashion';
        break;
      case 'google_shopping':
      default:
        urlStr = 'https://www.google.com/search?tbm=shop&q=$encoded';
        break;
    }

    final uri = Uri.parse(urlStr);
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    return false;
  }

  /// Gera sugestões de produtos similares em lojas com base na peça do closet
  List<ShopItem> getSimilarShopItems(ClothingItem item) {
    final baseName = item.name;
    final color = item.color;
    final categoryName = item.category.displayName;

    return [
      ShopItem(
        title: '$baseName $color Slim Fit',
        storeName: 'Zara',
        priceEstimate: 'R\$ 259,90',
        searchQuery: '$baseName $color Zara',
        directUrl: 'https://www.zara.com/br/pt/search?searchTerm=${Uri.encodeComponent('$baseName $color')}',
        matchScore: 0.96,
      ),
      ShopItem(
        title: '$categoryName $color Conforto Algodão',
        storeName: 'Lojas Renner',
        priceEstimate: 'R\$ 139,90',
        searchQuery: '$categoryName $color Renner',
        directUrl: 'https://www.lojasrenner.com.br/b?Ntt=${Uri.encodeComponent('$categoryName $color')}',
        matchScore: 0.91,
      ),
      ShopItem(
        title: '$baseName Essencial Premium',
        storeName: 'C&A Moda',
        priceEstimate: 'R\$ 119,90',
        searchQuery: '$baseName $color C&A',
        directUrl: 'https://www.cea.com.br/busca?ft=${Uri.encodeComponent('$baseName $color')}',
        matchScore: 0.88,
      ),
      ShopItem(
        title: '$baseName Alfaiataria Designer',
        storeName: 'Farfetch Luxo',
        priceEstimate: 'R\$ 780,00',
        searchQuery: '$baseName $color Farfetch',
        directUrl: 'https://www.farfetch.com/br/shopping/men/search/items.aspx?q=${Uri.encodeComponent('$baseName $color')}',
        matchScore: 0.94,
      ),
      ShopItem(
        title: '$categoryName Trendsetter $color',
        storeName: 'Shein Brasil',
        priceEstimate: 'R\$ 68,90',
        searchQuery: '$baseName $color Shein',
        directUrl: 'https://br.shein.com/pdsearch/${Uri.encodeComponent('$baseName $color')}',
        matchScore: 0.85,
      ),
    ];
  }
}
