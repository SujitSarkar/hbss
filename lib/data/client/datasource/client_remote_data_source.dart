import 'package:dio/dio.dart';

import 'package:maori_health/core/error/exceptions.dart';
import 'package:maori_health/core/network/api_endpoints.dart';
import 'package:maori_health/core/network/dio_client.dart';
import 'package:maori_health/data/Client/models/Client_model.dart';

abstract class ClientRemoteDataSource {
  Future<List<ClientModel>> getClients({int page = 1});
}

class ClientRemoteDataSourceImpl implements ClientRemoteDataSource {
  final DioClient _client;

  ClientRemoteDataSourceImpl({required DioClient client}) : _client = client;

  @override
  Future<List<ClientModel>> getClients({int page = 1}) async {
    try {
      final List<ClientModel> clients = [];
      while (true) {
        List<ClientModel> newList = [];
        final response = await _client.get(ApiEndpoints.clients, queryParameters: {'page': page});
        final body = response.data as Map<String, dynamic>;
        if (body['success'] != true) {
          throw ApiException(
            statusCode: response.statusCode,
            message: body['message']?.toString() ?? 'Failed to fetch Clients',
          );
        }
        final dataList = body['data']?['data'] as List<dynamic>? ?? [];
        newList = dataList.map((e) => ClientModel.fromJson(e as Map<String, dynamic>)).toList();
        clients.addAll(newList);

        if (body['data']?['last_page'] == page) {
          break;
        }
        page++;
      }
      return clients;
    } on DioException catch (e) {
      final message = (e.response?.data is Map) ? (e.response!.data as Map)['message']?.toString() : null;
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: message ?? e.message ?? 'Failed to fetch Clients',
      );
    }
  }
}
