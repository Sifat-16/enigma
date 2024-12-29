import 'package:dartz/dartz.dart';
import 'package:enigma/src/core/network/remote/firebase/firebase_handler.dart';
import 'package:enigma/src/core/network/responses/failure_response.dart';
import 'package:enigma/src/core/network/responses/success_response.dart';
import 'package:enigma/src/core/utils/logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDataSource {
  Future<Either<Failure, User>> signUp({required String email, required String password}) async {
    Failure failure;
    try {
      UserCredential userCredential =
          await FirebaseHandler.auth.createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user!.sendEmailVerification();
      return Right(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          failure = Failure(message: 'The email address is already in use by another account.');
          break;
        case 'invalid-email':
          failure = Failure(message: 'The email address is not valid.');
          break;
        case 'operation-not-allowed':
          failure = Failure(message: 'Email/password accounts are not enabled.');
          break;
        case 'weak-password':
          failure = Failure(message: 'The password is too weak.');
          break;
        case 'too-many-requests':
          failure = Failure(message: 'Too many requests. Please try again later.');
          break;
        case 'network-request-failed':
          failure = Failure(message: 'Network error. Please check your connection.');
          break;
        case 'user-token-expired':
          failure = Failure(message: 'Your session has expired. Please log in again.');
          break;
        default:
          failure = Failure(message: 'An unknown error occurred.');
          break;
      }
    }
    return Left(failure);
  }

  Future<Either<Failure, User>> signIn({required String email, required String password}) async {
    Failure failure;
    try {
      UserCredential userCredential =
          await FirebaseHandler.auth.signInWithEmailAndPassword(email: email, password: password);

      if (!userCredential.user!.emailVerified) {
        // If email is not verified, return failure
        failure = Failure(message: 'Email is not verified. Please verify your email.');
        return Left(failure);
      }
      return Right(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          failure = Failure(message: 'The email address is not valid.');
          break;
        case 'user-disabled':
          failure = Failure(message: 'This user has been disabled.');
          break;
        case 'user-not-found':
          failure = Failure(message: 'No user found for that email.');
          break;
        case 'wrong-password':
          failure = Failure(message: 'Incorrect password. Please try again.');
          break;
        case 'too-many-requests':
          failure = Failure(message: 'Too many requests. Please try again later.');
          break;
        case 'network-request-failed':
          failure = Failure(message: 'Network error. Please check your connection.');
          break;
        case 'user-token-expired':
          failure = Failure(message: 'Your session has expired. Please log in again.');
          break;
        case 'operation-not-allowed':
          failure = Failure(message: 'Email/password accounts are not enabled.');
          break;
        case 'invalid-credential':
          failure = Failure(message: 'Invalid login credentials.');
          break;
        default:
          failure = Failure(message: 'An unknown error occurred.');
          break;
      }
    }
    return Left(failure);
  }

  Future<Either<Failure, Success>> logout() async {
    Failure failure;
    try {
      await FirebaseHandler.auth.signOut();
      return Right(Success(message: "Logout successful"));
    } catch (e) {
      failure = Failure(message: "An unknown error occurred.");
    }
    return Left(failure);
  }

  Future<Either<Failure, Success>> changePassword({required String password}) async {
    Failure failure;
    try {
      await FirebaseHandler.auth.currentUser!.updatePassword(password);
      return Right(Success(message: "Change password successful"));
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          failure = Failure(message: 'The new password is too weak.');
          break;
        case 'requires-recent-login':
          failure = Failure(message: 'Please re-authenticate to change your password.');
          break;
        case 'network-request-failed':
          failure = Failure(message: 'Network error. Please check your connection.');
          break;
        default:
          failure = Failure(message: 'An unknown error occurred.');
          break;
      }
      return Left(failure);
    }
  }

  Future<Either<Failure, Success>> updateEmail({required String email}) async {
    Failure failure;

    try {
      await FirebaseHandler.auth.currentUser!.verifyBeforeUpdateEmail(email);
      return Right(Success(message: "Verification email sent successfully"));
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          failure = Failure(message: 'The email address is not valid.');
          break;
        case 'email-already-in-use':
          failure = Failure(message: 'The email address is already in use by another account.');
          break;
        case 'requires-recent-login':
          failure = Failure(message: 'Please re-authenticate to update your email.');
          break;
        case 'network-request-failed':
          failure = Failure(message: 'Network error. Please check your connection.');
          break;
        default:
          debug("errorrr");
          failure = Failure(message: 'An unknown error occurred.');
          break;
      }
      return Left(failure);
    }
  }

  /// Forgot Password
  Future<Either<Failure, Success>> forgotPassword({required String email}) async {
    try {
      await FirebaseHandler.auth.sendPasswordResetEmail(email: email);
      return Right(Success(message: 'Password reset email sent successfully to $email.'));
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return Left(Failure(message: 'The email address is not valid.'));
        case 'user-not-found':
          return Left(Failure(message: 'No user found for that email.'));
        case 'too-many-requests':
          return Left(Failure(message: 'Too many requests. Please try again later.'));
        case 'network-request-failed':
          return Left(Failure(message: 'Network error. Please check your connection.'));
        default:
          return Left(Failure(message: 'An unknown error occurred.'));
      }
    } catch (e) {
      return Left(Failure(message: 'An unexpected error occurred.'));
    }
  }
}
