import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'receivers_phone_numbers_state.dart';

class ReceiversPhoneNumbersCubit extends Cubit<ReceiversPhoneNumbersState> {
  ReceiversPhoneNumbersCubit() : super(ReceiversPhoneNumbersInitial());

  void addPhoneNumber(String phoneNumber) {
    List<String> numbers = [phoneNumber];

    if (state is ReceiversPhoneNumbersLoaded) {
      _addPhoneNumber(phoneNumber);
    } else {
      emit(ReceiversPhoneNumbersLoaded(numbers: numbers));
    }
  }

  void _addPhoneNumber(String phoneNumber) {
    final currentState = (state as ReceiversPhoneNumbersLoaded);

    if (!currentState.numbers.contains(phoneNumber)) {
      emit(currentState.copyWith(
        numbers: List.from(currentState.numbers)..add(phoneNumber),
      ));
    }
  }

  void removePhoneNumber(String phoneNumber) {
    final currentState = state as ReceiversPhoneNumbersLoaded;
    final numbers =
        currentState.numbers.where((number) => number != phoneNumber).toList();
    emit(currentState.copyWith(numbers: numbers));
  }
}
