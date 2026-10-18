import 'package:flutter/material.dart';
import 'package:pharos/core/theme/app_spacing.dart';
import 'package:pharos/data/models/address_model.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/user_provider.dart';
import 'package:pharos/core/utils/form_validation.dart';
import 'package:pharos/core/utils/validation_feedback.dart';
import 'package:pharos/l10n/app_localizations.dart';

class AddressFormScreen extends StatefulWidget {
  final AddressModel? address;

  const AddressFormScreen({super.key, this.address});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  late TextEditingController _aliasController;
  // ... reszta controllerów
  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _address1Controller;
  late TextEditingController _postcodeController;
  late TextEditingController _cityController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _aliasController = TextEditingController(text: widget.address?.alias ?? 'Mój Adres');
    _firstnameController = TextEditingController(text: widget.address?.firstname ?? '');
    _lastnameController = TextEditingController(text: widget.address?.lastname ?? '');
    _address1Controller = TextEditingController(text: widget.address?.address1 ?? '');
    _postcodeController = TextEditingController(text: widget.address?.postcode ?? '');
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _phoneController = TextEditingController(text: widget.address?.phone ?? '');
  }

  @override
  void dispose() {
    _aliasController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _address1Controller.dispose();
    _postcodeController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    final missingLabels = FormValidation.collectMissingLabels({
      'nazwa adresu': FormValidation.requiredField(_aliasController.text, 'Nazwa adresu'),
      'imię': FormValidation.nameField(_firstnameController.text, AppLocalizations.of(context)!.firstName),
      'nazwisko': FormValidation.nameField(_lastnameController.text, AppLocalizations.of(context)!.lastName),
      'ulica i numer': FormValidation.addressField(_address1Controller.text),
      'kod pocztowy': FormValidation.postcodeField(_postcodeController.text),
      'miasto': FormValidation.cityField(_cityController.text),
      'numer telefonu': FormValidation.phoneField(_phoneController.text),
    });

    if (missingLabels.isNotEmpty) {
      showValidationSnackBar(context, FormValidation.formatMissingFields(missingLabels));
    }

    if (!_formKey.currentState!.validate() || _isSaving) {
      return;
    }

    setState(() => _isSaving = true);
    final userProvider = context.read<UserProvider>();

    final address = AddressModel(
        id: widget.address?.id ?? 0,
        alias: _aliasController.text,
        firstname: _firstnameController.text,
        lastname: _lastnameController.text,
        address1: _address1Controller.text,
        postcode: _postcodeController.text,
        city: _cityController.text,
        country: 'Polska',
        phone: _phoneController.text,
    );

    bool success;
    if (widget.address == null) {
      success = await userProvider.addAddress(address);
    } else {
      success = await userProvider.updateAddress(address);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.addressSavedSuccess), backgroundColor: Colors.green),
        );
        await userProvider.fetchAddresses();
        if (mounted && userProvider.addresses.isNotEmpty) {
          Navigator.pop(context, userProvider.addresses.last);
        } else {
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.addressError ?? 'Nie udało się zapisać adresu. Sprawdź wprowadzone dane.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: Text(widget.address == null ? AppLocalizations.of(context)!.newAddress : AppLocalizations.of(context)!.editAddress, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(_aliasController, 'Nazwa adresu (np. Dom, Praca)', Icons.label_outline,
                validator: (value) => FormValidation.requiredField(value, 'Nazwa adresu')),
              const SizedBox(height: AppSpacing.s16),
              Row(
                children: [
                  Expanded(child: _buildField(_firstnameController, AppLocalizations.of(context)!.firstName, Icons.person_outline, validator: (value) => FormValidation.nameField(value, AppLocalizations.of(context)!.firstName))),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(child: _buildField(_lastnameController, AppLocalizations.of(context)!.lastName, Icons.person_outline, validator: (value) => FormValidation.nameField(value, AppLocalizations.of(context)!.lastName))),
                ],
              ),
              const SizedBox(height: AppSpacing.s16),
              _buildField(_address1Controller, 'Ulica i numer domu', Icons.home_outlined,
                validator: (value) => FormValidation.addressField(value)),
              const SizedBox(height: AppSpacing.s16),
              Row(
                children: [
                  Expanded(child: _buildField(_postcodeController, 'Kod pocztowy (np. 00-000)', Icons.markunread_mailbox_outlined,
                    validator: (value) => FormValidation.postcodeField(value))),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(child: _buildField(_cityController, 'Miasto', Icons.location_city_outlined,
                    validator: (value) => FormValidation.cityField(value))),
                ],
              ),
              const SizedBox(height: AppSpacing.s16),
              _buildField(_phoneController, 'Numer telefonu', Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) => FormValidation.phoneField(value)),
              const SizedBox(height: AppSpacing.s40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(AppLocalizations.of(context)!.saveAddressButton, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.orange),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
      validator: validator ?? (value) => FormValidation.requiredField(value, label),
    );
  }
}
