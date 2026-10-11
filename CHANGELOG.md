# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- reTerminal E1004 (13.3") example using ESPHome's native `Seeed-reTerminal-E1004` display.
- `packages/battery.yaml`, shared by the reTerminals and the EE04.
- Docker Compose services (`validate`, `build`, `lint`, `dashboard`), pre-commit
  checks, CI, Lint and Release workflows, Renovate, and project docs following
  [esphome-ai-coding-rules](https://github.com/romkey/esphome-ai-coding-rules).
- Safe-mode button, esphome-lib restart button, and ESPHome project version.

### Changed

- **Breaking:** repository layout. Device configs moved from `src/` to
  `examples/`, `src/lib/events-display*.yaml` became `packages/events.yaml`
  (logic) plus `packages/events-ui-800x480.yaml` / `events-ui-1600x1200.yaml`
  (LVGL UI), and `src/local_components/` became `components/`. Secrets now
  live in `examples/secrets.yaml`, using `api_encryption_key` and
  `fallback_ap_password`.
- **Breaking:** entity names no longer repeat the device name ("reTerminal
  Temperature" is now "Temperature", and so on), so Home Assistant entity ids
  and history for those entities change.
- **Breaking:** OTA uses encryption with the API key instead of a password.
- The 7.3" devices now use the same change detection and 15-minute refresh
  limit as the 13.3" ones.
- esphome-lib packages are pinned to v0.2.0 instead of `main`.
- Images use the `platform: file` form ESPHome now requires.
- The EE04 no longer defines an unused buzzer output.
- The 13.3" panel datasheet is Seeed's current revision, with its source recorded.
- Battery voltage reports device/state class and is smoothed with a
  moving average.

### Security

- API keys, OTA passwords and Wi-Fi credentials are no longer hardcoded in
  configs. Keys that were committed before should be rotated.
