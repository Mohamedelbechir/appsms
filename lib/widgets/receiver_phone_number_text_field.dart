import 'package:appsms/cubit/receiversPhoneNumber/receivers_phone_numbers_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

final phoneNumberMaskFormatter = MaskTextInputFormatter(
  mask: '##-##-##-##',
  filter: {"#": RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy,
);

// ignore: must_be_immutable
class ReceiverPhoneNumberTextField extends StatefulWidget {
  TextEditingController receiverPhoneNumberController;

  ReceiverPhoneNumberTextField(
      {Key? key, required this.receiverPhoneNumberController})
      : super(key: key);

  @override
  State<ReceiverPhoneNumberTextField> createState() =>
      _ReceiverPhoneNumberTextFieldState();
}

class _ReceiverPhoneNumberTextFieldState
    extends State<ReceiverPhoneNumberTextField> {
  final phoneNumberLength = 8;

  @override
  Widget build(BuildContext context) {
    return TextField(
      inputFormatters: [phoneNumberMaskFormatter],
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(10),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        hintText: "Saisir le numéro de téléphone du bénéficiaire",
        prefixIcon: const Icon(Icons.numbers),
        suffixIcon: InkWell(
          onTap: () {
            _addReceiverPhoneNumber();
          },
          child: const Icon(
            Icons.add,
            color: Colors.orange,
          ),
        ),
      ),
      controller: widget.receiverPhoneNumberController,
    );
  }

  void _addReceiverPhoneNumber() {
    final phoneNumber = phoneNumberMaskFormatter
        .unmaskText(widget.receiverPhoneNumberController.text);
    if (phoneNumber.length == phoneNumberLength) {
      context.read<ReceiversPhoneNumbersCubit>().addPhoneNumber(phoneNumber);
      widget.receiverPhoneNumberController.clear();
    }
  }
}
