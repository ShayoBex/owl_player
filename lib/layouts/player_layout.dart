import 'dart:async';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:owl_player/controllers/player_controller.dart';
import 'package:subtitle_wrapper_package/subtitle_text_view.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';
import 'package:video_player/video_player.dart';
import 'package:window_manager/window_manager.dart';

class PlayerLayout extends StatelessWidget {
  const PlayerLayout({super.key});

  static const String id = "PlayerLayout";
  static const String tag = "PlayerController";

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlayerController>(
      id: id,
      tag: tag,
      init: Get.isRegistered<PlayerController>(tag: tag) ? Get.find<PlayerController>(tag: tag) : Get.put(PlayerController(), tag: tag),
      builder: (controller) {
        return Scaffold(
          body: MouseRegion(
            cursor: controller.isFullscreen && controller.isGuiVisible == false ? SystemMouseCursors.none : MouseCursor.defer,
            onHover: (event) {
              if (controller.isGuiVisible == false) {
                controller.isGuiVisible = true;
                controller.update([id]);
                try {
                  controller.timer.cancel();
                } catch (e) {
                  // print(e);
                } finally {
                  controller.timer = Timer(Duration(seconds: 5), () {
                    controller.isGuiVisible = false;
                    controller.update([id]);
                  });
                }
              }
            },
            child: GestureDetector(
              onPanStart: (details) => windowManager.startDragging(),
              child: DropTarget(
                onDragDone: (detail) async {
                  await controller.loadFile(detail.files.first.path);
                },
                child: Builder(builder: (context) {
                  try {
                    return Stack(
                      children: [
                        GestureDetector(
                          onDoubleTap: controller.onChangeFullscreen,
                          child: CallbackShortcuts(
                            bindings: {
                              const SingleActivator(LogicalKeyboardKey.enter, includeRepeats: false): controller.onChangeFullscreen,
                              const SingleActivator(LogicalKeyboardKey.space, includeRepeats: false): controller.onChangeStatus,
                              const SingleActivator(LogicalKeyboardKey.arrowRight): controller.onForward,
                              const SingleActivator(LogicalKeyboardKey.arrowLeft): controller.onBackward,
                              const SingleActivator(LogicalKeyboardKey.arrowUp): controller.onIncVolume,
                              const SingleActivator(LogicalKeyboardKey.arrowDown): controller.onDecVolume,
                            },
                            child: Focus(
                              autofocus: true,
                              child: SubtitleWrapper(
                                videoChild: VideoPlayer(
                                  controller.videoController,
                                ),
                                subtitleController: controller.subtitleController,
                                videoPlayerController: controller.videoController,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Visibility(
                            visible: controller.isGuiVisible,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                controller.videoController.dataSource.split('/').last,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: AnimatedOpacity(
                            opacity: controller.isFullscreen && controller.isGuiVisible == false ? 0 : 1,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.ease,
                            child: Container(
                              height: 50,
                              margin: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Row(
                                children: [
                                  ButtonIconWidget(
                                    icon: controller.videoController.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    onTap: controller.onChangeStatus,
                                  ),
                                  VerticalDivider(
                                    width: 1,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Slider(
                                        value: controller.videoController.value.position.inMilliseconds.toDouble(),
                                        min: 0,
                                        max: controller.videoController.value.duration.inMilliseconds.toDouble(),
                                        thumbColor: Colors.white,
                                        activeColor: Colors.white,
                                        inactiveColor: Colors.white.withOpacity(0.3),
                                        onChanged: (double value) async {
                                          controller.videoController.seekTo(Duration(milliseconds: value.toInt())).whenComplete(() {
                                            controller.update([PlayerLayout.id]);
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  VerticalDivider(
                                    width: 1,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                  SizedBox(
                                    width: 150,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Slider(
                                        value: controller.videoController.value.volume,
                                        min: 0,
                                        max: 1,
                                        thumbColor: Colors.white,
                                        activeColor: Colors.white,
                                        inactiveColor: Colors.white.withOpacity(0.3),
                                        onChanged: (double value) {
                                          controller.lastVolume = controller.videoController.value.volume;
                                          controller.videoController.setVolume(value);
                                          controller.update([PlayerLayout.id]);
                                        },
                                      ),
                                    ),
                                  ),
                                  VerticalDivider(
                                    width: 1,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                  ButtonIconWidget(
                                    icon: controller.videoController.value.volume > 0 ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
                                    onTap: () {
                                      controller.videoController.setVolume(controller.videoController.value.volume > 0 ? 0 : controller.lastVolume);
                                      controller.update([id]);
                                    },
                                  ),
                                  VerticalDivider(
                                    width: 1,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                  ButtonIconWidget(
                                    icon: controller.isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                                    onTap: controller.onChangeFullscreen,
                                  ),
                                  VerticalDivider(
                                    width: 1,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                  ButtonIconWidget(
                                    icon: controller.isAlwaysOnTop ? Icons.push_pin : Icons.push_pin_outlined,
                                    onTap: controller.onChangeAlwaysOnTop,
                                  ),
                                  VerticalDivider(
                                    width: 1,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                  ButtonIconWidget(
                                    icon: Icons.open_in_browser_rounded,
                                    onTap: controller.pickFile,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  } catch (e) {
                    return EmptyWidget(
                      onDoubleTap: controller.pickFile,
                    );
                  }
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ButtonIconWidget extends StatelessWidget {
  const ButtonIconWidget({
    super.key,
    required this.icon,
    this.onTap,
  });

  final IconData icon;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 50,
          height: 50,
          color: Colors.transparent,
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    super.key,
    this.onDoubleTap,
  });

  final VoidCallback? onDoubleTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: onDoubleTap,
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: Text(
            'drag and drop the file',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
