import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';

main() {
  runApp(
    const MaterialApp(
      home: Example(),
    ),
  );
}

class Example extends StatefulWidget {
  const Example({Key? key}) : super(key: key);

  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  PhoneStateStatus status = PhoneStateStatus.NOTHING;
  int permissionCount = 0;
  bool dialogOpen = false;
  String dialogContent = "";
  bool granted = false;

  @override
  void initState() {
    super.initState();
    getPermission();
  }

  void setStream() {
    PhoneState.phoneStateStream.listen((event) {
      setState(() {
        if (event != null) {
          status = event;
        }
      });
    });
  }

  void getPermission() async {
    var status = await Permission.phone.request();
    if(status.isGranted){
      print('권한 부여');
      setState(() => setStream());
    }else if(status.isDenied) {
      print('권한이 없습니다.');
      if(permissionCount > 0){
        Permission.phone.request();
        setState(() => {permissionCount = 1});
      }
      if(Platform.isIOS) exit(0);
      if(Platform.isAndroid) SystemNavigator.pop();

    }else if(status.isPermanentlyDenied){
      openAppSettings();
    }else{
      if(Platform.isIOS) exit(0);
      if(Platform.isAndroid) SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (Platform.isAndroid)
            const Text(
              "전화 수신",
              style: TextStyle(fontSize: 24),
            ),
            Icon(
              getIcons(),
              color: getColor(),
              size: 80,
            )
          ],
        ),
      ),
    );
  }

  IconData getIcons() {
    switch (status) {
      case PhoneStateStatus.NOTHING:
        return Icons.call_end;
      case PhoneStateStatus.CALL_INCOMING:
        return Icons.add_call;
      case PhoneStateStatus.CALL_STARTED:
        return Icons.call;
      case PhoneStateStatus.CALL_ENDED:
        return Icons.call_end;
    }
  }

  Color getColor() {
    switch (status) {
      case PhoneStateStatus.NOTHING:
      case PhoneStateStatus.CALL_ENDED:
        return Colors.red;
      case PhoneStateStatus.CALL_INCOMING:
        return Colors.green;
      case PhoneStateStatus.CALL_STARTED:
        return Colors.orange;
    }
  }
}