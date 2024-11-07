package com.wakil_training_.enigma
// For Audio Record v
// For Memomry Information v
import android.Manifest
import android.app.ActivityManager
import android.content.Context
import android.content.pm.PackageManager
import android.media.MediaRecorder
import android.os.ParcelFileDescriptor
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.io.InputStream


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.wakil_training_.enigma/info"
    private var fileName: String = ""
    private var recorder: MediaRecorder? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getMemoryInfo") {
                val memoryInfo = getMemoryInfo()
                result.success(memoryInfo)
            } else if(call.method == "startRecording"){
                val isGranted = checkPermissions()
                if(isGranted){
                    startRecording()
                    result.success("Recording Started")
                } else{
                    result.error("", "Permission denied", null)
                }

            } else if(call.method == "stopRecording"){
                stopRecording()
                result.success(fileName)
            }
            else {
                result.notImplemented()
            }
        }
    }

    private fun getMemoryInfo():  Map<String, Long> {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memoryInfo = ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(memoryInfo)
        // Return the available memory in MB
        val availableMemory = (memoryInfo.availMem).toLong()
        val totalMemory = (memoryInfo.totalMem).toLong()
        println(totalMemory)
        println(availableMemory)
        return  mapOf("availableMemory" to availableMemory, "totalMemory" to totalMemory)
    }

    private fun checkPermissions(): Boolean {
        val recordPermission = ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
        return recordPermission == PackageManager.PERMISSION_GRANTED
    }

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
                        println(data.size)
                        byteArrayOutputStream.write(data, 0, read)
                        println(byteArrayOutputStream.size())
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

