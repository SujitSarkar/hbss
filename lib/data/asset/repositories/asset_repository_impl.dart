import 'package:maori_health/core/error/exceptions.dart';
import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/network/network_checker.dart';
import 'package:maori_health/core/result/result.dart';

import 'package:maori_health/data/asset/datasources/asset_remote_data_source.dart';
import 'package:maori_health/data/asset/models/asset_response_model.dart';
import 'package:maori_health/domain/asset/repositories/asset_repository.dart';

class AssetRepositoryImpl implements AssetRepository {
  final AssetRemoteDataSource _remoteDataSource;
  final NetworkChecker _networkChecker;

  AssetRepositoryImpl({required AssetRemoteDataSource remoteDataSource, required NetworkChecker networkChecker})
    : _remoteDataSource = remoteDataSource,
      _networkChecker = networkChecker;

  @override
  Future<Result<AppError, List<AssetResponseModel>>> getAssets() async {
    if (!await _networkChecker.hasConnection) {
      return const ErrorResult(NetworkError());
    }
    try {
      final assets = await _remoteDataSource.getAssets();
      return SuccessResult(assets);
    } on ApiException catch (e) {
      return ErrorResult(ApiError(errorCode: e.statusCode, errorMessage: e.message));
    } catch (e) {
      return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
    }
  }

  @override
  Future<Result<AppError, AssetResponseModel>> acceptAsset(int assetId) async {
    if (!await _networkChecker.hasConnection) {
      return const ErrorResult(NetworkError());
    }
    try {
      final asset = await _remoteDataSource.acceptAsset(assetId);
      return SuccessResult(asset);
    } on ApiException catch (e) {
      return ErrorResult(ApiError(errorCode: e.statusCode, errorMessage: e.message));
    } catch (e) {
      return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
    }
  }
}
