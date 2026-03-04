import 'package:equatable/equatable.dart';
import 'package:maori_health/domain/client/entities/address.dart';

class Client extends Equatable {
  final int? id;
  final String? fullName;
  final String? fName;
  final String? mName;
  final String? lName;
  final String? nickName;
  final String? email;
  final String? phone;
  final String? location;
  final String? userType;
  final String? gender;
  final String? proNoun;
  final DateTime? dob;
  final String? status;
  final String? age;
  final String? ageGroup;
  final String? avatar;
  final dynamic photoId;
  final String? nhi;
  final String? ethnicity;
  final dynamic teamId;
  final String? externalAccess;
  final String? limitedAccess;
  final dynamic externalLoginOtp;
  final DateTime? externalLoginOtpExpiredAt;
  final int? operatorId;
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final Address? address;

  const Client({
    this.id,
    this.fName,
    this.mName,
    this.lName,
    this.nickName,
    this.email,
    this.phone,
    this.location,
    this.userType,
    this.gender,
    this.proNoun,
    this.dob,
    this.status,
    this.age,
    this.ageGroup,
    this.avatar,
    this.photoId,
    this.nhi,
    this.ethnicity,
    this.teamId,
    this.externalAccess,
    this.limitedAccess,
    this.externalLoginOtp,
    this.externalLoginOtpExpiredAt,
    this.operatorId,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.fullName,
    this.address,
  });

  @override
  List<Object?> get props => [
    id,
    fName,
    mName,
    lName,
    nickName,
    email,
    phone,
    location,
    userType,
    gender,
    proNoun,
    dob,
    status,
    age,
    ageGroup,
    avatar,
    photoId,
    nhi,
    ethnicity,
    teamId,
    externalAccess,
    limitedAccess,
    externalLoginOtp,
    externalLoginOtpExpiredAt,
    operatorId,
    emailVerifiedAt,
    createdAt,
    updatedAt,
    deletedAt,
    address,
  ];
}
