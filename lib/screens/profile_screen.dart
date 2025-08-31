import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ZenDo/models/user.dart';
import 'package:hive/hive.dart';
import 'package:ZenDo/theme/app_theme.dart';
import 'package:ZenDo/utils/responsive.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final box = Hive.box<User>('user');
    final user = box.get('current_user');
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _profileImagePath = user.profileImagePath;
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _profileImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final newUser = User(
        name: _nameController.text,
        email: _emailController.text,
        profileImagePath: _profileImagePath,
      );

      final box = Hive.box<User>('user');
      box.put('current_user', newUser);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profile saved successfully!',
            style: TextStyle(fontSize: Responsive.textSize(14, context)),
          ),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.gradientBoxDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Your Profile',
            style: TextStyle(fontSize: Responsive.textSize(18, context)),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.save, size: Responsive.textSize(24, context)),
              onPressed: _saveProfile,
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(Responsive.width(5, context)),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: Responsive.width(12, context),
                      backgroundImage: _profileImagePath != null
                          ? FileImage(File(_profileImagePath!))
                          : null,
                      child: _profileImagePath == null
                          ? Icon(
                              Icons.add_a_photo,
                              size: Responsive.textSize(30, context),
                            )
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: Responsive.height(2.5, context)),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Your Name',
                    prefixIcon: Icon(
                      Icons.person,
                      size: Responsive.textSize(24, context),
                    ),
                    labelStyle: TextStyle(
                      fontSize: Responsive.textSize(16, context),
                    ),
                  ),
                  style: TextStyle(fontSize: Responsive.textSize(16, context)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: Responsive.height(2, context)),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(
                      Icons.email,
                      size: Responsive.textSize(24, context),
                    ),
                    labelStyle: TextStyle(
                      fontSize: Responsive.textSize(16, context),
                    ),
                  ),
                  style: TextStyle(fontSize: Responsive.textSize(16, context)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: Responsive.height(3.5, context)),
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: Responsive.height(2, context),
                    ),
                  ),
                  child: Text(
                    'Save Profile',
                    style: TextStyle(
                      fontSize: Responsive.textSize(16, context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
