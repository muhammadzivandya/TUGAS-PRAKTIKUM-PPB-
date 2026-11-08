import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../app/theme/app_colors.dart';
import '../../state/cart_provider.dart';
import '../../state/products_provider.dart';
import '../../state/wishlist_provider.dart';
import '../format/formatters.dart';
import '../ui_types.dart';
import 'detail_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<ProductsProvider>().loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final cart = context.read<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => provider.loadProducts(isRefresh: true),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Halo, Shopper! 👋',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.neutral)),
                              Text('Belanja pastel, hati senang.', style: TextStyle(color: AppColors.inkSoft)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.neutral),
                            onPressed: () {},
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        onChanged: (val) => provider.setQuery(val),
                        decoration: InputDecoration(
                          hintText: 'Cari barang impian di DummyJSON...',
                          prefixIcon: const Icon(Icons.search, color: AppColors.inkSoft),
                          suffixIcon: provider.query.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: AppColors.inkSoft),
                                  onPressed: () {
                                    _searchController.clear();
                                    provider.setQuery('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('DISKON 35%',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDeep)),
                                  const Text('Voucher ZOYPASTEL siap pakai', style: TextStyle(color: AppColors.neutral)),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryDeep,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: () {
                                      cart.applyVoucher('ZOYPASTEL');
                                      provider.selectCategory('beauty');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Voucher ZOYPASTEL diklaim! Menampilkan kategori Beauty.')),
                                      );
                                    },
                                    child: const Text('Klaim Promo', style: TextStyle(color: Colors.white)),
                                  )
                                ],
                              ),
                            ),
                            const Icon(Icons.card_giftcard_rounded, size: 64, color: AppColors.primaryDeep)
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 36,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: provider.categorySlugs.length + 1,
                          itemBuilder: (context, idx) {
                            if (idx == 0) {
                              final isSelected = provider.selectedCategory == null;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: const Text('Semua'),
                                  selected: isSelected,
                                  selectedColor: AppColors.tertiary,
                                  onSelected: (_) => provider.selectCategory(null),
                                ),
                              );
                            }
                            final cat = provider.categorySlugs[idx - 1];
                            final isSelected = provider.selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(cat),
                                selected: isSelected,
                                selectedColor: AppColors.tertiary,
                                onSelected: (_) => provider.selectCategory(cat),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Menampilkan \${provider.items.length} dari \${provider.total} produk',
                              style: const TextStyle(color: AppColors.inkSoft, fontSize: 12)),
                          PopupMenuButton<SortOption>(
                            initialValue: provider.sort,
                            onSelected: (val) => provider.setSort(val),
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: SortOption.defaultSort, child: Text('Default')),
                              PopupMenuItem(value: SortOption.priceLowHigh, child: Text('Harga Termurah')),
                              PopupMenuItem(value: SortOption.priceHighLow, child: Text('Harga Termahal')),
                              PopupMenuItem(value: SortOption.ratingHigh, child: Text('Rating Tertinggi')),
                              PopupMenuItem(value: SortOption.nameAZ, child: Text('Nama A-Z')),
                            ],
                            child: const Row(
                              children: [
                                Text('Urutkan', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDeep)),
                                Icon(Icons.arrow_drop_down, color: AppColors.primaryDeep),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),

              if (provider.status == LoadingStatus.loading)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      childCount: 6,
                    ),
                  ),
                )
              else if (provider.status == LoadingStatus.error)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Text(provider.errorMessage, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => provider.loadProducts(isRefresh: true),
                            child: const Text('Coba Lagi'),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = provider.items[index];
                        final isFav = wishlist.contains(product.id);
                        final finalPrice = Formatters.discountedPrice(product);

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => DetailView(product: product)),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                        child: Hero(
                                          tag: 'product-\${product.id}',
                                          child: CachedNetworkImage(
                                            imageUrl: product.thumbnail,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            placeholder: (_, __) => Container(color: AppColors.tintPink),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white.withOpacity(0.9),
                                          radius: 16,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: Icon(
                                              isFav ? Icons.favorite : Icons.favorite_border,
                                              size: 18,
                                              color: isFav ? AppColors.primary : AppColors.inkSoft,
                                            ),
                                            onPressed: () => wishlist.toggle(product),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, size: 14, color: Colors.amber),
                                          Text(' \${product.rating}', style: const TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('\$${finalPrice}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primaryDeep,
                                                  fontSize: 15)),
                                          IconButton(
                                            icon: const Icon(Icons.add_shopping_cart, size: 20, color: AppColors.primaryDeep),
                                            onPressed: () {
                                              final added = cart.add(product, 1);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(added
                                                      ? 'Ditambahkan ke keranjang'
                                                      : 'Stok barang habis'),
                                                  duration: const Duration(seconds: 1),
                                                ),
                                              );
                                            },
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: provider.items.length,
                    ),
                  ),
                ),

              if (provider.status == LoadingStatus.loadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text('Memuat produk pastel lainnya...', style: TextStyle(color: AppColors.inkSoft)),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
