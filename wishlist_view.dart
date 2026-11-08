import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_colors.dart';
import '../../state/cart_provider.dart';
import '../../state/wishlist_provider.dart';
import '../format/formatters.dart';
import 'detail_view.dart';

class WishlistView extends StatelessWidget {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final cart = context.read<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wishlist Saya', style: TextStyle(color: AppColors.neutral, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: wishlist.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border_rounded, size: 64, color: AppColors.inkSoft),
                  const SizedBox(height: 12),
                  const Text('Wishlist masih kosong', style: TextStyle(color: AppColors.inkSoft)),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.tintPink, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Siap checkout semua?', style: TextStyle(fontWeight: FontWeight.bold)),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDeep),
                          onPressed: () {
                            int added = 0;
                            for (var p in wishlist.items) {
                              if (cart.add(p, 1)) added++;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('$added produk dimasukkan ke keranjang.')),
                            );
                          },
                          child: const Text('Tambahkan Semua', style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: wishlist.items.length,
                    itemBuilder: (context, idx) {
                      final item = wishlist.items[idx];
                      final price = Formatters.discountedPrice(item);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => DetailView(product: item)),
                            );
                          },
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: item.thumbnail,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(item.title, maxLines: 1, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('\$${price}', 
                                            style: const TextStyle(
                                            color: AppColors.primaryDeep)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add_shopping_cart, color: AppColors.primaryDeep),
                                onPressed: () {
                                  cart.add(item, 1);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Dimasukkan ke keranjang')),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: AppColors.inkSoft),
                                onPressed: () => wishlist.toggle(item),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
