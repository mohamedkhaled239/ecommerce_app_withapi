import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class FetchProductsEvent extends ProductEvent {}

class FetchProductDetailsEvent extends ProductEvent {
  final int productId;

  const FetchProductDetailsEvent(this.productId);

  @override
  List<Object> get props => [productId];
}

class ResetProductStateEvent extends ProductEvent {}  // Add this line