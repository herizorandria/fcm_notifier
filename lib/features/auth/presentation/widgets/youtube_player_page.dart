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
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
      ),
    );
  }

  void _switchVideo(Media media) {
    setState(() {
      currentVideo = media;
      _controller.load(YoutubePlayer.convertUrlToId(media.url)!);
      _controller.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final relatedVideos = widget.videosInSameCategory
        .where((v) => v.id != currentVideo.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentVideo.titre,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Player YouTube
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
              child: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: colorScheme.primary,
                progressColors: ProgressBarColors(
                  playedColor: colorScheme.primary,
                  handleColor: colorScheme.primary,
                  bufferedColor: colorScheme.surfaceContainerHighest,
                  backgroundColor: colorScheme.onSurface.withOpacity(0.2),
                ),
                onReady: () {
                  // Vous pouvez ajouter des actions lorsque le player est prêt
                },
              ),
            ),

          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentVideo.titre,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                if (currentVideo.description != null)
                  Text(
                    currentVideo.description!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.category, size: 18, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      "Catégorie: ${currentVideo.categorie}",
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.timer_outlined, size: 18, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      "Durée: ${currentVideo.duree ?? 'N/A'} min",
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Section vidéos connexes
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      "Autres vidéos dans cette catégorie",
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                  if (relatedVideos.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.video_library_outlined,
                              size: 48,
                              color: colorScheme.onSurface.withOpacity(0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Aucune autre vidéo disponible",
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: relatedVideos.length,
                        separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final media = relatedVideos[index];
                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => _switchVideo(media),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            YoutubePlayer.getThumbnail(
                                              videoId: YoutubePlayer
                                                  .convertUrlToId(media.url) ?? '',
                                              quality: ThumbnailQuality.medium,
                                            ),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.play_circle_fill,
                                          size: 28,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            media.titre,
                                            style: textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Durée: ${media.duree ?? 'N/A'}",
                                            style: textTheme.bodySmall?.copyWith(
                                              color: colorScheme.onSurface
                                                  .withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}