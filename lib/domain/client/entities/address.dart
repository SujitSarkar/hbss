import 'package:equatable/equatable.dart';

class Address extends Equatable {
  final int? id;
  final int? userId;
  final int? operatorId;
  final String? homeStreetAddress;
  final String? homeSuburb;
  final String? homeCity;
  final int? homePostCode;
  final dynamic homeSa3Region;
  final dynamic homeLatitude;
  final dynamic homeLongitude;
  final String? postalStreetAddress;
  final String? postalSuburb;
  final String? postalCity;
  final int? postalPostCode;
  final dynamic postalSa3Region;
  final dynamic postalLatitude;
  final dynamic postalLongitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;
  final String? fullAddress;

  const Address({
    this.id,
    this.userId,
    this.operatorId,
    this.homeStreetAddress,
    this.homeSuburb,
    this.homeCity,
    this.homePostCode,
    this.homeSa3Region,
    this.homeLatitude,
    this.homeLongitude,
    this.postalStreetAddress,
    this.postalSuburb,
    this.postalCity,
    this.postalPostCode,
    this.postalSa3Region,
    this.postalLatitude,
    this.postalLongitude,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.fullAddress,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    operatorId,
    homeStreetAddress,
    homeSuburb,
    homeCity,
    homePostCode,
    homeSa3Region,
    homeLatitude,
    homeLongitude,
    postalStreetAddress,
    postalSuburb,
    postalCity,
    postalPostCode,
    postalSa3Region,
    postalLatitude,
    postalLongitude,
    createdAt,
    updatedAt,
    deletedAt,
    fullAddress,
  ];
}
