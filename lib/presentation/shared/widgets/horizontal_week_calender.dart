import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum WeekStartFrom {
  saturday('Sat'),
  sunday('Sun'),
  monday('Mon');

  final String value;

  const WeekStartFrom(this.value);
}

const double _cellHeight = 60;

class HorizontalWeekCalendar extends StatefulWidget {
  /// week start from Monday or Sunday
  ///
  /// default value is
  /// ```dart
  /// [WeekStartFrom.Monday]
  /// ```
  final WeekStartFrom? weekStartFrom;

  ///get DateTime on date select
  ///
  /// ```dart
  /// onDateChange: (DateTime date){
  ///    print(date);
  /// }
  /// ```
  final Function(DateTime)? onDateChange;

  ///get the list of DateTime on week change
  ///
  /// ```dart
  /// onWeekChange: (List<DateTime> list){
  ///    print("First date: ${list.first}");
  ///    print("Last date: ${list.last}");
  /// }
  /// ```
  final Function(List<DateTime>)? onWeekChange;

  /// Active background color
  ///
  /// Default value is
  /// ```dart
  /// Theme.of(context).primaryColor
  /// ```
  final Color? activeBackgroundColor;

  /// In-Active background color
  ///
  /// Default value is
  /// ```dart
  /// Theme.of(context).primaryColor.withOpacity(.2)
  /// ```
  final Color? inactiveBackgroundColor;

  /// Disable background color
  ///
  /// Default value is
  /// ```dart
  /// Colors.grey
  /// ```
  final Color? disabledBackgroundColor;

  /// Active text color
  ///
  /// Default value is
  /// ```dart
  /// Theme.of(context).primaryColor
  /// ```
  final Color? activeTextColor;

  /// In-Active text color
  ///
  /// Default value is
  /// ```dart
  /// Theme.of(context).primaryColor.withOpacity(.2)
  /// ```
  final Color? inactiveTextColor;

  /// Disable text color
  ///
  /// Default value is
  /// ```dart
  /// Colors.grey
  /// ```
  final Color? disabledTextColor;

  /// Active Navigator color
  ///
  /// Default value is
  /// ```dart
  /// Theme.of(context).primaryColor
  /// ```
  final Color? activeNavigatorColor;

  /// In-Active Navigator color
  ///
  /// Default value is
  /// ```dart
  /// Colors.grey
  /// ```
  final Color? inactiveNavigatorColor;

  /// Month Color
  ///
  /// Default value is
  /// ```dart
  /// Theme.of(context).primaryColor.withOpacity(.2)
  /// ```
  final Color? monthColor;

  /// border radius of date card
  ///
  /// Default value is `null`
  final BorderRadiusGeometry? borderRadius;

  /// scroll physics
  ///
  /// Default value is
  /// ```
  /// scrollPhysics: const ClampingScrollPhysics(),
  /// ```
  final ScrollPhysics? scrollPhysics;

  /// showNavigationButtons
  ///
  /// Default value is `true`
  final bool? showNavigationButtons;

  /// monthFormat
  ///
  /// If it's current year then
  /// Default value will be ```MMMM```
  ///
  /// Otherwise
  /// Default value will be `MMMM yyyy`
  final String? monthFormat;

  final DateTime minDate;

  final DateTime maxDate;

  final DateTime initialDate;

  final bool showTopNavbar;

  final bool disableDayPicker;

  final HorizontalWeekCalenderController? controller;

  ///controll the date jump
  ///
  /// ```dart
  /// jumpPre()
  /// Jump scoll calender to left
  ///
  /// jumpNext()
  /// Jump calender to right date
  /// ```

  HorizontalWeekCalendar({
    super.key,
    this.onDateChange,
    this.onWeekChange,
    this.activeBackgroundColor,
    this.controller,
    this.inactiveBackgroundColor,
    this.disabledBackgroundColor = Colors.grey,
    this.activeTextColor = Colors.white,
    this.inactiveTextColor = Colors.white,
    this.disabledTextColor = Colors.white,
    this.activeNavigatorColor,
    this.inactiveNavigatorColor,
    this.monthColor,
    this.weekStartFrom = WeekStartFrom.monday,
    this.borderRadius,
    this.scrollPhysics = const ClampingScrollPhysics(),
    this.showNavigationButtons = true,
    this.monthFormat,
    required this.minDate,
    required this.maxDate,
    required this.initialDate,
    this.showTopNavbar = true,
    this.disableDayPicker = false,
  }) : // assert(minDate != null && maxDate != null),
       assert(minDate.isBefore(maxDate)),
       assert(minDate.isBefore(initialDate) && (initialDate).isBefore(maxDate)),
       super();

  @override
  State<HorizontalWeekCalendar> createState() => _HorizontalWeekCalendarState();
}

class _HorizontalWeekCalendarState extends State<HorizontalWeekCalendar> {
  late final PageController pageController;

  final int _initialPage = 1;

  DateTime today = DateTime.now();
  DateTime selectedDate = DateTime.now();
  List<DateTime> currentWeek = [];
  int currentWeekIndex = 0;

