import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:appsms/cubit/messages/list_messages_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

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

  @override
  void initState() {
    super.initState();
    context.read<ListMessagesCubit>().loadMessages(pattern: 'Mabrouk');
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
                widgetKeys.add(currentKey);
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
                        currentMessage.body ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return Container();
        },
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await shareMessages();
        },
        child: const Icon(Icons.share),
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
