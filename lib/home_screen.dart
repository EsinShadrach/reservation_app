import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:reservation_app/app_state.dart';
import 'package:reservation_app/guest_book.dart';
import 'package:reservation_app/src/authentication.dart';
import 'package:reservation_app/src/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Meetup'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus!.unfocus();
        },
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset('assets/codelab.png'),
              ),
            ),
            const SizedBox(height: 8),
            const IconAndDetail(LucideIcons.calendar, 'October 30'),
            const IconAndDetail(LucideIcons.mapPin, 'San Francisco'),
            Consumer<ApplicationState>(
              builder: (context, value, child) => AuthFunc(
                loggedIn: value.loggedIn,
                signOut: () {
                  FirebaseAuth.instance.signOut();
                },
              ),
            ),
            const Divider(
              height: 8,
              thickness: 1,
              indent: 8,
              endIndent: 8,
              color: Colors.grey,
            ),
            const Header("What we'll be doing"),
            const Paragraph(
              'Join us for a day full of Firebase Workshops and Pizza!',
            ),
            Consumer<ApplicationState>(
              builder: (context, value, child) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (value.loggedIn) ...[
                    const Header("Discussion"),
                    GuestBook(
                      messages: value.guestBookMessages,
                      addMessage: value.addMessageToGuestBook,
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
