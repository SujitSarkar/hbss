import 'package:maori_health/domain/auth/entities/forgot_pass_response.dart';

class ForgotPasswordResponseModel extends ForgotPasswordResponse {
  const ForgotPasswordResponseModel({required super.success, required super.message, required super.data});

  factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponseModel(success: json['success'], message: json['message'], data: json['data']);
  }
}
