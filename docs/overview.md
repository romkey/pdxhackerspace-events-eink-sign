# E-ink Event Sign overview

**What:** ESPHome firmware for a color ePaper sign showing upcoming PDX
Hackerspace events, a 5-day weather forecast and a QR code.
**Kind:** app (no published firmware).
**Hardware:** ESP32-S3 with PSRAM and Seeed Spectra6 panels: reTerminal
E1002 (7.3"), reTerminal E1004 (13.3"), EE04 + 7.3", EE02 + 13.3".
reTerminals add an SHT4x at I2C 0x44.

## Files

- `packages/events.yaml`: fetch events + HA forecast, change detection and
  refresh rate limiting. No UI; exposes no-op render scripts.
- `packages/events-ui-800x480.yaml`, `events-ui-1600x1200.yaml`: LVGL
  layouts; `!extend` the render scripts.
- `packages/battery.yaml`: LiPo voltage + level.
- `components/epaper_spi/`: fork of ESPHome's epaper_spi with the T133A01
  13.3" controller (esphome#13860) and hardware rotation. EE02 only.
- `examples/*.yaml`: the four devices; all board/pin choices.
- `examples/common/base.yaml`: project, network, security, recovery,
  esphome-lib packages.
- `examples/common/reterminal.yaml`: reTerminal E10xx shared hardware.
- `examples/local-*.yaml`: personal device configs, gitignored.
- `images/`: QR codes. `cases/`: OpenSCAD case (WIP), STLs built by
  `.github/workflows/openscad.yml`.

## Required by packages

- events: `wifi`, `api`, a HA sensor `sensor.weather_forecast_5_day` with
  a JSON `forecast` attribute.
- events-ui-*: events package, a display with id `epaper_display`.
- battery: `battery_adc_pin`, `battery_enable_pin`.

## Conventions

- Substitutions prefixed with the package name, all with defaults unless
  listed above.
- Internal ids (LVGL widgets, `events_*` globals and scripts) are fixed;
  each package is included once.
- Examples are all ESP32-S3 (no esp32dev/C3): the UI needs PSRAM and a
  specific panel.
- Rules: https://github.com/romkey/esphome-ai-coding-rules/blob/main/RULES.md
