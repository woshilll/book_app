import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:book_app/log/log.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextPlayerHandler extends BaseAudioHandler with QueueHandler {
  final _tts = Tts();
  final _sleeper = Sleeper();
  Completer<void>? _completer;
  var _index = 0;
  bool _interrupted = false;
  var _running = false;

  bool get _playing => playbackState.value.playing;

  TextPlayerHandler() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    // Handle audio interruptions.
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        if (_playing) {
          pause();
          _interrupted = true;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.pause:
          case AudioInterruptionType.duck:
            if (!_playing && _interrupted) {
              play();
            }
            break;
          case AudioInterruptionType.unknown:
            break;
        }
        _interrupted = false;
      }
    });
    // Handle unplugged headphones.
    session.becomingNoisyEventStream.listen((_) {
      if (_playing) pause();
    });
    // queue.add(List.generate(
    //     10,
    //         (i) => MediaItem(
    //       id: 'tts_${i + 1}',
    //       album: 'Numbers',
    //       title: 'Number ${i + 1}',
    //       artist: 'Sample Artist',
    //       extras: <String, int>{'number': i + 1},
    //       duration: const Duration(seconds: 1),
    //     )));
  }

  Future<void> run() async {
    _completer = Completer<void>();
    _running = true;
    while (_running) {
      try {
        if (_playing) {
          mediaItem.add(queue.value[_index]);
          playbackState.add(playbackState.value.copyWith(
            updatePosition: Duration.zero,
            queueIndex: _index,
          ));
          AudioService.androidForceEnableMediaButtons();
          await Future.wait([
            _tts.speak('${mediaItem.value!.extras!["content"]}'),
            _sleeper.sleep(const Duration(seconds: 1)),
          ]);
          if (_index + 1 < queue.value.length) {
            _index++;
          } else {
            _running = false;
          }
        } else {
          await _sleeper.sleep();
        }
        // ignore: empty_catches
      } on SleeperInterruptedException {
        // ignore: empty_catches
      } on TtsInterruptedException {}
    }
    _index = 0;
    mediaItem.add(queue.value[_index]);
    playbackState.add(playbackState.value.copyWith(
      updatePosition: Duration.zero,
    ));
    if (playbackState.value.processingState != AudioProcessingState.idle) {
      stop();
    }
    _completer?.complete();
    _completer = null;
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    _index = index;
    _signal();
  }

  @override
  Future<void> play() async {
    if (_playing) return;
    final session = await AudioSession.instance;
    // flutter_tts doesn't activate the session, so we do it here. This
    // allows the app to stop other apps from playing audio while we are
    // playing audio.
    if (await session.setActive(true)) {
      // If we successfully activated the session, set the state to playing
      // and resume playback.
      playbackState.add(playbackState.value.copyWith(
        controls: [MediaControl.pause, MediaControl.stop],
        processingState: AudioProcessingState.ready,
        playing: true,
      ));
      if (_completer == null) {
        run();
      } else {
        _sleeper.interrupt();
      }
    }
  }

  @override
  Future<void> pause() async {
    _interrupted = false;
    playbackState.add(playbackState.value.copyWith(
      controls: [MediaControl.play, MediaControl.stop],
      processingState: AudioProcessingState.ready,
      playing: false,
    ));
    _signal();
  }

  @override
  Future<void> stop() async {
    playbackState.add(playbackState.value.copyWith(
      controls: [],
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
    _running = false;
    _signal();
    // Wait for the speech to stop
    await _completer?.future;
    // Shut down this task
    await super.stop();
  }

  void _signal() {
    _sleeper.interrupt();
    _tts.interrupt();
  }
}

/// An object that performs interruptable sleep.
class Sleeper {
  Completer<void>? _blockingCompleter;

  /// Sleep for a duration. If sleep is interrupted, a
  /// [SleeperInterruptedException] will be thrown.
  Future<void> sleep([Duration? duration]) async {
    _blockingCompleter = Completer();
    if (duration != null) {
      await Future.any<void>(
          [Future.delayed(duration), _blockingCompleter!.future]);
    } else {
      await _blockingCompleter!.future;
    }
    final interrupted = _blockingCompleter!.isCompleted;
    _blockingCompleter = null;
    if (interrupted) {
      throw SleeperInterruptedException();
    }
  }

  /// Interrupt any sleep that's underway.
  void interrupt() {
    if (_blockingCompleter?.isCompleted == false) {
      _blockingCompleter!.complete();
    }
  }
}

class SleeperInterruptedException {}

/// A wrapper around FlutterTts that makes it easier to wait for speech to
/// complete.
class Tts {
  final FlutterTts _flutterTts = FlutterTts();
  Completer<void>? _speechCompleter;
  bool _interruptRequested = false;
  bool _playing = false;

  Tts() {
    _flutterTts.setCompletionHandler(() {
      _speechCompleter?.complete();
    });
  }

  bool get playing => _playing;

  Future<void> speak(String text) async {
    _playing = true;
    if (!_interruptRequested) {
      _speechCompleter = Completer();
      await _flutterTts.speak(text);
      await _speechCompleter!.future;
      _speechCompleter = null;
    }
    _playing = false;
    if (_interruptRequested) {
      _interruptRequested = false;
      throw TtsInterruptedException();
    }
  }

  Future<void> stop() async {
    if (_playing) {
      await _flutterTts.stop();
      _speechCompleter?.complete();
    }
  }

  void interrupt() {
    if (_playing) {
      _interruptRequested = true;
      stop();
    }
  }
  void listen() {
    _flutterTts.setProgressHandler((text, start, end, word) {
      Log.i(text);
      Log.i(start);
      Log.i(end);
      Log.i(word);
    });
  }
}

class TtsInterruptedException {}
