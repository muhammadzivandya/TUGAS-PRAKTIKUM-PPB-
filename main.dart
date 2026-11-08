import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/theme/app_colors.dart';
import 'state/cart_provider.dart';
import 'state/products_provider.dart';
import 'state/wishlist_provider.dart';
import 'ui/views/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const ZoymartApp(),
    ),
  );
}

class ZoymartApp extends StatelessWidget {
  const ZoymartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'zoymart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Plus Jakarta Sans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primaryDeep,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
        ),
      ),
      home: const MainShell(),
    );
  }
}