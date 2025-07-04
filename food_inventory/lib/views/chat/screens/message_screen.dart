import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_mate/bloc/message/message_bloc.dart';
import 'package:stock_mate/bloc/message/message_event.dart';
import 'package:stock_mate/bloc/message/message_state.dart';
import 'package:stock_mate/core/config/app_config.dart';
import 'package:stock_mate/core/config/app_format.dart';
import 'package:stock_mate/core/di/injection_container.dart';
import 'package:stock_mate/models/client_filter.dart';
import 'package:stock_mate/models/message.dart';
import 'package:stock_mate/services/supabase_service.dart';
import 'package:stock_mate/views/chat/widgets/message_bubble.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final SupabaseService _realtimeService;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int? _currentStorageId;
  String? _storageName = "Kho của tôi";
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadStorageData();
    if (_currentStorageId != null) {
      context
          .read<MessageBloc>()
          .add(LoadMessages(conversationId: _currentStorageId!));
      registerRealtime();
    }
    _animationController.forward();
  }

  Future<void> _loadStorageData() async {
    try {
      final prefs = getIt<SharedPreferences>();
      final currentStorage = prefs.getInt(AppConfig.storageIdKey) ?? -1;
      final nameStorage = prefs.getString(AppConfig.nameStorageKey) ?? '';
      if (!mounted) return;
      setState(() {
        _currentStorageId = currentStorage != -1 ? currentStorage : null;
        _storageName = nameStorage.isNotEmpty ? nameStorage : "Kho của tôi";
      });
    } catch (e) {
      debugPrint('Error loading storage: $e');
      setState(() {
        _currentStorageId = null;
        _storageName = null;
      });
    }
  }

  void registerRealtime() {
    _realtimeService = SupabaseService();
    _realtimeService.subscribeToPostgresChanges(
      table: 'messages',
      serverFilter: PostgresChangeFilter(
        column: 'conversation_id',
        type: PostgresChangeFilterType.eq,
        value: _currentStorageId,
      ),
      // clientFilters: [
      //   const ClientFilter(
      //     column: 'sender_type',
      //     type: FilterType.in_,
      //     value: ['contact', 'bot'],
      //   ),
      // ],
      onInsert: (newRecord) {
        final message = Message.fromJson(newRecord);
        context.read<MessageBloc>().add(MessageRealtimeInserted(message));
        _scrollToBottom();
        print('New message received: ${message.content}');
      },
      onUpdate: (oldRecord, newRecord) {
        final newMessage = Message.fromJson(newRecord);
        final oldMessage = Message.fromJson(oldRecord);
        context.read<MessageBloc>().add(
              MessageRealtimeUpdated(
                oldMessage: oldMessage,
                newMessage: newMessage,
              ),
            );
        print('Message updated: ${newMessage.content}');
      },
      onDelete: (oldRecord) {
        final messageId = oldRecord['id'];
        context.read<MessageBloc>().add(MessageRealtimeDeleted(messageId));
        print('Message deleted: $messageId');
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _realtimeService.unsubscribe(table: 'messages');
    _controller.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: Colors.green.shade300,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade600,
            Colors.green.shade700,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.message_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Trò chuyện",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_storageName != null)
                      Text(
                        _storageName!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.more_vert,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isTyping ? Colors.green.shade200 : Colors.transparent,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                onChanged: (value) {
                  setState(() {
                    _isTyping = value.isNotEmpty;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Material(
              color: _isTyping ? Colors.green.shade600 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(24),
              elevation: _isTyping ? 4 : 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: _sendMessage,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    color: _isTyping ? Colors.white : Colors.grey.shade600,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _currentStorageId == null
                  ? _buildEmptyState(
                      'Tham gia kho để bắt đầu câu chuyện',
                      Icons.inventory_2_outlined,
                    )
                  : BlocBuilder<MessageBloc, MessageState>(
                      builder: (context, state) {
                        if (state is MessageLoading) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.green.shade600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Đang tải tin nhắn...',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (state is MessageError) {
                          return _buildEmptyState(
                            'Vui lòng kiểm tra lại kết nối',
                            Icons.wifi_off_outlined,
                          );
                        } else if (state is MessageLoaded) {
                          final userId = getIt<SharedPreferences>()
                              .getInt(AppConfig.userIdKey);
                          if (userId == null) {
                            return _buildEmptyState(
                              'Vui lòng đăng nhập',
                              Icons.login_outlined,
                            );
                          }
                          final messages = state.messages;
                          if (messages.isEmpty) {
                            return _buildEmptyState(
                              'Bắt đầu cuộc trò chuyện',
                              Icons.chat_outlined,
                            );
                          }

                          const timeGap = Duration(hours: 3);
                          List<Widget> widgets = [];
                          for (int i = 0; i < messages.length; i++) {
                            final msg = messages[i];
                            widgets.add(
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 2,
                                ),
                                child: MessageBubble(
                                  message: msg.content!,
                                  isMe: msg.senderId == userId,
                                  sender: msg.nameSender,
                                  date: msg.createdAt,
                                ),
                              ),
                            );

                            if (i < messages.length - 1) {
                              final currentTime = msg.createdAt;
                              final nextTime = messages[i + 1].createdAt;
                              final timeDiff =
                                  nextTime.difference(currentTime).abs();
                              final isDifferentDay =
                                  currentTime.day != nextTime.day ||
                                      currentTime.month != nextTime.month ||
                                      currentTime.year != nextTime.year;
                              final shouldShowTime =
                                  timeDiff >= timeGap || isDifferentDay;

                              if (shouldShowTime) {
                                final timeLabel =
                                    AppFormat.formatFriendlyTime(currentTime);
                                widgets.add(
                                  Container(
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        timeLabel,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            } else {
                              final timeLabel =
                                  AppFormat.formatFriendlyTime(msg.createdAt);
                              widgets.add(
                                Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.only(
                                    top: 12,
                                    bottom: 20,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      timeLabel,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          }

                          return ListView(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(top: 16),
                            reverse: true,
                            children: widgets,
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    final text = _controller.text.trim();
    _controller.clear();
    setState(() {
      _isTyping = false;
    });

    final prefs = getIt<SharedPreferences>();
    final userId = prefs.getInt(AppConfig.userIdKey);
    final userName = prefs.getString(AppConfig.userNameKey);
    if (userId == null || userName == null) return;

    final message = Message(
      conversationId: _currentStorageId!,
      senderId: userId,
      content: text,
      nameSender: '',
    );

    context.read<MessageBloc>().add(AddMessage(message));
    _scrollToBottom();
  }
}
