// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:appsms/cubit/parameter/parameter_cubit.dart';
import 'package:appsms/models/app_parameter.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:telephony/telephony.dart';
import 'package:equatable/equatable.dart';

import '../../models/my_message.dart';

part 'list_messages_state.dart';

class ListMessagesCubit extends Cubit<ListMessagesState> {
  final Telephony telephony = Telephony.instance;
  final ParameterCubit _parameterCubit;
  AppParameter? _parameter;

  StreamSubscription<ParameterState>? appParameterSubscription;

  ListMessagesCubit(this._parameterCubit) : super(ListMessagesInitial()) {
    appParameterSubscription =
        _parameterCubit.stream.listen(_subscribeToAppParameter);
    if (_parameterCubit.state is ParameterInitial) {
      _parameterCubit.loadAppParameter();
    }
  }

  void loadMessages({
    String expeditor = "Orange",
    List<String> receiverPhoneNumbers = const [],
    DateTime? date,
  }) async {
    final messages = await telephony.getInboxSms(
      filter: _getFilter(expeditor, date),
      columns: _getColumns,
      sortOrder: _getSortOrder,
    );

    var list = _applyPatternFilter(messages, receiverPhoneNumbers)
        .map(mapToMySmsMessage)
        .toList();

    emit(MessagesLoaded(
      list,
      appreciation: _parameter?.displayAppreciation() ?? "",
      displaySensitiveDetail: _parameter?.isSensitiveInfoDisplayed ?? false,
      selectedIndexies: const [],
    ));
  }

  void setMessageSelection(int messageIndex, bool selected) {
    final currentState = state as MessagesLoaded;
    final currentSelectedIndexies = currentState.selectedIndexies;
    List<int> selectedIndexies;
    if (selected) {
      selectedIndexies = List.from(currentSelectedIndexies)..add(messageIndex);
    } else {
      selectedIndexies = currentSelectedIndexies
          .where((currentIndex) => currentIndex != messageIndex)
          .toList();
    }
    emit(
      currentState.copyWith(selectedIndexies: selectedIndexies),
    );
  }

  List<OrderBy> get _getSortOrder {
    return [OrderBy(SmsColumn.DATE, sort: Sort.ASC), OrderBy(SmsColumn.BODY)];
  }

  List<SmsColumn> get _getColumns {
    return [
      SmsColumn.ADDRESS,
      SmsColumn.BODY,
      SmsColumn.DATE,
    ];
  }

  Iterable<SmsMessage> _applyPatternFilter(
    List<SmsMessage> messages,
    List<String> receiverPhoneNumbers,
  ) {
    if (receiverPhoneNumbers.isEmpty) return messages;
    return messages.where((currentMessage) {
      return receiverPhoneNumbers.any((receiverPhoneNumber) {
        return currentMessage.body!.contains(receiverPhoneNumber);
      });
    });
  }

  SmsFilter _getFilter(
    String expeditor,
    DateTime? dateFrom,
  ) {
    var filter = SmsFilter.where(SmsColumn.ADDRESS).equals(expeditor);

    if (dateFrom != null) {
      var dateTo = dateFrom.add(const Duration(days: 1));

      filter = filter
          .and(SmsColumn.DATE)
          .greaterThanOrEqualTo(dateFrom.millisecondsSinceEpoch.toString())
          .and(SmsColumn.DATE)
          .lessThan(dateTo.millisecondsSinceEpoch.toString());
    }
    return filter;
  }

  MySmsMessage mapToMySmsMessage(SmsMessage message) {
    return MySmsMessage(
      expeditor: message.address,
      body: message.body,
      timestamp: message.date,
    );
  }

  void _onAppParameterChanged(AppParameter parameter) {
    _parameter = parameter;
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      emit(
        currentState.copyWith(
          displaySensitiveDetail: parameter.isSensitiveInfoDisplayed,
          appreciation: parameter.displayAppreciation(),
        ),
      );
    } else {
      emit(MessagesLoaded(
        const [],
        displaySensitiveDetail: parameter.isSensitiveInfoDisplayed,
        appreciation: parameter.displayAppreciation(),
      ));
    }
  }

  void _subscribeToAppParameter(parameterState) {
    if (parameterState is ParameterLoaded) {
      _onAppParameterChanged(parameterState.parameter);
    }
  }

  @override
  Future<void> close() async {
    appParameterSubscription?.cancel();
    await super.close();
  }
}
