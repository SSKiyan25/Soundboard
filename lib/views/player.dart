import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musicplayerv2/consts/colors.dart';
import 'package:musicplayerv2/consts/text_style.dart';
import 'package:musicplayerv2/controllers/player_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Player extends StatelessWidget {
  final List<SongModel> data;
  const Player({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<PlayerController>();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Column(children: [
          Expanded(
            child: Obx(
              () => Container(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  height: 300,
                  width: 300,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: QueryArtworkWidget(
                    id: data[controller.playIndex.value].id,
                    type: ArtworkType.AUDIO,
                    artworkHeight: double.infinity,
                    artworkWidth: double.infinity,
                    nullArtworkWidget: const Icon(
                      Icons.music_note_rounded,
                      size: 100,
                      color: whiteColor,
                    ),
                  )),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                color: whiteColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Center(
                  child: Obx(
                    () => Column(children: [
                      Text(data[controller.playIndex.value].displayNameWOExt,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: ourStyle(
                            color: bgDarkColor,
                            family: bold,
                            size: 24,
                          )),
                      const SizedBox(height: 12),
                      Text(data[controller.playIndex.value].artist.toString(),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: ourStyle(
                            color: bgDarkColor,
                            family: regular,
                            size: 20,
                          )),
                      const SizedBox(height: 12),
                      // Slider and Duration
                      Obx(
                        () => Row(
                          children: [
                            Text(controller.position.value,
                                style: ourStyle(color: bgDarkColor)),
                            Expanded(
                                child: Slider(
                                    thumbColor: sliderColor,
                                    inactiveColor: bgColor,
                                    activeColor: sliderColor,
                                    min: const Duration(seconds: 0)
                                        .inSeconds
                                        .toDouble(),
                                    max: controller.max.value,
                                    value: controller.value.value,
                                    onChanged: (newValue) {
                                      controller.changeDurationToSeconds(
                                          newValue.toInt());
                                      newValue = newValue;
                                    })),
                            Text(controller.duration.value,
                                style: ourStyle(color: bgDarkColor)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              onPressed: () {
                                int nextIndex = controller.playIndex.value + 1;
                                if (nextIndex >= data.length) {
                                  nextIndex = 0;
                                }
                                controller.playSong(
                                    data[nextIndex].uri, nextIndex);
                              },
                              icon: const Icon(
                                Icons.skip_next_rounded,
                                size: 48,
                                color: bgDarkColor,
                              ),
                            ),
                            Obx(
                              () => CircleAvatar(
                                radius: 35,
                                backgroundColor: bgDarkColor,
                                child: Transform.scale(
                                  scale: 2.5,
                                  child: IconButton(
                                      onPressed: () {
                                        if (controller.isPlaying.value) {
                                          controller.audioPlayer.pause();
                                          controller.isPlaying(false);
                                        } else {
                                          controller.audioPlayer.play();
                                          controller.isPlaying(true);
                                        }
                                      },
                                      icon: controller.isPlaying.value
                                          ? const Icon(Icons.pause)
                                          : const Icon(
                                              Icons.play_arrow_rounded),
                                      color: whiteColor),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                int prevIndex = controller.playIndex.value - 1;
                                if (prevIndex < 0) {
                                  prevIndex = data.length - 1;
                                }
                                controller.playSong(
                                    data[prevIndex].uri, prevIndex);
                              },
                              icon: const Icon(
                                Icons.skip_previous_rounded,
                                size: 48,
                                color: bgDarkColor,
                              ),
                            ),
                          ]),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
