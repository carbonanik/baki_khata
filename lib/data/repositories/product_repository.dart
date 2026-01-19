import 'package:sembast/sembast.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/database_service.dart';

class SembastProductRepository implements ProductRepository {
  final _store = stringMapStoreFactory.store('products');

  @override
  Future<void> addProduct(Product product) async {
    final db = await DatabaseService.instance.database;
    await _store.record(product.id).put(db, product.toJson());
  }

  @override
  Future<void> deleteProduct(String id) async {
    final db = await DatabaseService.instance.database;
    await _store.record(id).delete(db);
  }

  @override
  Future<List<Product>> getProducts() async {
    final db = await DatabaseService.instance.database;
    final snapshots = await _store.find(db);
    return snapshots
        .map((snapshot) => Product.fromJson(snapshot.value))
        .toList();
  }

  @override
  Future<void> updateProduct(Product product) async {
    final db = await DatabaseService.instance.database;
    await _store.record(product.id).update(db, product.toJson());
  }

  @override
  Stream<List<Product>> watchProducts() {
    // Sembast stream needs a database reference.
    // Since we need to wait for the database, we can use a Stream.fromFuture or similar,
    // but sembast's query.onSnapshots(db) expects a synchronous db object if possible,
    // or we can await inside the stream controller.
    // However, `DatabaseService.instance.database` is async.
    // For simplicity, let's just make it async loop or use Stream.fromFuture.

    // Better approach matching expected usage: use execute locally.
    // But since we can't easily make a stream async wait for db without StreamBuilder or similar.
    // Let's check how we can do this.

    return Stream.fromFuture(DatabaseService.instance.database).asyncExpand((
      db,
    ) {
      return _store.query().onSnapshots(db).map((snapshots) {
        return snapshots
            .map((snapshot) => Product.fromJson(snapshot.value))
            .toList();
      });
    });
  }
}
