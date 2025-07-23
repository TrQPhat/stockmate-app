import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_mate/bloc/storage/storage_bloc.dart';
import 'package:stock_mate/core/theme/app_theme.dart';
import 'package:stock_mate/models/user.dart';
import 'package:stock_mate/core/config/app_config.dart';
import 'package:stock_mate/core/di/injection_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageMembersScreen extends StatefulWidget {
  const StorageMembersScreen({super.key});

  @override
  State<StorageMembersScreen> createState() => _StorageMembersScreenState();
}

class _StorageMembersScreenState extends State<StorageMembersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _filteredMembers = [];
  List<User> _allMembers = [];
  int? _currentUserId;
  String? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    context.read<StorageBloc>().add(const StorageMembersRequested());
    _searchController.addListener(_onSearchChanged);
  }

  void _loadCurrentUser() {
    final prefs = getIt<SharedPreferences>();
    _currentUserId = prefs.getInt(AppConfig.userIdKey);
    _currentUserRole = prefs.getString('user_role');
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredMembers = _allMembers;
      } else {
        _filteredMembers = _allMembers.where((member) {
          final fullName = member.fullName?.toLowerCase() ?? '';
          final email = member.email.toLowerCase();
          final phone = member.phone?.toLowerCase() ?? '';
          return fullName.contains(query) ||
              email.contains(query) ||
              phone.contains(query);
        }).toList();
      }
    });
  }

  void _updateMembersList(List<User> members) {
    setState(() {
      _allMembers = members;
      _filteredMembers = members;
    });
  }

  bool get _isOwner => _currentUserRole == 'owner';
  bool get _canManageMembers => _isOwner;
  bool get _canViewDetails => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Thành viên',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              context.read<StorageBloc>().add(const StorageMembersRequested());
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
          if (_canManageMembers)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                switch (value) {
                  case 'invite':
                    _showInviteMemberDialog();
                    break;
                  case 'manage_roles':
                    _showManageRolesScreen();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'invite',
                  child: Row(
                    children: [
                      Icon(Icons.person_add_outlined,
                          size: 20, color: AppTheme.primaryGreen),
                      SizedBox(width: 12),
                      Text('Mời thành viên'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'manage_roles',
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings_outlined,
                          size: 20, color: AppTheme.primaryGreen),
                      SizedBox(width: 12),
                      Text('Quản lý quyền'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surfaceColor,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm thành viên...',
                hintStyle: const TextStyle(color: AppTheme.textSecondary),
                prefixIcon:
                    const Icon(Icons.search, color: AppTheme.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: const Icon(Icons.clear,
                            color: AppTheme.textSecondary),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.textLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppTheme.primaryGreen, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.textLight),
                ),
                filled: true,
                fillColor: AppTheme.backgroundLight,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Members list
          Expanded(
            child: BlocConsumer<StorageBloc, StorageState>(
              listener: (context, state) {
                if (state is StorageMembersLoaded) {
                  _updateMembersList(state.members);
                }
              },
              builder: (context, state) {
                if (state is StorageLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                    ),
                  );
                }

                if (state is StorageError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.errorRed,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Có lỗi xảy ra',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<StorageBloc>()
                                .add(const StorageMembersRequested());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is StorageMembersLoaded ||
                    _filteredMembers.isNotEmpty) {
                  if (_filteredMembers.isEmpty &&
                      _searchController.text.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppTheme.textLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không tìm thấy thành viên',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Thử tìm kiếm với từ khóa khác',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppTheme.primaryGreen,
                    onRefresh: () async {
                      context
                          .read<StorageBloc>()
                          .add(const StorageMembersRequested());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredMembers.length,
                      itemBuilder: (context, index) {
                        final member = _filteredMembers[index];
                        return _buildMemberCard(member);
                      },
                    ),
                  );
                }

                // Empty state
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 64,
                        color: AppTheme.textLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có thành viên nào',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.textPrimary,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Danh sách thành viên sẽ hiển thị ở đây',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Floating action button chỉ hiển thị cho owner
      floatingActionButton: _canManageMembers
          ? FloatingActionButton(
              onPressed: () {
                _showInviteMemberDialog();
              },
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              child: const Icon(Icons.person_add),
            )
          : null,
    );
  }

  Widget _buildMemberCard(User member) {
    final isCurrentUser = member.userId == _currentUserId;
    final canManageThisMember =
        _canManageMembers && !isCurrentUser && member.role != 'owner';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shadowColor: AppTheme.cardShadow.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundLight,
              AppTheme.backgroundLight.withOpacity(0.95),
              AppTheme.accentGreen.withOpacity(0.1),
              AppTheme.lightGreen.withOpacity(0.05),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
          // Thêm shimmer effect
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentGreen.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 4,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Shimmer overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.transparent,
                      AppTheme.accentGreen.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.3, 0.6, 1.0],
                  ),
                ),
              ),
            ),
            // Sparkle effects
            Positioned(
              top: 10,
              right: 20,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.accentYellow.withOpacity(0.6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentYellow.withOpacity(0.4),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 30,
              right: 40,
              child: Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  color: AppTheme.lightGreen.withOpacity(0.7),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.lightGreen.withOpacity(0.3),
                      blurRadius: 3,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 30,
              child: Container(
                width: 2,
                height: 2,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.5),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                      blurRadius: 2,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
            // Main content
            ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _getRoleColor(member.role ?? 'viewer')
                              .withOpacity(0.2),
                          _getRoleColor(member.role ?? 'viewer')
                              .withOpacity(0.05),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getRoleColor(member.role ?? 'viewer')
                              .withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.transparent,
                      backgroundImage: member.avatarUrl != null &&
                              member.avatarUrl!.isNotEmpty
                          ? NetworkImage(member.avatarUrl!)
                          : null,
                      child: member.avatarUrl == null ||
                              member.avatarUrl!.isEmpty
                          ? Text(
                              _getInitials(member.fullName ?? member.email),
                              style: TextStyle(
                                color: _getRoleColor(member.role ?? 'viewer'),
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.white.withOpacity(0.8),
                                    offset: const Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            )
                          : null,
                    ),
                  ),
                  if (member.role == 'owner')
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.accentYellow,
                              AppTheme.accentYellow.withOpacity(0.8),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentYellow.withOpacity(0.5),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.star,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      member.fullName ?? member.email,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                        shadows: [
                          Shadow(
                            color: Colors.white.withOpacity(0.8),
                            offset: const Offset(0.5, 0.5),
                            blurRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isCurrentUser)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryGreen.withOpacity(0.2),
                            AppTheme.lightGreen.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.primaryGreen.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Bạn',
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hiển thị email nếu fullName có giá trị
                  if (member.fullName != null &&
                      member.fullName!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 16,
                          color: AppTheme.textSecondary,
                          shadows: [
                            Shadow(
                              color: Colors.white.withOpacity(0.8),
                              offset: const Offset(0.5, 0.5),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            member.email,
                            style:
                                const TextStyle(color: AppTheme.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (member.phone != null && member.phone!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 16,
                          color: AppTheme.textSecondary,
                          shadows: [
                            Shadow(
                              color: Colors.white.withOpacity(0.8),
                              offset: const Offset(0.5, 0.5),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          member.phone!,
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                  if (member.gender != null && member.gender!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          member.gender?.toLowerCase() == 'male'
                              ? Icons.male
                              : member.gender?.toLowerCase() == 'female'
                                  ? Icons.female
                                  : Icons.person_outline,
                          size: 16,
                          color: AppTheme.textSecondary,
                          shadows: [
                            Shadow(
                              color: Colors.white.withOpacity(0.8),
                              offset: const Offset(0.5, 0.5),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          member.gender!,
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                  if (member.joinedAt != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppTheme.textSecondary,
                          shadows: [
                            Shadow(
                              color: Colors.white.withOpacity(0.8),
                              offset: const Offset(0.5, 0.5),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tham gia: ${_formatDate(member.joinedAt!)}',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getRoleColor(member.role ?? 'viewer')
                              .withOpacity(0.15),
                          _getRoleColor(member.role ?? 'viewer')
                              .withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _getRoleColor(member.role ?? 'viewer')
                            .withOpacity(0.4),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getRoleColor(member.role ?? 'viewer')
                              .withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.8),
                          blurRadius: 2,
                          offset: const Offset(-1, -1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getRoleIcon(member.role ?? 'viewer'),
                          size: 14,
                          color: _getRoleColor(member.role ?? 'viewer'),
                          shadows: [
                            Shadow(
                              color: Colors.white.withOpacity(0.8),
                              offset: const Offset(0.5, 0.5),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getRoleDisplayName(member.role ?? 'viewer'),
                          style: TextStyle(
                            color: _getRoleColor(member.role ?? 'viewer'),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.white.withOpacity(0.8),
                                offset: const Offset(0.3, 0.3),
                                blurRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              trailing: canManageThisMember || _canViewDetails
                  ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.8),
                            Colors.white.withOpacity(0.3),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.textSecondary.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: AppTheme.textSecondary,
                          shadows: [
                            Shadow(
                              color: Colors.white.withOpacity(0.8),
                              offset: const Offset(0.5, 0.5),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case 'view':
                              _showMemberDetails(member);
                              break;
                            case 'change_role':
                              _showChangeRoleDialog(member);
                              break;
                            case 'remove':
                              _showRemoveMemberDialog(member);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          if (_canViewDetails)
                            const PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility_outlined,
                                      size: 20, color: AppTheme.primaryGreen),
                                  SizedBox(width: 12),
                                  Text('Xem chi tiết'),
                                ],
                              ),
                            ),
                          if (canManageThisMember) ...[
                            const PopupMenuItem(
                              value: 'change_role',
                              child: Row(
                                children: [
                                  Icon(Icons.admin_panel_settings_outlined,
                                      size: 20, color: AppTheme.primaryGreen),
                                  SizedBox(width: 12),
                                  Text('Thay đổi quyền'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'remove',
                              child: Row(
                                children: [
                                  Icon(Icons.person_remove_outlined,
                                      size: 20, color: AppTheme.errorRed),
                                  SizedBox(width: 12),
                                  Text('Xóa khỏi kho',
                                      style:
                                          TextStyle(color: AppTheme.errorRed)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words.first[0]}${words.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hôm nay';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} tuần trước';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return AppTheme.primaryOrange; // Màu cam nổi bật cho owner
      case 'editor':
        return AppTheme.primaryGreen; // Màu xanh chính cho editor
      case 'viewer':
        return AppTheme.textSecondary; // Màu xám cho viewer
      default:
        return AppTheme.textLight;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return Icons.star;
      case 'editor':
        return Icons.edit;
      case 'viewer':
        return Icons.visibility;
      default:
        return Icons.person;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return 'Chủ sở hữu';
      case 'editor':
        return 'Biên tập viên';
      case 'viewer':
        return 'Người xem';
      default:
        return role;
    }
  }

  String _getRoleDescription(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return 'Có toàn quyền quản lý kho hàng và thành viên';
      case 'editor':
        return 'Có thể chỉnh sửa và quản lý sản phẩm trong kho';
      case 'viewer':
        return 'Chỉ có thể xem thông tin kho hàng';
      default:
        return '';
    }
  }

  void _showMemberDetails(User member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor:
                  _getRoleColor(member.role ?? 'viewer').withOpacity(0.15),
              backgroundImage:
                  member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                      ? NetworkImage(member.avatarUrl!)
                      : null,
              child: member.avatarUrl == null || member.avatarUrl!.isEmpty
                  ? Text(
                      _getInitials(member.fullName ?? member.email),
                      style: TextStyle(
                        color: _getRoleColor(member.role ?? 'viewer'),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                member.fullName ?? member.email,
                style: const TextStyle(
                  fontSize: 18,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.email_outlined, 'Email', member.email),
            const SizedBox(height: 12),
            if (member.phone != null && member.phone!.isNotEmpty) ...[
              _buildDetailRow(
                  Icons.phone_outlined, 'Điện thoại', member.phone!),
              const SizedBox(height: 12),
            ],
            if (member.gender != null && member.gender!.isNotEmpty) ...[
              _buildDetailRow(
                  member.gender?.toLowerCase() == 'male'
                      ? Icons.male
                      : member.gender?.toLowerCase() == 'female'
                          ? Icons.female
                          : Icons.person_outline,
                  'Giới tính',
                  member.gender!),
              const SizedBox(height: 12),
            ],
            _buildDetailRow(
              _getRoleIcon(member.role ?? 'viewer'),
              'Vai trò',
              _getRoleDisplayName(member.role ?? 'viewer'),
            ),
            const SizedBox(height: 8),
            Text(
              _getRoleDescription(member.role ?? 'viewer'),
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (member.joinedAt != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.access_time,
                'Tham gia',
                _formatDate(member.joinedAt!),
              ),
            ],
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.calendar_today_outlined,
              'Tạo tài khoản',
              _formatDate(member.createdAt),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryGreen,
            ),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showChangeRoleDialog(User member) {
    String selectedRole = member.role ?? 'viewer';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          title: Text(
            'Thay đổi quyền - ${member.fullName ?? member.email}',
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Row(
                  children: [
                    Icon(Icons.edit, size: 20, color: AppTheme.primaryGreen),
                    SizedBox(width: 8),
                    Text('Biên tập viên',
                        style: TextStyle(color: AppTheme.textPrimary)),
                  ],
                ),
                subtitle: const Text(
                  'Có thể chỉnh sửa và quản lý sản phẩm',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                value: 'editor',
                groupValue: selectedRole,
                activeColor: AppTheme.primaryGreen,
                onChanged: (value) => setState(() => selectedRole = value!),
              ),
              RadioListTile<String>(
                title: const Row(
                  children: [
                    Icon(Icons.visibility,
                        size: 20, color: AppTheme.textSecondary),
                    SizedBox(width: 8),
                    Text('Người xem',
                        style: TextStyle(color: AppTheme.textPrimary)),
                  ],
                ),
                subtitle: const Text(
                  'Chỉ có thể xem thông tin kho hàng',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                value: 'viewer',
                groupValue: selectedRole,
                activeColor: AppTheme.primaryGreen,
                onChanged: (value) => setState(() => selectedRole = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
              ),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: selectedRole != member.role
                  ? () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Đã thay đổi quyền của ${member.fullName ?? member.email} thành ${_getRoleDisplayName(selectedRole)}'),
                          backgroundColor: AppTheme.successGreen,
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveMemberDialog(User member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text(
          'Xác nhận xóa',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn có chắc chắn muốn xóa ${member.fullName ?? member.email} khỏi kho hàng?',
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hành động này không thể hoàn tác.',
              style: TextStyle(
                color: AppTheme.errorRed,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
            ),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Đã xóa ${member.fullName ?? member.email} khỏi kho hàng'),
                  backgroundColor: AppTheme.errorRed,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showInviteMemberDialog() {
    final emailController = TextEditingController();
    String selectedRole = 'viewer';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          title: const Text(
            'Mời thành viên mới',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                  hintText: 'Nhập email người dùng',
                  hintStyle: TextStyle(color: AppTheme.textLight),
                  prefixIcon:
                      Icon(Icons.email_outlined, color: AppTheme.primaryGreen),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppTheme.primaryGreen, width: 2),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Chọn quyền:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              RadioListTile<String>(
                title: const Text(
                  'Biên tập viên',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                subtitle: const Text(
                  'Có thể chỉnh sửa và quản lý sản phẩm',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                value: 'editor',
                groupValue: selectedRole,
                activeColor: AppTheme.primaryGreen,
                onChanged: (value) => setState(() => selectedRole = value!),
              ),
              RadioListTile<String>(
                title: const Text(
                  'Người xem',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                subtitle: const Text(
                  'Chỉ có thể xem thông tin kho hàng',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                value: 'viewer',
                groupValue: selectedRole,
                activeColor: AppTheme.primaryGreen,
                onChanged: (value) => setState(() => selectedRole = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
              ),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (emailController.text.isNotEmpty) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Đã gửi lời mời đến ${emailController.text}'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Gửi lời mời'),
            ),
          ],
        ),
      ),
    );
  }

  void _showManageRolesScreen() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text(
          'Quản lý quyền',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRoleInfo(
                'Chủ sở hữu',
                'Có toàn quyền quản lý kho hàng và thành viên',
                Icons.star,
                AppTheme.primaryOrange),
            const SizedBox(height: 12),
            _buildRoleInfo(
                'Biên tập viên',
                'Có thể chỉnh sửa và quản lý sản phẩm trong kho',
                Icons.edit,
                AppTheme.primaryGreen),
            const SizedBox(height: 12),
            _buildRoleInfo('Người xem', 'Chỉ có thể xem thông tin kho hàng',
                Icons.visibility, AppTheme.textSecondary),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryGreen,
            ),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleInfo(
      String title, String description, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
