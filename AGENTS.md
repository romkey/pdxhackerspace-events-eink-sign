# Instructions for AI assistants

Follow https://github.com/romkey/esphome-ai-coding-rules/blob/main/RULES.md.
With Claude Code, the `esphome-rules` plugin loads them for you.

Read docs/overview.md first. `main` is protected: work on a branch and
open a pull request; CI and Lint must pass before it can merge.

<!-- Project-specific notes go below. -->

- App, not a library; no published firmware. Examples are the four real
  ESP32-S3 devices, not the generic esp32/C3/S3 set: the LVGL UI needs
  PSRAM and a specific panel.
- `components/epaper_spi` is a fork of ESPHome's component carrying
  esphome/esphome#13860. Keep it close to upstream so it can go back as a PR.
- Panels are Spectra6: only black, white, red, yellow, blue, orange, green.
- `cases/` is OpenSCAD; `.github/workflows/openscad.yml` regenerates STLs.
