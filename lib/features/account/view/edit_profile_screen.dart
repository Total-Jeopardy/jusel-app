import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/navigation_helper.dart';
import 'package:jusel_app/core/utils/theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Jane Boss');
    _phoneController = TextEditingController(text: '+1 234 567 890');
    _emailController = TextEditingController(text: 'jane@jusel.store');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
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
                    _ProfilePhoto(),
                    const SizedBox(height: JuselSpacing.s6),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Change Photo',
                        style: TextStyle(
                          color: JuselColors.primary,
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
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: JuselSpacing.s12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: JuselColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
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
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        const CircleAvatar(
          radius: 85,
          backgroundImage: AssetImage('assets/avatar_placeholder.png'),
        ),
        Positioned(
          bottom: 6,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: JuselColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: JuselColors.border),
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
                borderSide: const BorderSide(color: JuselColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: JuselColors.primary),
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
                borderSide: const BorderSide(color: JuselColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: JuselColors.primary),
              ),
              hintText: 'Enter full name',
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
                borderSide: const BorderSide(color: JuselColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: JuselColors.primary),
              ),
              hintText: 'Enter full name',
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
                  color: JuselColors.success,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  children: [
                    Text(
                      'BOSS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.verified, size: 18, color: Colors.white),
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
      style: JuselTextStyles.bodySmall.copyWith(
        color: JuselColors.mutedForeground,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }
}
