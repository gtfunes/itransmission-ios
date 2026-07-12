# Third-Party Licenses

iTransmission is released under the **GNU General Public License v3.0 or later**
(see [`LICENSE`](LICENSE)). It bundles the third-party components listed below.
Each remains under its own license; those licenses are compatible with the GPLv3
distribution of this app, and the original copyright and permission notices are
retained in the corresponding source files.

This file is a convenience index. For the authoritative and complete license
text of each component, consult the notice in its source files and/or the
upstream project.

## Objective-C components (`Source/`)

| Component | Author | License | Location |
|-----------|--------|---------|----------|
| ALAlertBanner | Anthony Lobianco | MIT | `Source/ALAlertBanner/` |
| SVWebViewController | Sam Vermette | MIT | `Source/Web View/` |
| Reachability | Tony Million | BSD-2-Clause | `Source/Reachability/` |
| CocoaLumberjack | Robbie Hanson & contributors | BSD-3-Clause | `Source/DDlog/` |
| NSDate+Helper | Billy Gray (Zetetic LLC) | BSD-2-Clause | `Source/Helpers+Additions/NSDate+Helper.*` |
| UncaughtExceptionHandler | Matt Gallagher | Permissive (attribution required) | `Source/Helpers+Additions/UncaughtExceptionHandler.*` |
| TDBadgedCell | Tim Davies | Attribution required | `Source/Cells/TDBadgedCell.*` |

## JavaScript components (`Resources/Web/`)

| Component | Author | License | Notes |
|-----------|--------|---------|-------|
| Transmission web client | The Transmission Project | GPLv2 / GPLv3 | `Resources/Web/javascript/*.js` — the bundled remote UI |
| jQuery 3.7.1 | OpenJS Foundation | MIT | `Resources/Web/javascript/jquery/jquery.min.js` |
| jQuery UI 1.13.3 | OpenJS Foundation | MIT | file is named `jqueryui-1.8.16.min.js` but is 1.13.3 |
| jquery.contextmenu | Chris Domigan | Permissive | `Resources/Web/javascript/jquery/jquery.contextmenu.*` |
| jquery.transmenu | Roman Weich | GPL / MIT | `Resources/Web/javascript/jquery/jquery.transmenu.*` |
| json2 | Douglas Crockford | Public Domain | `Resources/Web/javascript/jquery/json2.js` |

## Native static libraries (`libraries/`)

These are prebuilt static libraries with their headers under
`libraries/include/`. See the project [`README`](README.md) for their versions
and important security notes — several are older releases.

| Library | Author / Project | License | Version |
|---------|------------------|---------|---------|
| libtransmission | The Transmission Project | GPLv2 / GPLv3 (with MIT-licensed portions) | 2.82 (14160) |
| OpenSSL (libssl, libcrypto) | The OpenSSL Project | OpenSSL License + original SSLeay License (dual) | 1.0.1f |
| libcurl | Daniel Stenberg & contributors | curl license (MIT/X11-style) | 7.35.0 |
| libevent | Niels Provos, Nick Mathewson | BSD-3-Clause | 2.0.21-stable |
| libutp (µTP) | BitTorrent, Inc. | MIT | — |
| miniupnpc | Thomas Bernard | BSD-3-Clause | — |
| libnatpmp | Thomas Bernard | BSD-3-Clause | — |
| libdht | Juliusz Chroboczek | MIT | — |

---

If you believe a component is missing or misattributed here, please open an
issue so it can be corrected.
