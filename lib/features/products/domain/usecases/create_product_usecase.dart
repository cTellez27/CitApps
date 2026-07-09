import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class CreateProductUseCase {
  final ProductRepository repository;

  const CreateProductUseCase(this.repository);

  Future<Either<Failure, ProductEntity>> execute(ProductEntity product) {
    return repository.createProduct(product);
  }
}
