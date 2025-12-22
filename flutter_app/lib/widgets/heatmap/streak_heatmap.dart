import 'package:flutter/material.dart';
import '../../config/theme.dart';

class StreakHeatmap extends StatelessWidget {
  const StreakHeatmap({super.key});

  @override
  Widget build(BuildContext context) {
    // Generate 30 days of sample data
    final now = DateTime.now();
    final days = List.generate(30, (index) {
      final date = now.subtract(Duration(days: 29 - index));
      final intensity = _getIntensity(index);
      return _DayData(date: date, intensity: intensity);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heatmap grid
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: days.map((day) => _HeatmapCell(data: day)).toList(),
        ),
        
        const SizedBox(height: 12),
        
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Less',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(width: 8),
            ...List.generate(5, (index) => Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: _getColorForIntensity(index / 4),
                borderRadius: BorderRadius.circular(3),
              ),
            )),
            const SizedBox(width: 8),
            Text(
              'More',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  double _getIntensity(int index) {
    // Sample data - would be replaced with actual data
    final pattern = [0.8, 0.6, 0.0, 0.4, 0.9, 0.3, 0.7, 0.0, 0.0, 0.5,
                     0.8, 0.9, 0.4, 0.6, 0.0, 0.7, 0.5, 0.3, 0.8, 0.9,
                     0.6, 0.4, 0.0, 0.7, 0.8, 0.5, 0.9, 0.3, 0.6, 0.8];
    return pattern[index % pattern.length];
  }

  static Color _getColorForIntensity(double intensity) {
    if (intensity == 0) {
      return AppColors.border;
    } else if (intensity < 0.25) {
      return AppColors.primary.withOpacity(0.2);
    } else if (intensity < 0.5) {
      return AppColors.primary.withOpacity(0.4);
    } else if (intensity < 0.75) {
      return AppColors.primary.withOpacity(0.6);
    } else {
      return AppColors.primary;
    }
  }
}

class _DayData {
  final DateTime date;
  final double intensity;

  _DayData({required this.date, required this.intensity});
}

class _HeatmapCell extends StatelessWidget {
  final _DayData data;

  const _HeatmapCell({required this.data});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${data.date.day}/${data.date.month}: ${(data.intensity * 10).toInt()} entries',
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: StreakHeatmap._getColorForIntensity(data.intensity),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: AppColors.border.withOpacity(0.5),
            width: 0.5,
          ),
        ),
        child: data.intensity > 0.8
            ? const Center(
                child: Icon(
                  Icons.local_fire_department,
                  size: 14,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }
}
