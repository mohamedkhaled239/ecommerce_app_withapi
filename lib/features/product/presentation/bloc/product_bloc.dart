import 'package:ecommerce_task/features/product/presentation/bloc/product_event.dart';
import 'package:ecommerce_task/features/product/presentation/bloc/product_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_all_products.dart';
import '../../domain/usecases/get_product_details.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetAllProducts getAllProducts;
  final GetProductDetails getProductDetails;

  ProductBloc({required this.getAllProducts, required this.getProductDetails})
    : super(ProductInitial()) {
    on<FetchProductsEvent>(_onFetchProducts);
    on<FetchProductDetailsEvent>(_onFetchProductDetails);
    on<ResetProductStateEvent>(_onResetState);
  }

  Future<void> _onFetchProducts(
    FetchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    final result = await getAllProducts();
    result.fold(
      (failure) => emit(ProductError(message: failure.toString())),
      (products) => emit(ProductsLoaded(products: products)),
    );
  }

  Future<void> _onFetchProductDetails(
    FetchProductDetailsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    final result = await getProductDetails(event.productId);
    result.fold(
      (failure) => emit(ProductError(message: failure.toString())),
      (product) => emit(ProductDetailLoaded(product: product)),
    );
  }

  void _onResetState(ResetProductStateEvent event, Emitter<ProductState> emit) {
    emit(ProductInitial());
  }
}
