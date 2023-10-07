import 'package:appsms/cubit/messages/list_messages_cubit.dart';
import 'package:appsms/cubit/parameter/parameter_cubit.dart';
import 'package:appsms/cubit/receiversPhoneNumber/receivers_phone_numbers_cubit.dart';
import 'package:appsms/pages/parameter/parameter_modal.dart';
import 'package:appsms/pages/home/widgets/date_selector.dart';
import 'package:appsms/pages/home/widgets/receiver_phone_number_text_field.dart';
import 'package:appsms/utils/widget_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../widgets/app_title.dart';
import 'widgets/empty_list_of_message.dart';
import 'widgets/message_item.dart';
import 'widgets/receiver_phone_numbers_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final messageWidgetKeyPars = <int, GlobalKey>{};
  bool isSensitiveDetailDisplayed = false;
  final _receiverPhoneNumberController = TextEditingController(text: '');
  var selectedDate = DateUtils.dateOnly(DateTime.now());

  @override
  void initState() {
    context.read<ParameterCubit>().loadAppParameter();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const AppTitle(),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: BlocBuilder<ListMessagesCubit, ListMessagesState>(
                builder: (_, state) => _renderListMessages(state),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              color: const Color.fromARGB(255, 248, 241, 229).withOpacity(.2),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DateSelector(
                        onSelect: (value) => selectedDate = value,
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        await shareMessages();
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.share,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        parameterModal(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.more_vert),
                      ),
                    )
                  ],
                ),
                const ReceiverPhoneNumbersWidget(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ReceiverPhoneNumberTextField(
                          receiverPhoneNumberController:
                              _receiverPhoneNumberController,
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: _searchMessages,
                        child: const Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Icon(Icons.search, color: Colors.orange),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 25),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _searchMessages() {
    final phoneNumbers = _getPhoneNumbers();
    context.read<ListMessagesCubit>().loadMessages(
          expeditor: "OrangeMoney",
          receiverPhoneNumbers: phoneNumbers,
          date: selectedDate,
        );
  }

  List<String> _getPhoneNumbers() {
    final currentState = context.read<ReceiversPhoneNumbersCubit>().state;

    final phoneNumbers = <String>[];

    final currentPhoneInTextField = phoneNumberMaskFormatter
        .unmaskText(_receiverPhoneNumberController.text);

    if (currentPhoneInTextField.trim().isNotEmpty) {
      phoneNumbers.add(currentPhoneInTextField);
    }
    if (currentState is ReceiversPhoneNumbersLoaded) {
      phoneNumbers.addAll(currentState.numbers);
    }
    return phoneNumbers;
  }

  Widget _renderListMessages(ListMessagesState state) {
    if (_canDisplayEmptyMessages(state)) {
      return const EmptyListOfMessage();
    }
    if (state is MessagesLoaded) {
      return _listMessages(state);
    }

    return Container();
  }

  bool _canDisplayEmptyMessages(ListMessagesState state) {
    if (state is ListMessagesInitial ||
        (state is MessagesLoaded && state.messages.isEmpty)) {
      return true;
    }
    return false;
  }

  Widget _listMessages(MessagesLoaded state) {
    messageWidgetKeyPars.clear();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        key: const Key("list_messages"),
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(state.messages.length, (index) {
          final currentMessage = state.messages.elementAt(index);
          final currentKey = GlobalKey();
          messageWidgetKeyPars.putIfAbsent(index, () => currentKey);
          var messageContent = currentMessage.getMessage(
              displaySensitiveDetails: state.isSensitiveDetailDisplayed);
          return MessageItem(
            key: Key("list_messages_$index"),
            index: index,
            transactionDate: currentMessage.date,
            currentKey: currentKey,
            messageContent: messageContent,
            appreciation: state.appreciation,
            isMultiSelectEnabled: state.isMultiSelectionEnabled,
            onChange: (value) {
              context
                  .read<ListMessagesCubit>()
                  .setMessageSelection(index, value);
            },
          );
        }),
      ),
    );
  }

  Future<void> shareMessages() async {
    if (messageWidgetKeyPars.isEmpty) return;

    final result = await Share.shareXFiles(
      await getXFiles(_getMessageWidgtKey(), context),
      subject: 'OrangeMoney',
      text: 'OrangeMoney',
    );

    if (result.status == ShareResultStatus.success) {
      print('Thank you for sharing the picture!');
    }
  }

  List<GlobalKey<State<StatefulWidget>>> _getMessageWidgtKey() {
    final listMessageState = context.read<ListMessagesCubit>().state;
    if (listMessageState is MessagesLoaded) {
      if (listMessageState.isMultiSelectionEnabled) {
        return messageWidgetKeyPars.entries
            .where((currentKeyPair) {
              return listMessageState.selectedIndexies
                  .contains(currentKeyPair.key);
            })
            .map((currentKeyPair) => currentKeyPair.value)
            .toList();
      }
      return messageWidgetKeyPars.entries
          .map((currentKeyPair) => currentKeyPair.value)
          .toList();
    }
    return [];
  }
}
