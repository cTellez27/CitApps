import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/employee_repository.dart';

class DeleteEmployeeUseCase {
  final EmployeeRepository repository;

  const DeleteEmployeeUseCase(this.repository);

  Future<Either<Failure, void>> execute(String id) {
    return repository.deleteEmployee(id);
  }
}
