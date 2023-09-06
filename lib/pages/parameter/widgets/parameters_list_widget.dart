import 'package:appsms/cubit/parameter/parameter_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'appreciation_text_widget.dart';

class ParametersListWidget extends StatelessWidget {
  const ParametersListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParameterCubit, ParameterState>(
      builder: (context, state) {
        if (state is ParameterLoaded) {
          final parameter = state.parameter;
          const switchTextStyle = TextStyle(fontWeight: FontWeight.w500);
          return Column(
             mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                key: const Key("sensitive_detail"),
                value: parameter.isSensitiveInfoDisplayed,
                onChanged: (value) {
                  context
                      .read<ParameterCubit>()
                      .setSensitiveInfoVisibility(value);
                },
                title: const Text(
                  "Afficher les details de mon solde",
                  style: switchTextStyle,
                ),
              ),
              SwitchListTile(
                value: parameter.isAppreciationDisplayed,
                onChanged: (value) {
                  context.read<ParameterCubit>().setAppreciationDisplay(value);
                },
                title: const Text(
                  "Activer l'appréciation",
                  style: switchTextStyle,
                ),
              ),
              const AppreciationTextWidget()
            ],
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
