/// FFmpeg.wasm for Flutter Web.
@JS()
library ffmpeg;

import 'dart:js_interop';
import 'dart:typed_data';

@JS('FFmpegWASM.FFmpeg')
extension type FFmpeg._(JSObject _) implements JSObject {
  external FFmpeg();

  external bool get loaded;

  @JS('load')
  external JSPromise _load(JSAny? config);

  Future<void> load(dynamic config) async {
    await _load(config as JSAny?).toDart;
  }

  @JS('writeFile')
  external JSPromise<JSBoolean> _writeFile(JSString path, JSAny? data);

  Future<bool> writeFile(String path, dynamic data) async {
    JSAny? jsData;
    if (data is Uint8List) {
      jsData = data.toJS;
    } else if (data is String) {
      jsData = data.toJS;
    } else {
      jsData = data as JSAny?;
    }
    return (await _writeFile(path.toJS, jsData).toDart).toDart;
  }

  @JS('readFile')
  external JSPromise<JSUint8Array> _readFile(JSString path);

  Future<Uint8List> readFile(String path) async {
    return (await _readFile(path.toJS).toDart).toDart;
  }

  @JS('deleteFile')
  external JSPromise<JSBoolean> _deleteFile(JSString path);

  Future<bool> deleteFile(String path) async {
    return (await _deleteFile(path.toJS).toDart).toDart;
  }

  @JS('listDir')
  external JSPromise<JSArray> _listDir(JSString path);

  Future<JSArray> listDir(String path) async {
    return await _listDir(path.toJS).toDart;
  }

  @JS('exec')
  external JSPromise<JSNumber> _exec(JSArray<JSString> args, JSNumber? timeout);

  Future<int> exec(List<String> args, [int? timeout]) async {
    final jsArgs = args.map((e) => e.toJS).toList().toJS;
    return (await _exec(jsArgs, timeout?.toJS).toDart).toDartInt;
  }

  @JS('execCommand')
  external JSPromise<JSNumber> _execCommand(JSString args, JSNumber? timeout);

  Future<int> execCommand(String args, [int? timeout]) async {
    return (await _execCommand(args.toJS, timeout?.toJS).toDart).toDartInt;
  }

  external void terminate();

  external void on(String event, JSFunction callback);

  external void off(String event, JSFunction callback);
}

@JS('FFmpegUtil.fetchFile')
external JSPromise<JSAny?> _fetchFile(JSAny? file);

Future<Uint8List> fetchFile(dynamic file) async {
  JSAny? jsFile;
  if (file is Uint8List) {
    jsFile = file.toJS;
  } else if (file is String) {
    jsFile = file.toJS;
  } else {
    jsFile = file as JSAny?;
  }
  final result = await _fetchFile(jsFile).toDart;
  if (result.isA<JSUint8Array>()) {
    return (result as JSUint8Array).toDart;
  }
  return Uint8List(0);
}

@JS('FFmpegUtil.toBlobURL')
external JSPromise<JSAny?> _toBlobURL(JSString url, JSString mimeType);

Future<String> toBlobURL(String url, String mimeType) async {
  final result = await _toBlobURL(url.toJS, mimeType.toJS).toDart;
  if (result.isA<JSString>()) {
    return (result as JSString).toDart;
  }
  return '';
}

@JS()
extension type LogEvent._(JSObject _) implements JSObject {
  external String get type;
  external String get message;
}

@JS()
extension type ProgressEvent._(JSObject _) implements JSObject {
  external double get progress;
  external int get time;
}
