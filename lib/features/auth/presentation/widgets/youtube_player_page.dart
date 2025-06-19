import 'package:flutter/material.dart';
import 'package:wizi_learn/features/auth/data/models/media_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


class YoutubePlayerPage extends StatefulWidget {
  final Media video;
  final List<Media> videosInSameCategory;

  const YoutubePlayerPage({
    super.key,
    required this.video,
    required this.videosInSameCategory,
  });

  @override
  State<YoutubePlayerPage> createState() => _YoutubePlayerPageState();
}

class _YoutubePlayerPageState extends State<YoutubePlayerPage> {
  late YoutubePlayerController _controller;
  late Media currentVideo;

  @override
  void initState() {
    super.initState();
    currentVideo = widget.video;
    _initYoutubeController(currentVideo.url);
  }

  void _initYoutubeController(String url) {
    final videoId = YoutubePlayer.convertUrlToId(url) ?? '';
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: true),
    );
  }

  void _switchVideo(Media media) {
    setState(() {
      currentVideo = media;
      _controller.load(YoutubePlayer.convertUrlToId(media.url)!);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final relatedVideos = widget.videosInSameCategory
        .where((v) => v.id != currentVideo.id)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(currentVideo.titre)),
      body: Column(
        children: [
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Autres vidéos",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: relatedVideos.length,
              itemBuilder: (context, index) {
                final media = relatedVideos[index];
                return ListTile(
                  title: Text(media.titre),
                  subtitle: Text(media.url),
                  leading: const Icon(Icons.play_circle_fill),
                  onTap: () => _switchVideo(media),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
