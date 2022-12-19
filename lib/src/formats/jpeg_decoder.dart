import 'dart:typed_data';

import '../image/animation.dart';
import '../image/image.dart';
import '../util/image_exception.dart';
import '../util/input_buffer.dart';
import 'decode_info.dart';
import 'decoder.dart';
import 'jpeg/jpeg_data.dart';
import 'jpeg/jpeg_info.dart';

/// Decode a jpeg encoded image.
class JpegDecoder extends Decoder {
  JpegInfo? info;
  InputBuffer? input;

  /// Is the given file a valid JPEG image?
  @override
  bool isValidFile(Uint8List data) => JpegData().validate(data);

  @override
  DecodeInfo? startDecode(Uint8List bytes) {
    input = InputBuffer(bytes, bigEndian: true);
    return info = JpegData().readInfo(bytes);
  }

  @override
  int numFrames() => info == null ? 0 : info!.numFrames;

  @override
  Image? decodeFrame(int frame) {
    if (input == null) {
      return null;
    }
    final jpeg = JpegData()
    ..read(input!.buffer);
    if (jpeg.frames.length != 1) {
      throw ImageException('only single frame JPEGs supported');
    }

    return jpeg.getImage();
  }

  @override
  Image? decodeImage(Uint8List bytes, {int frame = 0}) {
    final jpeg = JpegData()
    ..read(bytes);

    if (jpeg.frames.length != 1) {
      throw ImageException('only single frame JPEGs supported');
    }

    return jpeg.getImage();
  }

  @override
  Animation? decodeAnimation(Uint8List bytes) {
    final image = decodeImage(bytes);
    if (image == null) {
      return null;
    }

    final anim = Animation()
    ..width = image.width
    ..height = image.height
    ..addFrame(image);

    return anim;
  }
}
