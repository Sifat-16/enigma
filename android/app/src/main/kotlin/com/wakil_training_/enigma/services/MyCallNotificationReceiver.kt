package com.wakil_training_.enigma.services

import android.app.ActivityManager
import android.app.KeyguardManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Person
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.RemoteMessage
import com.wakil_training_.enigma.CallActionReceiver
import com.wakil_training_.enigma.MainActivity
import com.wakil_training_.enigma.R
import com.wakil_training_.enigma.models.PushBodyModel
import io.flutter.Log
import io.flutter.plugins.firebase.messaging.ContextHolder
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingReceiver
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingStore
import io.flutter.plugins.firebase.messaging.FlutterFirebaseRemoteMessageLiveData


class MyCallNotificationReceiver: FlutterFirebaseMessagingReceiver() {

    val TAG = "CALL_FROM_NATIVE_CHECK_RECEIVER"
    var notifications: HashMap<String?, RemoteMessage> = HashMap()
    var pushBodyModel: PushBodyModel = PushBodyModel();

    override fun onReceive(context: Context, intent: Intent) {
        Log.w(TAG, "broadcast received for message")
        if (ContextHolder.getApplicationContext() == null) {
            var aContext: Context? = context
            if (context.applicationContext != null) {
                aContext = context.applicationContext
            }

            ContextHolder.setApplicationContext(aContext)
        }


        if (intent.extras == null) {
            Log.w(
                TAG,
                "broadcast received but intent contained no extras to process RemoteMessage. Operation cancelled."
            )
            return
        }

        val remoteMessage = RemoteMessage(intent.extras)

        // Store the RemoteMessage if the message contains a notification payload.
        if (remoteMessage.notification != null) {
            notifications[remoteMessage.messageId] = remoteMessage
            FlutterFirebaseMessagingStore.getInstance().storeFirebaseMessage(remoteMessage)
        }


        // TODO(developer): Handle FCM messages here.
        // Not getting messages here? See why this may be: https://goo.gl/39bRNJ
        Log.w(TAG, "From: ${remoteMessage.from}")

        // Check if message contains a data payload.
        if (remoteMessage.data.isNotEmpty()) {
            val pushBodyModel = PushBodyModel.fromJson(remoteMessage.data);
            Log.w(TAG, "Message data payload: ${remoteMessage.data}")
            Log.w(TAG, "PushBodyModel: $pushBodyModel");
        }

        // Check if message contains a notification payload.
        remoteMessage.notification?.let {
            Log.w(TAG, "Message Notification Body: ${it.body}")
        }

        if(pushBodyModel.type == "incoming_call"){
            if(isApplicationForeground(context)){
                Log.w(TAG, "IN FOREGROUND STATE")
                return
            }else{
                Log.w(TAG, "NOT IN FOREGROUND STATE")
                showCallNotification(context)
            }
        }else{
            return
        }




//        //  |-> ---------------------
//        //      App in Foreground
//        //   ------------------------
//        if (FlutterFirebaseMessagingUtils.isApplicationForeground(context)) {
//            if(pushBodyModel.type == "incoming_call") {
//                return;
//            }
//            FlutterFirebaseRemoteMessageLiveData.getInstance().postRemoteMessage(remoteMessage)
//            return
//        }
//
//        //  |-> ---------------------
//        //    App in Background/Quit
//        //   ------------------------
//        val onBackgroundMessageIntent =
//            Intent(context, FlutterFirebaseMessagingBackgroundService::class.java)
//
//        val parcel = Parcel.obtain()
//        remoteMessage.writeToParcel(parcel, 0)
//        // We write to parcel using RemoteMessage.writeToParcel() to pass entire RemoteMessage as array of bytes
//        // Which can be read using RemoteMessage.createFromParcel(parcel) API
//        onBackgroundMessageIntent.putExtra(
//            FlutterFirebaseMessagingUtils.EXTRA_REMOTE_MESSAGE, parcel.marshall()
//        )
//
//        FlutterFirebaseMessagingBackgroundService.enqueueMessageProcessing(
//            context,
//            onBackgroundMessageIntent,
//            remoteMessage.originalPriority == RemoteMessage.PRIORITY_HIGH
//        )
    }

