import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:owl_player/layouts/player_layout.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';
import 'package:video_player/video_player.dart';
import 'package:window_manager/window_manager.dart';

class PlayerController extends GetxController {
  late VideoPlayerController videoController;
  late SubtitleController subtitleController;

  late Timer timer;

  double lastVolume = 1;

  bool isPickFile = false;
  bool isGuiVisible = false;
  bool isFullscreen = false;
  bool isAlwaysOnTop = false;

  @override
  void onInit() {
    const platform = MethodChannel('fileChannel');

    platform.setMethodCallHandler((call) async {
      if (call.method == 'loadFile') {
        String filePath = call.arguments;
        await loadFile(filePath);
      }
    });

    super.onInit();
  }

  @override
  void onClose() {
    videoController.dispose();
    super.onClose();
  }

  void pickFile() {
    if (isPickFile == false) {
      isPickFile = true;
      FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.video, lockParentWindow: true).then((value) {
        if (value != null) {
          loadFile(value.files.single.path!);
        }
        isPickFile = false;
      });
    }
  }

  Future<void> loadFile(String path) async {
    try {
      await videoController.dispose();
    } catch (e) {
      // print(e);
    } finally {
      videoController = VideoPlayerController.file(
        File(path),
        videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
      );
      await videoController.initialize();
      subtitleController = SubtitleController(
        showSubtitles: false,
      );
      videoController.play();
      await adjustWindowSizeWithAspectRatio(videoController.value.aspectRatio);
      update([PlayerLayout.id]);
    }
  }

  Future<void> adjustWindowSizeWithAspectRatio(double aspectRatio) async {
    Size currentSize = await windowManager.getSize();

    double newHeight = currentSize.width / aspectRatio;

    if (newHeight < 450) {
      newHeight = 450;

      double newWidth = newHeight * aspectRatio;

      await windowManager.setSize(Size(newWidth, newHeight));
    } else {
      await windowManager.setSize(Size(currentSize.width, newHeight));
    }
  }

  Future<void> onChangeFullscreen() async {
    isFullscreen = !(await windowManager.isFullScreen());
    windowManager.setFullScreen(isFullscreen);
    update([PlayerLayout.id]);
  }

  Future<void> onChangeAlwaysOnTop() async {
    isAlwaysOnTop = !(await windowManager.isAlwaysOnTop());
    windowManager.setAlwaysOnTop(isAlwaysOnTop);
    update([PlayerLayout.id]);
  }

  Future<void> onChangeStatus() async {
    videoController.value.isPlaying ? await videoController.pause() : await videoController.play();
    update([PlayerLayout.id]);
  }

  Future<void> onForward() async {
    videoController.seekTo((await videoController.position)! + Duration(seconds: 10));
    update([PlayerLayout.id]);
  }

  Future<void> onBackward() async {
    videoController.seekTo((await videoController.position)! - Duration(seconds: 10));
    update([PlayerLayout.id]);
  }

  Future<void> onIncVolume() async {
    videoController.setVolume(clampDouble(videoController.value.volume + 0.1, 0, 1));
    lastVolume = videoController.value.volume;
    update([PlayerLayout.id]);
  }

  Future<void> onDecVolume() async {
    videoController.setVolume(clampDouble(videoController.value.volume - 0.1, 0, 1));
    lastVolume = videoController.value.volume;
    update([PlayerLayout.id]);
  }
}
