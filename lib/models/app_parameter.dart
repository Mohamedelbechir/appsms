import 'package:equatable/equatable.dart';

class AppParameter extends Equatable {
  final String appreciation;
  final bool isSensitiveInfoDisplayed;

  const AppParameter({
    required this.appreciation,
    required this.isSensitiveInfoDisplayed,
  });

  @override
  List<Object?> get props => [appreciation, isSensitiveInfoDisplayed];

  AppParameter copyWith({
    String? appreciation,
    bool? isSensitiveInfoDisplayed,
  }) {
    return AppParameter(
      appreciation: appreciation ?? this.appreciation,
      isSensitiveInfoDisplayed:
          isSensitiveInfoDisplayed ?? this.isSensitiveInfoDisplayed,
    );
  }
}
