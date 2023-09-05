part of 'list_messages_cubit.dart';

@immutable
abstract class ListMessagesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ListMessagesInitial extends ListMessagesState {}

class MessagesLoaded extends ListMessagesState {
  final List<MySmsMessage> messages;
  late final bool isSensitiveDetailDisplayed;
  late final String appreciation;

  MessagesLoaded(
    this.messages, {
    bool displaySensitiveDetail = false,
    this.appreciation = "",
  }) {
    isSensitiveDetailDisplayed = displaySensitiveDetail;
  }

  MessagesLoaded copyWith({
    List<MySmsMessage>? messages,
    bool? displaySensitiveDetail,
    String? appreciation,
  }) {
    return MessagesLoaded(
      messages ?? this.messages,
      displaySensitiveDetail:
          displaySensitiveDetail ?? isSensitiveDetailDisplayed,
      appreciation: appreciation ?? this.appreciation,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        isSensitiveDetailDisplayed,
        appreciation,
      ];
}
