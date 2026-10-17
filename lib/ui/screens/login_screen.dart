import 'package:flutter/material.dart';
import 'package:pharos/core/theme/app_spacing.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/user_provider.dart';
import 'package:pharos/core/utils/form_validation.dart';
import 'package:pharos/core/utils/validation_feedback.dart';
import 'package:pharos/ui/widgets/pharos_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regFirstnameController = TextEditingController();
  final _regLastnameController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regFirstnameController.dispose();
    _regLastnameController.dispose();
    super.dispose();
  }

  String? _emailValidator(String? value) => FormValidation.emailField(value);

  String? _passwordValidator(String? value) => FormValidation.passwordField(value);

  String? _firstnameValidator(String? value) => FormValidation.nameField(value, 'Imię');

  String? _lastnameValidator(String? value) => FormValidation.nameField(value, 'Nazwisko');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('KONTO PHAROS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.orange,
          indicatorWeight: 3,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(text: 'LOGOWANIE'),
            Tab(text: 'REJESTRACJA'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLoginForm(),
          _buildRegisterForm(),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    final userProvider = context.watch<UserProvider>();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildTextField(
              controller: _loginEmailController,
              label: 'E-mail',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: _emailValidator,
            ),
            const SizedBox(height: AppSpacing.s16),
            _buildTextField(
              controller: _loginPasswordController,
              label: 'Hasło',
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              validator: _passwordValidator,
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white30),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            const SizedBox(height: AppSpacing.s32),
            PharosButton(
              label: 'ZALOGUJ SIĘ',
              isLoading: userProvider.isLoading,
              onPressed: _handleLogin,
            ),
            const SizedBox(height: AppSpacing.s32),
            const Row(
              children: [
                Expanded(child: Divider(color: Colors.white10)),
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('LUB', style: TextStyle(color: Colors.white30, fontWeight: FontWeight.bold))),
                Expanded(child: Divider(color: Colors.white10)),
              ],
            ),
            const SizedBox(height: AppSpacing.s32),
            _buildGoogleButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    final userProvider = context.watch<UserProvider>();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _registerFormKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildTextField(controller: _regFirstnameController, label: 'Imię', icon: Icons.person_outline, validator: _firstnameValidator)),
                const SizedBox(width: AppSpacing.s16),
                Expanded(child: _buildTextField(controller: _regLastnameController, label: 'Nazwisko', icon: Icons.person_outline, validator: _lastnameValidator)),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            _buildTextField(
              controller: _regEmailController, 
              label: 'E-mail', 
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: _emailValidator,
            ),
            const SizedBox(height: AppSpacing.s16),
            _buildTextField(
              controller: _regPasswordController, 
              label: 'Hasło', 
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              validator: _passwordValidator,
            ),
            const SizedBox(height: AppSpacing.s32),
            PharosButton(
              label: 'ZAŁÓŻ KONTO',
              isLoading: userProvider.isLoading,
              onPressed: _handleRegister,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.orange),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    final userProvider = context.watch<UserProvider>();
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: userProvider.isLoading ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white.withOpacity(0.05),
        ),
        child: userProvider.isLoading 
          ? const SizedBox(width: AppSpacing.s24, height: 24, child: CircularProgressIndicator(color: Colors.orange, strokeWidth: 2))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://authjs.dev/img/providers/google.svg',
                  height: 24,
                  width: 24,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.login, color: Colors.white),
                ),
                const SizedBox(width: AppSpacing.s12),
                const Text(
                  'KONTYNUUJ PRZEZ GOOGLE', 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)
                ),
              ],
            ),
      ),
    );
  }

  void _handleGoogleSignIn() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.signInWithGoogle();
    
    if (mounted) {
      if (userProvider.isLoggedIn) {
        Navigator.pop(context);
      } else if (userProvider.authError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.authError!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleLogin() async {
    final missingLabels = FormValidation.collectMissingLabels({
      'adres e-mail': FormValidation.emailField(_loginEmailController.text),
      'hasło': FormValidation.passwordField(_loginPasswordController.text),
    });

    if (missingLabels.isNotEmpty) {
      showValidationSnackBar(context, FormValidation.formatMissingFields(missingLabels));
    }

    if (!_loginFormKey.currentState!.validate()) {
      return;
    }

    final userProvider = context.read<UserProvider>();
    final success = await userProvider.login(
      _loginEmailController.text.trim(),
      _loginPasswordController.text,
    );

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userProvider.authError ?? 'Nie udało się zalogować. Sprawdź e-mail i hasło.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleRegister() async {
    final missingLabels = FormValidation.collectMissingLabels({
      'imię': FormValidation.nameField(_regFirstnameController.text, 'Imię'),
      'nazwisko': FormValidation.nameField(_regLastnameController.text, 'Nazwisko'),
      'adres e-mail': FormValidation.emailField(_regEmailController.text),
      'hasło': FormValidation.passwordField(_regPasswordController.text),
    });

    if (missingLabels.isNotEmpty) {
      showValidationSnackBar(context, FormValidation.formatMissingFields(missingLabels));
    }

    if (!_registerFormKey.currentState!.validate()) {
      return;
    }

    final userProvider = context.read<UserProvider>();
    final success = await userProvider.register(
      email: _regEmailController.text.trim(),
      password: _regPasswordController.text,
      firstname: _regFirstnameController.text.trim(),
      lastname: _regLastnameController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userProvider.authError ?? 'Nie udało się utworzyć konta. Sprawdź wprowadzone dane.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
