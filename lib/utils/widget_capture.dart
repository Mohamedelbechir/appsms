import 'dart:typed_data';
import 'dart:ui';

import 'package:appsms/models/save_image_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';

Future<ByteData?> convertToImageByteData(
  GlobalKey<State<StatefulWidget>> key,
  BuildContext context,
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

Future<List<XFile>> getXFiles(
  List<GlobalKey> messageWidgetKeys,
  BuildContext context,
) async {
  final bytesImages =
      await Future.wait(messageWidgetKeys.map((currentKey) async {
    return await convertToImageByteData(currentKey, context);
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

Future<SaveImageResult> takeWidgetCapture(
  GlobalKey widgetKey,
  BuildContext context,
) async {
  final byteData = await convertToImageByteData(widgetKey, context);

  return await saveToGallery(byteData);
}
