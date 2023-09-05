import 'package:equatable/equatable.dart';

class AppParameter extends Equatable {
  final String appreciation;
  final bool isAppreciationDisplayed;
  final bool isSensitiveInfoDisplayed;

  const AppParameter({
    required this.appreciation,
    required this.isSensitiveInfoDisplayed,
    required this.isAppreciationDisplayed,
  });

  String displayAppreciation() => isAppreciationDisplayed ? appreciation : "";

  @override
  List<Object?> get props => [
        appreciation,
        isSensitiveInfoDisplayed,
        isAppreciationDisplayed,
      ];

  AppParameter copyWith({
    String? appreciation,
    bool? isSensitiveInfoDisplayed,
    bool? isAppreciationDisplayed,
  }) {
    return AppParameter(
      appreciation: appreciation ?? this.appreciation,
      isSensitiveInfoDisplayed:
          isSensitiveInfoDisplayed ?? this.isSensitiveInfoDisplayed,
      isAppreciationDisplayed:
          isAppreciationDisplayed ?? this.isAppreciationDisplayed,
    );
  }
}
