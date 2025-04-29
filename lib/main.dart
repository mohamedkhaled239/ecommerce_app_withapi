import 'package:ecommerce_task/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecommerce_task/features/product/presentation/bloc/product_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;
import 'features/product/presentation/pages/product_list_page.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Clear existing database if needed (for debugging)
  // await _resetDatabase();

  await di.init();

  runApp(const MyApp());
}

// Future<void> _resetDatabase() async {
//   final dbPath = await getDatabasesPath();
//   final path = join(dbPath, 'fake_store.db');
//   try {
//     await deleteDatabase(path);
//     debugPrint('Old database deleted');
//   } catch (e) {
//     debugPrint('Error deleting database: $e');
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<ProductBloc>()..add(FetchProductsEvent()),
        ),
        BlocProvider(
          create: (context) => di.sl<CartBloc>()..add(LoadCartItems()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            primary: Colors.deepPurple,
            secondary: Colors.deepOrange,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 2,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          cardTheme: CardTheme(
            elevation: 2,
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          useMaterial3: true,
        ),
        home: const ProductListPage(),
      ),
    );
  }
}
