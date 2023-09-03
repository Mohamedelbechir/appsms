import 'dart:typed_data';
import 'dart:ui';

import 'package:appsms/cubit/messages/list_messages_cubit.dart';
import 'package:appsms/cubit/receiversPhoneNumber/receivers_phone_numbers_cubit.dart';
import 'package:appsms/widgets/receiver_phone_number_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../widgets/receiver_phone_numbers_widget.dart';

class SaveImageResult {
  final String path;
  final bool isSuccess;

  SaveImageResult(this.path, this.isSuccess);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final widgetKeys = <GlobalKey>[];
  bool isSensitiveDetailDisplayed = true;
  final _receiverPhoneNumberController = TextEditingController(text: '');

  List<DateTime?> _singleDatePickerValueWithDefaultValue = [
    DateUtils.dateOnly(DateTime.now()),
  ];

  @override
  void initState() {
    super.initState();
    context.read<ListMessagesCubit>().loadMessages(pattern: '');

    context.read<ListMessagesCubit>().stream.listen((event) {
      if (event is MessagesLoaded) {
        setState(() {
          isSensitiveDetailDisplayed = event.isSensitiveDetailDisplayed;
        });
      }
    });
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

  Widget _buildDefaultSingleDatePickerWithValue() {
    final config = getCalendarPickerConfig();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CalendarDatePicker2(
          config: config,
          value: _singleDatePickerValueWithDefaultValue,
          onValueChanged: (dates) => setState(() {
            _singleDatePickerValueWithDefaultValue = dates;
          }),
        ),
      ],
    );
  }

  CalendarDatePicker2Config getCalendarPickerConfig() {
    return CalendarDatePicker2Config(
      selectedDayHighlightColor: Colors.amber[900],
      weekdayLabels: [
        'Dimanche',
        'Lundi',
        'Mardi',
        'Mercredi',
        'Jeudi',
        'Vendredi',
        'Samedi'
      ],
      weekdayLabelTextStyle: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
      firstDayOfWeek: 1,
      controlsHeight: 50,
      controlsTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
      dayTextStyle: const TextStyle(
        color: Colors.amber,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
                _buildDefaultSingleDatePickerWithValue(),
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
                        onTap: () {
                          context.read<ListMessagesCubit>().loadMessages(
                                pattern: _receiverPhoneNumberController.text,
                                date: _singleDatePickerValueWithDefaultValue
                                    .first,
                              );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Icon(Icons.search, color: Colors.orange),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                InkWell(
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
                      const Text(
                          "Supprimer les details de mon solde Orange Money"),
                    ],
                  ),
                ),
              ],
            ),
          ) /*   Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              
              ElevatedButton(
                onPressed: () async {
                  await shareMessages();
                },
                child: Column(
                  children: const [
                    Icon(Icons.share),
                    Text("Partager"),
                  ],
                ),
              )
            ],
          ) */
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await shareMessages();
        },
        child: const Icon(Icons.share),
      ),
    );
  }

  Widget _renderListMessages(ListMessagesState state) {
    if (state is MessagesLoaded) {
      return _listMessages(state);
    }
    return Container();
  }

  Widget _listMessages(MessagesLoaded state) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(state.messages.length, (index) {
          final currentMessage = state.messages.elementAt(index);
          final currentKey = GlobalKey();
          widgetKeys.add(currentKey);
          var messageContent = currentMessage.getMessage(
                  noSensitiveDetails: state.isSensitiveDetailDisplayed) ??
              '';
          return InkWell(
            onTap: () => takeWidgetCapture(currentKey),
            child: RepaintBoundary(
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
                child: Text(
                  messageContent,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<void> shareMessages() async {
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
    final bytesImages = await Future.wait(widgetKeys.map((currentKey) async {
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
