import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:reservation_app/firebase_options.dart';
import 'package:reservation_app/guest_book_msg.dart';

class ApplicationState extends ChangeNotifier {
  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;
  StreamSubscription<QuerySnapshot>? _guestBookSub;
  List<GuestBookMessage> _guestBookMessages = [];
  List<GuestBookMessage> get guestBookMessages => _guestBookMessages;

  ApplicationState() {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.userChanges().listen((event) {
      if (event != null) {
        _loggedIn = true;
        _guestBookSub = FirebaseFirestore.instance
            .collection("guestBook")
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshots) {
          for (var document in snapshots.docs) {
            _guestBookMessages.add(
              GuestBookMessage(
                name: document.data()['name'] as String,
                message: document.data()['text'] as String,
              ),
            );
          }
          notifyListeners();
        });
      } else {
        _loggedIn = false;
        _guestBookMessages = [];
        _guestBookSub?.cancel();
      }

      notifyListeners();
    });
  }

  Future<DocumentReference> addMessageToGuestBook(String msg) {
    if (!loggedIn) {
      throw Exception("Must be logged In to add messages");
    }

    Map<String, Object?> data = {
      'text': msg,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
    };

    return FirebaseFirestore.instance.collection("guestBook").add(data);
  }
}
