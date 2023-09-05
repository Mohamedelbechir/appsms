import 'package:appsms/cubit/messages/list_messages_cubit.dart';
import 'package:appsms/pages/parameter/widgets/modal_parameter_title.dart';
import 'package:appsms/pages/parameter/widgets/sensitive_detail_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


const modalTopBorderRadius = BorderRadius.only(
  topLeft: Radius.circular(10),
  topRight: Radius.circular(10),
);


void parameterModal(BuildContext parentContext) {
  Widget? modal;
  final size = MediaQuery.of(parentContext).size;

  showModalBottomSheet(
    context: parentContext,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: modalTopBorderRadius),
    builder: (context) {
      return BlocProvider.value(
        value: parentContext.read<ListMessagesCubit>(),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: .75,
          minChildSize: 0.1,
          builder: (_, controller) {
            if (modal != null) return modal!; // for performance purpose
            return modal = SingleChildScrollView(
              controller: controller,
              child: Container(
                decoration: BoxDecoration(
                  color:
                      const Color.fromARGB(255, 248, 241, 229).withOpacity(.2),
                  borderRadius: modalTopBorderRadius,
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                ),
                constraints: BoxConstraints(maxHeight: size.height),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          height: 5,
                          width: 70,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const ModalParameterTitle(),
                      const SensitiveDetailConfig(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
