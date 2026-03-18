import 'package:dio/dio.dart';

import 'package:maori_health/core/error/exceptions.dart';
import 'package:maori_health/core/network/api_endpoints.dart';
import 'package:maori_health/core/network/dio_client.dart';
import 'package:maori_health/data/employee/models/employee_model.dart';

abstract class EmployeeRemoteDataSource {
  Future<List<EmployeeModel>> getEmployees({int page = 1});
}

class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  final DioClient _client;

  EmployeeRemoteDataSourceImpl({required DioClient client}) : _client = client;

  @override
  Future<List<EmployeeModel>> getEmployees({int page = 1}) async {
    try {
      final List<EmployeeModel> employees = [];
      while (true) {
        List<EmployeeModel> newList = [];
        final response = await _client.get(ApiEndpoints.employees, queryParameters: {'page': page});
        final body = response.data as Map<String, dynamic>;
        if (body['success'] != true) {
          throw ApiException(
            statusCode: response.statusCode,
            message: body['message']?.toString() ?? 'Failed to fetch employees',
          );
        }
        final dataList = body['data']?['data'] as List<dynamic>? ?? [];
        newList = dataList.map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>)).toList();
        employees.addAll(newList);

        if (body['data']?['last_page'] == page) {
          break;
        }
        page++;
      }
      return employees;
    } on DioException catch (e) {
      final message = (e.response?.data is Map) ? (e.response!.data as Map)['message']?.toString() : null;
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: message ?? e.message ?? 'Failed to fetch employees',
      );
    }
  }
}
