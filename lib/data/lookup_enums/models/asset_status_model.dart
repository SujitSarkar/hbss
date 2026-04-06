import 'package:maori_health/domain/lookup_enums/entities/asset_status.dart';

class AssetStatusModel extends AssetStatus {
  const AssetStatusModel({
    super.assigned,
    super.available,
    super.damaged,
    super.stockOut,
    super.warranty,
    super.expired,
    super.laptopInitiative,
    super.missing,
    super.returned,
  });

  factory AssetStatusModel.fromJson(Map<String, dynamic> json) => AssetStatusModel(
    assigned: json["assigned"],
    available: json["available"],
    damaged: json["damaged"],
    expired: json["expired"],
    laptopInitiative: json["laptop_initiative"],
    missing: json["missing"],
    returned: json["returned"],
    stockOut: json["stock_out"],
    warranty: json["warranty"],
  );

  Map<String, dynamic> toJson() => {
    'assigned': assigned,
    'available': available,
    'damaged': damaged,
    'expired': expired,
    'laptop_initiative': laptopInitiative,
    'missing': missing,
    'returned': returned,
    'stock_out': stockOut,
    'warranty': warranty,
  };
}
