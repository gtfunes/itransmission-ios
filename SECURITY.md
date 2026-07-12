# Security Policy

## Supported versions

iTransmission is a hobby project. Only the latest `master` branch receives fixes.

## Reporting a vulnerability

Please **do not** open a public issue for security vulnerabilities.

Instead, use GitHub's private vulnerability reporting:

1. Go to the repository's **Security** tab.
2. Click **Report a vulnerability**.
3. Describe the issue and, if possible, steps to reproduce.

You'll receive a response as soon as the maintainer is able. Thanks for
disclosing responsibly.

## Known security considerations

This app is intended for local, personal use. A few things are worth knowing:

- **Legacy native libraries.** The bundled binaries — `libtransmission` 2.82,
  OpenSSL 1.0.1f, libcurl 7.35.0, libevent 2.0.21 — are older releases with
  known CVEs. They should be rebuilt from current upstream sources before any
  production or App Store use.
- **Remote (RPC) access is off by default.** If you enable it, change the
  default `admin` / `admin` credentials immediately and do not expose the RPC
  port to untrusted networks.
- **Embedded file server.** When the remote is enabled, the app serves its
  Documents directory over plaintext HTTP without authentication. Only enable it
  on trusted networks.

Treat BitTorrent traffic and any exposed remote interface as untrusted, and
avoid running the remote on public or shared Wi-Fi.
