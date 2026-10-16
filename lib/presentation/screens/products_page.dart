import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../widgets/dialogs/add_product_dialog.dart';
import '../widgets/home/shop_selector.dart';
import '../widgets/product/product_tile.dart';

const _pageBackground = Color(0xFFF8F9FF);
const _accentColor = Color(0xFF006B4F);
const _inkColor = Color(0xFF13243A);
const _mutedColor = Color(0xFF718096);

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider);
    final query = _searchController.text.trim().toLowerCase();
    final visibleProducts = products
        .where((product) => product.name.toLowerCase().contains(query))
        .toList();

    return Scaffold(
      backgroundColor: _pageBackground,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductSheet(context),
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'পণ্য যোগ করুন',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF95F6C8),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: Color(0xFF002114),
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(child: ShopSelector()),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEF2FF),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${products.length}',
                          style: const TextStyle(
                            color: _accentColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFFE8EAF2)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      icon: const Icon(
                        Icons.search_rounded,
                        color: _mutedColor,
                        size: 24,
                      ),
                      hintText: 'পণ্য খুঁজুন (তেল, চাল, ডাল, সাবান...)',
                      hintStyle: const TextStyle(
                        color: _mutedColor,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      suffixIcon: query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'মুছে ফেলুন',
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded, size: 19),
                            ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'আপনার পণ্যসমূহ',
                        style: TextStyle(
                          color: _inkColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      query.isEmpty
                          ? 'মোট ${products.length}টি পণ্য'
                          : '${visibleProducts.length}টি পাওয়া গেছে',
                      style: const TextStyle(
                        color: _mutedColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (visibleProducts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyProductsState(
                  isSearching: query.isNotEmpty,
                  onAddProduct: () => _showProductSheet(context),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList.builder(
                  itemCount: visibleProducts.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ProductTile(product: visibleProducts[index]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showProductSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddProductDialog(),
    );
  }
}

class _EmptyProductsState extends StatelessWidget {
  const _EmptyProductsState({
    required this.isSearching,
    required this.onAddProduct,
  });

  final bool isSearching;
  final VoidCallback onAddProduct;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F8F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: _accentColor,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching ? 'কোনো পণ্য পাওয়া যায়নি' : 'এখনো কোনো পণ্য নেই',
              style: const TextStyle(
                color: _inkColor,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isSearching
                  ? 'অন্য নামে খুঁজে দেখুন'
                  : 'আপনার দোকানের পণ্য যোগ করে শুরু করুন',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _mutedColor, fontSize: 13),
            ),
            if (!isSearching) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onAddProduct,
                icon: const Icon(Icons.add_rounded),
                label: const Text('পণ্য যোগ করুন'),
                style: TextButton.styleFrom(foregroundColor: _accentColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