    private fun showCallNotification(context: Context) {
        Log.w(TAG, "IN SHOWCALLNOTIFICATION");
        if(Build.VERSION.SDK_INT>= Build.VERSION_CODES.S){
            Log.w(TAG, "IN IF BLOCK");
            val incomingCaller = Person.Builder()
                .setName("Jane Doe")
                .setImportant(true)
                .build()


            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val channelId = "call_channel"
            val channelName = "Call Notification"

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_HIGH)
                notificationManager.createNotificationChannel(channel)
            }


            val intent = Intent(context, MainActivity::class.java)  // Update to target a specific screen if needed
            val pendingIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_MUTABLE)

            // Define intents for "Answer" and "Decline" actions
            val answerIntent = Intent(context, CallActionReceiver::class.java).apply {
                action = "ACTION_ANSWER_CALL"
            }
            val declineIntent = Intent(context, CallActionReceiver::class.java).apply {
                action = "ACTION_DECLINE_CALL"
            }

            val answerPendingIntent = PendingIntent.getBroadcast(context, 0, answerIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE)
            val declinePendingIntent = PendingIntent.getBroadcast(context, 1, declineIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE)

            // Intent to open the app when notification is tapped
            val openAppIntent = Intent(context, MainActivity::class.java)
            val openAppPendingIntent = PendingIntent.getActivity(context, 0, openAppIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE)

            val notification = Notification.Builder(context, channelId)
                .setContentIntent(openAppPendingIntent)
                .setFullScreenIntent(pendingIntent, true)
                .setSmallIcon(R.drawable.ic_call_missed)
                .setOngoing(true)
                .setAutoCancel(true)
                .setStyle(
                    Notification.CallStyle.forIncomingCall(incomingCaller, declinePendingIntent, answerPendingIntent))
                .addPerson(incomingCaller)
                .build()

            notificationManager.notify(1, notification)
        }else{
            Log.w(TAG, "IN ELSE BLOCK");
            val incomingCaller = androidx.core.app.Person.Builder()
                .setName("Jane Doe")
                .setImportant(true)
                .build()
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val channelId = "call_channel"
            val channelName = "Call Notification"

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_HIGH)
                notificationManager.createNotificationChannel(channel)
            }

            val intent = Intent(context, MainActivity::class.java)  // Update to target a specific screen if needed
            val pendingIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_MUTABLE)

            // Define intents for "Answer" and "Decline" actions
            val answerIntent = Intent(context, CallActionReceiver::class.java).apply {
                action = "ACTION_ANSWER_CALL"
            }
            val declineIntent = Intent(context, CallActionReceiver::class.java).apply {
                action = "ACTION_DECLINE_CALL"
            }

            val answerPendingIntent = PendingIntent.getBroadcast(context, 0, answerIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE)
            val declinePendingIntent = PendingIntent.getBroadcast(context, 1, declineIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE)

            // Intent to open the app when notification is tapped
            val openAppIntent = Intent(context, MainActivity::class.java)
            val openAppPendingIntent = PendingIntent.getActivity(context, 0, openAppIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE)

            val notification = NotificationCompat.Builder(context, channelId)
                .setContentIntent(openAppPendingIntent)
                .setSmallIcon(R.drawable.ic_call_missed)
                .setAutoCancel(true)
                .setFullScreenIntent(pendingIntent, true)
                .setOngoing(true)
                .setStyle(
                    NotificationCompat.CallStyle.forIncomingCall(incomingCaller, declinePendingIntent, answerPendingIntent))
                .addPerson(incomingCaller)
                .build()

            notificationManager.notify(1, notification)
        }


    }


    private fun isApplicationForeground(context: Context): Boolean {
        val keyguardManager =
            context.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager

        if (keyguardManager.isKeyguardLocked) {
            return false
        }

        val activityManager =
            context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                ?: return false

        val appProcesses =
            activityManager.runningAppProcesses ?: return false

        val packageName = context.packageName
        for (appProcess in appProcesses) {
            if (appProcess.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND && appProcess.processName == packageName) {
                return true
            }
        }

        return false
    }

}