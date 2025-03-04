import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewContactPage extends StatefulWidget {
  final int contactId;

  const ViewContactPage({Key? key, required this.contactId}) : super(key: key);

  @override
  _ViewContactPageState createState() => _ViewContactPageState();
}

class _ViewContactPageState extends State<ViewContactPage> {
  Map<String, dynamic>? _contactDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchContactDetails();
  }

  Future<void> _fetchContactDetails() async {
    final url =
        Uri.parse('https://restapi.nayan.pro/api/contacts/${widget.contactId}');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _contactDetails = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        _showSnackbar(
          'Failed to fetch contact details. Error: ${response.statusCode}',
          Colors.red,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackbar(
        'An error occurred while fetching contact details. Please try again.',
        Colors.red,
      );
      Navigator.pop(context);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Contact'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contactDetails == null
              ? const Center(child: Text('No contact details available.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _contactDetails!['name'] ?? 'N/A',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Email:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _contactDetails!['email'] ?? 'N/A',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Phone:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _contactDetails!['phone'] ?? 'N/A',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Message:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _contactDetails!['message'] ?? 'N/A',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
    );
  }
}
