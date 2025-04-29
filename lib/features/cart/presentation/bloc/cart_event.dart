import 'package:ecommerce_task/features/product/data/models/product_model.dart';
import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class AddProductToCart extends CartEvent {
  final ProductModel product;

  const AddProductToCart({required this.product});

  @override
  List<Object> get props => [product];
}

class LoadCartItems extends CartEvent {}

class RemoveProductFromCart extends CartEvent {
  final int productId;

  const RemoveProductFromCart({required this.productId});

  @override
  List<Object> get props => [productId];
}
