import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_colors.dart';
import '../../data/models/product.dart';
import '../../state/cart_provider.dart';
import '../../state/wishlist_provider.dart';
import '../format/formatters.dart';

class DetailView extends StatefulWidget {
  final Product product;

  const DetailView({super.key, required this.product});

  @override
  State<DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> with SingleTickerProviderStateMixin {
  int _qty = 1;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final wishlist = context.watch<WishlistProvider>();
    final cart = context.read<CartProvider>();
    final isFav = wishlist.contains(product.id);
    final finalPrice = Formatters.discountedPrice(product);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? AppColors.primary : AppColors.neutral),
            onPressed: () => wishlist.toggle(product),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Hero(
                      tag: 'product-\${product.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: CachedNetworkImage(
                          imageUrl: product.thumbnail,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(product.title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.neutral)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('\$${finalPrice}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDeep)),
                      const SizedBox(width: 8),
                      if (product.discountPercentage > 0)
                        Text('\$${product.price}',
                            style: const TextStyle(
                                decoration: TextDecoration.lineThrough, color: AppColors.inkSoft)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      Text(' \${product.rating} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('(\${product.reviews.length} ulasan)', style: const TextStyle(color: AppColors.inkSoft)),
                      const Spacer(),
                      Chip(
                        backgroundColor: AppColors.tertiary,
                        label: Text(Formatters.stockStatusText(product.stock)),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Jumlah:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                      ),
                      Text('\$_qty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: _qty < product.stock ? () => setState(() => _qty++) : null,
                      ),
                    ],
                  ),
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primaryDeep,
                    unselectedLabelColor: AppColors.inkSoft,
                    indicatorColor: AppColors.primaryDeep,
                    tabs: const [
                      Tab(text: 'Deskripsi'),
                      Tab(text: 'Spesifikasi'),
                      Tab(text: 'Ulasan'),
                    ],
                  ),
                  SizedBox(
                    height: 200,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(product.description),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Brand: \${product.brand.isEmpty ? "-" : product.brand}'),
                              Text('SKU: \${product.sku}'),
                              Text('Garansi: \${product.warrantyInformation}'),
                              Text('Pengembalian: \${Formatters.returnPolicyText(product.returnPolicy)}'),
                            ],
                          ),
                        ),
                        ListView.builder(
                          itemCount: product.reviews.length,
                          itemBuilder: (context, idx) {
                            final r = product.reviews[idx];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(r.reviewerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(r.comment),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, size: 14, color: Colors.amber),
                                  Text('\${r.rating}'),
                                ],
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDeep,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: product.stock == 0
                    ? null
                    : () {
                        cart.add(product, _qty);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Berhasil ditambahkan ke keranjang!'),
                            action: SnackBarAction(
                              label: 'Lihat',
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                child: Text(
                  product.stock == 0
                      ? 'Stok Habis'
                      : 'Tambah ke Keranjang • \$${(finalPrice * _qty).toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
    
  }
}
