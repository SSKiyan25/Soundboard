import 'package:get/get.dart';
import 'dart:developer';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class PlayerController extends GetxController {
  final audioQuery = OnAudioQuery();
  final audioPlayer = AudioPlayer();

  var duration = ''.obs;
  var position = ''.obs;

  var playIndex = 0.obs;
  var isPlaying = false.obs;

  var max = 0.0.obs;
  var value = 0.0.obs;

  var isShuffled = false.obs;
  var shuffledIndices = <int>[].obs;

  var repeatMode = 'none'.obs;

  List<SongModel> songs = []; // Add this line

  @override
  void onInit() {
    super.onInit();
    checkPermission();

    // Listen to the processing state stream
    audioPlayer.processingStateStream.listen((state) {
      // If the song has finished playing
      if (state == ProcessingState.completed) {
        // Play the next song
        playNextSong(songs); // Pass the songs list here
      }
    });
  }

  updatePosition() {
    audioPlayer.durationStream.listen((d) {
      duration.value = d.toString().split('.')[0];
      max.value = d!.inSeconds.toDouble();
    });
    audioPlayer.positionStream.listen((p) {
      position.value = p.toString().split('.')[0];
      value.value = p.inSeconds.toDouble();
    });
  }

  changeDurationToSeconds(seconds) {
    var duration = Duration(seconds: seconds);
    audioPlayer.seek(duration);
  }

  void shuffleSongs(List<SongModel> songs) {
    if (isShuffled.value) {
      isShuffled.value = false;
      shuffledIndices.clear();
    } else {
      isShuffled.value = true;
      shuffledIndices.value = List<int>.generate(songs.length, (i) => i)
        ..shuffle();
    }
  }

  void toggleRepeatMode() {
    if (repeatMode.value == 'none') {
      repeatMode.value = 'song';
    } else if (repeatMode.value == 'song') {
      repeatMode.value = 'list';
    } else {
      repeatMode.value = 'none';
    }
  }

  playSong(String? uri, index) {
    playIndex.value = index;
    try {
      audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
      audioPlayer.play();
      isPlaying(true);
      updatePosition();
    } on Exception catch (e) {
      log('Error: ${e.toString()}');
    }
  }

  checkPermission() async {
    var req = await Permission.storage.request();
    if (req.isGranted) {
      //
    } else {
      checkPermission();
    }
  }

  void playNextSong(List<SongModel> data) {
    int nextIndex;
    if (repeatMode.value == 'song') {
      // Repeat the current song
      nextIndex = playIndex.value;
    } else if (isShuffled.value) {
      // Play the next song based on the shuffled indices
      nextIndex =
          shuffledIndices[(playIndex.value + 1) % shuffledIndices.length];
    } else {
      // Play the next song in the original order
      nextIndex = (playIndex.value + 1) % data.length;
      // If repeat list mode is on and we're at the end of the list, go back to the first song
      if (repeatMode.value == 'list' && nextIndex == 0) {
        nextIndex = data.length - 1;
      }
    }
    playSong(data[nextIndex].uri, nextIndex);
  }
}
