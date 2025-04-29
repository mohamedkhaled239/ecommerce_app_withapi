import 'package:dartz/dartz.dart';
import 'package:ecommerce_task/features/product/data/models/product_model.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/cart_repository.dart';

class AddToCart {
  final CartRepository repository;

  AddToCart(this.repository);

  Future<Either<Failure, void>> call(ProductModel product) async {
    return await repository.addToCart(product);
  }
}
