import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:enigma/src/core/network/remote/firebase/document_finder.dart';
import 'package:enigma/src/core/network/remote/firebase/firebase_handler.dart';
import 'package:enigma/src/core/network/remote/firebase/firestore_collection_name.dart';
import 'package:enigma/src/core/network/responses/failure_response.dart';
import 'package:enigma/src/core/utils/id_hashing/id_hashing.dart';
import 'package:enigma/src/features/chat/data/model/chat_model.dart';
import 'package:enigma/src/features/message/data/model/message_model.dart';
import 'package:enigma/src/features/profile/domain/entity/profile_entity.dart';

class MessageRemoteDataSource {
  Future<Either<Failure, ChatModel>> getAllFriendsLastMessage(
      {required String buddyID, required String myID}) async {
    Failure failure;
    try {
      String roomID = HashGenerator.idHashing(
        myUid: myID,
        friendUid: buddyID,
      );
      bool doesExist = await DocumentFinder.checkExistence(roomID: roomID);
      // debug(roomID);
      // debug(doesExist);
      if (!doesExist) {
        roomID = HashGenerator.idHashing(
          myUid: buddyID,
          friendUid: myID,
        );
      }
      QuerySnapshot querySnapshot = await FirebaseHandler.fireStore
          .collection(FirestoreCollectionName.chatCollection)
          .doc(roomID)
          .collection(FirestoreCollectionName.messageCollection)
          .orderBy("timestamp", descending: true)
          .get();
      ChatModel lastMessage = ChatModel.fromJson(querySnapshot.docs.first.data() as Map<String, dynamic>);
      return Right(lastMessage);
    } catch (e) {
      failure = Failure(message: e.toString());
    }
    return Left(failure);
  }
}
