import 'package:get/get.dart';
import 'dart:developer';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class PlayerController extends GetxController {
  final audioQuery = OnAudioQuery();
  final audioPlayer = AudioPlayer();

  var duration = Duration.zero.obs;
  var position = Duration.zero.obs;

  var playIndex = 0.obs;
  var isPlaying = false.obs;

  var max = 0.0.obs;
  var value = 0.0.obs;

  var isShuffled = false.obs;
  var shuffledIndices = <int>[].obs;

  var repeatMode = 'none'.obs;

  List<SongModel> songs = [];

  @override
  void onInit() {
    super.onInit();
    checkPermission();

    // Fetch the songs and store them in the songs list
    fetchSongs();

    audioPlayer.positionStream.listen((p) {
      position.value = p;
      double newValue = p.inSeconds.toDouble();
      if (newValue <= max.value) {
        value.value = newValue;
      } else {
        value.value = max.value;
      }
    });

    audioPlayer.durationStream.listen((d) {
      if (d != null) {
        duration.value = d;
        max.value = d.inSeconds.toDouble();
      }
    });

    audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        if (repeatMode.value == 'song') {
          audioPlayer.seek(Duration.zero);
          audioPlayer.play();
        } else {
          playNextSong(songs);
        }
      }
    });
  }

  void fetchSongs() async {
    songs = await audioQuery.querySongs();
  }

  void updatePosition() {
    audioPlayer.positionStream.listen((p) {
      position.value = p;
      value.value = p.inSeconds.toDouble();
    });
  }

  void changeDurationToSeconds(seconds) {
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

  Future<void> playSong(String? uri, int index) async {
    if (isPlaying.value && playIndex.value == index) {
      await audioPlayer.pause();
      isPlaying(false);
    } else {
      playIndex.value = index;
      isPlaying(true);
      try {
        await audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
        await audioPlayer.play();
        isPlaying(true);
      } on Exception catch (e) {
        log('Error: ${e.toString()}');
      }
    }
  }

  void checkPermission() async {
    var req = await Permission.storage.request();
    if (req.isGranted) {
      // Permission granted
    } else {
      checkPermission();
    }
  }

  void playNextSong(List<SongModel> data) async {
    int nextIndex;
    if (repeatMode.value == 'song') {
      // Repeat the current song
      nextIndex = playIndex.value;
    } else if (isShuffled.value && shuffledIndices.isNotEmpty) {
      // Play the next song in the shuffled order
      nextIndex =
          shuffledIndices[(playIndex.value + 1) % shuffledIndices.length];
    } else if (data.isNotEmpty) {
      // Play the next song in the original order
      nextIndex = (playIndex.value + 1) % data.length;
    } else {
      // If data is empty, we can't proceed. Throw an error.
      throw Exception('Error: data is empty');
    }

    // If repeat mode is 'none' and the song list is over, stop the player
    if (repeatMode.value == 'none' &&
        repeatMode.value != 'song' &&
        nextIndex == 0 &&
        playIndex.value == data.length - 1) {
      audioPlayer.stop();
      isPlaying(false);
    } else {
      // Check if nextIndex is a valid index for data
      if (nextIndex >= 0 && nextIndex < data.length) {
        await playSong(data[nextIndex].uri, nextIndex);
      } else {
        log('Error: Invalid nextIndex: $nextIndex for data length: ${data.length}');
      }
    }
  }
}
