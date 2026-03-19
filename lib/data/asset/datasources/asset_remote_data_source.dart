import 'package:dio/dio.dart';

import 'package:maori_health/core/error/exceptions.dart';
import 'package:maori_health/core/network/api_endpoints.dart';
import 'package:maori_health/core/network/dio_client.dart';

import 'package:maori_health/data/asset/models/asset_response_model.dart';

abstract class AssetRemoteDataSource {
  Future<List<AssetResponseModel>> getAssets();
  Future<AssetResponseModel> acceptAsset(int assetId);
}

class AssetRemoteDataSourceImpl implements AssetRemoteDataSource {
  final DioClient _client;

  AssetRemoteDataSourceImpl({required DioClient client}) : _client = client;

  @override
  Future<List<AssetResponseModel>> getAssets() async {
    try {
      final response = await _client.get(ApiEndpoints.assets);
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw ApiException(
          statusCode: response.statusCode,
          message: body['message']?.toString() ?? 'Failed to fetch assets',
        );
      }
      final responseData = body['data'] as List<dynamic>? ?? [];
      return responseData.map((e) => AssetResponseModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      final message = (e.response?.data is Map) ? (e.response?.data as Map)['message']?.toString() : null;
      throw ApiException(statusCode: e.response?.statusCode, message: message ?? e.message ?? 'Failed to fetch assets');
    } catch (e) {
      throw ApiException(statusCode: 0, message: e.toString());
    }
  }

  @override
  Future<AssetResponseModel> acceptAsset(int assetId) async {
    try {
      final response = await _client.get(ApiEndpoints.acceptAsset(assetId));
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw ApiException(
          statusCode: response.statusCode,
          message: body['message']?.toString() ?? 'Failed to accept asset',
        );
      }
      return AssetResponseModel.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = (e.response?.data is Map) ? (e.response?.data as Map)['message']?.toString() : null;
      throw ApiException(statusCode: e.response?.statusCode, message: message ?? e.message ?? 'Failed to accept asset');
    } catch (e) {
      throw ApiException(statusCode: 0, message: e.toString());
    }
  }
}
