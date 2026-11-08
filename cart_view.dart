import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_colors.dart';
import '../../state/cart_provider.dart';
import '../format/formatters.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final TextEditingController _voucherController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final summary = cart.summary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Keranjang Belanja', style: TextStyle(color: AppColors.neutral, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (cart.lines.isNotEmpty)
            TextButton(
              onPressed: () => cart.removeSelected(),
              child: const Text('Hapus', style: TextStyle(color: AppColors.primaryDeep)),
            )
        ],
      ),
      body: cart.lines.isEmpty
          ? const Center(
              child: Text('Keranjang belanja kosong', style: TextStyle(color: AppColors.inkSoft)),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.lines.length,
                    itemBuilder: (context, idx) {
                      final line = cart.lines[idx];
                      final price = Formatters.discountedPrice(line.product);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: line.selected,
                              activeColor: AppColors.primaryDeep,
                              onChanged: (_) => cart.toggleSelected(line.product.id),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: line.product.thumbnail,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(line.product.title,
                                      maxLines: 1, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('\$$price{price}',
                                      style: const TextStyle(color: AppColors.primaryDeep, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                                  onPressed: line.qty > 1 ? () => cart.setQty(line.product.id, line.qty - 1) : null,
                                ),
                                Text('\${line.qty}'),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 20),
                                  onPressed: line.qty < line.product.stock
                                      ? () => cart.setQty(line.product.id, line.qty + 1)
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _voucherController,
                                decoration: const InputDecoration(
                                  hintText: 'Kode Voucher (ZOYPASTEL)',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                              onPressed: () {
                                final res = cart.applyVoucher(_voucherController.text);
                                if (res == 'SUKSES') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Voucher -\$10.00 berhasil diterapkan!')),
                                  );
                                } else if (res == 'MINIMUM_KURANG') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Subtotal belanja minimal \$50 untuk voucher ini.')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Kode voucher tidak valid.')),
                                  );
                                }
                              },
                              child: const Text('Pasang', style: TextStyle(color: AppColors.neutral)),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal:'),
                            Text('\${summary.subtotal}'),
                          ],
                        ),
                        if (summary.voucherDiscount > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Diskon Voucher:'),
                              Text('-\${summary.voucherDiscount}', style: const TextStyle(color: Colors.green)),
                            ],
                          ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Pembayaran:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('\${summary.total}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryDeep)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDeep,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: summary.total <= 0
                              ? null
                              : () async {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                                  );
                                  await cart.checkout();
                                  if (mounted) {
                                    Navigator.pop(context);
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Pembayaran Berhasil! 🎉'),
                                        content: const Text('Terima kasih telah berbelanja di zoymart.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('OK'),
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                },
                          child: const Text('Lanjut ke Pembayaran →',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
