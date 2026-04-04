/// First day of the week for scheduling UI. Values align with [DateTime.weekday]
/// (Monday = 1 … Sunday = 7).
enum WeekStartFrom {
  monday(1, 'Mon'),
  tuesday(2, 'Tue'),
  wednesday(3, 'Wed'),
  thursday(4, 'Thu'),
  friday(5, 'Fri'),
  saturday(6, 'Sat'),
  sunday(7, 'Sun');

  /// [DateTime.weekday] for this week-start day.
  final int dateTimeWeekday;

  /// Short label (e.g. API / settings).
  final String value;

  const WeekStartFrom(this.dateTimeWeekday, this.value);
}

/// Parses settings strings such as `Monday`, `mon`, `Sat`, `thursday`.
WeekStartFrom? tryParseWeekStartFrom(String? raw) {
  final n = (raw ?? '').trim().toLowerCase();
  if (n.isEmpty) return null;

  const ordered = <(List<String>, WeekStartFrom)>[
    (['saturday'], WeekStartFrom.saturday),
    (['sunday'], WeekStartFrom.sunday),
    (['monday'], WeekStartFrom.monday),
    (['tuesday'], WeekStartFrom.tuesday),
    (['wednesday'], WeekStartFrom.wednesday),
    (['thursday'], WeekStartFrom.thursday),
    (['friday'], WeekStartFrom.friday),
    (['sat'], WeekStartFrom.saturday),
    (['sun'], WeekStartFrom.sunday),
    (['mon'], WeekStartFrom.monday),
    (['tue'], WeekStartFrom.tuesday),
    (['wed'], WeekStartFrom.wednesday),
    (['thu'], WeekStartFrom.thursday),
    (['fri'], WeekStartFrom.friday),
  ];

  for (final (prefixes, value) in ordered) {
    for (final p in prefixes) {
      if (n.startsWith(p)) return value;
    }
  }
  return null;
}

/// The seven calendar dates in the week that contains [currentDate], ordered
/// from the configured first day through the following six days.
List<DateTime> weekDatesContaining({required WeekStartFrom weekStartFrom, DateTime? currentDate}) {
  final DateTime now = currentDate ?? DateTime.now();
  final DateTime dateOnly = DateTime(now.year, now.month, now.day);
  final int start = weekStartFrom.dateTimeWeekday;
  final int offset = (dateOnly.weekday - start + 7) % 7;
  final DateTime firstDayOfWeek = dateOnly.subtract(Duration(days: offset));
  return List.generate(7, (index) => firstDayOfWeek.add(Duration(days: index)));
}
