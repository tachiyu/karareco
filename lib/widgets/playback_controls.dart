import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlaybackControls extends StatefulWidget {
  final AudioPlayer player;

  PlaybackControls({required this.player});

  @override
  _PlaybackControlsState createState() => _PlaybackControlsState();
}

class _PlaybackControlsState extends State<PlaybackControls> {
  final List<double> _speedOptions = [1.0, 1.1, 1.25, 2.0, 0.5, 0.75];
  int _currentSpeedIndex = 0;
  IconData _playPauseIcon = Icons.play_arrow;
  LoopMode _loopMode = LoopMode.off;

  @override
  void initState() {
    super.initState();
    widget.player.setSpeed(_speedOptions[_currentSpeedIndex]);
    _initAudioPlayerListeners();
  }

  @override
  void dispose() {
    widget.player.dispose();
    super.dispose();
  }

  void _initAudioPlayerListeners() {
    widget.player.playingStream.listen((playing) {
      if (playing) {
        setState(() {
          _playPauseIcon = Icons.pause;
        });
      } else {
        setState(() {
          _playPauseIcon = Icons.play_arrow;
        });
      }
    });
  }

  void _playPause() {
    if (widget.player.playing) {
      widget.player.pause();
    } else {
      widget.player.play();
    }
  }

  void _rewind(int seconds) {
    if (widget.player.position > Duration(seconds: seconds)) {
      widget.player.seek(widget.player.position - Duration(seconds: seconds));
    } else {
      widget.player.seek(Duration.zero);
    }
  }

  void _forward(int seconds) {
    if (widget.player.position <
        widget.player.duration! - Duration(seconds: seconds)) {
      widget.player.seek(widget.player.position + Duration(seconds: seconds));
    } else {
      widget.player.seek(widget.player.duration!);
    }
  }

  void _changeSpeed() {
    setState(() {
      _currentSpeedIndex = (_currentSpeedIndex + 1) % _speedOptions.length;
    });
    widget.player.setSpeed(_speedOptions[_currentSpeedIndex]);
  }

  void _changeLoopMode() {
    setState(() {
      _loopMode =
          LoopMode.values[(_loopMode.index + 1) % LoopMode.values.length];
    });
    widget.player.setLoopMode(_loopMode);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return hours > 0
        ? '${hours.toString()}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString()}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.loop),
                onPressed: _changeLoopMode,
              ),
              IconButton(
                icon: const Icon(Icons.replay_30),
                onPressed: () => _rewind(30),
              ),
              IconButton(
                icon: const Icon(Icons.replay_5),
                onPressed: () => _rewind(5),
              ),
              IconButton(
                icon: Icon(_playPauseIcon),
                onPressed: _playPause,
              ),
              IconButton(
                icon: const Icon(Icons.forward_5),
                onPressed: () => _forward(5),
              ),
              IconButton(
                icon: const Icon(Icons.forward_30),
                onPressed: () => _forward(30),
              ),
              IconButton(
                icon: const Icon(Icons.speed),
                onPressed: _changeSpeed,
              )
            ],
          ),
          StreamBuilder<Duration>(
              stream: widget.player.durationStream
                  .map((duration) => duration ?? Duration.zero),
              builder: (context, snapshot) {
                final duration = snapshot.data ?? Duration.zero;
                return StreamBuilder<Duration>(
                  stream: widget.player.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    return Row(children: [
                      Slider(
                        min: 0.0,
                        max: duration.inMilliseconds.toDouble(),
                        value: position.inMilliseconds
                            .toDouble()
                            .clamp(0.0, duration.inMilliseconds.toDouble()),
                        onChanged: (value) {
                          widget.player
                              .seek(Duration(milliseconds: value.toInt()));
                        },
                      ),
                      Text(
                        "${_formatDuration(position)}/${_formatDuration(duration)}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ]);
                  },
                );
              }),
        ],
      ),
    );
  }
}
