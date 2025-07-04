import 'package:stock_mate/models/client_filter.dart';
import 'package:stock_mate/core/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _client;
  final Map<String, RealtimeChannel> _channels = {};
  static bool isInitialized = false;

  Future<void> initialize() async {
    if (isInitialized) return;

    await Supabase.initialize(
      url: AppConfig.supabaseProjectUrl,
      anonKey: AppConfig.apiKey,
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );
    _client = Supabase.instance.client;
    isInitialized = true;
  }

  SupabaseClient get client => _client;

  void subscribeToPostgresChanges({
    required String table,
    String schema = 'public',
    List<ClientFilter>? clientFilters,
    PostgresChangeFilter? serverFilter,
    void Function(Map<String, dynamic> newRecord)? onInsert,
    void Function(
            Map<String, dynamic> oldRecord, Map<String, dynamic> newRecord)?
        onUpdate,
    void Function(Map<String, dynamic> oldRecord)? onDelete,
  }) {
    if (_channels.containsKey(table)) {
      print('[SupabaseService] Already subscribed to $table');
      return;
    }

    if (!isInitialized) return;

    final channelName = 'realtime:$table';
    _channels[table] = _client.channel(channelName);

    if (onInsert != null) {
      _channels[table]?.onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: schema,
        table: table,
        filter: serverFilter,
        callback: (payload) {
          if (applyClientFilters(payload.newRecord, clientFilters)) {
            onInsert(payload.newRecord);
          }
        },
      );
    }

    if (onUpdate != null) {
      _channels[table]?.onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: schema,
        table: table,
        filter: serverFilter,
        callback: (payload) {
          if (applyClientFilters(payload.newRecord, clientFilters)) {
            onUpdate(payload.oldRecord, payload.newRecord);
          }
        },
      );
    }

    if (onDelete != null) {
      _channels[table]?.onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: schema,
        table: table,
        filter: serverFilter,
        callback: (payload) {
          if (applyClientFilters(payload.oldRecord, clientFilters)) {
            onDelete(payload.oldRecord);
          }
        },
      );
    }

    _channels[table]?.subscribe();
  }

  /// Tham gia channel có hỗ trợ broadcast và presence
  void subscribeToBroadcastAndPresence({
    required String channelName,
    required String presenceKey,
    void Function(Map<String, dynamic> payload)? onBroadcast,
    String? broadcastEvent,
    void Function(List<String> userIds)? onPresenceSync,
  }) {
    if (_channels.containsKey(channelName)) {
      print('[SupabaseService] Already joined $channelName');
      return;
    }

    if (!isInitialized) return;

    final channel = _client.channel(
      channelName,
      opts: RealtimeChannelConfig(
        key: presenceKey,
        self: true,
      ),
    );

    _channels[channelName] = channel;

    // Lắng nghe broadcast
    if (onBroadcast != null && broadcastEvent != null) {
      channel.onBroadcast(
        event: broadcastEvent,
        callback: (payload, [ref]) {
          onBroadcast(payload);
        },
      );
    }

    // Lắng nghe presence sync
    if (onPresenceSync != null) {
      channel.onPresenceSync((_) {
        final newState = channel.presenceState();
        print('sync: $newState');
      }).onPresenceJoin((payload) {
        print('join: $payload');
      }).onPresenceLeave((payload) {
        print('leave: $payload');
      }).subscribe();
    }

    channel.subscribe();
  }

  /// Gửi broadcast event
  Future<void> sendBroadcast({
    required String channelName,
    required String event,
    required Map<String, dynamic> payload,
  }) async {
    final channel = _channels[channelName];
    if (channel == null) {
      print('[SupabaseService] Channel $channelName not joined');
      return;
    }

    await channel.sendBroadcastMessage(
      event: event,
      payload: payload,
    );
  }

  /// Gửi trạng thái presence (ví dụ: user_id, name, avatar)
  Future<void> trackPresence({
    required String channelName,
    required Map<String, dynamic> payload,
  }) async {
    final channel = _channels[channelName];
    if (channel == null) {
      print('[SupabaseService] Channel $channelName not joined');
      return;
    }

    await channel.track(payload);
  }

  void unsubscribe({String? table}) {
    if (!isInitialized) return;
    if (table != null) {
      final ch = _channels[table];
      if (ch != null) {
        _client.removeChannel(ch);
        _channels.remove(table);
      }
    } else {
      for (final ch in _channels.values) {
        _client.removeChannel(ch);
      }
      _channels.clear();
    }
  }

  bool applyClientFilters(
    Map<String, dynamic> record,
    List<ClientFilter>? filters,
  ) {
    if (filters == null || filters.isEmpty) return true;

    for (final filter in filters) {
      final actual = record[filter.column];
      final expected = filter.value;

      // Nếu dữ liệu không chứa field đó hoặc null
      if (actual == null) return false;

      switch (filter.type) {
        case FilterType.eq:
          if (actual != expected) return false;
          break;

        case FilterType.neq:
          if (actual == expected) return false;
          break;

        case FilterType.gt:
        case FilterType.gte:
        case FilterType.lt:
        case FilterType.lte:
          if (actual is Comparable && expected is Comparable) {
            final cmp = actual.compareTo(expected);

            switch (filter.type) {
              case FilterType.gt:
                if (cmp <= 0) return false;
                break;
              case FilterType.gte:
                if (cmp < 0) return false;
                break;
              case FilterType.lt:
                if (cmp >= 0) return false;
                break;
              case FilterType.lte:
                if (cmp > 0) return false;
                break;
              default:
                break;
            }
          } else {
            return false;
          }
          break;

        case FilterType.in_:
          if (expected is List && !expected.contains(actual)) return false;
          break;

        case FilterType.notIn:
          if (expected is List && expected.contains(actual)) return false;
          break;
      }
    }

    return true;
  }
}
