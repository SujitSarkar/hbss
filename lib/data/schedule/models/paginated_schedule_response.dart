import 'package:maori_health/core/utils/data_parse_util.dart';
import 'package:maori_health/data/dashboard/models/schedule_model.dart';

class PaginatedScheduleResponse {
  final List<ScheduleModel> schedules;
  final int currentPage;
  final int lastPage;

  const PaginatedScheduleResponse({required this.schedules, required this.currentPage, required this.lastPage});

  bool get hasMore => currentPage < lastPage;

  Map<String, dynamic> toJson() {
    return {'schedules': schedules.map((e) => e.toJson()).toList(), 'current_page': currentPage, 'last_page': lastPage};
  }

  factory PaginatedScheduleResponse.fromJson(Map<String, dynamic> json) {
    final list = json['schedules'];
    return PaginatedScheduleResponse(
      schedules: list is List
          ? list.map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>)).toList()
          : <ScheduleModel>[],
      currentPage: DataParseUtil.parseInt(json['current_page'], defaultValue: 1),
      lastPage: DataParseUtil.parseInt(json['last_page'], defaultValue: 1),
    );
  }
}
