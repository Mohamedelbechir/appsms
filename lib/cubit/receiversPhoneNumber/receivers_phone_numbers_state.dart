part of 'receivers_phone_numbers_cubit.dart';

@immutable
abstract class ReceiversPhoneNumbersState extends Equatable {
  const ReceiversPhoneNumbersState();

  @override
  List<Object> get props => [];
}

class ReceiversPhoneNumbersInitial extends ReceiversPhoneNumbersState {}

class ReceiversPhoneNumbersLoaded extends ReceiversPhoneNumbersState {
  final List<String> numbers;

  const ReceiversPhoneNumbersLoaded({required this.numbers});
  @override
  List<Object> get props => [numbers];

  ReceiversPhoneNumbersLoaded copyWith({
    List<String>? numbers,
  }) {
    return ReceiversPhoneNumbersLoaded(
      numbers: numbers ?? this.numbers,
    );
  }
}
