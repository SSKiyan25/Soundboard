import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musicplayerv2/consts/colors.dart';
import 'package:musicplayerv2/consts/text_style.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:musicplayerv2/controllers/player_controller.dart';

class SongPage extends StatelessWidget {
  final List<SongModel> data;
  const SongPage({super.key, required this.data});

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<PlayerController>();

    return Scaffold(
      backgroundColor: bgDarkColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: SingleChildScrollView(
            // Added SingleChildScrollView
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Button Back
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),

                    // Title
                    Text("S O U N D B O A R D",
                        style: ourStyle(
                            family: bold, size: 18, color: whiteColor)),

                    // Menu
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.menu),
                    )
                  ],
                ),

                const SizedBox(
                  height: 25,
                ),
                // Album Artwork
                Column(
                  children: [
                    // Image
                    Obx(
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
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Song & Artist Name & Icon
                    Obx(
                      () => Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //  Song & Artist Name
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data[controller.playIndex.value]
                                      .displayNameWOExt,
                                  style: ourStyle(
                                      color: whiteColor,
                                      family: bold,
                                      size: 24),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  data[controller.playIndex.value]
                                      .artist
                                      .toString(),
                                  style: ourStyle(
                                      color: whiteColor,
                                      size: 20,
                                      family: regular),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),
                // Slider and Duration
                Obx(
                  () => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Start Time
                            Text(formatDuration(controller.position.value),
                                style: ourStyle(
                                    color: whiteColor, family: regular)),

                            // Shuffle
                            IconButton(
                              icon: Obx(
                                () => Icon(
                                  Icons.shuffle,
                                  color: controller.isShuffled.value
                                      ? Colors.green
                                      : whiteColor,
                                ),
                              ),
                              onPressed: () {
                                controller.shuffleSongs(data);
                              },
                            ),

                            // Repeat
                            IconButton(
                              icon: Obx(
                                () => Icon(
                                  controller.repeatMode.value == 'none'
                                      ? Icons.repeat
                                      : controller.repeatMode.value == 'song'
                                          ? Icons.repeat_one
                                          : Icons.repeat,
                                  color: controller.repeatMode.value == 'none'
                                      ? whiteColor
                                      : Colors.green,
                                ),
                              ),
                              onPressed: () {
                                controller.toggleRepeatMode();
                              },
                            ),

                            // End Time
                            Text(formatDuration(controller.duration.value),
                                style: ourStyle(
                                    color: whiteColor, family: regular)),
                          ],
                        ),
                      ),

                      // Song Duration Progress
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 0),
                        ),
                        child: Slider(
                          thumbColor: sliderColor,
                          inactiveColor: bgColor,
                          activeColor: sliderColor,
                          min: const Duration(seconds: 0).inSeconds.toDouble(),
                          max: controller.max.value.toDouble(),
                          value: controller.value.value.toDouble(),
                          onChanged: (newValue) {
                            controller
                                .changeDurationToSeconds(newValue.toInt());
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),
                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Skip to Previous
                    IconButton(
                      // When the IconButton is pressed, this function is called
                      onPressed: () {
                        // Calculate the index of the previous song
                        int prevIndex = controller.playIndex.value - 1;
                        // If the previous index is less than 0, set it to the last song in the list
                        if (prevIndex < 0) {
                          prevIndex = data.length - 1;
                        }
                        // If the current position of the song is more than 3 seconds
                        if (controller.position.value.inSeconds > 3) {
                          // Restart the current song
                          controller.playSong(
                              data[controller.playIndex.value].uri,
                              controller.playIndex.value);
                        } else {
                          // Play the previous song
                          controller.playSong(data[prevIndex].uri, prevIndex);
                        }
                      },
                      icon: const Icon(
                        Icons.skip_previous_rounded,
                        size: 42,
                        color: whiteColor,
                      ),
                    ),

                    // Play/Pause
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
                                ? const Icon(Icons.pause, color: whiteColor)
                                : const Icon(Icons.play_arrow_rounded,
                                    color: whiteColor),
                          ),
                        ),
                      ),
                    ),

                    // Skip to Next
                    IconButton(
                      onPressed: () {
                        int nextIndex;
                        if (controller.isShuffled.value) {
                          // Play the next song based on the shuffled indices
                          nextIndex = controller.shuffledIndices[
                              (controller.playIndex.value + 1) %
                                  controller.shuffledIndices.length];
                        } else {
                          // Play the next song in the original order
                          nextIndex =
                              (controller.playIndex.value + 1) % data.length;
                          // If repeat list mode is on and we're at the end of the list, go back to the first song
                          if (controller.repeatMode.value == 'list' &&
                              nextIndex == 0) {
                            nextIndex = data.length - 1;
                          }
                        }
                        controller.playSong(data[nextIndex].uri, nextIndex);
                      },
                      icon: const Icon(
                        Icons.skip_next_rounded,
                        size: 42,
                        color: whiteColor,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
