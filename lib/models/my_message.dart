import 'package:equatable/equatable.dart';

class MySmsMessage extends Equatable {
  final String? expeditor;
  final String? body;
  DateTime? date;

  MySmsMessage({
    required this.expeditor,
    required this.body,
    required int? timestamp,
  }) {
    if (timestamp == null) {
      date = null;
    } else {
      date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
  }

  @override
  List<Object?> get props => [
        expeditor,
        body,
        date,
      ];
}
