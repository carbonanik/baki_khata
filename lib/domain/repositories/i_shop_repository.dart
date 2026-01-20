import '../entities/shop.dart';

abstract class IShopRepository {
  Future<List<Shop>> getShops();
  Future<void> addShop(Shop shop);
  Future<void> updateShop(Shop shop);
  Future<void> deleteShop(String id);
}
