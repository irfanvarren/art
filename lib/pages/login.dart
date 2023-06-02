import 'package:art/main.dart';
import 'package:art/layout/adaptive.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String errorMessage = '';

  void login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter both username and password.';
      });
      return;
    }
    errorMessage = '';

    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String storedPassword = '';
    await initializeFirebase();
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .get();
    if (snapshot.exists) {
      storedPassword = snapshot['password'];
    }

    if (storedPassword == '') {
      setState(() {
        errorMessage = 'Invalid username.';
      });
      return;
    }
    if (storedPassword != '' && password == storedPassword) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AdaptiveNav(username: username)),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login Failed'),
          content: Text('Invalid username or password.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      errorMessage = 'Invalid password.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            Text(
              errorMessage,
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                login();
              },
              child: Text(
                'Login',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
