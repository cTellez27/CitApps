import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class UpdateProductUseCase {
  final ProductRepository repository;

  const UpdateProductUseCase(this.repository);

  Future<Either<Failure, ProductEntity>> execute(ProductEntity product) {
    return repository.updateProduct(product);
  }
}
