import '../models/category.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';

class TravelCapsule {
  final String destination;
  final int days;
  final String tripTheme;
  final List<ClothingItem> packedClothes;
  final List<Outfit> generatedTripOutfits;
  final List<String> travelEssentialsChecklist;

  const TravelCapsule({
    required this.destination,
    required this.days,
    required this.tripTheme,
    required this.packedClothes,
    required this.generatedTripOutfits,
    required this.travelEssentialsChecklist,
  });

  List<Outfit> get dailyOutfits => generatedTripOutfits;
  List<String> get checklist => travelEssentialsChecklist;
}

class SmartPackingService {
  SmartPackingService._();
  static final SmartPackingService instance = SmartPackingService._();

  TravelCapsule generateCapsule({
    required String destination,
    required int days,
    required String tripTheme, // 'Trabalho', 'Lazer', 'Praia', 'Inverno'
    required List<ClothingItem> allClothes,
  }) {
    final tops = allClothes.where((i) => i.category == ClothingCategory.top).toList();
    final bottoms = allClothes.where((i) => i.category == ClothingCategory.bottom).toList();
    final shoes = allClothes.where((i) => i.category == ClothingCategory.shoes).toList();
    final outers = allClothes.where((i) => i.category == ClothingCategory.outerwear).toList();
    final accessories = allClothes.where((i) => i.category == ClothingCategory.accessory).toList();

    // Regra da Cápsula 5-4-3-2-1 para viagens inteligentes
    final int topCount = (days <= 3 ? 3 : (days <= 5 ? 4 : 6)).clamp(1, tops.length);
    final int bottomCount = (days <= 3 ? 2 : (days <= 5 ? 3 : 4)).clamp(1, bottoms.length);
    final int shoeCount = (days <= 3 ? 2 : 3).clamp(1, shoes.length);
    final int outerCount = (tripTheme == 'Inverno' ? 2 : 1).clamp(0, outers.length);

    final selectedTops = tops.take(topCount).toList();
    final selectedBottoms = bottoms.take(bottomCount).toList();
    final selectedShoes = shoes.take(shoeCount).toList();
    final selectedOuters = outers.take(outerCount).toList();
    final selectedAcc = accessories.take(2).toList();

    final packedList = [
      ...selectedTops,
      ...selectedBottoms,
      ...selectedShoes,
      ...selectedOuters,
      ...selectedAcc,
    ];

    // Gera um look recomendado para cada dia da viagem combinando as peças da mala
    final tripOutfits = <Outfit>[];
    for (int day = 1; day <= days; day++) {
      final top = selectedTops.isNotEmpty ? selectedTops[(day - 1) % selectedTops.length] : null;
      final bottom = selectedBottoms.isNotEmpty ? selectedBottoms[(day - 1) % selectedBottoms.length] : null;
      final shoe = selectedShoes.isNotEmpty ? selectedShoes[(day - 1) % selectedShoes.length] : null;
      final outer = selectedOuters.isNotEmpty ? selectedOuters[(day - 1) % selectedOuters.length] : null;

      final items = [
        if (top != null) top,
        if (bottom != null) bottom,
        if (shoe != null) shoe,
        if (outer != null && (day % 2 == 0 || tripTheme == 'Inverno')) outer,
      ];

      tripOutfits.add(
        Outfit(
          id: 'trip_day_$day',
          name: 'Dia $day em $destination',
          occasion: tripTheme,
          itemIds: items.map((e) => e.id).toList(),
          items: items,
          aiStylistNote: 'Combinação planejada para o Dia $day da sua viagem com as peças da sua mala cápsula.',
          createdAt: DateTime.now(),
        ),
      );
    }

    final essentials = [
      'Passaporte / Documento com foto',
      'Carregadores & Adaptador de tomada',
      'Itens de higiene pessoal (frascos até 100ml)',
      'Medicamentos essenciais',
      if (tripTheme == 'Praia') 'Protetor solar & Óculos de sol',
      if (tripTheme == 'Inverno') 'Cachecol térmico & Hidratante labial',
      'Garrafa de água reutilizável',
    ];

    return TravelCapsule(
      destination: destination,
      days: days,
      tripTheme: tripTheme,
      packedClothes: packedList,
      generatedTripOutfits: tripOutfits,
      travelEssentialsChecklist: essentials,
    );
  }
}