  List<List<DateTime>> listOfWeeks = [];

  @override
  void initState() {
    pageController = PageController(initialPage: _initialPage);
    initCalender();
    super.initState();
  }

  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  void initCalender() {
    final date = widget.initialDate;
    selectedDate = widget.initialDate;

    DateTime startOfCurrentWeek = widget.weekStartFrom == WeekStartFrom.monday
        ? getDate(date.subtract(Duration(days: date.weekday - 1)))
        : getDate(date.subtract(Duration(days: date.weekday % 7)));

    currentWeek.add(startOfCurrentWeek);
    for (int index = 0; index < 6; index++) {
      DateTime addDate = startOfCurrentWeek.add(Duration(days: (index + 1)));
      currentWeek.add(addDate);
    }

    listOfWeeks.add(currentWeek);

    _getMorePreviousWeeks();

    _getMoreNextWeeks();

    if (widget.controller != null) {
      widget.controller!._stateChangerPre.addListener(() {
        print("previous");
        _onBackClick();
      });

      widget.controller!._stateChangerNex.addListener(() {
        print("next");
        _onNextClick();
      });
    }
  }

  void _getMorePreviousWeeks() {
    List<DateTime> minus7Days = [];
    DateTime startFrom = listOfWeeks[currentWeekIndex].first;

    bool canAdd = false;
    for (int index = 0; index < 7; index++) {
      DateTime minusDate = startFrom.add(Duration(days: -(index + 1)));
      minus7Days.add(minusDate);
      // if (widget.minDate != null) {
      if (minusDate.add(const Duration(days: 1)).isAfter(widget.minDate)) {
        canAdd = true;
      }
      // } else {
      //   canAdd = true;
      // }
    }
    if (canAdd == true) {
      listOfWeeks.add(minus7Days.reversed.toList());
    }
    setState(() {});
  }

  void _getMoreNextWeeks() {
    List<DateTime> plus7Days = [];
    // DateTime startFrom = currentWeek.last;
    DateTime startFrom = listOfWeeks[currentWeekIndex].last;

    // bool canAdd = false;
    // int newCurrentWeekIndex = 1;
    for (int index = 0; index < 7; index++) {
      DateTime addDate = startFrom.add(Duration(days: (index + 1)));
      plus7Days.add(addDate);
      // if (widget.maxDate != null) {
      //   if (addDate.isBefore(widget.maxDate!)) {
      //     canAdd = true;
      //     newCurrentWeekIndex = 1;
      //   } else {
      //     newCurrentWeekIndex = 0;
      //   }
      // } else {
      //   canAdd = true;
      //   newCurrentWeekIndex = 1;
      // }
    }
    // print("canAdd: $canAdd");
    // print("newCurrentWeekIndex: $newCurrentWeekIndex");

    // if (canAdd == true) {
    listOfWeeks.insert(0, plus7Days);
    // }
    currentWeekIndex = 1;
    setState(() {});
  }

  void _onDateSelect(DateTime date) {
    setState(() {
      selectedDate = date;
    });
    widget.onDateChange?.call(selectedDate);
  }

