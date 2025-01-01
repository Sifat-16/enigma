import 'package:dartz/dartz.dart';
import 'package:enigma/src/core/network/responses/failure_response.dart';
import 'package:enigma/src/core/utils/validators/validator.dart';
import 'package:enigma/src/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:enigma/src/shared/dependency_injection/dependency_injection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';



@GenerateMocks([AuthRemoteDataSource])
void main() {


  group("Validator Functions Testing", () {
    test("Testing emailValidator function", () {
      String? result = Validators.emailValidator("nayemgmail.com");
      expect(result, "Invalid Format");
    });

    test("Testing passwordValidator function", () {
      String? result = Validators.passwordValidator("Nayem123");
      expect(result, null);
    });
  });

}
