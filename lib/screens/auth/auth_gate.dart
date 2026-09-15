import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../services/auth_service.dart';
import '../admin/admin_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return FutureBuilder(
            future: AuthService().ensureUserProfile(),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (profileSnapshot.hasError) {
                return Scaffold(
                  body: Center(child: Text('Error: ${profileSnapshot.error}')),
                );
              }

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(snapshot.data!.uid)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (userSnapshot.hasError) {
                    return Scaffold(
                      body: Center(child: Text('Error: ${userSnapshot.error}')),
                    );
                  }

                  final data =
                      userSnapshot.data?.data() as Map<String, dynamic>?;

                  final role = data?['role'] ?? 'user';

                  if (role == 'admin') {
                    return const AdminScreen();
                  }

                  return const HungerHomePage();
                },
              );
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}
