// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';

class MySmsMessage extends Equatable {
  final String? expeditor;
  final String? body;
  late final String? bodyWithNoSensitiveInfo;
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
    bodyWithNoSensitiveInfo = "${body?.split('.').first}.";
  }

  String? getMessage({bool displaySensitiveDetails = true}) {
    return displaySensitiveDetails ? body : bodyWithNoSensitiveInfo;
  }

  MySmsMessage.withDateTime({
    required this.expeditor,
    required this.body,
    required this.date,
  });
  @override
  List<Object?> get props => [
        expeditor,
        body,
        date,
      ];

  MySmsMessage copyWith({
    String? expeditor,
    String? body,
    DateTime? date,
  }) {
    return MySmsMessage.withDateTime(
      expeditor: expeditor ?? this.expeditor,
      body: body ?? this.body,
      date: date ?? this.date,
    );
  }
}
