import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ContactFormPage.dart';
import 'EditContactPage.dart';
import 'ViewContactPage.dart';

class ContactTablePage extends StatefulWidget {
  @override
  _ContactTablePageState createState() => _ContactTablePageState();
}

class _ContactTablePageState extends State<ContactTablePage> {
  List<dynamic> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    final url = Uri.parse('https://restapi.nayan.pro/api/contacts');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _contacts = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        _showSnackbar('Failed to fetch contacts. Error: ${response.statusCode}',
            Colors.red);
      }
    } catch (e) {
      _showSnackbar(
          'An error occurred while fetching contacts. Please try again.',
          Colors.red);
    }
  }

  Future<void> _deleteContact(int id) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Contact'),
          content: Text('Are you sure you want to delete this contact?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmation == true) {
      final url = Uri.parse('https://restapi.nayan.pro/api/contacts/$id');
      try {
        final response = await http.delete(url);

        if (response.statusCode == 404) {
          _showSnackbar('Failed to delete contact.', Colors.red);
        } else {
          _showSnackbar('Contact deleted successfully!', Colors.green);
          setState(() {
            _contacts.removeWhere((contact) => contact['id'] == id);
          });
        }
      } catch (e) {
        _showSnackbar(
            'An error occurred while deleting the contact. Please try again.',
            Colors.red);
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
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ContactFormPage())).then(
                  (_) => _fetchContacts()); // Refresh contacts after adding
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchContacts,
              child: _contacts.isEmpty
                  ? const Center(child: Text('No contacts available.'))
                  : ListView.builder(
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) {
                        final contact = _contacts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          child: ListTile(
                            title: Text(contact['name']),
                            subtitle: Text(contact['email']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_red_eye,
                                      color: Colors.green),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ViewContactPage(
                                          contactId: contact['id'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditContactPage(
                                          contactId: contact['id'],
                                          contactName: contact['name'],
                                          contactEmail: contact['email'],
                                          contactPhone: contact['phone'],
                                          contactMessage: contact['message'],
                                        ),
                                      ),
                                    ).then((_) => _fetchContacts());
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _deleteContact(contact['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
