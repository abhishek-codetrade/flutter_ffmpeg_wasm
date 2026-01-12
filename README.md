# ffmpeg_wasm

[`ffmpeg.wasm`](https://github.com/ffmpegwasm/ffmpeg.wasm) for Flutter web. 
[`See Demo`](https://flutter-ffmpeg-wasm.web.app/)

## Installation

### Development

Add the following src script in the `head` tag of the `index.html` file:

```html
<script src="https://unpkg.com/@ffmpeg/ffmpeg@0.12.15/dist/umd/ffmpeg.js" crossorigin="anonymous"></script>
<script src="https://unpkg.com/@ffmpeg/util@0.12.15/dist/umd/util.js" crossorigin="anonymous"></script>
```

**Run shell**

```shell
flutter run -d chrome --web-browser-flag --enable-features=SharedArrayBuffer
```

**Android Studio**

`Run` -> `Edit Configurations...` -> `Create / edit your Flutter Configuration` -> `Additional run args:`
```shell
--web-browser-flag --enable-features=SharedArrayBuffer
```

**Visual Studio Code**

Create / edit your `launch.json`

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Example",
      "request": "launch",
      "type": "dart",
      "args": [
        "--web-browser-flag",
        "--enable-features=SharedArrayBuffer"
      ]
    }
  ]
}
```

### Production

Add the following src script in the `head` tag of the `index.html` file:

```html
<script src="https://unpkg.com/@ffmpeg/ffmpeg@0.12.15/dist/umd/ffmpeg.js" crossorigin="anonymous" async></script>
<script src="https://unpkg.com/@ffmpeg/util@0.12.15/dist/umd/util.js" crossorigin="anonymous" async></script>
```

The document _`index.html`_ should contain these headers:

```shell
Cross-Origin-Embedder-Policy: require-corp
Cross-Origin-Opener-Policy: same-origin
```

**For Firebase Hosting add below in `firebase.json`**

```json
{
  "hosting": {
     "headers": [
        {
          "source": "**",
          "headers": [
            {
              "key": "Cross-Origin-Embedder-Policy",
              "value": "require-corp"
            },
            {
              "key": "Cross-Origin-Opener-Policy",
              "value": "same-origin"
            }
          ]
        }
     ]
  }
}
```

**For Node.js Express**

```js
app.use(express.static(staticDir, {
  setHeaders: (res, filePath) => {
    const fileName = path.basename(filePath);

    if (fileName === 'index.html') {
      res.setHeader('Cross-Origin-Embedder-Policy', 'require-corp');
      res.setHeader('Cross-Origin-Opener-Policy', 'same-origin');
    }
  }
}));
```

**Importing scripts from other domains**

The response should contain the proper `Cross-Origin-Embedder-Policy: require-corp` / `Cross-Origin-Opener-Policy: same-origin` headers, and the client should add `crossorigin="anonymous"` to the script element: `<script src="..." crossorigin="anonymous" async></script>`. Otherwise, you will get the following error:

> GET https://unpkg.com/canvaskit-wasm@0.37.1/bin/canvaskit.js net::ERR_BLOCKED_BY_RESPONSE.NotSameOriginAfterDefaultedToSameOriginByCoep 200

In this case, if you don't own the CDN which provides the script, you should download it and serve it from your own CDN that provides those headers or put it in your static directory.

Since Flutter uses external `canvaskit` source when the app is in production, you should serve your own `canvaskit` (_note: when you are using `--web-renderer html` this is not a problem_):

This is the easiest way to download the `canvaskit` version which is used by flutter and also defines local `canvaskit` path:

```shell
#!/bin/sh
# Download CanvasKit
flutter build web
canvaskitLocation=$(grep canvaskit-wasm build/web/main.dart.js | sed -e 's|.*https|https|' -e 's|/bin.*|/bin/|' | uniq)
echo "Downloading CanvasKit from $canvaskitLocation"
curl -o build/web/canvaskit.js "$canvaskitLocation/canvaskit.js"
curl -o build/web/canvaskit.wasm "$canvaskitLocation/canvaskit.wasm"
# Configure flutter web to use local canvaskit
flutter build web --dart-define=FLUTTER_WEB_CANVASKIT_URL=/
```

_Note_: When importing a script from another domain, it's recommended to use `localhost` origin or `https` protocol. Otherwise, you may encounter the following error:

> The `Cross-Origin-Opener-Policy` header has been ignored, because the origin was untrustworthy. It was defined either in the final response or a redirect. Please deliver the response using the `HTTPS` protocol. You can also use the `'localhost'` origin instead. See https://www.w3.org/TR/powerful-features/#potentially-trustworthy-origin and [https://html.spec.whatwg.org/#the-cross-origin-opener-policy-header.](https://html.spec.whatwg.org/#the-cross-origin-opener-policy-header.%22)

## Usage

### Create FFmpeg instance

```dart
// Create instance
FFmpeg ffmpeg = FFmpeg();

// Load ffmpeg.wasm
// You can pass a config object if needed, but default relies on CDN or local setup
await ffmpeg.load(js.JsObject.jsify({
  'coreURL': await toBlobURL('https://unpkg.com/@ffmpeg/core@0.12.10/dist/umd/ffmpeg-core.js', 'text/javascript'),
  'wasmURL': await toBlobURL('https://unpkg.com/@ffmpeg/core@0.12.10/dist/umd/ffmpeg-core.wasm', 'application/wasm'),
}));
```

### Use FFmpeg instance

```dart
Future<Uint8List> exportVideo(Uint8List input) async {
  final ffmpeg = FFmpeg();
  
  final baseURL = 'https://unpkg.com/@ffmpeg/core@0.12.10/dist/umd';
  await ffmpeg.load(js.JsObject.jsify({
    'coreURL': await toBlobURL('$baseURL/ffmpeg-core.js', 'text/javascript'),
    'wasmURL': await toBlobURL('$baseURL/ffmpeg-core.wasm', 'application/wasm'),
  }));

  const inputFile = 'input.mp4';
  const outputFile = 'output.mp4';

  await ffmpeg.writeFile(inputFile, input);

  // Exec command
  await ffmpeg.exec(['-i', inputFile, '-s', '1920x1080', outputFile]);

  final data = await ffmpeg.readFile(outputFile);
  return data;
}

void _onLogHandler(LogEvent logger) {
  print('Log: ${logger.message}');
}
```

### Usage with [`video_player`](https://pub.dev/packages/video_player) package

The easiest way is to add a dependency to the [`cross_file`](https://pub.dev/packages/cross_file) package, import it, and then use the `VideoPlayerController.network` constructor to create a controller.

```dart
import 'package:cross_file/cross_file.dart';

final exportBytes = await exportVideo(inputBytes);
final xFile = XFile.fromData(exportBytes);

final controller = VideoPlayerController.network(xFile.path);
```

Supported Browsers - https://caniuse.com/sharedarraybuffer


### Roadmap

- [ ] Migrate to 0.12.x.