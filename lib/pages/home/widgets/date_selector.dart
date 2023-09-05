import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:intl/intl.dart';

class DateSelector extends StatefulWidget {
  final ValueChanged onSelect;

  const DateSelector({Key? key, required this.onSelect}) : super(key: key);

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  var selectedDate = DateUtils.dateOnly(DateTime.now());

  Future<void> showDatePicker(BuildContext context) async {
    final newDateTime = await showRoundedDatePicker(
      context: context,
      theme: ThemeData(primarySwatch: Colors.orange),
      initialDate: selectedDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
      borderRadius: 16,
    );
    setState(() {
      selectedDate = newDateTime ?? selectedDate;
      widget.onSelect(selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await showDatePicker(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: Colors.orange),
            const SizedBox(width: 10),
            Text(
              DateFormat('dd-MM-yyyy')
                  .format(selectedDate)
                  .toString()
                  .replaceAll("00:00:00.000", ""),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.edit, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
