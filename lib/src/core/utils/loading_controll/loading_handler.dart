import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
class LoadingHandler {
  static showLoading() {
    BotToast.showCustomLoading(
      toastBuilder: (cancelFunc) {
        return Align(
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        );
      },
      clickClose: true,
      allowClick: false,
      crossPage: true,
      backgroundColor: Colors.transparent,

    );
  }


  static hideLoading() {
    BotToast.closeAllLoading();
  }
}