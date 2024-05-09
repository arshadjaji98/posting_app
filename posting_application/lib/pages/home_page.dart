import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:posting_application/components/post_wall.dart';
import 'package:posting_application/components/text_field.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final textController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  void signOut() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut(); // Logout the user
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  void postMessage() {
    if (textController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser!.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now()
      }).then((value) {
        textController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Welcome',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: signOut,
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ))
        ],
      ),
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .orderBy("TimeStamp", descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final post = snapshot.data!.docs[index];
                          return WallPost(
                            message: post['Message'],
                            user: post['UserEmail'],
                          );
                        });
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error:${snapshot.error}'),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  Expanded(
                    child: MyTextField(
                      controller: textController,
                      obscureText: false,
                      hintText: 'Write something here ',
                    ),
                  ),
                  IconButton(
                      onPressed: postMessage, icon: Icon(Icons.arrow_circle_up))
                ],
              ),
            ),
            Text("Currently logged in as ${currentUser!.email!}"),
          ],
        ),
      ),
    );
  }
}
