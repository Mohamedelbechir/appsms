// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:telephony/telephony.dart';
import 'package:equatable/equatable.dart';

import '../../models/my_message.dart';

part 'list_messages_state.dart';

enum Expeditor { orangeMoney, all }

extension ExpeditorExtension on Expeditor {
  String display() {
    switch (this) {
      case Expeditor.orangeMoney:
        return "OrangeMoney";
      default:
        return '';
    }
  }
}

class ListMessagesCubit extends Cubit<ListMessagesState> {
  final Telephony telephony = Telephony.instance;

  ListMessagesCubit() : super(ListMessagesInitial());

  void loadMessages({
    String expeditor = "Orange",
    required String pattern,
    DateTime? date,
  }) async {
    final messages = await telephony
        .getInboxSms(filter: _getFilter(expeditor, pattern, date), columns: [
      SmsColumn.ADDRESS,
      SmsColumn.BODY,
      SmsColumn.DATE,
    ], sortOrder: [
      OrderBy(SmsColumn.DATE, sort: Sort.ASC),
      OrderBy(SmsColumn.BODY)
    ]);

    var list = messages.map(mapToMySmsMessage).toList();
    emit(MessagesLoaded(list));
  }

  SmsFilter _getFilter(String expeditor, String pattern, DateTime? date) {
    var filter = SmsFilter.where(SmsColumn.ADDRESS)
        .equals(expeditor)
        .and(SmsColumn.BODY)
        .like('%$pattern%');

    if (date != null) {
      filter = filter
          .and(SmsColumn.DATE)
          .greaterThanOrEqualTo(date.millisecondsSinceEpoch.toString())
          .and(SmsColumn.DATE)
          .lessThan(date
              .add(const Duration(days: 1))
              .millisecondsSinceEpoch
              .toString());
    }
    return filter;
  }

  MySmsMessage mapToMySmsMessage(SmsMessage message) => MySmsMessage(
        expeditor: message.address,
        body: message.body,
        timestamp: message.date,
      );

  Future<void> findWhereBodyContains(String phoneNumber) async {
    final messages = await telephony.getInboxSms(
        columns: [
          SmsColumn.ADDRESS,
          SmsColumn.BODY,
          SmsColumn.DATE,
        ],
        filter: SmsFilter.where(SmsColumn.BODY).like(phoneNumber),
        sortOrder: [
          OrderBy(SmsColumn.DATE, sort: Sort.ASC),
          OrderBy(SmsColumn.BODY)
        ]);
    var list = messages.map(mapToMySmsMessage).toList();
    print(list);
  }

  void toggleSensitiveDetails() {
    if (state is MessagesLoaded) {
      final currentState = (state as MessagesLoaded);
      emit(currentState.copyWith(
        isSensitiveDetailDisplayed: !currentState.isSensitiveDetailDisplayed,
      ));
    }
  }
}
