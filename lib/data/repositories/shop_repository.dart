import 'package:sembast/sembast.dart';
import '../../domain/entities/shop.dart';
import '../../domain/repositories/i_shop_repository.dart';
import '../datasources/database_service.dart';

class ShopRepository implements IShopRepository {
  final _store = stringMapStoreFactory.store('shops');

  @override
  Future<List<Shop>> getShops() async {
    final db = await DatabaseService.instance.database;
    final snapshots = await _store.find(db);
    return snapshots.map((s) => Shop.fromJson(s.value)).toList();
  }

  @override
  Future<void> addShop(Shop shop) async {
    final db = await DatabaseService.instance.database;
    await _store.record(shop.id).put(db, shop.toJson());
  }

  @override
  Future<void> updateShop(Shop shop) async {
    final db = await DatabaseService.instance.database;
    await _store.record(shop.id).put(db, shop.toJson());
  }

  @override
  Future<void> deleteShop(String id) async {
    final db = await DatabaseService.instance.database;
    await _store.record(id).delete(db);
  }
}
