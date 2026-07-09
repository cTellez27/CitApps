import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;

  const GetProductsUseCase(this.repository);

  Future<Either<Failure, List<ProductEntity>>> execute(String barbershopId) {
    return repository.getProducts(barbershopId);
  }
}
