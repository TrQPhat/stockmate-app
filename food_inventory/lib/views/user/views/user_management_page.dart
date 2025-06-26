import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_mate/models/user_tam.dart';

import '../../../core/config/app_config.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../../../bloc/user/user_bloc.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? currentStorageId;
  bool isOwner = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStorageId();
  }

  void _loadStorageId() async {
    final prefs = getIt<SharedPreferences>();
    setState(() {
      currentStorageId = prefs.getInt(AppConfig.currentStorageKey);
    });

    if (currentStorageId != null) {
      context
          .read<UserManagementBloc>()
          .add(LoadStorageMembers(currentStorageId!));
    }

    // TODO: Check if current user is owner
    // For now, we'll assume the user is the owner
    setState(() {
      isOwner = true;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Thành viên'),
            Tab(text: 'Mã mời'),
          ],
          labelColor: AppTheme.primaryGreen,
          indicatorColor: AppTheme.primaryGreen,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMembersTab(),
          _buildInviteCodeTab(),
        ],
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton(
              onPressed: () {
                _showInviteUserDialog();
              },
              backgroundColor: AppTheme.primaryGreen,
              child: const Icon(Icons.person_add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildMembersTab() {
    return BlocConsumer<UserManagementBloc, UserState>(
      listener: (context, state) {
        if (state is UserManagementError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is UserManagementLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is StorageMembersLoaded) {
          if (state.members.isEmpty) {
            return Center(
              child: Text(
                'Chưa có thành viên nào trong kho',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: state.members.length,
            itemBuilder: (context, index) {
              final member = state.members[index];
              return _buildMemberCard(member);
            },
          );
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Không thể tải danh sách thành viên',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  if (currentStorageId != null) {
                    context
                        .read<UserManagementBloc>()
                        .add(LoadStorageMembers(currentStorageId!));
                  }
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInviteCodeTab() {
    return BlocConsumer<UserManagementBloc, UserState>(
      listener: (context, state) {
        if (state is UserManagementError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        } else if (state is InviteCodeLoaded) {
          // Show success message when new code is generated
          if (state.inviteCode.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mã mời đã được tạo thành công'),
                backgroundColor: AppTheme.primaryGreen,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        String inviteCode = '';

        if (state is InviteCodeLoaded) {
          inviteCode = state.inviteCode;
        }

        return Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mã mời kho',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Chia sẻ mã này với người khác để họ có thể tham gia vào kho của bạn',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24.h),

              // Invite code display
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: state is UserManagementLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Text(
                              inviteCode.isEmpty
                                  ? 'Chưa có mã mời'
                                  : inviteCode,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                    if (inviteCode.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: inviteCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã sao chép mã mời'),
                              backgroundColor: AppTheme.primaryGreen,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: state is UserManagementLoading || !isOwner
                          ? null
                          : () {
                              if (currentStorageId != null) {
                                context.read<UserManagementBloc>().add(
                                      GetStorageInviteCode(currentStorageId!),
                                    );
                              }
                            },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Lấy mã mời'),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: state is UserManagementLoading || !isOwner
                          ? null
                          : () {
                              if (currentStorageId != null) {
                                context.read<UserManagementBloc>().add(
                                      GenerateNewInviteCode(currentStorageId!),
                                    );
                              }
                            },
                      icon: const Icon(Icons.autorenew),
                      label: const Text('Tạo mã mới'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.lightGreen,
                      ),
                    ),
                  ),
                ],
              ),

              // Share options
              if (inviteCode.isNotEmpty) ...[
                SizedBox(height: 32.h),
                Text(
                  'Chia sẻ qua',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildShareOption(
                      icon: Icons.message,
                      label: 'SMS',
                      onTap: () {
                        // TODO: Share via SMS
                      },
                    ),
                    _buildShareOption(
                      icon: Icons.email,
                      label: 'Email',
                      onTap: () {
                        // TODO: Share via Email
                      },
                    ),
                    _buildShareOption(
                      icon: Icons.chat,
                      label: 'Messenger',
                      onTap: () {
                        // TODO: Share via Messenger
                      },
                    ),
                    _buildShareOption(
                      icon: Icons.more_horiz,
                      label: 'Khác',
                      onTap: () {
                        // TODO: Show more share options
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMemberCard(UserMember member) {
    // Replace this with your actual logic to get the current user's email or id
    final prefs = getIt<SharedPreferences>();
    final String? currentUserEmail = prefs.getString('user_email');
    final bool isSelf = member.email == currentUserEmail;
    final bool canEdit = isOwner && !isSelf;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: member.avatarUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(25.r),
                    child: Image.network(
                      member.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          color: AppTheme.primaryGreen,
                          size: 24.w,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: AppTheme.primaryGreen,
                    size: 24.w,
                  ),
          ),
          SizedBox(width: 16.w),

          // Member info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName ?? member.email,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (member.fullName != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    member.email,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: _getRoleColor(member.role),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        _getRoleName(member.role),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isSelf) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          'Bạn',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Actions
          if (canEdit)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, size: 20.w),
              onSelected: (value) {
                if (value == 'change_role') {
                  _showChangeRoleDialog(member);
                } else if (value == 'remove') {
                  _showRemoveMemberDialog(member);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'change_role',
                  child: Text('Thay đổi quyền'),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Text('Xóa thành viên'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryGreen,
              size: 24.w,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  void _showInviteUserDialog() {
    final emailController = TextEditingController();
    MemberRole selectedRole = MemberRole.viewer;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Mời thành viên'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Nhập email người dùng...',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16.h),
                DropdownButtonFormField<MemberRole>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Quyền',
                  ),
                  items: [
                    DropdownMenuItem(
                      value: MemberRole.viewer,
                      child: Text(_getRoleName(MemberRole.viewer)),
                    ),
                    DropdownMenuItem(
                      value: MemberRole.editor,
                      child: Text(_getRoleName(MemberRole.editor)),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedRole = value;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (emailController.text.trim().isNotEmpty &&
                      currentStorageId != null) {
                    context.read<UserManagementBloc>().add(
                          InviteUserToStorage(
                            storageId: currentStorageId!,
                            email: emailController.text.trim(),
                            role: selectedRole,
                          ),
                        );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Mời'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showChangeRoleDialog(UserMember member) {
    MemberRole selectedRole = member.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Thay đổi quyền'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thành viên: ${member.fullName ?? member.email}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16.h),
                DropdownButtonFormField<MemberRole>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Quyền mới',
                  ),
                  items: [
                    DropdownMenuItem(
                      value: MemberRole.viewer,
                      child: Text(_getRoleName(MemberRole.viewer)),
                    ),
                    DropdownMenuItem(
                      value: MemberRole.editor,
                      child: Text(_getRoleName(MemberRole.editor)),
                    ),
                    DropdownMenuItem(
                      value: MemberRole.owner,
                      child: Text(_getRoleName(MemberRole.owner)),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedRole = value;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (currentStorageId != null) {
                    context.read<UserManagementBloc>().add(
                          UpdateMemberRole(
                            storageId: currentStorageId!,
                            memberId: member.id,
                            role: selectedRole,
                          ),
                        );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRemoveMemberDialog(UserMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa thành viên'),
        content: Text(
          'Bạn có chắc chắn muốn xóa ${member.fullName ?? member.email} khỏi kho?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (currentStorageId != null) {
                context.read<UserManagementBloc>().add(
                      RemoveMemberFromStorage(
                        storageId: currentStorageId!,
                        memberId: member.id,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(MemberRole role) {
    switch (role) {
      case MemberRole.owner:
        return Colors.orange;
      case MemberRole.editor:
        return AppTheme.primaryGreen;
      case MemberRole.viewer:
        return Colors.blue;
    }
  }

  String _getRoleName(MemberRole role) {
    switch (role) {
      case MemberRole.owner:
        return 'Chủ kho';
      case MemberRole.editor:
        return 'Biên tập viên';
      case MemberRole.viewer:
        return 'Người xem';
    }
  }
}
