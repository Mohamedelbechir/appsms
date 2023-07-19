import 'package:appsms/cubit/messages/list_messages_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final keys = <GlobalKey>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Colors.white,
      body: Center(child: BlocBuilder<ListMessagesCubit, ListMessagesState>(
        builder: (context, state) {
          if (state is MessagesLoaded) {
            return ListView.builder(
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final currentMessage = state.messages.elementAt(index);
                final currentKey = GlobalKey();
                keys.add(currentKey);
                return RepaintBoundary(
                  key: currentKey,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(currentMessage.body ?? ''),
                  ),
                );
              },
            );
          }
          return Container();
        },
      )),
      floatingActionButton: FloatingActionButton(onPressed: () {
        context.read<ListMessagesCubit>().loadMessages(pattern: 'Mabrouk');
      }),
    );
  }
}
