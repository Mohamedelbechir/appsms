import 'dart:typed_data';
import 'dart:ui';

import 'package:appsms/cubit/messages/list_messages_cubit.dart';
import 'package:appsms/cubit/parameter/parameter_cubit.dart';
import 'package:appsms/cubit/receiversPhoneNumber/receivers_phone_numbers_cubit.dart';
import 'package:appsms/pages/parameter/parameter_modal.dart';
import 'package:appsms/pages/home/widgets/date_selector.dart';
import 'package:appsms/pages/home/widgets/receiver_phone_number_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/save_image_result.dart';
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
  final messageWidgetKeys = <GlobalKey>[];
  bool isSensitiveDetailDisplayed = false;
  final _receiverPhoneNumberController = TextEditingController(text: '');
  var selectedDate = DateUtils.dateOnly(DateTime.now());

  @override
  void initState() {
    context.read<ParameterCubit>().loadAppParameter();
    super.initState();
  }

  Future<SaveImageResult> takeWidgetCapture(GlobalKey widgetKey) async {
    final byteData = await convertToImageByteData(widgetKey);

    return await saveToGallery(byteData);
  }

  Future<ByteData?> convertToImageByteData(
    GlobalKey<State<StatefulWidget>> key,
  ) async {
    final renderObject = key.currentContext?.findRenderObject();
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final image = await (renderObject as RenderRepaintBoundary?)?.toImage(
      pixelRatio: pixelRatio,
    );
    return await image?.toByteData(format: ImageByteFormat.png);
  }

  Future<SaveImageResult> saveToGallery(ByteData? byteData) async {
    if (byteData == null) return SaveImageResult('', false);

    final result = await ImageGallerySaver.saveImage(
      byteData.buffer.asUint8List(),
      name: 'app_sms_${DateTime.now().millisecondsSinceEpoch}',
    );

    return SaveImageResult(result['filePath'], result['isSuccess']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        //centerTitle: true,
        title: const AppTitle(),
      ),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
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
          bodyPatterns: phoneNumbers,
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
          messageWidgetKeys.add(currentKey);
          var messageContent = currentMessage.getMessage(
                  displaySensitiveDetails: state.isSensitiveDetailDisplayed) ??
              '';
          return MessageItem(
            currentKey: currentKey,
            messageContent: messageContent,
            appreciation: state.appreciation,
          );
        }),
      ),
    );
  }

  Future<void> shareMessages() async {
    if (messageWidgetKeys.isEmpty) return;

    final result = await Share.shareXFiles(
      await getXFiles(),
      subject: 'OrangeMoney',
      text: 'OrangeMoney',
    );

    if (result.status == ShareResultStatus.success) {
      print('Thank you for sharing the picture!');
    }
  }

  Future<List<XFile>> getXFiles() async {
    final bytesImages =
        await Future.wait(messageWidgetKeys.map((currentKey) async {
      return await convertToImageByteData(currentKey);
    }));

    return bytesImages
        .where((currentImageByte) => currentImageByte?.buffer != null)
        .map(mapBinaryToXFileImage)
        .toList();
  }

  XFile mapBinaryToXFileImage(ByteData? currentCaptureResult) {
    return XFile.fromData(
      currentCaptureResult!.buffer.asUint8List(),
      name: '${DateTime.now().millisecondsSinceEpoch}.png',
      mimeType: 'image/png',
    );
  }
}
