import 'package:maori_health/core/utils/data_parse_util.dart';

import 'package:maori_health/data/asset/models/product_model.dart';
import 'package:maori_health/domain/asset/entities/stock.dart';

class StockModel extends Stock {
  const StockModel({
    required super.id,
    required super.productId,
    required super.categoryTypeId,
    required super.supplierId,
    required super.note,
    required super.uniqueId,
    required super.unitPrice,
    required super.quantity,
    required super.totalStock,
    required super.status,
    required super.macId,
    required super.purchaseDate,
    required super.warrantyDate,
    required super.testingDate,
    required super.location,
    required super.operatorId,
    required super.createdAt,
    required super.updatedAt,
    required super.product,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) => StockModel(
    id: DataParseUtil.parseInt(json["id"]),
    productId: DataParseUtil.parseInt(json["product_id"]),
    categoryTypeId: DataParseUtil.parseInt(json["category_type_id"]),
    supplierId: DataParseUtil.parseInt(json["supplier_id"]),
    note: json["note"],
    uniqueId: json["unique_id"],
    unitPrice: DataParseUtil.parseDouble(json["unit_price"]),
    quantity: DataParseUtil.parseInt(json["quantity"]),
    totalStock: DataParseUtil.parseInt(json["total_stock"]),
    status: json["status"]?.toString(),
    macId: json["mac_id"]?.toString(),
    purchaseDate: json["purchase_date"] == null ? null : DateTime.parse(json["purchase_date"]),
    warrantyDate: json["warranty_date"] == null ? null : DateTime.parse(json["warranty_date"]),
    testingDate: json["testing_date"] == null ? null : DateTime.parse(json["testing_date"]),
    location: json["location"]?.toString(),
    operatorId: DataParseUtil.parseInt(json["operator_id"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    product: json["product"] != null ? ProductModel.fromJson(json["product"]) : null,
  );
}
