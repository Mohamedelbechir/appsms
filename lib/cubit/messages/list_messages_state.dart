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
  final List<int> selectedIndexies;

  MessagesLoaded(
    this.messages, {
    bool displaySensitiveDetail = false,
    this.appreciation = "",
    this.selectedIndexies = const [],
  }) {
    isSensitiveDetailDisplayed = displaySensitiveDetail;
  }
  bool get isMultiSelectionEnabled => selectedIndexies.isNotEmpty;

  MessagesLoaded copyWith({
    List<MySmsMessage>? messages,
    bool? displaySensitiveDetail,
    String? appreciation,
    List<int>? selectedIndexies,
  }) {
    return MessagesLoaded(
      messages ?? this.messages,
      displaySensitiveDetail:
          displaySensitiveDetail ?? isSensitiveDetailDisplayed,
      appreciation: appreciation ?? this.appreciation,
      selectedIndexies: selectedIndexies ?? this.selectedIndexies,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        isSensitiveDetailDisplayed,
        appreciation,
        selectedIndexies,
      ];
}
