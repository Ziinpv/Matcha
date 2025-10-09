import 'package:flutter/material.dart';

class ProfileFormWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final String? initialName;
  final String? initialBio;
  final String? initialGender;
  final String? initialLocation;
  final DateTime? initialDob;

  final FormFieldSetter<String> onSavedName;
  final FormFieldSetter<String> onSavedBio;
  final FormFieldSetter<String> onSavedGender;
  final FormFieldSetter<String> onSavedLocation;
  final FormFieldSetter<DateTime> onSavedDob;

  final VoidCallback onSubmit;

  const ProfileFormWidget({
    Key? key,
    required this.formKey,
    required this.initialName,
    required this.initialBio,
    required this.initialGender,
    required this.initialLocation,
    required this.initialDob,
    required this.onSavedName,
    required this.onSavedBio,
    required this.onSavedGender,
    required this.onSavedLocation,
    required this.onSavedDob,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<ProfileFormWidget> createState() => _ProfileFormWidgetState();
}

class _ProfileFormWidgetState extends State<ProfileFormWidget> {
  DateTime? _selectedDob;

  @override
  void initState() {
    super.initState();
    _selectedDob = widget.initialDob;
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year - 10), // tối thiểu 10 tuổi
    );
    if (picked != null) {
      setState(() => _selectedDob = picked);
    }
  }

  String? _validateDob() {
    if (_selectedDob == null) return "Please select your date of birth";
    final now = DateTime.now();
    final age = now.year - _selectedDob!.year;
    if (age < 18) return "You must be at least 18 years old";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          TextFormField(
            initialValue: widget.initialName,
            decoration: const InputDecoration(
              labelText: "Name",
              border: OutlineInputBorder(),
            ),
            validator: (val) =>
            val == null || val.isEmpty ? "Enter your name" : null,
            onSaved: widget.onSavedName,
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: widget.initialGender,
            items: const [
              DropdownMenuItem(value: "male", child: Text("Male")),
              DropdownMenuItem(value: "female", child: Text("Female")),
              DropdownMenuItem(value: "other", child: Text("Other")),
            ],
            onChanged: (_) {},
            onSaved: widget.onSavedGender,
            decoration: const InputDecoration(
              labelText: "Gender",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          InkWell(
            onTap: () => _pickDate(context),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: "Date of Birth",
                border: OutlineInputBorder(),
              ),
              child: Text(
                _selectedDob != null
                    ? "${_selectedDob!.day}/${_selectedDob!.month}/${_selectedDob!.year}"
                    : "Select date",
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_validateDob() != null)
            Text(_validateDob()!,
                style: const TextStyle(color: Colors.red, fontSize: 12)),
          Builder(builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onSavedDob(_selectedDob);
            });
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 16),

          TextFormField(
            initialValue: widget.initialLocation,
            decoration: const InputDecoration(
              labelText: "Location",
              border: OutlineInputBorder(),
            ),
            validator: (val) =>
            val == null || val.isEmpty ? "Enter your location" : null,
            onSaved: widget.onSavedLocation,
          ),
          const SizedBox(height: 16),

          TextFormField(
            initialValue: widget.initialBio,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Bio",
              border: OutlineInputBorder(),
            ),
            onSaved: widget.onSavedBio,
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              if (widget.formKey.currentState!.validate() &&
                  _validateDob() == null) {
                widget.onSubmit();
              }
            },
            child: const Text("Save Profile"),
          ),
        ],
      ),
    );
  }
}
