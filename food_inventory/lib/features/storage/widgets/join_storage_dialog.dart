import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/storage_bloc.dart';

class JoinStorageDialog extends StatefulWidget {
  const JoinStorageDialog({super.key});

  @override
  State<JoinStorageDialog> createState() => _JoinStorageDialogState();
}

class _JoinStorageDialogState extends State<JoinStorageDialog> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tham gia kho'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Mã mời',
                hintText: 'Nhập mã mời',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập mã mời';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              context.read<StorageBloc>().add(
                StorageJoinRequested(_codeController.text.trim()),
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Tham gia'),
        ),
      ],
    );
  }
}
