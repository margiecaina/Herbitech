import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Page5 extends StatefulWidget {
  const Page5({super.key});

  @override
  State<Page5> createState() => _Page5State();
}

class _Page5State extends State<Page5> {
  String username = '';
  String email = '';
  bool isLoading = true;
  bool isEditing = false; // Track if the username is being edited

  // Create a TextEditingController to manage the text field
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Fetch the user's data from Firestore
  Future<void> _loadUserData() async {
    try {
      // Get the current logged-in user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Set the email from Firebase Auth
        email = user.email ?? 'No Email';

        // Fetch the username from Firestore using the user's UID
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        // Check if the user document exists and get the username
        if (userDoc.exists) {
          setState(() {
            username = userDoc['username'] ?? 'No Username';
            _usernameController.text = username; // Initialize controller text
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to update the username in Firestore
  Future<void> _updateUsername() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'username': _usernameController.text});

        // Update the local username variable
        setState(() {
          username = _usernameController.text;
          isEditing = false; // Close the editing mode
        });

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username updated successfully!')),
        );
      }
    } catch (e) {
      print('Error updating username: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update username.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.person,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 20),

            // Row for displaying username and edit icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display username
                Text(
                  isEditing ? '' : 'Username: $username',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                // Edit icon
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.green),
                  onPressed: () {
                    if (!isEditing) {
                      setState(() {
                        isEditing = true; // Start editing
                        _usernameController.text = username; // Populate the text field
                      });
                    }
                  },
                ),
              ],
            ),

            // Editable Username Field
            if (isEditing) ...[
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Edit Username',
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                onPressed: _updateUsername,
                child: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Email Display
            Text(
              'Email: $email',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
