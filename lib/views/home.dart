import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musicplayerv2/consts/colors.dart';
import 'package:musicplayerv2/consts/text_style.dart';
import 'package:musicplayerv2/controllers/player_controller.dart';
import 'package:musicplayerv2/views/song_page.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final controller = Get.put(PlayerController());
  final searchController = TextEditingController();
  bool isSearching = false;
  List<SongModel> filteredSongs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDarkColor,
      appBar: AppBar(
        backgroundColor: bgDarkColor,
        actions: [
          isSearching
              ? Expanded(
                  child: Row(
                    children: [
                      const Expanded(
                          child:
                              SizedBox()), // This will take up all available space
                      SizedBox(
                        width: MediaQuery.of(context).size.width *
                            0.75, // Adjust the width as needed
                        child: TextField(
                          controller: searchController,
                          style: ourStyle(
                              color: whiteColor, family: regular, size: 18),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(left: 15),
                            border: InputBorder.none,
                            hintText: 'Search...',
                            hintStyle: ourStyle(
                                color: whiteColor.withOpacity(0.5),
                                size: 18,
                                family: regular),
                          ),
                          onSubmitted: (value) {
                            setState(() {
                              filteredSongs = controller.songs
                                  .where((song) => song.displayName
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: whiteColor),
                        onPressed: () {
                          setState(() {
                            isSearching = false;
                            searchController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                )
              : IconButton(
                  onPressed: () {
                    setState(() {
                      isSearching = true;
                    });
                  },
                  icon: const Icon(Icons.search, color: whiteColor),
                ),
        ],
        leading: const Icon(Icons.sort_rounded, color: whiteColor),
        title: Text(
          "S O U N D B O A R D",
          style: ourStyle(
            family: bold,
            size: 18,
          ),
        ),
      ),
      body: FutureBuilder<List<SongModel>>(
        future: controller.audioQuery.querySongs(
          ignoreCase: true,
          orderType: OrderType.ASC_OR_SMALLER,
          sortType: null,
          uriType: UriType.EXTERNAL,
        ),
        builder: (BuildContext context, snapshot) {
          if (snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.data!.isEmpty ||
              isSearching && filteredSongs.isEmpty) {
            return Center(
              child: Text(
                "No song/s found",
                style: ourStyle(),
              ),
            );
          } else {
            var songsToDisplay = isSearching ? filteredSongs : snapshot.data;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: songsToDisplay!.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: Obx(
                      () => ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: bgColor)),
                        tileColor: bgColor,
                        title: Text(songsToDisplay[index].displayNameWOExt,
                            style: ourStyle(
                                family: bold, size: 15, color: whiteColor)),
                        subtitle: Text(
                            songsToDisplay[index].artist ?? "Unknown",
                            style: ourStyle(
                                family: regular, size: 12, color: whiteColor)),
                        leading: QueryArtworkWidget(
                          id: songsToDisplay[index].id,
                          type: ArtworkType.AUDIO,
                          nullArtworkWidget: const Icon(Icons.music_note,
                              color: whiteColor, size: 32),
                        ),
                        trailing: controller.playIndex.value == index &&
                                controller.isPlaying.value
                            ? const Icon(Icons.play_arrow,
                                color: whiteColor, size: 26)
                            : null,
                        onTap: () {
                          Get.to(() => SongPage(data: songsToDisplay));
                          controller.playSong(songsToDisplay[index].uri, index);
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
