import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const platform = MethodChannel('com.example.flutter_call_auto/call');

  Future<void> startListening() async {
    try {
      final String result = await platform.invokeMethod('startListening');
      print(result);
    } on PlatformException catch (e) {
      print("Failed to start listening: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('전화 자동 응답 및 # 버튼 누르기'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: startListening,
            child: Text('전화 수신 감지 시작'),
          ),
        ),
      ),
    );
  }
}
