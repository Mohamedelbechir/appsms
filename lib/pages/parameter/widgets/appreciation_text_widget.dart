import 'dart:async';

import 'package:appsms/cubit/parameter/parameter_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppreciationTextWidget extends StatefulWidget {
  const AppreciationTextWidget({super.key});

  @override
  State<AppreciationTextWidget> createState() => _AppreciationTextWidgetState();
}

class _AppreciationTextWidgetState extends State<AppreciationTextWidget> {
  final _appreciationTextFieldController = TextEditingController();
  String appreciationFromState = "";
  bool isSaveButtonActivated = false;

  StreamSubscription<ParameterState>? subscription;

  @override
  void initState() {
    _appreciationTextFieldController.addListener(_onAppreciationChanged);
    _onAppParameterStateChanged(context.read<ParameterCubit>().state);
    subscription = context
        .read<ParameterCubit>()
        .stream
        .listen(_onAppParameterStateChanged);
    super.initState();
  }

  void _onAppParameterStateChanged(state) {
    if (state is ParameterLoaded) {
      setState(() {
        appreciationFromState = state.parameter.appreciation;
        _appreciationTextFieldController.text = appreciationFromState;
      });
    }
  }

  bool _canSaveButtonBeActivated() {
    if (appreciationFromState == _appreciationTextFieldController.text) {
      return false;
    }
    if (_appreciationTextFieldController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  void _onAppreciationChanged() {
    setState(() {
      isSaveButtonActivated = _canSaveButtonBeActivated();
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParameterCubit, ParameterState>(
      builder: (context, state) {
        if (_canBeDisplayed(state)) {
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  maxLines: 8,
                  controller: _appreciationTextFieldController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    hintText: "Saisir l'appreciation",
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: ElevatedButton(
                    onPressed: isSaveButtonActivated
                        ? () => context.read<ParameterCubit>().setAppreciation(
                            _appreciationTextFieldController.text)
                        : null,
                    child: const Text("Enregistrer"),
                  ),
                )
              ],
            ),
          );
        }
        return Container();
      },
    );
  }

  bool _canBeDisplayed(ParameterState state) {
    return state is ParameterLoaded && state.parameter.isAppreciationDisplayed;
  }
}
