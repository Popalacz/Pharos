import 'package:flutter/material.dart';
import 'package:pharos/core/constants/pharos_layout.dart';
import 'package:pharos/core/theme/app_colors.dart';
import 'package:pharos/core/theme/app_spacing.dart';
import 'package:pharos/core/utils/form_validation.dart';
import 'package:pharos/l10n/app_localizations.dart';

/// Kontrolery i walidacja formularza gościa, bez zależności od widgetów.
class GuestFormController {
  final email = TextEditingController();
  final firstname = TextEditingController();
  final lastname = TextEditingController();
  final address = TextEditingController();
  final postcode = TextEditingController();
  final city = TextEditingController();
  final phone = TextEditingController();

  bool get hasEmail => email.text.isNotEmpty;

  /// Etykiety pól do poprawy, w kolejności formularza.
  List<String> missingLabels(AppLocalizations l10n) {
    return FormValidation.collectMissingLabels({
      l10n.guestEmailLabel.toLowerCase(): FormValidation.emailField(email.text),
      l10n.firstName.toLowerCase(): FormValidation.nameField(firstname.text, l10n.firstName),
      l10n.lastName.toLowerCase(): FormValidation.nameField(lastname.text, l10n.lastName),
      l10n.guestStreetLabel.toLowerCase(): FormValidation.addressField(address.text),
      l10n.guestPostcodeLabel.toLowerCase(): FormValidation.postcodeField(postcode.text),
      l10n.guestCityLabel.toLowerCase(): FormValidation.cityField(city.text),
      l10n.guestPhoneLabel.toLowerCase(): FormValidation.phoneField(phone.text),
    });
  }

  bool get isValid => [
        FormValidation.emailField(email.text),
        FormValidation.nameField(firstname.text, ''),
        FormValidation.nameField(lastname.text, ''),
        FormValidation.addressField(address.text),
        FormValidation.postcodeField(postcode.text),
        FormValidation.cityField(city.text),
        FormValidation.phoneField(phone.text),
      ].every((error) => error == null);

  Map<String, dynamic> toPayload({required bool createAccount}) => {
        'email': email.text,
        'firstname': firstname.text,
        'lastname': lastname.text,
        'address1': address.text,
        'postcode': postcode.text,
        'city': city.text,
        'phone': phone.text,
        'create_account': createAccount,
      };

  void dispose() {
    email.dispose();
    firstname.dispose();
    lastname.dispose();
    address.dispose();
    postcode.dispose();
    city.dispose();
    phone.dispose();
  }
}

class CheckoutGuestForm extends StatelessWidget {
  const CheckoutGuestForm({
    super.key,
    required this.formKey,
    required this.controller,
    required this.createAccount,
    required this.onCreateAccountChanged,
    required this.onFieldChanged,
    required this.onAddressChanged,
    this.addressSuggestions,
  });

  final GlobalKey<FormState> formKey;
  final GuestFormController controller;
  final bool createAccount;
  final ValueChanged<bool> onCreateAccountChanged;
  final VoidCallback onFieldChanged;
  final ValueChanged<String> onAddressChanged;
  final Widget? addressSuggestions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: AutofillGroup(
        child: Container(
          key: const ValueKey('guest_form'),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(PharosLayout.radiusLg),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              _GuestField(
                controller: controller.email,
                label: l10n.guestEmailLabel,
                icon: Icons.alternate_email_rounded,
                autofillHints: const [AutofillHints.email],
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                validator: FormValidation.emailField,
                onChanged: (_) => onFieldChanged(),
              ),
              const SizedBox(height: AppSpacing.s12),
              Row(
                children: [
                  Expanded(
                    child: _GuestField(
                      controller: controller.firstname,
                      label: l10n.firstName,
                      icon: Icons.person_outline_rounded,
                      autofillHints: const [AutofillHints.givenName],
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => FormValidation.nameField(value, l10n.firstName),
                      onChanged: (_) => onFieldChanged(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: _GuestField(
                      controller: controller.lastname,
                      label: l10n.lastName,
                      icon: Icons.person_outline_rounded,
                      autofillHints: const [AutofillHints.familyName],
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => FormValidation.nameField(value, l10n.lastName),
                      onChanged: (_) => onFieldChanged(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),
              _GuestField(
                controller: controller.address,
                label: l10n.guestStreetLabel,
                icon: Icons.home_work_outlined,
                autofillHints: const [AutofillHints.streetAddressLine1],
                textCapitalization: TextCapitalization.words,
                validator: FormValidation.addressField,
                onChanged: (value) {
                  onAddressChanged(value);
                  onFieldChanged();
                },
              ),
              ?addressSuggestions,
              const SizedBox(height: AppSpacing.s12),
              Row(
                children: [
                  Expanded(
                    child: _GuestField(
                      controller: controller.postcode,
                      label: l10n.guestPostcodeLabel,
                      icon: Icons.map_outlined,
                      autofillHints: const [AutofillHints.postalCode],
                      keyboardType: TextInputType.number,
                      validator: FormValidation.postcodeField,
                      onChanged: (_) => onFieldChanged(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: _GuestField(
                      controller: controller.city,
                      label: l10n.guestCityLabel,
                      icon: Icons.location_city_rounded,
                      autofillHints: const [AutofillHints.addressCity],
                      textCapitalization: TextCapitalization.words,
                      validator: FormValidation.cityField,
                      onChanged: (_) => onFieldChanged(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),
              _GuestField(
                controller: controller.phone,
                label: l10n.guestPhoneLabel,
                icon: Icons.phone_android_rounded,
                autofillHints: const [AutofillHints.telephoneNumber],
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                validator: FormValidation.phoneField,
                onChanged: (_) => onFieldChanged(),
              ),
              const SizedBox(height: AppSpacing.s16),
              Material(
                color: Colors.transparent,
                child: Theme(
                  data: ThemeData(unselectedWidgetColor: Colors.white54),
                  child: CheckboxListTile(
                    value: createAccount,
                    onChanged: (val) => onCreateAccountChanged(val ?? false),
                    title: Text(l10n.createAccountForFaster, style: TextStyle(color: Colors.white70, fontSize: 13)),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.accentText,
                    dense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuestField extends StatelessWidget {
  const _GuestField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.autofillHints,
    required this.validator,
    required this.onChanged,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Iterable<String> autofillHints;
  final String? Function(String?) validator;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final bool autocorrect;

  OutlineInputBorder _border(Color color, [double width = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(PharosLayout.radiusMd),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      autocorrect: autocorrect,
      enableSuggestions: autocorrect,
      autofillHints: autofillHints,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      cursorColor: AppColors.accentText,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: AppColors.accentText, fontSize: 12),
        prefixIcon: Icon(icon, size: 18, color: AppColors.accentText.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.black.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _border(Colors.transparent),
        enabledBorder: _border(Colors.white.withOpacity(0.05)),
        focusedBorder: _border(AppColors.accent.withOpacity(0.6)),
        errorBorder: _border(Colors.redAccent),
        focusedErrorBorder: _border(Colors.redAccent, 2),
        errorMaxLines: 3,
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
      ),
    );
  }
}