  void _onBackClick() {
    pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _onNextClick() {
    pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void onWeekChange(index) {
    if (currentWeekIndex < index) {
      // on back
    }
    if (currentWeekIndex > index) {
      // on next
    }

    currentWeekIndex = index;
    currentWeek = listOfWeeks[currentWeekIndex];

    if (currentWeekIndex + 1 == listOfWeeks.length) {
      _getMorePreviousWeeks();
    }

    if (index == 0) {
      _getMoreNextWeeks();
      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }

    widget.onWeekChange?.call(currentWeek);
    setState(() {});
  }

  // =================

  bool _isReachMinimum(DateTime dateTime) {
    return widget.minDate.add(const Duration(days: -1)).isBefore(dateTime);
  }

  bool _isReachMaximum(DateTime dateTime) {
    return widget.maxDate.add(const Duration(days: 1)).isAfter(dateTime);
  }

  bool _isNextDisabled() {
    DateTime lastDate = listOfWeeks[currentWeekIndex].last;
    // if (widget.maxDate != null) {
    String lastDateFormatted = DateFormat('yyyy/MM/dd').format(lastDate);
    String maxDateFormatted = DateFormat('yyyy/MM/dd').format(widget.maxDate);
    if (lastDateFormatted == maxDateFormatted) return true;
    // }

    bool isAfter =
        // widget.maxDate == null ? false :
        lastDate.isAfter(widget.maxDate);

    return isAfter;
    // return listOfWeeks[currentWeekIndex].last.isBefore(DateTime.now());
  }

  bool isBackDisabled() {
    DateTime firstDate = listOfWeeks[currentWeekIndex].first;
    // if (widget.minDate != null) {
    String firstDateFormatted = DateFormat('yyyy/MM/dd').format(firstDate);
    String minDateFormatted = DateFormat('yyyy/MM/dd').format(widget.minDate);
    if (firstDateFormatted == minDateFormatted) return true;
    // }

    bool isBefore =
        // widget.minDate == null ? false :
        firstDate.isBefore(widget.minDate);

    return isBefore;
    // return listOfWeeks[currentWeekIndex].last.isBefore(DateTime.now());
  }

  bool isCurrentYear() {
    return DateFormat('yyyy').format(currentWeek.first) == DateFormat('yyyy').format(today);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    // var withOfScreen = MediaQuery.of(context).size.width;

    // double boxHeight = withOfScreen / 7;

    return currentWeek.isEmpty
        ? const SizedBox()
        : Column(
            children: [
              if (widget.showTopNavbar)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.showNavigationButtons == true
                        ? GestureDetector(
                            onTap: isBackDisabled()
                                ? null
                                : () {
                                    _onBackClick();
                                  },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 17,
                                  color: isBackDisabled()
                                      ? (widget.inactiveNavigatorColor ?? Colors.grey)
                                      : theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Prev",
                                  style: theme.textTheme.titleMedium!.copyWith(
                                    color: isBackDisabled()
                                        ? (widget.inactiveNavigatorColor ?? Colors.grey)
                                        : theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(),
                    Text(
                      widget.monthFormat?.isEmpty ?? true
                          ? (isCurrentYear()
                                ? DateFormat('MMMM').format(currentWeek.first)
                                : DateFormat('MMMM yyyy').format(currentWeek.first))
                          : DateFormat(widget.monthFormat).format(currentWeek.first),
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: widget.monthColor ?? theme.colorScheme.primary,
                      ),
                    ),
                    widget.showNavigationButtons == true
                        ? GestureDetector(
                            onTap: _isNextDisabled()
                                ? null
                                : () {
                                    _onNextClick();
                                  },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Next",
                                  style: theme.textTheme.titleMedium!.copyWith(
                                    color: _isNextDisabled()
                                        ? (widget.inactiveNavigatorColor ?? Colors.grey)
                                        : theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 17,
                                  color: _isNextDisabled()
                                      ? (widget.inactiveNavigatorColor ?? Colors.grey)
                                      : theme.colorScheme.primary,
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              if (widget.showTopNavbar) const SizedBox(height: 12),
              SizedBox(
                height: _cellHeight,
                child: PageView.builder(
                  controller: pageController,
                  physics: widget.scrollPhysics ?? const ClampingScrollPhysics(),
                  reverse: true,
                  itemCount: listOfWeeks.length,
                  onPageChanged: (index) {
                    onWeekChange(index);
                  },
                  itemBuilder: (context, ind) {
                    return SizedBox(
                      height: _cellHeight,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          for (int weekIndex = 0; weekIndex < listOfWeeks[ind].length; weekIndex++)
                            Builder(
                              builder: (_) {
                                DateTime currentDate = listOfWeeks[ind][weekIndex];
                                final bool isSelected =
                                    !widget.disableDayPicker &&
                                    DateFormat('dd-MM-yyyy').format(currentDate) ==
                                        DateFormat('dd-MM-yyyy').format(selectedDate);
                                final bool isEnabled = _isReachMaximum(currentDate) && _isReachMinimum(currentDate);
                                final bool canSelectDay = isEnabled && !widget.disableDayPicker;
                                final BorderRadiusGeometry borderRadius =
                                    widget.borderRadius ?? const BorderRadius.all(Radius.circular(8));
                                final Color primary = theme.colorScheme.primary;
                                return Expanded(
                                  child: GestureDetector(
                                    // TODO: disabled
                                    onTap: canSelectDay
                                        ? () {
                                            _onDateSelect(listOfWeeks[ind][weekIndex]);
                                          }
                                        : null,
                                    child: Container(
                                      height: _cellHeight,
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      decoration: BoxDecoration(
                                        color: theme.dividerColor.withAlpha(80),
                                        borderRadius: borderRadius,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: _cellHeight,
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                            decoration: BoxDecoration(
                                              border: isSelected ? Border.all(color: primary) : null,
                                              borderRadius: borderRadius,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "${currentDate.day}".padLeft(2, '0'),
                                                  textAlign: TextAlign.center,
                                                  style: theme.textTheme.titleSmall?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: isSelected ? primary : (isEnabled ? null : theme.hintColor),
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  DateFormat('EEE').format(listOfWeeks[ind][weekIndex]),
                                                  textAlign: TextAlign.center,
                                                  style: theme.textTheme.labelSmall?.copyWith(
                                                    fontSize: 8,
                                                    color: isSelected
                                                        ? primary
                                                        : (isEnabled ? theme.hintColor : theme.disabledColor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }
}

class HorizontalWeekCalenderController {
  final ValueNotifier<int> _stateChangerPre = ValueNotifier<int>(0);
  final ValueNotifier<int> _stateChangerNex = ValueNotifier<int>(0);

  void jumpPre() {
    _stateChangerPre.value = _stateChangerPre.value + 1;
  }

  void jumpNext() {
    _stateChangerNex.value = _stateChangerNex.value + 1;
  }
}
