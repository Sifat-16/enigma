import 'package:dartz/dartz.dart';
import 'package:enigma/src/core/network/responses/failure_response.dart';
import 'package:enigma/src/core/network/responses/success_response.dart';
import 'package:enigma/src/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:enigma/src/features/auth/domain/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource = AuthRemoteDataSource();

  @override
  Future<Either<Failure, User>> login({required String email, required String password}) async {
    Either<Failure, User> result = await _authRemoteDataSource.signIn(email: email, password: password);
    return result;
  }

  @override
  Future<Either<Failure, User>> signUp({required String email, required String password}) async {
    Either<Failure, User> result = await _authRemoteDataSource.signUp(email: email, password: password);
    return result;
  }

  @override
  Future<Either<Failure, Success>> logout() async {
    Either<Failure, Success> result = await _authRemoteDataSource.logout();
    return result;
  }

  @override
  Future<Either<Failure, Success>> changePassword({required String password}) async {
    Either<Failure, Success> result = await _authRemoteDataSource.changePassword(password: password);
    return result;
  }

  @override
  Future<Either<Failure, Success>> forgotPassword({required String email}) async {
    Either<Failure, Success> result = await _authRemoteDataSource.forgotPassword(email: email);
    return result;
  }

  @override
  Future<Either<Failure, Success>> updateEmail({required String email}) async {
    Either<Failure, Success> result = await _authRemoteDataSource.updateEmail(email: email);
    return result;
  }
}
