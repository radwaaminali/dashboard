import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TopBarWidget extends StatefulWidget {
  final String currentPage;
  const TopBarWidget({super.key, required this.currentPage});

  @override
  State<TopBarWidget> createState() => _TopBarWidgetState();
}

class _TopBarWidgetState extends State<TopBarWidget> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> notifications = [];
  bool loading = false;
  int unreadCount = 0;

  RealtimeChannel? _notificationsChannel;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _setupRealtime();
  }

  @override
  void dispose() {
    _notificationsChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _fetchNotifications() async {
    setState(() => loading = true);

    try {
      final response = await supabase
          .from('notifications')
          .select('*')
          .order('created_at', ascending: false)
          .limit(10);

      final data = List<Map<String, dynamic>>.from(response);

      setState(() {
        notifications = data;
        unreadCount = notifications.where((n) => n['is_read'] == false).length;
      });
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _setupRealtime() {
    _notificationsChannel = supabase
        .channel('public:notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          callback: (payload) {
            final newRecord = payload.newRecord;
            if (!mounted) return;

            final newRow = Map<String, dynamic>.from(newRecord);

            setState(() {
              notifications.insert(0, newRow);
              if (notifications.length > 10) notifications.removeLast();
              if (newRow['is_read'] != true) unreadCount++;
            });
          },
        )
        .subscribe();
  }

  Future<void> _markAllAsRead() async {
    try {
      await supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('is_read', false);

      setState(() {
        unreadCount = 0;
        notifications = notifications
            .map((n) => {...n, 'is_read': true})
            .toList();
      });
    } catch (e) {
      debugPrint('Error marking notifications as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1ABC9C),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.currentPage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              _buildNotificationButton(),
              const SizedBox(width: 20),
              const CircleAvatar(
                backgroundColor: Colors.white,
                child: Text('KA', style: TextStyle(color: Color(0xFF1ABC9C))),
              ),
              const SizedBox(width: 8),
              const Text(
                'Khalifa Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        PopupMenuButton<int>(
          icon: const Icon(Icons.notifications, color: Colors.white, size: 26),
          color: const Color(0xFF34495E),
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onOpened: () {
            if (unreadCount > 0) _markAllAsRead();
          },
          itemBuilder: (context) {
            if (loading) {
              return const [
                PopupMenuItem<int>(
                  value: -1,
                  enabled: false,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ];
            }

            if (notifications.isEmpty) {
              return const [
                PopupMenuItem<int>(
                  value: -1,
                  enabled: false,
                  child: Text(
                    'No notifications',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ];
            }

            return [
              const PopupMenuItem<int>(
                value: -1,
                enabled: false,
                child: Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const PopupMenuDivider(),
              ...notifications.map((n) {
                final isRead = n['is_read'] == true;
                return PopupMenuItem<int>(
                  value: n['id'] as int,
                  child: ListTile(
                    leading: Icon(
                      Icons.circle,
                      size: 10,
                      color: isRead ? Colors.white30 : Colors.tealAccent,
                    ),
                    title: Text(
                      n['title'] ?? 'No title',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      n['message'] ?? '',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }),
            ];
          },
        ),
        if (unreadCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                unreadCount > 9 ? '9+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
