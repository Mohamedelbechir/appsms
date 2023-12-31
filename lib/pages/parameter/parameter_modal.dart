import 'package:appsms/cubit/parameter/parameter_cubit.dart';
import 'package:appsms/pages/parameter/widgets/modal_parameter_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/parameters_list_widget.dart';

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
    isDismissible: true,
    shape: const RoundedRectangleBorder(borderRadius: modalTopBorderRadius),
    builder: (_) {
      return LayoutBuilder(builder: (context, _) {
        return AnimatedPadding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: BlocProvider.value(
            value: parentContext.read<ParameterCubit>(),
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: .80,
              minChildSize: 0.1,
              builder: (_, controller) {
                if (modal != null) return modal!; // for performance purpose
                return modal = SingleChildScrollView(
                  controller: controller,
                  child: Container(
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
                          const SizedBox(height: 8),
                          const ModalParameterTitle(),
                          const SizedBox(height: 20),
                          const ParametersListWidget(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      });
    },
  );
}
