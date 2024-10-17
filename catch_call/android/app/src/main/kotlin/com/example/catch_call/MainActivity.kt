package com.example.catch_call

import android.content.Context
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.DataOutputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.flutter_call_auto/call"

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "startListening") {
                startCallListening()
                result.success("Listening started")
            } else {
                result.notImplemented()
            }
        }
    }

    private fun startCallListening() {
        val telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        val phoneStateListener = object : PhoneStateListener() {
            override fun onCallStateChanged(state: Int, phoneNumber: String?) {
                when (state) {
                    TelephonyManager.CALL_STATE_RINGING -> {
                        // 전화가 울릴 때 자동 통화 받기
                        acceptCall()
                    }
                    TelephonyManager.CALL_STATE_OFFHOOK -> {
                        // 통화 중에 # 버튼 누르기
                        pressHashKey()
                    }
                    TelephonyManager.CALL_STATE_IDLE -> {
                        // 통화 종료
                        println("전화가 종료되었습니다.")
                    }
                }
            }
        }

        telephonyManager.listen(phoneStateListener, PhoneStateListener.LISTEN_CALL_STATE)
    }

    private fun acceptCall() {
        try {
            val process = Runtime.getRuntime().exec("su")
            val os = DataOutputStream(process.outputStream)
            os.writeBytes("input keyevent KEYCODE_CALL\n")  // 통화 받기
            os.flush()
            os.writeBytes("exit\n")
            os.flush()
            os.close()
            process.waitFor()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun pressHashKey() {
        try {
            val process = Runtime.getRuntime().exec("su")
            val os = DataOutputStream(process.outputStream)
            os.writeBytes("input keyevent KEYCODE_POUND\n")  // # 버튼 누르기
            os.flush()
            os.writeBytes("exit\n")
            os.flush()
            os.close()
            process.waitFor()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
