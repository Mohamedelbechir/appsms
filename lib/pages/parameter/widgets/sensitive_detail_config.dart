import 'dart:async';

import 'package:appsms/cubit/messages/list_messages_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SensitiveDetailConfig extends StatefulWidget {
  const SensitiveDetailConfig({
    super.key,
  });

  @override
  State<SensitiveDetailConfig> createState() => _SensitiveDetailConfigState();
}

class _SensitiveDetailConfigState extends State<SensitiveDetailConfig> {
  bool isSensitiveDetailDisplayed = false;
  StreamSubscription<ListMessagesState>? streamSubscription;
  @override
  void initState() {
    super.initState();
    final currentState = context.read<ListMessagesCubit>().state;

    if (currentState is MessagesLoaded) {
      isSensitiveDetailDisplayed = currentState.isSensitiveDetailDisplayed;
    }
    _subscribeToMessageChanges();
  }

  void _subscribeToMessageChanges() {
    streamSubscription =
        context.read<ListMessagesCubit>().stream.listen((state) {
      if (state is MessagesLoaded) {
        setState(() {
          isSensitiveDetailDisplayed = state.isSensitiveDetailDisplayed;
        });
      }
    });
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<ListMessagesCubit>().toggleSensitiveDetails();
      },
      child: Row(
        children: [
          IgnorePointer(
            child: Switch(
              value: isSensitiveDetailDisplayed,
              onChanged: (_) {},
            ),
          ),
          const Text("Supprimer les details de mon solde"),
        ],
      ),
    );
  }
}
