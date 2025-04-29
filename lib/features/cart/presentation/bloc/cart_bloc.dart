import 'package:ecommerce_task/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecommerce_task/features/cart/presentation/bloc/cart_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/add_to_cart.dart';
import '../../domain/usecases/get_cart_items.dart';
import '../../domain/usecases/remove_from_cart.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final AddToCart addToCart;
  final GetCartItems getCartItems;
  final RemoveFromCart removeFromCart;

  CartBloc({
    required this.addToCart,
    required this.getCartItems,
    required this.removeFromCart,
  }) : super(CartInitial()) {
    on<AddProductToCart>(_onAddProductToCart);
    on<LoadCartItems>(_onLoadCartItems);
    on<RemoveProductFromCart>(_onRemoveProductFromCart);
  }

  Future<void> _onAddProductToCart(
    AddProductToCart event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    final result = await addToCart(event.product);
    result.fold(
      (failure) => emit(CartError(message: failure.toString())),
      (_) => emit(ProductAddedToCart()),
    );
  }

  Future<void> _onLoadCartItems(
    LoadCartItems event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    final result = await getCartItems();
    result.fold(
      (failure) => emit(CartError(message: failure.toString())),
      (cartItems) => emit(CartLoaded(cartItems: cartItems)),
    );
  }

  Future<void> _onRemoveProductFromCart(
    RemoveProductFromCart event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    final result = await removeFromCart(event.productId);
    result.fold(
      (failure) => emit(CartError(message: failure.toString())),
      (_) => emit(ProductRemovedFromCart()),
    );
  }
}
