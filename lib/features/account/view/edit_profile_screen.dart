import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/services/image_upload_service.dart';
import 'package:jusel_app/core/services/permission_service.dart';
import 'package:jusel_app/core/utils/navigation_helper.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/data/repositories/auth_repository.dart';
import 'package:jusel_app/features/auth/viewmodel/auth_viewmodel.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  
  File? _selectedImage;
  String? _profileImageUrl;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  
  final ImagePicker _imagePicker = ImagePicker();
  final ImageUploadService _imageUploadService = ImageUploadService(
    folderOverride: 'jusel/users',
  );

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    final user = ref.read(authViewModelProvider).valueOrNull;
    if (user == null) return;
    
    // Load profile image from settings
    final settingsService = await ref.read(settingsServiceProvider.future);
    final imageUrl = await settingsService.getProfileImageUrl();
    
    setState(() {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      _emailController.text = user.email;
      _profileImageUrl = imageUrl;
    });
  }
  
  Future<void> _pickImage() async {
    try {
      final permissionService = ref.read(permissionServiceProvider);
      final hasPermission = await permissionService.requestImagePermission(
        context,
        ImageSource.gallery,
      );
      
      if (!hasPermission) return;
      
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _profileImageUrl = null; // Clear old URL when new image is selected
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: JuselColors.destructiveColor(context),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
  
  Future<void> _saveChanges() async {
    if (_isLoading) return;
    
    final user = ref.read(authViewModelProvider).valueOrNull;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You must be logged in to update your profile'),
          backgroundColor: JuselColors.destructiveColor(context),
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      String? finalImageUrl = _profileImageUrl;
      
      // Upload image if new one is selected
      if (_selectedImage != null) {
        setState(() => _isUploadingImage = true);
        try {
          finalImageUrl = await _imageUploadService.uploadUserProfileImage(
            file: _selectedImage!,
            userId: user.uid,
          );
          
          // Save to settings
          final settingsService = await ref.read(settingsServiceProvider.future);
          await settingsService.setProfileImageUrl(finalImageUrl);
          
          setState(() {
            _profileImageUrl = finalImageUrl;
            _selectedImage = null;
            _isUploadingImage = false;
          });
        } catch (e) {
          setState(() => _isUploadingImage = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload image: $e'),
                backgroundColor: JuselColors.destructiveColor(context),
              ),
            );
          }
          setState(() => _isLoading = false);
          return;
        }
      }
      
      // Update profile in Firestore and local DB
      final authRepo = AuthRepository(
        auth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
        usersDao: ref.read(appDatabaseProvider).usersDao,
      );
      
      await authRepo.updateUserProfile(
        uid: user.uid,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        profileImageUrl: finalImageUrl,
      );
      
      // Update auth viewmodel to refresh user data
      ref.invalidate(authViewModelProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: JuselColors.successColor(context),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: JuselColors.destructiveColor(context),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => safePop(context, fallbackRoute: '/boss-dashboard'),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 420;
          final horizontalPadding = isNarrow ? 20.0 : 32.0;
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                20,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    _ProfilePhoto(
                      imageUrl: _profileImageUrl,
                      selectedImage: _selectedImage,
                      isUploading: _isUploadingImage,
                    ),
                    const SizedBox(height: JuselSpacing.s6),
                    TextButton(
                      onPressed: _isLoading ? null : _pickImage,
                      child: Text(
                        'Change Photo',
                        style: TextStyle(
                          color: JuselColors.primaryColor(context),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s12),
                    _FormCard(
                      nameController: _nameController,
                      phoneController: _phoneController,
                      emailController: _emailController,
                    ),
                    const SizedBox(height: JuselSpacing.s20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_isLoading || _isUploadingImage) ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: JuselSpacing.s12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: JuselColors.primaryColor(context),
                          foregroundColor: JuselColors.primaryForeground,
                        ),
                        child: _isLoading || _isUploadingImage
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    JuselColors.primaryForeground,
                                  ),
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfilePhoto extends StatelessWidget {
  final String? imageUrl;
  final File? selectedImage;
  final bool isUploading;

  const _ProfilePhoto({
    this.imageUrl,
    this.selectedImage,
    this.isUploading = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    
    if (isUploading) {
      imageWidget = Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            JuselColors.primaryColor(context),
          ),
        ),
      );
    } else if (selectedImage != null) {
      imageWidget = ClipOval(
        child: Image.file(
          selectedImage!,
          fit: BoxFit.cover,
          width: 170,
          height: 170,
        ),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageWidget = ClipOval(
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          width: 170,
          height: 170,
          errorBuilder: (_, __, ___) => _PlaceholderAvatar(),
        ),
      );
    } else {
      imageWidget = _PlaceholderAvatar();
    }
    
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CircleAvatar(
          radius: 85,
          backgroundColor: JuselColors.muted(context),
          child: imageWidget,
        ),
        Positioned(
          bottom: 6,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: JuselColors.primaryColor(context),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.camera_alt_outlined,
              color: JuselColors.primaryForeground,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlaceholderAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(
        color: JuselColors.muted(context),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: 80,
        color: JuselColors.mutedForeground(context),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;

  const _FormCard({
    required this.nameController,
    required this.phoneController,
    required this.emailController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(JuselSpacing.s16),
      decoration: BoxDecoration(
        color: JuselColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: JuselColors.border(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Full Name'),
          const SizedBox(height: JuselSpacing.s8),
          TextFormField(
            controller: nameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: JuselColors.border(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: JuselColors.primaryColor(context),
                ),
              ),
              hintText: 'Enter full name',
            ),
          ),
          const SizedBox(height: JuselSpacing.s16),
          const _FieldLabel('Phone Number'),
          const SizedBox(height: JuselSpacing.s6),
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: JuselColors.border(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: JuselColors.primaryColor(context),
                ),
              ),
              hintText: 'Enter phone number',
            ),
          ),
          const SizedBox(height: JuselSpacing.s16),
          const _FieldLabel('Email Address'),
          const SizedBox(height: JuselSpacing.s6),
          TextFormField(
            controller: emailController,
            readOnly: true,
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: JuselColors.border(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: JuselColors.primaryColor(context),
                ),
              ),
              hintText: 'Email cannot be changed',
              filled: true,
              fillColor: JuselColors.muted(context).withOpacity(0.5),
            ),
          ),
          const SizedBox(height: JuselSpacing.s20),
          const _FieldLabel('User Role'),
          const SizedBox(height: JuselSpacing.s20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: JuselColors.successColor(context),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  children: [
                    Text(
                      'BOSS',
                      style: TextStyle(
                        color: JuselColors.primaryForeground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.verified, size: 18, color: JuselColors.primaryForeground),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: JuselSpacing.s20),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: JuselTextStyles.bodySmall(context).copyWith(
        color: JuselColors.mutedForeground(context),
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }
}
