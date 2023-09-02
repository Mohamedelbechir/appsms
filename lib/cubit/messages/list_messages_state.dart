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

  MessagesLoaded(this.messages, {bool displaySensitiveDetail = false}) {
    isSensitiveDetailDisplayed = displaySensitiveDetail;
  }

  MessagesLoaded copyWith({
    List<MySmsMessage>? messages,
    bool? isSensitiveDetailDisplayed,
  }) {
    return MessagesLoaded(
      messages ?? this.messages,
      displaySensitiveDetail:
          isSensitiveDetailDisplayed ?? this.isSensitiveDetailDisplayed,
    );
  }

  @override
  List<Object?> get props => [messages, isSensitiveDetailDisplayed];
}
