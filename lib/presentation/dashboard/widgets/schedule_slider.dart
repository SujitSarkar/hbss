import 'package:flutter/material.dart';

import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/domain/schedule/entities/schedule.dart';
import 'package:maori_health/presentation/schedule/widgets/schedule_list_tile_widget.dart';

class ScheduleSlider extends StatefulWidget {
  final List<Schedule> schedules;
  final void Function(Schedule schedule)? onScheduleTap;
  final double height;

  const ScheduleSlider({super.key, required this.schedules, this.onScheduleTap, this.height = 160});

  @override
  State<ScheduleSlider> createState() => _ScheduleSliderState();
}

class _ScheduleSliderState extends State<ScheduleSlider> {
  final _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int delta) {
    final next = (_currentPage + delta).clamp(0, widget.schedules.length - 1);
    _pageController.animateToPage(next, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final schedules = widget.schedules;
    if (schedules.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: schedules.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) {
              final schedule = schedules[i];
              return Padding(
                padding: const .symmetric(horizontal: 4),
                child: ScheduleListTileWidget(
                  schedule: schedule,
                  onTap: widget.onScheduleTap != null ? () => widget.onScheduleTap!(schedule) : null,
                ),
              );
            },
          ),
          if (schedules.length > 1) ...[
            _CarouselArrow(
              icon: Icons.chevron_left,
              alignment: Alignment.centerLeft,
              onTap: _currentPage > 0 ? () => _goToPage(-1) : null,
            ),
            _CarouselArrow(
              icon: Icons.chevron_right,
              alignment: Alignment.centerRight,
              onTap: _currentPage < schedules.length - 1 ? () => _goToPage(1) : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _CarouselArrow extends StatelessWidget {
  final IconData icon;
  final AlignmentGeometry alignment;
  final VoidCallback? onTap;

  const _CarouselArrow({required this.icon, required this.alignment, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const .all(2),
          decoration: BoxDecoration(
            color: context.colorScheme.surface.withAlpha(220),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 4)],
          ),
          child: Icon(
            icon,
            size: 22,
            color: onTap != null ? context.colorScheme.onSurface : context.colorScheme.onSurface.withAlpha(80),
          ),
        ),
      ),
    );
  }
}
