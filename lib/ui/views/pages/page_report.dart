import 'package:flutter/material.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContactForm();
  }
}

class ContactForm extends StatefulWidget {
  const ContactForm({super.key});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();

  String? _feedbackType;
  String? _issueType;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _hasUnsavedChanges() {
    return _nameController.text.isNotEmpty ||
        _emailController.text.isNotEmpty ||
        _subjectController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty ||
        _feedbackType != null ||
        _issueType != null;
  }

  Future<bool> _showWarningDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
            'You have unsaved form data. Are you sure you want to go back?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  bool _isForcingPop = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: _isForcingPop,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (_hasUnsavedChanges()) {
            final shouldPop = await _showWarningDialog();

            if (shouldPop && context.mounted) {
              setState(() => _isForcingPop = true);
              Navigator.of(context).pop();
            }
          } else {
            setState(() => _isForcingPop = true);
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // 1. Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),

                //Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Email is required'
                      : null,
                ),
                const SizedBox(height: 16),

                //Dropdowns (Feedback Type and Issue Type)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _feedbackType,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Type of Feedback',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Suggestion',
                            child: Text('Provide Suggestion',
                                overflow: TextOverflow.ellipsis),
                          ),
                          DropdownMenuItem(
                            value: 'Issue',
                            child: Text('Report an Issue',
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                        validator: (v) => v == null ? 'Required' : null,
                        onChanged: (value) {
                          setState(() {
                            _feedbackType = value;
                            if (value != 'Issue') _issueType = null;
                          });
                        },
                      ),
                    ),
                    if (_feedbackType == 'Issue') ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _issueType,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Type of issue',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Bug',
                              child:
                                  Text('Bug', overflow: TextOverflow.ellipsis),
                            ),
                            DropdownMenuItem(
                              value: 'Issue 2',
                              child: Text('Issue 2',
                                  overflow: TextOverflow.ellipsis),
                            ),
                            DropdownMenuItem(
                              value: 'Issue 3',
                              child: Text('Issue 3',
                                  overflow: TextOverflow.ellipsis),
                            ),
                            DropdownMenuItem(
                              value: 'Other',
                              child: Text('Other',
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                          validator: (v) => v == null ? 'Required' : null,
                          onChanged: (value) =>
                              setState(() => _issueType = value),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                //Subject Field (Show only if feedback type is issue)
                if (_feedbackType == 'Issue') ...[
                  TextFormField(
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Subject is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],

                //Description Field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Description is required'
                      : null,
                ),
                const SizedBox(height: 24),

                // Submit Button that shows success Dialog
                FilledButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Success'),
                          content: const Text('Form sent successfully!'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                //Closes dialog and resets the form
                                Navigator.of(context).pop();
                                _formKey.currentState?.reset();
                                _nameController.clear();
                                _emailController.clear();
                                _subjectController.clear();
                                _descriptionController.clear();

                                setState(() {
                                  _feedbackType = null;
                                  _issueType = null;
                                });
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ));
  }
}
