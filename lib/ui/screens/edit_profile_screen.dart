import 'package:pharos/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:pharos/core/theme/app_spacing.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/user_provider.dart';
import 'package:pharos/core/utils/form_validation.dart';
import 'package:pharos/core/utils/validation_feedback.dart';
import 'package:pharos/l10n/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    if (user != null) {
      _firstnameController.text = user.firstname;
      _lastnameController.text = user.lastname;
      _emailController.text = user.email;
    }
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editProfileTitle, style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                _firstnameController,
                AppLocalizations.of(context)!.firstName,
                Icons.person_outline,
                validator: (value) => FormValidation.nameField(value, AppLocalizations.of(context)!.firstName),
              ),
              const SizedBox(height: AppSpacing.s16),
              _buildTextField(
                _lastnameController,
                AppLocalizations.of(context)!.lastName,
                Icons.person_outline,
                validator: (value) => FormValidation.nameField(value, AppLocalizations.of(context)!.lastName),
              ),
              const SizedBox(height: AppSpacing.s16),
              _buildTextField(
                _emailController,
                AppLocalizations.of(context)!.email,
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => FormValidation.emailField(value),
              ),
              const SizedBox(height: AppSpacing.s32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: AppColors.text)
                      : Text(AppLocalizations.of(context)!.saveChangesButton, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textDisabled),
        prefixIcon: Icon(icon, color: AppColors.accentText),
        filled: true,
        fillColor: AppColors.text.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.text.withOpacity(0.05))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accentText)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error, width: 2)),
      ),
    );
  }

  Future<void> _handleSave() async {
    final missingLabels = FormValidation.collectMissingLabels({
      AppLocalizations.of(context)!.firstName.toLowerCase(): FormValidation.nameField(_firstnameController.text, AppLocalizations.of(context)!.firstName),
      AppLocalizations.of(context)!.lastName.toLowerCase(): FormValidation.nameField(_lastnameController.text, AppLocalizations.of(context)!.lastName),
      AppLocalizations.of(context)!.guestEmailLabel.toLowerCase(): FormValidation.emailField(_emailController.text),
    });

    if (missingLabels.isNotEmpty) {
      showValidationSnackBar(context, FormValidation.formatMissingFields(missingLabels));
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    final userProvider = context.read<UserProvider>();
    final success = await userProvider.updateProfile(
      firstname: _firstnameController.text.trim(),
      lastname: _lastnameController.text.trim(),
      email: _emailController.text.trim(),
    );
    setState(() => _isSaving = false);

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdated), backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
      return;
    }

    showValidationSnackBar(
      context,
      userProvider.authError ?? 'Nie udało się zaktualizować profilu. Sprawdź wprowadzone dane.',
    );
  }
}
