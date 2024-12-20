import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:enigma/src/core/network/responses/failure_response.dart';
import 'package:enigma/src/core/network/responses/success_response.dart';
import 'package:enigma/src/shared/data/data_source/remote/media_remote_data_source.dart';
import 'package:enigma/src/shared/domain/repository/media_repository.dart';

class MediaRepositoryImpl extends MediaRepository {
  final MediaRemoteDataSource _mediaRemoteDataSource = MediaRemoteDataSource();

  @override
  Future<Either<Failure, Success>> addMediaImage(
      {required File file,
      required String directory,
      required String fileName}) async {
    Either<Failure, Success> response = await _mediaRemoteDataSource
        .addMediaImage(file: file, directory: directory, fileName: fileName);
    return response;
  }
}
