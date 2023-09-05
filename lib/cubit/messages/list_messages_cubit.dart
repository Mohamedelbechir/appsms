// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:telephony/telephony.dart';
import 'package:equatable/equatable.dart';

import '../../models/my_message.dart';

part 'list_messages_state.dart';

class ListMessagesCubit extends Cubit<ListMessagesState> {
  final Telephony telephony = Telephony.instance;

  ListMessagesCubit() : super(ListMessagesInitial());

  void loadMessages({
    String expeditor = "Orange",
    List<String> bodyPatterns = const [],
    DateTime? date,
  }) async {
    final messages = await telephony
        .getInboxSms(filter: _getFilter(expeditor, date), columns: [
      SmsColumn.ADDRESS,
      SmsColumn.BODY,
      SmsColumn.DATE,
    ], sortOrder: [
      OrderBy(SmsColumn.DATE, sort: Sort.ASC),
      OrderBy(SmsColumn.BODY)
    ]);

    var list = _applyPatternFilter(messages, bodyPatterns)
        .map(mapToMySmsMessage)
        .toList();
    emit(MessagesLoaded(list));
  }

  Iterable<SmsMessage> _applyPatternFilter(
    List<SmsMessage> messages,
    List<String> patterns,
  ) {
    if (patterns.isEmpty) return messages;
    return messages.where((currentMessage) {
      return patterns.any((pattern) => currentMessage.body!.contains(pattern));
    });
  }

  SmsFilter _getFilter(
    String expeditor,
    DateTime? date,
  ) {
    var filter = SmsFilter.where(SmsColumn.BODY).equals("");

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
    } else {
      emit(MessagesLoaded(const [], displaySensitiveDetail: true));
    }
  }
}
