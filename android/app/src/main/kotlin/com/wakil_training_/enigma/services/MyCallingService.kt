package com.wakil_training_.enigma.services

import android.annotation.SuppressLint
import com.google.firebase.messaging.RemoteMessage
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService

@SuppressLint("MissingFirebaseInstanceTokenRefresh")
class MyCallingService: FlutterFirebaseMessagingService() {

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)

    }

}