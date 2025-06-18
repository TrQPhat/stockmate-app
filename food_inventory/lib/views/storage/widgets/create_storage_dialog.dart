import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/storage/storage_bloc.dart';

class CreateStorageDialog extends StatefulWidget {
  const CreateStorageDialog({super.key});

  @override
  State<CreateStorageDialog> createState() => _CreateStorageDialogState();
}

class _CreateStorageDialogState extends State<CreateStorageDialog> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tạo kho mới'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên kho',
                hintText: 'Nhập tên kho',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên kho';
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
                    StorageCreateRequested(_nameController.text.trim()),
                  );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Tạo'),
        ),
      ],
    );
  }
}
