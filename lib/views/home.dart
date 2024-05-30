import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musicplayerv2/consts/colors.dart';
import 'package:musicplayerv2/consts/text_style.dart';
import 'package:musicplayerv2/controllers/player_controller.dart';
//import 'package:musicplayerv2/views/player.dart';
import 'package:musicplayerv2/views/song_page.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(PlayerController());

    return Scaffold(
        backgroundColor: bgDarkColor,
        appBar: AppBar(
          backgroundColor: bgDarkColor,
          actions: [
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search, color: whiteColor)),
          ],
          leading: const Icon(Icons.sort_rounded, color: whiteColor),
          title: Text("S O U N D B O A R D",
              style: ourStyle(
                family: bold,
                size: 18,
              )),
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
            } else if (snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  "No song/s found",
                  style: ourStyle(),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: Obx(
                        () => ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: bgColor)),
                          tileColor: bgColor,
                          title: Text(snapshot.data![index].displayNameWOExt,
                              style: ourStyle(
                                  family: bold, size: 15, color: whiteColor)),
                          subtitle: Text(
                              snapshot.data![index].artist ?? "Unknown",
                              style: ourStyle(
                                  family: regular,
                                  size: 12,
                                  color: whiteColor)),
                          leading: QueryArtworkWidget(
                            id: snapshot.data![index].id,
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
                            Get.to(() => SongPage(data: snapshot.data!));
                            controller.playSong(
                                snapshot.data![index].uri, index);
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          },
        ));
  }
}
