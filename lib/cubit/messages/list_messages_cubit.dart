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
    required String pattern,
  }) async {
    List<SmsMessage> messages = await telephony.getInboxSms(
        filter: SmsFilter.where(SmsColumn.ADDRESS)
            .equals(expeditor)
            .and(SmsColumn.BODY)
            .like('%$pattern%'),
        columns: [
          SmsColumn.ADDRESS,
          SmsColumn.BODY,
          SmsColumn.DATE,
        ],
        sortOrder: [
          OrderBy(SmsColumn.DATE, sort: Sort.ASC),
          OrderBy(SmsColumn.BODY)
        ]);

    var list = messages.map(mapToMySmsMessage).toList();
    emit(MessagesLoaded(list));
  }

  MySmsMessage mapToMySmsMessage(item) => MySmsMessage(
        expeditor: item.address,
        body: item.body,
        timestamp: item.date,
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
}
