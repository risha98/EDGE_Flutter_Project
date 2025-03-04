import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditContactPage extends StatefulWidget {
  final int contactId;
  final String contactName;
  final String contactEmail;
  final String contactPhone;
  final String contactMessage;

  const EditContactPage({
    Key? key,
    required this.contactId,
    required this.contactName,
    required this.contactEmail,
    required this.contactPhone,
    required this.contactMessage,
  }) : super(key: key);

  @override
  _EditContactPageState createState() => _EditContactPageState();
}

class _EditContactPageState extends State<EditContactPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _messageController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contactName);
    _emailController = TextEditingController(text: widget.contactEmail);
    _phoneController = TextEditingController(text: widget.contactPhone);
    _messageController = TextEditingController(text: widget.contactMessage);
  }

  Future<void> _updateContact() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final url = Uri.parse(
          'https://restapi.nayan.pro/api/contacts/${widget.contactId}');
      final body = json.encode({
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'message': _messageController.text,
      });

      try {
        final response = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

        if (response.statusCode == 200) {
          _showSnackbar('Contact updated successfully!', Colors.green);
          Navigator.pop(context); // Go back to contacts list
        } else {
          _showSnackbar('Failed to update contact.', Colors.red);
        }
      } catch (e) {
        _showSnackbar(
            'An error occurred while updating the contact. Please try again.',
            Colors.red);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Contact')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, 'Name', 'Enter name'),
              _buildTextField(_emailController, 'Email', 'Enter email'),
              _buildTextField(_phoneController, 'Phone', ''),
              _buildTextField(_messageController, 'Message', '', maxLines: 3),
              const SizedBox(height: 16),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _updateContact,
                      child: const Text('Update Contact'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String errorText,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value == null || value.isEmpty ? errorText : null,
      maxLines: maxLines,
    );
  }
}
