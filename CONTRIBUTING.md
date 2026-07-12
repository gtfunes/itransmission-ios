# Contributing to iTransmission-iOS

Thanks for your interest in improving iTransmission! This is a small,
volunteer-maintained project, so please keep contributions focused and easy to
review.

## Reporting bugs

Open a [GitHub issue](https://github.com/gtfunes/itransmission-ios/issues) and include:

- What you did and what you expected to happen
- What actually happened (screenshots or a screen recording help a lot)
- Your device model, iOS version, and Xcode version
- Whether it reproduces on a clean checkout of `master`

For anything security-sensitive, follow [`SECURITY.md`](SECURITY.md) instead of
opening a public issue.

## Development setup

See the [Building](README.md#building) section of the README. In short: open
`iTransmission.xcodeproj`, set your signing team, and run on a **physical
device** (the Simulator on Apple Silicon is not supported — see the README note).

## Making changes

- Branch off `master` (e.g. `fix/magnet-parsing` or `chore/tidy-prefs`).
- Keep changes small and focused; unrelated cleanups belong in their own PR.
- Match the surrounding Objective-C style — this codebase predates Swift and
  stays consistent for readability.
- New source files should carry the project's license header:

  ```objc
  //
  //  MyFile.m
  //  iTransmission
  //
  //  SPDX-License-Identifier: GPL-3.0-or-later
  //
  ```

- Do not add third-party code without noting its license in
  [`THIRD_PARTY_LICENSES.md`](THIRD_PARTY_LICENSES.md), and keep its original
  copyright header intact.
- Test the core flows before opening a PR: adding a `.torrent`, adding a magnet
  link, downloading, and exporting a finished file.

## Submitting a pull request

- Fill out the pull request template.
- Make sure the project builds without new warnings.
- Reference any related issue with `Closes #123`.

## License

By contributing, you agree that your contributions are licensed under the
**GNU General Public License v3.0 or later**, the same license as the project.
