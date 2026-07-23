import 'package:dartz/dartz.dart';
import 'package:citapps/core/errors/exceptions.dart';
import 'package:citapps/core/errors/failures.dart';
import 'package:citapps/features/chatbot/data/datasources/chatbot_remote_data_source.dart';
import 'package:citapps/features/chatbot/domain/entities/chat_message.dart';
import 'package:citapps/features/chatbot/domain/repositories/chatbot_repository.dart';

class ChatbotRepositoryImpl implements ChatbotRepository {
  final ChatbotRemoteDataSource remoteDataSource;

  ChatbotRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ChatMessage>> sendMessage({
    required List<ChatMessage> history,
    required String message,
  }) async {
    try {
      final botResponseModel = await remoteDataSource.sendMessage(
        history: history,
        message: message,
      );
      return Right(botResponseModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }
}
