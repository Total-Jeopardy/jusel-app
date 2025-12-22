import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jusel_app/core/providers/global_providers.dart';
import 'package:jusel_app/core/services/image_upload_service.dart';
import 'package:jusel_app/core/services/permission_service.dart';
import 'package:jusel_app/core/ui/components/jusel_app_bar.dart';
import 'package:jusel_app/core/ui/components/jusel_button.dart';
import 'package:jusel_app/core/ui/components/jusel_card.dart';
import 'package:jusel_app/core/ui/components/jusel_text_field.dart';
import 'package:jusel_app/core/ui/components/profile_avatar.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/features/auth/viewmodel/auth_viewmodel.dart';

class FirstSetupScreen extends ConsumerStatefulWidget {
  const FirstSetupScreen({super.key});

  @override
  ConsumerState<FirstSetupScreen> createState() => _FirstSetupScreenState();
}

class _FirstSetupScreenState extends ConsumerState<FirstSetupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  final ImageUploadService _imageUploadService = ImageUploadService(
    folderOverride: 'jusel/users',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

  Future<void> _handleCreate() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final initialExists = ref.read(initialUserExistsProvider).maybeWhen(
          data: (value) => value,
          orElse: () => true,
        );

    // Sign up the user first
    if (initialExists) {
      await ref.read(authViewModelProvider.notifier).signUpAdditionalUser(
            name: name,
            phone: phone,
            email: email,
            password: password,
          );
    } else {
      await ref.read(authViewModelProvider.notifier).signUpFirstUser(
            name: name,
            phone: phone,
            email: email,
            password: password,
          );
    }
    
    // After signup, get the user and upload image if selected
    final user = ref.read(authViewModelProvider).valueOrNull;
    if (user != null && _selectedImage != null) {
      try {
        // Show loading indicator during upload
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Uploading profile image...'),
                ],
              ),
              duration: Duration(seconds: 30), // Long duration for upload
            ),
          );
        }
        
        final imageUrl = await _imageUploadService.uploadUserProfileImage(
          file: _selectedImage!,
          userId: user.uid,
        );
        
        // Save to settings
        final settingsService = await ref.read(settingsServiceProvider.future);
        await settingsService.setProfileImageUrl(imageUrl);
        
        // Update profile in Firestore
        final authRepo = ref.read(authRepositoryProvider);
        await authRepo.updateUserProfile(
          uid: user.uid,
          profileImageUrl: imageUrl,
        );
        
        // Dismiss loading and show success
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile image uploaded successfully'),
              backgroundColor: JuselColors.successColor(context),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        // Don't block signup if image upload fails, but show clear error
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account created successfully. Profile image upload failed: ${e.toString()}'),
              backgroundColor: JuselColors.warningColor(context),
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'OK',
                textColor: JuselColors.background(context),
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final initialExists = ref.watch(initialUserExistsProvider).maybeWhen(
          data: (value) => value,
          orElse: () => true,
        );
    final isLoading = authState.isLoading;
    final errorMessage =
        authState.whenOrNull(error: (e, st) => e.toString());

    return Scaffold(
      backgroundColor: JuselColors.background(context),
      appBar: const JuselAppBar(
        title: 'Create account',
        automaticallyImplyLeading: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    constraints.maxHeight -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 480),
                      padding: const EdgeInsets.symmetric(
                        horizontal: JuselSpacing.s20,
                      ),
                      child: JuselCard(
                        padding: JuselCardPadding.lg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              initialExists
                                  ? 'Create a new boss account'
                                  : 'Create your shop account',
                              style: JuselTextStyles.headlineMedium(context),
                            ),
                            const SizedBox(height: JuselSpacing.s12),
                            Text(
                              initialExists
                                  ? 'Forgot password? Create another boss account and continue.'
                                  : 'This runs only once. You are creating the boss/owner account.',
                              style: JuselTextStyles.bodyMedium(context).copyWith(
                                color: JuselColors.mutedForeground(context),
                              ),
                            ),
                            const SizedBox(height: JuselSpacing.s24),
                            // Profile Image Section
                            Center(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: isLoading ? null : _pickImage,
                                    child: Stack(
                                      children: [
                                        ProfileAvatar(
                                          radius: 50,
                                          userName: _nameController.text.isNotEmpty
                                              ? _nameController.text
                                              : null,
                                          imageUrl: _selectedImage != null
                                              ? _selectedImage!.path
                                              : null,
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: JuselColors.primaryColor(context),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: JuselColors.background(context),
                                                width: 2,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.camera_alt,
                                              size: 20,
                                              color: JuselColors.primaryForeground,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: JuselSpacing.s8),
                                  TextButton(
                                    onPressed: isLoading ? null : _pickImage,
                                    child: Text(
                                      _selectedImage != null ? 'Change Photo' : 'Add Photo',
                                      style: TextStyle(
                                        color: JuselColors.primaryColor(context),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: JuselSpacing.s16),
                            JuselTextField(
                              label: 'Full name',
                              hint: 'e.g. Jane Doe',
                              controller: _nameController,
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: JuselSpacing.s16),
                            JuselTextField(
                              label: 'Phone',
                              hint: 'e.g. 08012345678',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: JuselSpacing.s16),
                            JuselTextField(
                              label: 'Email',
                              hint: 'e.g. jane@example.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: JuselSpacing.s16),
                            JuselTextField(
                              label: 'Password',
                              hint: 'Minimum 6 characters',
                              type: JuselTextFieldType.password,
                              controller: _passwordController,
                              enabled: !isLoading,
                            ),
                            if (errorMessage != null) ...[
                              const SizedBox(height: JuselSpacing.s16),
                              Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 16,
                                    color: JuselColors.destructiveColor(context),
                                  ),
                                  const SizedBox(width: JuselSpacing.s8),
                                  Expanded(
                                    child: Text(
                                      errorMessage,
                                      style: JuselTextStyles.bodySmall(context).copyWith(
                                        color: JuselColors.destructiveColor(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else
                              const SizedBox(height: JuselSpacing.s16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s32),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 480),
                      padding: const EdgeInsets.symmetric(
                        horizontal: JuselSpacing.s20,
                      ),
                      child: SafeArea(
                        child: JuselButton(
                          label: isLoading ? 'Creating...' : 'Create account',
                          variant: JuselButtonVariant.primary,
                          size: JuselButtonSize.large,
                          isFullWidth: true,
                          onPressed: isLoading ? null : _handleCreate,
                        ),
                      ),
                    ),
                    const Spacer(),
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
