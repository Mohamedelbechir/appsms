import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageItem extends StatefulWidget {
  const MessageItem({
    super.key,
    required this.index,
    required this.transactionDate,
    required this.currentKey,
    required this.messageContent,
    required this.appreciation,
    this.isMultiSelectEnabled = false,
    required this.onChange,
  });

  final GlobalKey<State<StatefulWidget>> currentKey;
  final String messageContent;
  final String appreciation;
  final int index;
  final bool isMultiSelectEnabled;
  final ValueChanged<bool> onChange;
  final DateTime? transactionDate;

  @override
  State<MessageItem> createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem> {
  final locale = 'fr';
  bool _isSelected = false;

  @override
  void initState() {
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    timeago.setLocaleMessages('fr_short', timeago.FrShortMessages());
    super.initState();
  }

  String transactionDateDislay() {
    final formatter = DateFormat('dd-MM-yyyy hh:mm:ss');
    if (widget.transactionDate == null) {
      return 'Date de transaction inconnue';
    }
    return "${formatter.format(widget.transactionDate!)}  |  ${timeago.format(widget.transactionDate!, locale: locale)}";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.isMultiSelectEnabled) {
          _setState();
        }
      },
      onLongPress: () {
        if (!widget.isMultiSelectEnabled) HapticFeedback.lightImpact();

        _setState();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Text(
              transactionDateDislay(),
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Stack(
            children: [
              RepaintBoundary(
                key: widget.currentKey,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.messageContent,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (widget.appreciation.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            widget.appreciation,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (_isSelected)
                const Positioned(
                  top: -2.2,
                  left: 5,
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.orange,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _setState() {
    setState(() {
      final newValue = !_isSelected;
      _isSelected = newValue;
      widget.onChange(newValue);
    });
  }
}
