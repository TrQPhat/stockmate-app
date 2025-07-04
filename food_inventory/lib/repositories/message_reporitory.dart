import 'package:dio/dio.dart';
import 'package:stock_mate/core/config/app_config.dart';
import 'package:stock_mate/core/network/dio_client.dart';
import 'package:stock_mate/models/message.dart';

class MessageRepository {
  final DioClient dioClient;

  MessageRepository(this.dioClient);

  Future<List<Message>> getMessages(int conversationId) async {
    //Viết lại câu truy vấn
    final query = """
      query {
        messagesCollection(
          filter: { conversation_id: { eq: $conversationId } },
          orderBy: [{created_at: DescNullsFirst}]
        ){
          edges {
            node {
              id
              conversation_id
              type
              name_sender
              sender_id
              content
              file_url
              status
              created_at
            }
          }
        }
      }
    """;

    try {
      final response = await dioClient.graphql(query: query);
      final messages =
          response.data['data']['messagesCollection']['edges'] as List;
      return messages.map((e) => Message.fromJson(e['node'])).toList();
    } on DioException catch (e) {
      print(e.toString());
      throw Exception('Failed to fetch messages: ${e.toString()}');
    }
  }

  Future<Message?> insertMessages(Message message) async {
    try {
      final Map<String, dynamic> jsonData = message.toJson();

      final response = await dioClient.post(
        '${AppConfig.supabaseProjectUrl}/rest/v1/messages',
        data: jsonData,
        queryParameters: {'select': '*'},
        options: Options(
          headers: {
            'Prefer': 'return=representation',
            'Content-Type': 'application/json',
            'apikey': AppConfig.apiKey,
            'Authorization': 'Bearer ${AppConfig.supabaseServiceRoleKey}',
          },
          extra: {
            'attachAuthToken': false, // không gắn Bearer token mặc định
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final List data = response.data;

        if (data.isNotEmpty) {
          final insertedMessage = Message.fromJson(data.first);
          print('Insert thành công: $insertedMessage');
          return insertedMessage;
        } else {
          print('Insert thành công nhưng không có dữ liệu trả về');
          return null;
        }
      } else {
        print('Insert thất bại: ${response.statusCode} - ${response.data}');
        return null;
      }
    } catch (e) {
      print('Lỗi khi insert message: $e');
      if (e is DioException) {
        print('Lỗi chi tiết: ${e.response?.data}');
      }
      return null;
    }
  }
}
