import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/shop.dart';
import '../../domain/repositories/i_shop_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopNotifier extends StateNotifier<Shop?> {
  final IShopRepository _repository;
  final SharedPreferences _prefs;

  ShopNotifier(this._repository, this._prefs) : super(null) {
    _loadCurrentShop();
  }

  Future<void> _loadCurrentShop() async {
    final shops = await _repository.getShops();
    if (shops.isEmpty) {
      // Create default shop if none exists
      final defaultShop = Shop(name: 'My Shop');
      await _repository.addShop(defaultShop);
      state = defaultShop;
      await _prefs.setString('current_shop_id', defaultShop.id);
    } else {
      final savedShopId = _prefs.getString('current_shop_id');
      if (savedShopId != null) {
        state = shops.firstWhere(
          (s) => s.id == savedShopId,
          orElse: () => shops.first,
        );
      } else {
        state = shops.first;
      }
    }
  }

  Future<void> selectShop(Shop shop) async {
    state = shop;
    await _prefs.setString('current_shop_id', shop.id);
  }

  Future<void> addShop(Shop shop) async {
    await _repository.addShop(shop);
    await selectShop(shop);
  }

  Future<List<Shop>> getShops() async {
    return _repository.getShops();
  }
}
