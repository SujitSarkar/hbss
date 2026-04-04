import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/result/result.dart';
import 'package:maori_health/data/asset/models/asset_response_model.dart';
import 'package:maori_health/domain/asset/repositories/asset_repository.dart';

class AcceptAssetUsecase {
  final AssetRepository _repository;

  AcceptAssetUsecase({required AssetRepository repository}) : _repository = repository;

  Future<Result<AppError, AssetResponseModel>> call(int assetId) {
    return _repository.acceptAsset(assetId);
  }
}
