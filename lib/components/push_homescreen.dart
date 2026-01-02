import 'dart:async';
import 'package:flutter/material.dart';
import 'package:photo_album/auth/auth.dart';
import 'package:photo_album/pages/home_screen.dart';
import 'package:photo_album/services/fetch_service.dart';

void pushToHomeScreen(context, String transitionType) async {
  final FetchService fetchService = FetchService();
  final localNameController = StreamController<Map<String, dynamic>>();

  final username = AuthService.currentUsername;
  fetchService.fetchInstantNames(username!).listen(
    (data) {
      localNameController.add(data);
    },
    onDone: () => localNameController.close(),
    onError: (error) => localNameController.addError(error),
  );

  if(transitionType == "Fade"){
    // Wait for splashscreen animation to finish too
    await Future.delayed(Duration(seconds: 2));
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => HomeScreen(
          // key: ValueKey(username),
          fileStream: localNameController.stream,
          currentFolderPath: username,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: Duration(milliseconds: 800),
      ),
    );
  }
  else{
    if(!context.mounted) return;
    // Push but with no Fade when logged in already
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(
        // key: ValueKey(username),
        fileStream: localNameController.stream,
        currentFolderPath: username
      )),
    );
  }
      
}