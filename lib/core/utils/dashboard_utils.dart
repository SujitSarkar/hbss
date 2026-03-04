import 'package:maori_health/core/utils/extensions.dart';

abstract class DashboardUtils {
  static String formatJobType(String? type) => switch (type) {
    'pc' => 'Personal Care',
    'hm' => 'Home Management',
    _ => type?.capitalize() ?? 'Job',
  };
}
