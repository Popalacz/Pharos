import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/user_provider.dart';

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

  // PrestaShop common validators
  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Adres e-mail jest wymagany';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Wprowadź poprawny adres e-mail';
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Hasło jest wymagane';
    if (value.length < 5) return 'Hasło musi mieć min. 5 znaków (wymóg PrestaShop)';
    return null;
  }

  String? _nameValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'To pole jest wymagane';
    if (value.trim().length < 2) return 'Minimum 2 znaki';
    if (!RegExp(r'^[^0-9!<>,;?=+()@#"°*!$^_]+$').hasMatch(value.trim())) {
      return 'Pole zawiera niedozwolone znaki';
    }
    return null;
  }

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
            const SizedBox(height: 16),
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
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: userProvider.isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: userProvider.isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('ZALOGUJ SIĘ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 32),
            const Row(
              children: [
                Expanded(child: Divider(color: Colors.white10)),
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('LUB', style: TextStyle(color: Colors.white30, fontWeight: FontWeight.bold))),
                Expanded(child: Divider(color: Colors.white10)),
              ],
            ),
            const SizedBox(height: 32),
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
                Expanded(child: _buildTextField(controller: _regFirstnameController, label: 'Imię', icon: Icons.person_outline, validator: _nameValidator)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(controller: _regLastnameController, label: 'Nazwisko', icon: Icons.person_outline, validator: _nameValidator)),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _regEmailController, 
              label: 'E-mail', 
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: _emailValidator,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _regPasswordController, 
              label: 'Hasło', 
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              validator: _passwordValidator,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: userProvider.isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: userProvider.isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('ZAŁÓŻ KONTO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              ),
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
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () async {
          await context.read<UserProvider>().signInWithGoogle();
          if (mounted && context.read<UserProvider>().isLoggedIn) {
            Navigator.pop(context);
          }
        },
        icon: Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_Color_Icon.svg/1200px-Google_Color_Icon.svg.png', height: 20),
        label: const Text('KONTYNUUJ PRZEZ GOOGLE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (_loginFormKey.currentState!.validate()) {
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
            content: Text(userProvider.authError ?? 'Błąd logowania.'), 
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleRegister() async {
    if (_registerFormKey.currentState!.validate()) {
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
            content: Text(userProvider.authError ?? 'Błąd rejestracji.'), 
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
