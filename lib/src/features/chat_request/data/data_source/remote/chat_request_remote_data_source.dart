import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:enigma/src/core/network/remote/firebase/firebase_handler.dart';
import 'package:enigma/src/core/network/remote/firebase/firestore_collection_name.dart';
import 'package:enigma/src/core/network/responses/failure_response.dart';
import 'package:enigma/src/core/utils/logger/logger.dart';
import 'package:enigma/src/features/chat_request/data/model/chat_request_model.dart';
import 'package:enigma/src/features/chat_request/domain/entity/chat_request_entity.dart';
import 'package:enigma/src/features/profile/domain/dto/filter_dto.dart';

class ChatRequestRemoteDataSource {
  Future<Either<Failure, ChatRequestModel>> sendChatRequest(
      {required ChatRequestEntity chatRequestEntity}) async {
    Failure failure = Failure(message: "");
    try {
      String a = chatRequestEntity.senderUid ?? "";
      String b = chatRequestEntity.receiverUid ?? "";
      String docId = a + b;

      FirebaseHandler.fireStore
          .collection(FirestoreCollectionName.chatRequestCollection)
          .doc(docId)
          .set(chatRequestEntity.toJson());

      return Right(chatRequestEntity.toModel());
    } on FirebaseException catch (e) {
      // Handle Firebase-specific errors with switch-case on the error code
      switch (e.code) {
        case 'permission-denied':
          failure = Failure(
              message: "You don't have permission to perform this action.");
          break;
        case 'unavailable':
          failure = Failure(
              message:
                  "Firestore service is currently unavailable. Please try again later.");
          break;
        case 'not-found':
          failure = Failure(message: "The requested document was not found.");
          break;
        case 'already-exists':
          failure = Failure(message: "The document already exists.");
          break;
        case 'cancelled':
          failure = Failure(message: "The operation was cancelled.");
          break;
        case 'deadline-exceeded':
          failure = Failure(
              message:
                  "The operation took too long to complete. Please try again.");
          break;
        case 'invalid-argument':
          failure = Failure(
              message:
                  "Invalid data provided. Please check the input and try again.");
          break;
        case 'network-error':
          failure = Failure(
              message:
                  "A network error occurred. Please check your connection.");
          break;
        default:
          failure = Failure(
              message: e.message ?? "An unknown Firebase error occurred.");
          break;
      }
    } catch (e) {
      // Handle any other generic errors
      failure =
          Failure(message: "An unexpected error occurred: ${e.toString()}");
    }
    return Left(failure);
  }

  Future<Either<Failure, List<ChatRequestEntity>>> fetchPendingRequest(
      {FilterDto? filter}) async {
    Failure failure = Failure(message: "");
    List<ChatRequestEntity> pendingRequests = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseHandler
          .fireStore
          .collection(FirestoreCollectionName.chatRequestCollection)
          .where("status", isEqualTo: "pending")
          .where("senderUid",
              isEqualTo: FirebaseHandler.auth.currentUser?.uid ?? "")
          .get();

      // await FirebaseHandler.get(
      //     collectionName: FirestoreCollectionName.chatRequestCollection,
      //     where: filter?.firebaseWhereModel);
      for (QueryDocumentSnapshot q in querySnapshot.docs) {
        Map<String, dynamic> data = q.data() as Map<String, dynamic>;
        pendingRequests.add(ChatRequestEntity.fromJson(data));
      }
      for (ChatRequestEntity c in pendingRequests) {
        debug(c.receiverUid);
      }
      return Right(pendingRequests);
    } on FirebaseException catch (e) {
      // Handle Firebase-specific errors with switch-case on the error code
      switch (e.code) {
        case 'permission-denied':
          failure = Failure(
              message: "You don't have permission to perform this action.");
          break;
        case 'unavailable':
          failure = Failure(
              message:
                  "Firestore service is currently unavailable. Please try again later.");
          break;
        case 'not-found':
          failure = Failure(message: "The requested document was not found.");
          break;
        case 'already-exists':
          failure = Failure(message: "The document already exists.");
          break;
        case 'cancelled':
          failure = Failure(message: "The operation was cancelled.");
          break;
        case 'deadline-exceeded':
          failure = Failure(
              message:
                  "The operation took too long to complete. Please try again.");
          break;
        case 'invalid-argument':
          failure = Failure(
              message:
                  "Invalid data provided. Please check the input and try again.");
          break;
        case 'network-error':
          failure = Failure(
              message:
                  "A network error occurred. Please check your connection.");
          break;
        default:
          failure = Failure(
              message: e.message ?? "An unknown Firebase error occurred.");
          break;
      }
    } catch (e) {
      // Handle any other generic errors
      debug(e.toString());
      failure =
          Failure(message: "An unexpected error occurred: ${e.toString()}");
    }
    return Left(failure);
  }

  updateRequestStatus(String status) {}

  Future<Either<Failure, List<ChatRequestEntity>>> fetchChatRequest(
      {FilterDto? filter}) async {
    Failure failure = Failure(message: "");
    List<ChatRequestEntity> pendingRequests = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseHandler
          .fireStore
          .collection(FirestoreCollectionName.chatRequestCollection)
          .get();
      String userUid = FirebaseHandler.auth.currentUser?.uid ?? "";
      for (var q in querySnapshot.docs) {
        bool doesExist =
            q.id.contains(FirebaseHandler.auth.currentUser?.uid ?? "");
        Map<String, dynamic> data = q.data();
        if (doesExist) {
          if (data["receiverUid"] == userUid && data["status"] == "pending") {
            pendingRequests.add(ChatRequestEntity.fromJson(data));
          }
        }
      }

      return Right(pendingRequests);
    } on FirebaseException catch (e) {
      // Handle Firebase-specific errors with switch-case on the error code
      switch (e.code) {
        case 'permission-denied':
          failure = Failure(
              message: "You don't have permission to perform this action.");
          break;
        case 'unavailable':
          failure = Failure(
              message:
                  "Firestore service is currently unavailable. Please try again later.");
          break;
        case 'not-found':
          failure = Failure(message: "The requested document was not found.");
          break;
        case 'already-exists':
          failure = Failure(message: "The document already exists.");
          break;
        case 'cancelled':
          failure = Failure(message: "The operation was cancelled.");
          break;
        case 'deadline-exceeded':
          failure = Failure(
              message:
                  "The operation took too long to complete. Please try again.");
          break;
        case 'invalid-argument':
          failure = Failure(
              message:
                  "Invalid data provided. Please check the input and try again.");
          break;
        case 'network-error':
          failure = Failure(
              message:
                  "A network error occurred. Please check your connection.");
          break;
        default:
          failure = Failure(
              message: e.message ?? "An unknown Firebase error occurred.");
          break;
      }
    } catch (e) {
      // Handle any other generic errors
      debug(e.toString());
      failure =
          Failure(message: "An unexpected error occurred: ${e.toString()}");
    }
    return Left(failure);
  }
}