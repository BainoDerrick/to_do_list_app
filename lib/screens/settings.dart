import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:list/main.dart'; // Import ThemeProvider

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user information
    final user = _auth.currentUser;
    if (user != null) {
      _usernameController.text = user.displayName ?? '';
    }
  }

  Future<void> _updateUserInfo() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      // Update username
      if (_usernameController.text.isNotEmpty) {
        await user.updateProfile(displayName: _usernameController.text);
      }

      // Update password
      if (_passwordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text) {
        await user.updatePassword(_passwordController.text);
      }

      // Refresh user profile
      await user.reload();
      final updatedUser = _auth.currentUser;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User information updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user information: $e')),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Toggle Theme
            _buildThemeToggle(context, themeProvider, isDarkMode),

            SizedBox(height: 20),

            // Username Update
            _buildSectionTitle('Update Username'),
            _buildTextField(
              controller: _usernameController,
              labelText: 'New Username',
              hintText: 'Enter new username',
            ),

            SizedBox(height: 20),

            // Password Update
            _buildSectionTitle('Update Password'),
            _buildTextField(
              controller: _passwordController,
              labelText: 'New Password',
              hintText: 'Enter new password',
              obscureText: true,
            ),
            _buildTextField(
              controller: _confirmPasswordController,
              labelText: 'Confirm Password',
              hintText: 'Re-enter new password',
              obscureText: true,
            ),

            SizedBox(height: 20),

            // Save Button
            ElevatedButton(
              onPressed: _isUpdating ? null : _updateUserInfo,
              style: ElevatedButton.styleFrom(
                disabledForegroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: _isUpdating
                  ? CircularProgressIndicator()
                  : Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, ThemeProvider themeProvider, bool isDarkMode) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Theme Mode', style: Theme.of(context).textTheme.titleLarge),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text('Light Mode'),
                    leading: Radio(
                      value: false,
                      groupValue: isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme(false);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text('Dark Mode'),
                    leading: Radio(
                      value: true,
                      groupValue: isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme(true);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    bool obscureText = false,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
