import 'package:art/layout/adaptive.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    setState(() {
      errorMessage = '';
    });
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String storedPassword = '';

    final String url =
        'https://firestore.googleapis.com/v1/projects/pt-art-d22b7/databases/(default)/documents/users/${username}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Request successful, parse the response body
        final data = jsonDecode(response.body);
        storedPassword = data['fields']['password']['stringValue'];
        // Process the data as needed
        // ...
      } else {
        // Request failed, handle the error
        print('Request failed with status code: ${response.statusCode}' +
            response.body);
      }
    } catch (error) {
      // Error occurred while making the request
      print('Error: $error');
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
