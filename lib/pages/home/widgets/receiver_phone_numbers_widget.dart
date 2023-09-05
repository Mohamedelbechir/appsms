import 'package:appsms/cubit/receiversPhoneNumber/receivers_phone_numbers_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReceiverPhoneNumbersWidget extends StatefulWidget {
  const ReceiverPhoneNumbersWidget({
    super.key,
  });

  @override
  State<ReceiverPhoneNumbersWidget> createState() =>
      _ReceiverPhoneNumbersWidgetState();
}

class _ReceiverPhoneNumbersWidgetState
    extends State<ReceiverPhoneNumbersWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReceiversPhoneNumbersCubit, ReceiversPhoneNumbersState>(
        builder: (_, state) {
      if (state is ReceiversPhoneNumbersLoaded) {
        return Align(
          alignment: Alignment.topLeft,
          child: Wrap(
            children: List.generate(
              state.numbers.length,
              (index) {
                final phoneNumber = state.numbers.elementAt(index);
                return _buildItem(phoneNumber);
              },
            ),
          ),
        );
      }
      return Container();
    });
  }

  Widget _buildItem(String phoneNumber) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            phoneNumber,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              context
                  .read<ReceiversPhoneNumbersCubit>()
                  .removePhoneNumber(phoneNumber);
            },
            child: const Icon(Icons.clear),
          )
        ],
      ),
    );
  }
}
