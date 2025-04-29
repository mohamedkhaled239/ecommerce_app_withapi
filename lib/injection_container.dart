import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

import 'core/network/dio_client.dart';
import 'core/network/network_info.dart';
import 'features/product/data/datasources/product_local_data_source.dart';
import 'features/product/data/datasources/product_remote_data_source.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/product/domain/repositories/product_repository.dart';
import 'features/product/domain/usecases/get_all_products.dart';
import 'features/product/domain/usecases/get_product_details.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/cart/data/datasources/cart_local_data_source.dart';
import 'features/cart/data/repositories/cart_repository_impl.dart';
import 'features/cart/domain/repositories/cart_repository.dart';
import 'features/cart/domain/usecases/add_to_cart.dart';
import 'features/cart/domain/usecases/get_cart_items.dart';
import 'features/cart/domain/usecases/remove_from_cart.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => Connectivity());

  // Core
  sl.registerLazySingleton(() => DioClient(dio: sl()));
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Database
  final database = await _initDatabase();
  sl.registerLazySingleton(() => database);

  // Product Feature
  _initProductFeature();

  // Cart Feature
  _initCartFeature();
}

Future<Database> _initDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'fake_store.db');

  return await openDatabase(
    path,
    version: 2, // Incremented version
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY,
          title TEXT NOT NULL,
          price REAL NOT NULL,
          description TEXT NOT NULL,
          category TEXT NOT NULL,
          image TEXT NOT NULL,
          rate REAL NOT NULL,
          count INTEGER NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE cart (
          id INTEGER PRIMARY KEY,
          title TEXT NOT NULL,
          price REAL NOT NULL,
          description TEXT NOT NULL,
          category TEXT NOT NULL,
          image TEXT NOT NULL,
          rate REAL NOT NULL,
          count INTEGER NOT NULL
        )
      ''');
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute('DROP TABLE IF EXISTS products');
        await db.execute('DROP TABLE IF EXISTS cart');
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            price REAL NOT NULL,
            description TEXT NOT NULL,
            category TEXT NOT NULL,
            image TEXT NOT NULL,
            rate REAL NOT NULL,
            count INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE cart (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            price REAL NOT NULL,
            description TEXT NOT NULL,
            category TEXT NOT NULL,
            image TEXT NOT NULL,
            rate REAL NOT NULL,
            count INTEGER NOT NULL
          )
        ''');
      }
    },
  );
}

void _initProductFeature() {
  // Data sources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(database: sl()),
  );

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllProducts(sl()));
  sl.registerLazySingleton(() => GetProductDetails(sl()));

  // Bloc
  sl.registerFactory(
    () => ProductBloc(getAllProducts: sl(), getProductDetails: sl()),
  );
}

void _initCartFeature() {
  // Data sources
  sl.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(database: sl()),
  );

  // Repository
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => AddToCart(sl()));
  sl.registerLazySingleton(() => GetCartItems(sl()));
  sl.registerLazySingleton(() => RemoveFromCart(sl()));

  // Bloc
  sl.registerFactory(
    () => CartBloc(addToCart: sl(), getCartItems: sl(), removeFromCart: sl()),
  );
}
