import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RemoteDb {
  static final RemoteDb instance = RemoteDb._(); //singleton instance

  RemoteDb._(); //singleton

  final FirebaseAuth _auth = FirebaseAuth.instance; //firebase auth instance
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance

  // create user function
  Future<(User?, String?)> Createuser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCred.user;
      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload(); //refresh user info

        //saving extra detail in firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'phone': phone,
          'createdAt': DateTime.now(),
          'role': 'user',
        });
        await _auth.signOut();
        return (user, null);
      }
    } on FirebaseAuthException catch (e) {
      //common errors
      if (e.code == 'email-already-in-use') {
        return (null, "Email already registered.");
      } else if (e.code == 'weak-password') {
        return (null, "Password is too weak.use at least 6 characters.");
      } else if (e.code == "invalid-email") {
        return (null, "Invalid email address");
      } else {
        return (null, "An unknown error occurred(${e.code})");
      }
    } catch (e) {
      return (null, "Something went wrong:$e");
    }
    return (null, "Something went wrong.");
  }

  // login function
  Future<(Map<String, dynamic>?, String?)> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ); //signInWithEmailAndPassword is  a predefined function of firebase auth
      User? user = userCred.user;
      if (user == null) return (null, "Login failed. Please try again.");
      print("user:$user");
      await Future.delayed(Duration(milliseconds: 500));
      DocumentSnapshot userDoc = await _firestore
          .collection("users")
          .doc(user.uid)
          .get();
      Map<String, dynamic> data = {};
      if (userDoc.exists && userDoc.data() != null) {
        //prints user details if user exists
        data = userDoc.data() as Map<String, dynamic>;
        print("User Logged in successfully");
        print("Name:${userDoc['name']}");
        print("Email:${userDoc['email']}");
        print("Phone:${userDoc['phone']}");
        print("Role:${userDoc['role'] ?? 'user'}");
      } else {
        print("No  firestore data found for user${user.uid}");
      }
      return (
      {
        "name": data["name"] ?? "User",
        "email": data["email"] ?? "Email",
        "phone": data["phone"] ?? "N/A",
        "profileUrl": data["profileUrl"] ?? " ",
        "role": data["role"] ?? "user",
      },
      null,
      );
    } on FirebaseAuthException catch (e) {
      //catch block for firebase errors
      String errorMsg;
      if (e.code == "user-not-found") {
        errorMsg = "No user found with this email";
      } else if (e.code == "invalid-credential") {
        errorMsg = "Incorrect email or password. Try again";
      } else if (e.code == "invalid-email") {
        errorMsg = "Incorrect email address";
      } else if (e.code == "user-disabled") {
        errorMsg = "Account has been disabled. Please contact support";
      } else if (e.code == "too-many-requests") {
        errorMsg =
        "Too many failed attempts. Please wait for a few minutes before trying again";
      } else {
        errorMsg = "An unexpected error occurred:${e.message}";
      }
      return (null, errorMsg);
    } catch (e) {
      //catch block for any unexpected error
      return (null, "an unexpected error occurred");
    }
  }

  //logout function
  Future<void> logoutUser() async {
    try {
      await _auth.signOut(); //logs the user out
      print("User logged out successfully");
    } catch (e) {
      print("logout failed");
    }
  }

  //function to check if a user is already logged in
  User? getCurrentUser() {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        print("User logged in as:${user.email}");
      } else {
        print("No user currently loggedd in ");
      }
      return user;
    } catch (e) {
      print("failed to get current user:$e");
      return null;
    }
  }

  //fetching user profile from firestore
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection("users")
          .doc(uid)
          .get();
      if (userDoc.exists) {
        print("User profile fetched:${userDoc.data()}");
        return userDoc.data() as Map<String, dynamic>;
      } else {
        print("no profile found for this user");
        return null;
      }
    } catch (e) {
      print("Failed to fetch user profile:$e");
      return null;
    }
  }
  //function to send message
  Future<void> sendMessage(String receiverEmail, String content) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('messages').add({
      'senderId': user.uid,
      'senderEmail': user.email,
      'receiverEmail': receiverEmail,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
  //function to recieve message
  Stream<QuerySnapshot> getMessagesForUser(String userEmail) {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('receiverEmail', isEqualTo: userEmail)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

}
