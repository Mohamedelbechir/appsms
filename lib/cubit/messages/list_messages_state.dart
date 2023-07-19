part of 'list_messages_cubit.dart';

@immutable
abstract class ListMessagesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ListMessagesInitial extends ListMessagesState {}

class MessagesLoaded extends ListMessagesState {
  final List<MySmsMessage> messages;

  MessagesLoaded(this.messages);
}
