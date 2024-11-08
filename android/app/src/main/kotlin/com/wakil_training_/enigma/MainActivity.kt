package com.wakil_training_.enigma

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Person
import androidx.core.app.Person as Person2

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import com.wakil_training_.enigma.services.MyCallNotificationService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "skywalker_notification"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "showCallNotification") {
                showCallNotification()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }


    private fun showCallNotification() {


        if(Build.VERSION.SDK_INT>=Build.VERSION_CODES.S){
            val incomingCaller = Person.Builder()
                .setName("Jane Doe")
                .setImportant(true)
                .build()
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val channelId = "call_channel"
            val channelName = "Call Notification"

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_HIGH)
                notificationManager.createNotificationChannel(channel)
            }

            val intent = Intent(this, MainActivity::class.java)  // Update to target a specific screen if needed
            val pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_MUTABLE)

            // Define intents for "Answer" and "Decline" actions
            val answerIntent = Intent(this, CallActionReceiver::class.java).apply {
                action = "ACTION_ANSWER_CALL"
            }
            val declineIntent = Intent(this, CallActionReceiver::class.java).apply {
                action = "ACTION_DECLINE_CALL"
            }

            val answerPendingIntent = PendingIntent.getBroadcast(this, 0, answerIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE)
            val declinePendingIntent = PendingIntent.getBroadcast(this, 1, declineIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE)

            // Intent to open the app when notification is tapped
            val openAppIntent = Intent(this, MainActivity::class.java)
            val openAppPendingIntent = PendingIntent.getActivity(this, 0, openAppIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE)

            val notification = Notification.Builder(this, channelId)
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
            val incomingCaller = Person2.Builder()
                .setName("Jane Doe")
                .setImportant(true)
                .build()
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val channelId = "call_channel"
            val channelName = "Call Notification"

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_HIGH)
                notificationManager.createNotificationChannel(channel)
            }

            val intent = Intent(this, MainActivity::class.java)  // Update to target a specific screen if needed
            val pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_MUTABLE)

            // Define intents for "Answer" and "Decline" actions
            val answerIntent = Intent(this, CallActionReceiver::class.java).apply {
                action = "ACTION_ANSWER_CALL"
            }
            val declineIntent = Intent(this, CallActionReceiver::class.java).apply {
                action = "ACTION_DECLINE_CALL"
            }

            val answerPendingIntent = PendingIntent.getBroadcast(this, 0, answerIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE)
            val declinePendingIntent = PendingIntent.getBroadcast(this, 1, declineIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE)

            // Intent to open the app when notification is tapped
            val openAppIntent = Intent(this, MainActivity::class.java)
            val openAppPendingIntent = PendingIntent.getActivity(this, 0, openAppIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE)

            val notification = NotificationCompat.Builder(this, channelId)
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


}

// BroadcastReceiver to handle call actions
class CallActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            "ACTION_ANSWER_CALL" -> {
                // Handle answering the call
                // This could involve starting an activity, service, or some other action
            }
            "ACTION_DECLINE_CALL" -> {
                // Handle declining the call
                // You might want to stop a service or close a call interface here
            }
        }
    }
}

//saefjsifusifuifuihn
//sdkfjaseilfjaweilfailwefbaweifuhaifuwi
