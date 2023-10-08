import 'package:appsms/cubit/messages/list_messages_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShareButton extends StatefulWidget {
  const ShareButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  State<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
  int selectedMessageCount = 0;
  @override
  void initState() {
    context.read<ListMessagesCubit>().stream.listen((event) {
      if (event is MessagesLoaded) {
        setState(() {
          selectedMessageCount = event.isMultiSelectionEnabled
              ? event.selectedIndexies.length
              : event.messages.length;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const Icon(
              Icons.share,
              color: Colors.orange,
            ),
            const SizedBox(width: 10),
            Text(
              "Partager ($selectedMessageCount)",
              style: const TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
