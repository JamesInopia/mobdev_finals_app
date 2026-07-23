import 'package:flutter/material.dart';
import 'package:mobdev_finals_app/ui/views/theme/app_colors.dart'; // Adjust import path as needed

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

  /// Helper input decoration matching AppColors theme
  InputDecoration _buildInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
      filled: true,
      fillColor: AppColors.container,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColors.containerStroke, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent1, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  Future<bool> _showWarningDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.container,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(color: AppColors.containerStroke, width: 1.5),
        ),
        title: const Text(
          'Discard changes?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'You have unsaved form data. Are you sure you want to go back?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
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
        backgroundColor: AppColors.background,
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // 1. Name Field
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              // 2. Email Field
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Email is required' : null,
              ),
              const SizedBox(height: 16),

              // 3. Dropdowns (Feedback Type and Issue Type)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _feedbackType,
                      isExpanded: true,
                      dropdownColor: AppColors.menuNavigation,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      iconEnabledColor: AppColors.accent1,
                      decoration: _buildInputDecoration('Type of Feedback'),
                      items: const [
                        DropdownMenuItem(
                          value: 'Suggestion',
                          child: Text('Provide Suggestion',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: 'Issue',
                          child: Text('Report an Issue',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white)),
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
                        value: _issueType,
                        isExpanded: true,
                        dropdownColor: AppColors.menuNavigation,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                        iconEnabledColor: AppColors.accent1,
                        decoration: _buildInputDecoration('Type of issue'),
                        items: const [
                          DropdownMenuItem(
                            value: 'Bug',
                            child: Text('Bug',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.white)),
                          ),
                          DropdownMenuItem(
                            value: 'Issue 2',
                            child: Text('Issue 2',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.white)),
                          ),
                          DropdownMenuItem(
                            value: 'Issue 3',
                            child: Text('Issue 3',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.white)),
                          ),
                          DropdownMenuItem(
                            value: 'Other',
                            child: Text('Other',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.white)),
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

              // 4. Subject Field
              if (_feedbackType == 'Issue') ...[
                TextFormField(
                  controller: _subjectController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration('Subject'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Subject is required'
                      : null,
                ),
                const SizedBox(height: 16),
              ],

              // 5. Description Field
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Description').copyWith(
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: 24),

              // 6. Submit Button
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent1,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.container,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          side: const BorderSide(
                              color: AppColors.containerStroke, width: 1.5),
                        ),
                        title: const Text(
                          'Success',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        content: const Text(
                          'Form sent successfully!',
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
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
                            child: const Text(
                              'OK',
                              style: TextStyle(
                                color: AppColors.accent1,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: const Text(
                  'Send',
                  style: TextStyle(
                    color: AppColors.background,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
