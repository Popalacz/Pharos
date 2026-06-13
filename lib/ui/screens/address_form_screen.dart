import 'package:flutter/material.dart';
import 'package:pharos/data/models/address_model.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/user_provider.dart';

class AddressFormScreen extends StatefulWidget {
  final AddressModel? address;

  const AddressFormScreen({super.key, this.address});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _aliasController;
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

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      // W prawdziwej aplikacji tutaj wywołujemy repository.addAddress
      final newAddress = AddressModel(
        id: widget.address?.id ?? DateTime.now().millisecondsSinceEpoch,
        alias: _aliasController.text,
        firstname: _firstnameController.text,
        lastname: _lastnameController.text,
        address1: _address1Controller.text,
        postcode: _postcodeController.text,
        city: _cityController.text,
        country: 'Polska',
        phone: _phoneController.text,
      );

      // Symulacja sukcesu i powrót
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adres został zapisany w PrestaShop'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, newAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address == null ? 'Nowy adres' : 'Edytuj adres', style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(_aliasController, 'Nazwa adresu (np. Dom, Praca)', Icons.label_outline),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildField(_firstnameController, 'Imię', Icons.person_outline)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField(_lastnameController, 'Nazwisko', Icons.person_outline)),
                ],
              ),
              const SizedBox(height: 16),
              _buildField(_address1Controller, 'Ulica i numer domu', Icons.home_outlined),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildField(_postcodeController, 'Kod pocztowy', Icons.markunread_mailbox_outlined)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField(_cityController, 'Miasto', Icons.location_city_outlined)),
                ],
              ),
              const SizedBox(height: 16),
              _buildField(_phoneController, 'Numer telefonu', Icons.phone_android_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('ZAPISZ ADRES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.orange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Pole wymagane' : null,
    );
  }
}
