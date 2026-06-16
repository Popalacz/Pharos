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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KONTO PHAROS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.orange,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.white70,
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
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildTextField(
            controller: _loginEmailController,
            label: 'E-mail',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _loginPasswordController,
            label: 'Hasło',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
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
              onPressed: (userProvider.isLoading || _loginEmailController.text.isEmpty || _loginPasswordController.text.isEmpty) 
                ? null 
                : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: userProvider.isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('ZALOGUJ SIĘ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: Divider(color: Colors.white10)),
              Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('LUB', style: TextStyle(color: Colors.white30))),
              Expanded(child: Divider(color: Colors.white10)),
            ],
          ),
          const SizedBox(height: 24),
          _buildGoogleButton(),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    final userProvider = context.watch<UserProvider>();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTextField(controller: _regFirstnameController, label: 'Imię', icon: Icons.person_outline),
          const SizedBox(height: 16),
          _buildTextField(controller: _regLastnameController, label: 'Nazwisko', icon: Icons.person_outline),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _regEmailController, 
            label: 'E-mail', 
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _regPasswordController, 
            label: 'Hasło', 
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
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
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('ZAŁÓŻ KONTO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
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
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white30),
        prefixIcon: Icon(icon, color: Colors.orange),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange),
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
        icon: const Icon(Icons.login, color: Colors.white),
        label: const Text('KONTYNUUJ PRZEZ GOOGLE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _handleLogin() async {
    final userProvider = context.read<UserProvider>();
    final success = await userProvider.login(
      _loginEmailController.text,
      _loginPasswordController.text,
    );
    
    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userProvider.authError ?? 'Błąd logowania.'), backgroundColor: Colors.red),
      );
    }
  }

  void _handleRegister() async {
    final userProvider = context.read<UserProvider>();
    final success = await userProvider.register(
      email: _regEmailController.text,
      password: _regPasswordController.text,
      firstname: _regFirstnameController.text,
      lastname: _regLastnameController.text,
    );
    
    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userProvider.authError ?? 'Błąd rejestracji.'), backgroundColor: Colors.red),
      );
    }
  }
}
