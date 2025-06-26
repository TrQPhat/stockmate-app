import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stock_mate/views/home/widgets/custom_app_bar.dart';
import 'package:stock_mate/views/home/widgets/error_widget.dart';
import 'package:stock_mate/views/home/widgets/loading_widget.dart';
import 'package:stock_mate/bloc/storage/storage_bloc.dart';

import '../widgets/create_storage_dialog.dart';
import '../widgets/join_storage_dialog.dart';
import '../widgets/storage_card.dart';

class StorageListPage extends StatefulWidget {
  const StorageListPage({super.key});

  @override
  State<StorageListPage> createState() => _StorageListPageState();
}

class _StorageListPageState extends State<StorageListPage> {
  @override
  void initState() {
    super.initState();
    context.read<StorageBloc>().add(StorageLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Danh sách kho',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: BlocBuilder<StorageBloc, StorageState>(
        builder: (context, state) {
          if (state is StorageLoading) {
            return const LoadingWidget(message: 'Đang tải danh sách kho...');
          }

          if (state is StorageError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<StorageBloc>().add(StorageLoadRequested());
              },
            );
          }

          if (state is StorageLoaded) {
            if (state.storages.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có kho nào',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tạo kho mới hoặc tham gia kho có sẵn',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.storages.length,
              itemBuilder: (context, index) {
                final storage = state.storages[index];
                return StorageCard(
                  storage: storage,
                  onTap: () => context.go('/storage/${storage.id}'),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'join',
            onPressed: () => _showJoinStorageDialog(context),
            icon: const Icon(Icons.group_add),
            label: const Text('Tham gia'),
            backgroundColor: Colors.orange,
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'create',
            onPressed: () => _showCreateStorageDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Tạo kho'),
          ),
        ],
      ),
    );
  }

  void _showCreateStorageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<StorageBloc>(),
        child: const CreateStorageDialog(),
      ),
    );
  }

  void _showJoinStorageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<StorageBloc>(),
        child: const JoinStorageDialog(),
      ),
    );
  }
}
