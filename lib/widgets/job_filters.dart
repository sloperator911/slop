import 'package:flutter/material.dart';

class JobFilters extends StatelessWidget {
  const JobFilters({
    super.key,
    required this.technologies,
    required this.schedules,
    required this.selectedTechnology,
    required this.selectedSchedule,
    required this.onSearchChanged,
    required this.onTechnologyChanged,
    required this.onScheduleChanged,
  });

  final List<String> technologies;
  final List<String> schedules;
  final String selectedTechnology;
  final String selectedSchedule;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onTechnologyChanged;
  final ValueChanged<String> onScheduleChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Поиск',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: onSearchChanged,
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedTechnology,
              items: [
                const DropdownMenuItem(
                  value: '',
                  child: Text('Все технологии'),
                ),
                for (final technology in technologies)
                  DropdownMenuItem(
                    value: technology,
                    child: Text(technology),
                  ),
              ],
              onChanged: (value) {
                if (value != null) onTechnologyChanged(value);
              },
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedSchedule,
              items: [
                const DropdownMenuItem(
                  value: '',
                  child: Text('Любой график'),
                ),
                for (final schedule in schedules)
                  DropdownMenuItem(
                    value: schedule,
                    child: Text(schedule),
                  ),
              ],
              onChanged: (value) {
                if (value != null) onScheduleChanged(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
