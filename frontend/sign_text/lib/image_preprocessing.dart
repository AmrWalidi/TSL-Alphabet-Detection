import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

img.Image? convertCameraImageToImage(CameraImage image) {
  return convertYUV420ToImageColor(image);
}

img.Image convertYUV420ToImageColor(CameraImage cameraImage) {
  final width = cameraImage.width;
  final height = cameraImage.height;
  final yBuffer = cameraImage.planes[0].bytes;
  final uBuffer = cameraImage.planes[1].bytes;
  final vBuffer = cameraImage.planes[2].bytes;

  final img.Image image = img.Image(width: width,height:  height);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final int uvIndex =
      ((x ~/ 2) + (y ~/ 2) * (cameraImage.planes[1].bytesPerRow ~/ 2))
          .clamp(0, uBuffer.length - 1);
      final int yIndex = y * cameraImage.planes[0].bytesPerRow + x;

      final int yValue = yBuffer[yIndex];
      final int uValue = uBuffer[uvIndex];
      final int vValue = vBuffer[uvIndex];

      int r = (yValue + 1.402 * (vValue - 128)).clamp(0, 255).toInt();
      int g = (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128))
          .clamp(0, 255)
          .toInt();
      int b = (yValue + 1.772 * (uValue - 128)).clamp(0, 255).toInt();

      image.setPixelRgb(x, y, r, g, b);
    }
  }
  return image;
}