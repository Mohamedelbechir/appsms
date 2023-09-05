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
    streamSubscription =
        context.read<ListMessagesCubit>().stream.listen((event) {
      if (event is MessagesLoaded) {
        setState(() {
          isSensitiveDetailDisplayed = event.isSensitiveDetailDisplayed;
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
