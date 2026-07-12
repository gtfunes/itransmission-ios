# iTransmission-iOS

A native [BitTorrent](https://en.wikipedia.org/wiki/BitTorrent) client for iOS 16+,
built on the same [libtransmission](https://transmissionbt.com) backend that powers
Transmission on macOS. It is free and open source.

This is a maintained port of the original iTransmission, initially created by
[ccp0101](https://github.com/ccp0101) and formerly hosted on Google Code
(now [archived](https://code.google.com/archive/p/itransmission/)). It has been
updated for modern iOS: migrated to recommended project settings, moved to
`WKWebView`, and had a number of bugs fixed.

## Features

- Download from `.torrent` files and magnet links
- Built-in Transmission web remote (RPC) — off by default
- Export downloaded files to other apps via the iOS share sheet
- iPad support

## Requirements

- **Xcode 26.x** (see [`.xcode-version`](.xcode-version))
- **iOS 16.0+** deployment target
- An Apple Developer account for on-device signing (automatic signing is used)

## Building

All dependencies are vendored in this repository (there is no CocoaPods, Carthage,
or Swift Package Manager step), so building is straightforward:

1. Clone the repository.
2. Open `iTransmission.xcodeproj` in Xcode.
3. Select the `iTransmission` scheme and your target device.
4. Set your signing team under **Signing & Capabilities** (the project uses
   automatic signing).
5. Build and run (**⌘R**).

> [!IMPORTANT]
> **Run on a physical device.** The bundled static libraries were compiled for
> `arm64` (device) and `x86_64` (Intel simulator) only. They do **not** include
> an `arm64` iOS Simulator slice, so the Simulator on Apple Silicon Macs is not
> supported unless you rebuild the native libraries yourself. A physical device
> (or an Intel Mac simulator) works out of the box.

## Project structure

| Path | Contents |
|------|----------|
| `Source/` | Application code (Objective-C), grouped by responsibility |
| `Nibs/` | Interface Builder XIBs and the launch storyboard |
| `Resources/` | Assets, localizations, and the bundled web remote UI |
| `libraries/` | Prebuilt native static libraries and their headers |
| `Other Sources/` | `Info.plist`, prefix header, `main.m` |

## Security

The vendored native libraries (`libtransmission` 2.82, OpenSSL 1.0.1f,
libcurl 7.35.0, libevent 2.0.21) are **older releases** and carry known
vulnerabilities. They are adequate for local experimentation but should be
rebuilt from current sources before any production or App Store use. See
[`SECURITY.md`](SECURITY.md) for details and how to report a vulnerability.

## Contributing

Contributions are welcome — see [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Credits

- [@ccp0101](https://github.com/ccp0101) for the original project
- [@andywiik](https://github.com/andywiik) for iPad support, Safari magnet links, and the build script
- [@alobi](https://github.com/alobi) for ALAlertBanner
- All the libtransmission developers for their excellent backend

Bundled component versions: iTransmission 37 · libtransmission 2.82 (14160) ·
libevent 2.0.21-stable.

## License

iTransmission is released under the **GNU General Public License v3.0 or later**
(see [`LICENSE`](LICENSE)). Bundled third-party components remain under their own
licenses, indexed in [`THIRD_PARTY_LICENSES.md`](THIRD_PARTY_LICENSES.md).
