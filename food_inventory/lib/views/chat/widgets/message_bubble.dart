import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

enum MessageStatus { sending, sent, delivered, read }

class MessageBubble extends StatefulWidget {
  final String message;
  final bool isMe;
  final String sender;
  final DateTime date;
  final MessageStatus status;
  final String? avatarUrl;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.sender,
    required this.date,
    this.status = MessageStatus.sent,
    this.avatarUrl,
    this.onLongPress,
    this.onDoubleTap,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _timeAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _timeOpacityAnimation;
  late Animation<double> _timeScaleAnimation;

  bool _isPressed = false;
  bool _showTime = false;
  Timer? _hideTimeTimer;

  @override
  void initState() {
    super.initState();

    // Animation cho message bubble
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Animation cho thời gian
    _timeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: widget.isMe ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _timeOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _timeAnimationController,
      curve: Curves.easeInOut,
    ));

    _timeScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _timeAnimationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timeAnimationController.dispose();
    _hideTimeTimer?.cancel();
    super.dispose();
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatFullTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final localDateTime = dateTime.toLocal(); // Luôn đảm bảo là giờ địa phương

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate =
        DateTime(localDateTime.year, localDateTime.month, localDateTime.day);

    final timeStr =
        '${localDateTime.hour}:${localDateTime.minute.toString().padLeft(2, '0')}';

    if (messageDate == today) {
      return 'Hôm nay $timeStr';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Hôm qua $timeStr';
    } else {
      return '${localDateTime.day}/${localDateTime.month}/${localDateTime.year} $timeStr';
    }
  }

  void _toggleTimeDisplay() {
    setState(() {
      _showTime = !_showTime;
    });

    if (_showTime) {
      _timeAnimationController.forward();
      // Tự động ẩn sau 3 giây
      _hideTimeTimer?.cancel();
      _hideTimeTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          _hideTimeDisplay();
        }
      });
    } else {
      _timeAnimationController.reverse();
    }
  }

  void _hideTimeDisplay() {
    if (_showTime) {
      setState(() {
        _showTime = false;
      });
      _timeAnimationController.reverse();
    }
  }

  Widget _buildMessageStatus() {
    if (!widget.isMe) return const SizedBox.shrink();

    IconData icon;
    Color color;

    switch (widget.status) {
      case MessageStatus.sending:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          ),
        );
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.white70;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.white70;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.green.shade200;
        break;
    }

    return Icon(
      icon,
      size: 14,
      color: color,
    );
  }

  Widget _buildAvatar() {
    if (widget.isMe) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.green.shade100,
        backgroundImage:
            widget.avatarUrl != null ? NetworkImage(widget.avatarUrl!) : null,
        child: widget.avatarUrl == null
            ? Icon(
                Icons.person,
                color: Colors.green.shade600,
                size: 18,
              )
            : null,
      ),
    );
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    _toggleTimeDisplay();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.message));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.copy, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('Đã sao chép tin nhắn'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: widget.isMe
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!widget.isMe) _buildAvatar(),
                  Flexible(
                    child: GestureDetector(
                      onTap: _handleTap,
                      onTapDown: _handleTapDown,
                      onTapUp: _handleTapUp,
                      onTapCancel: _handleTapCancel,
                      onLongPress: () {
                        HapticFeedback.mediumImpact();
                        widget.onLongPress?.call();
                        _showMessageOptions();
                      },
                      onDoubleTap: widget.onDoubleTap,
                      child: AnimatedScale(
                        scale: _isPressed ? 0.95 : 1.0,
                        duration: const Duration(milliseconds: 100),
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          margin: EdgeInsets.only(
                            left: widget.isMe ? 50 : 0,
                            right: widget.isMe ? 0 : 50,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: widget.isMe
                                  ? LinearGradient(
                                      colors: [
                                        Colors.green.shade600,
                                        Colors.green.shade700,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: widget.isMe ? null : Colors.grey.shade100,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft:
                                    Radius.circular(widget.isMe ? 20 : 4),
                                bottomRight:
                                    Radius.circular(widget.isMe ? 4 : 20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.isMe
                                      ? Colors.green.withOpacity(0.3)
                                      : Colors.grey.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: widget.isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                if (!widget.isMe && widget.sender.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      widget.sender,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        widget.message,
                                        style: TextStyle(
                                          color: widget.isMe
                                              ? Colors.white
                                              : Colors.black87,
                                          fontSize: 15,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                    if (widget.isMe) ...[
                                      const SizedBox(width: 8),
                                      _buildMessageStatus(),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Thời gian hiển thị khi click
              AnimatedBuilder(
                animation: _timeAnimationController,
                builder: (context, child) {
                  return _showTime
                      ? FadeTransition(
                          opacity: _timeOpacityAnimation,
                          child: ScaleTransition(
                            scale: _timeScaleAnimation,
                            child: Container(
                              margin: const EdgeInsets.only(top: 4),
                              alignment: widget.isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _formatFullTime(widget.date),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.green),
              title: const Text('Sao chép'),
              onTap: () {
                Navigator.pop(context);
                _copyToClipboard();
              },
            ),
            ListTile(
              leading: const Icon(Icons.reply, color: Colors.green),
              title: const Text('Trả lời'),
              onTap: () {
                Navigator.pop(context);
                // Handle reply
              },
            ),
            if (widget.isMe)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Xóa'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle delete
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
