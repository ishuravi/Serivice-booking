import 'package:flutter/material.dart';
import '../../colors/colors.dart';

class OperatingHoursSection extends StatefulWidget {
  // Add a callback to return the operating hours to the parent
  final Function(List<Map<String, String>>) onOperatingHoursChanged;

  OperatingHoursSection({required this.onOperatingHoursChanged});

  @override
  _OperatingHoursSectionState createState() => _OperatingHoursSectionState();
}

class _OperatingHoursSectionState extends State<OperatingHoursSection> {
  Map<String, bool> _operatingDays = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };

  Map<String, TimeOfDay?> _startTimes = {
    'Monday': null,
    'Tuesday': null,
    'Wednesday': null,
    'Thursday': null,
    'Friday': null,
    'Saturday': null,
    'Sunday': null,
  };

  Map<String, TimeOfDay?> _endTimes = {
    'Monday': null,
    'Tuesday': null,
    'Wednesday': null,
    'Thursday': null,
    'Friday': null,
    'Saturday': null,
    'Sunday': null,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Business Operating Hours',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
            SizedBox(height: 10),
            Text('Select Operating Days', style: TextStyle(fontSize: 16, color: AppColors.darkBlue)),
            Wrap(
              spacing: 8.0,
              children: _operatingDays.keys.map((day) {
                return Column(
                  children: [
                    CheckboxListTile(
                      title: Text(day),
                      value: _operatingDays[day],
                      onChanged: (value) {
                        setState(() {
                          _operatingDays[day] = value!;
                        });
                        _updateOperatingHours();
                      },
                    ),
                    if (_operatingDays[day] == true) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => _selectStartTime(day),
                              child: Text(
                                _startTimes[day] != null
                                    ? 'Start Time: ${_startTimes[day]!.hour}:${_startTimes[day]!.minute.toString().padLeft(2, '0')}'
                                    : 'Select Start Time',
                                style: TextStyle(color: AppColors.darkBlue),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () => _selectEndTime(day),
                              child: Text(
                                _endTimes[day] != null
                                    ? 'End Time: ${_endTimes[day]!.hour}:${_endTimes[day]!.minute.toString().padLeft(2, '0')}'
                                    : 'Select End Time',
                                style: TextStyle(color: AppColors.darkBlue),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartTime(String day) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTimes[day] = picked;
      });
      _updateOperatingHours();
    }
  }

  Future<void> _selectEndTime(String day) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endTimes[day] = picked;
      });
      _updateOperatingHours();
    }
  }

  void _updateOperatingHours() {
    List<Map<String, String>> operatingHours = [];

    _operatingDays.forEach((day, isSelected) {
      if (isSelected && _startTimes[day] != null && _endTimes[day] != null) {
        operatingHours.add({
          'day': day,
          'startTime': '${_startTimes[day]!.hour.toString().padLeft(2, '0')}:${_startTimes[day]!.minute.toString().padLeft(2, '0')}',
          'endTime': '${_endTimes[day]!.hour.toString().padLeft(2, '0')}:${_endTimes[day]!.minute.toString().padLeft(2, '0')}',
        });
      }
    });

    widget.onOperatingHoursChanged(operatingHours);
  }
}
