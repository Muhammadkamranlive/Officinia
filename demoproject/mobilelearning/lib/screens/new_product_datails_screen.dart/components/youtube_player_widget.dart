import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerWidget extends StatefulWidget {
  final List<dynamic> itemDetails;

  YoutubePlayerWidget({required this.itemDetails});

  @override
  _YoutubePlayerWidgetState createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<YoutubePlayerWidget>
    with WidgetsBindingObserver {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    String? videoId = _getYouTubeVideoIdFromItemDetails();
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  String? _getYouTubeVideoIdFromItemDetails() {
    for (var item in widget.itemDetails) {
      if (item['type'] == 'youtube Video' && item['title'] != null) {
        return YoutubePlayer.convertUrlToId(item['title']);
      }
    }
    return null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _controller.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _controller.initialVideoId.isNotEmpty
        ? Container(
            height: 200,
            padding: const EdgeInsets.all(8.0),
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
            ),
          )
        : SizedBox.shrink();
  }
}
