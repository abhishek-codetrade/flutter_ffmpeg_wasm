// @dart=3.5
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:ffmpeg_wasm/src/ffmpeg.dart';

// Interop types for callbacks

extension type ProgressParam._(JSObject _) implements JSObject {
  external double get progress; // 0 to 1
  external int get time; // time in microseconds ? 0.12.x usually gives time.

  // Old code had: double get ratio; double? get time;
  // We need to adapt.
  double get ratio => progress;
}

extension type LoggerParam._(JSObject _) implements JSObject {
  external String get type;
  external String get message;
}

extension FFmpegExtension on FFmpeg {
  /// Load FFmpeg core wasm module. Call this only once.
  ///
  /// Typically the load() func might take few seconds to minutes to complete, better to do it as early as possible.
  Future<void> load() async {
    // 0.12.x load takes a config object, usually null or empty object if defaults are fine.
    // In dart:js_interop, references are handled differently, passing null might need care.
    // But dynamic in ffmpeg.dart allows passing JS objects.
    await this.load(null);
  }

  /// API to check where the core is loaded.
  bool isLoaded() {
    return loaded;
  }

  /// Write file to In-Memory File System (MEMFS).
  ///
  /// Note: This is now asynchronous.
  Future<void> writeFile(String fileName, Uint8List data) async {
    await this.writeFile(fileName, data);
  }

  /// Read file from MEMFS.
  ///
  /// Note: This is now asynchronous.
  Future<Uint8List> readFile(String fileName) async {
    return await this.readFile(fileName);
  }

  /// Delete a file in MEMFS.
  ///
  /// Note: This is now asynchronous.
  Future<void> unlink(String fileName) async {
    await deleteFile(fileName);
  }

  /// List files inside specific path.
  ///
  /// Note: This is now asynchronous.
  Future<List<String>> readDir(String path) async {
    final jsArray = await listDir(path);
    return jsArray.toDart.map((e) => (e as JSString).toDart).toList();
  }

  /// Kill the execution of the program, also remove MEMFS to free memory
  void exit() {
    terminate();
  }

  /// Progress handler to get current progress of ffmpeg command.
  void setProgress(void Function(ProgressParam progress) callback) {
    on(
        'progress',
        (JSAny event) {
          // event is a JS Object { progress: number, time: number }
          // We need to wrap it into ProgressParam or cast it.
          // Since ProgressParam was an abstract class in the old code, let's redefine it or map it.
          // But wait, the old code used @anonymous abstract class which is fine for JS interop (old).
          // With dart:js_interop, we can use extension types or just Map.
          // Let's assume we can cast event to a JSObject and read properties.
          // Or better, let's redefine ProgressParam as an extension type or interop class.
          final p = event as ProgressParam;
          callback(p);
        }.toJS);
  }

  /// Set custom logger to get ffmpeg output messages.
  void setLogger(void Function(LoggerParam logger) callback) {
    on(
        'log',
        (JSAny event) {
          final l = event as LoggerParam;
          callback(l);
        }.toJS);
  }

  // setLogging(bool) is not directly exposed in 0.12.x FFmpeg class usually,
  // but it might be part of load config or just handled by setting a logger.
  // For now, if the API doesn't have it, we might skip or leave a placeholder.
  // The FFmpeg class in ffmpeg.dart doesn't have setLogging.
  // We can probably ignore it or check if it's needed.
  // The old code had: external void setLogging(bool logging);
  // We will remove it if it's not supported, or just no-op.

  /// Run ffmpeg command.
  Future<void> run(List<String> command) async {
    await exec(command);
  }

  Future<void> runCommand(String command) async {
    await execCommand(command);
  }
}
