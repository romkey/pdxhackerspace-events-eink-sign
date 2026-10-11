# Configuration

## `packages/events.yaml`

Fetches upcoming events from the PDX Hackerspace event manager, subscribes
to a 5-day forecast from Home Assistant, and decides whether the panel needs
redrawing: only when events or weather changed, and at most once per
`events_min_refresh_seconds`. The **Refresh Events** button (or setting
`events_force_refresh` to `true` before running `events_update`) bypasses
both checks. Fetches on Wi-Fi connect and every `events_update_interval`.

Has no UI. A UI package draws the data by extending three no-op scripts:
`events_render_events`, `events_render_weather` and `events_refresh_display`.

**Requires:** `wifi:`, `api:` (Home Assistant time and weather), PSRAM or
enough RAM for a 50 KB response, and a Home Assistant sensor whose `forecast`
attribute is JSON shaped `{"f": [{"d":"Sun","c":"cloudy","h":65,"l":58}, ...]}`
(up to 5 days; `c` is an HA weather condition).

Ids other actions can use: `events_update` (script), `events_force_refresh`
(bool global), `events_list` and `events_last_updated` (text sensors),
`events_time`. Ids are fixed, so include the package once.

| Substitution | Default | Meaning |
|--------------|---------|---------|
| `events_url` | `https://events.pdxhackerspace.org/events/eink.json` | Events feed |
| `events_user_agent` | `reterminal-e1002-esphome` | HTTP user agent |
| `events_timezone` | `PST8PDT,M3.2.0,M11.1.0` | POSIX TZ string (ESP-IDF doesn't understand Olson names) |
| `events_max` | `5` | Events shown |
| `events_update_interval` | `30min` | How often to fetch |
| `events_connect_delay` | `8s` | Wait after Wi-Fi connects so HA time and weather arrive first |
| `events_min_refresh_seconds` | `900` | Minimum time between panel refreshes |
| `events_weather_entity` | `sensor.weather_forecast_5_day` | HA forecast sensor |
| `events_list_name` | `Hackerspace Events` | Entity name |
| `events_last_updated_name` | `Hackerspace Events Last Updated` | Entity name |
| `events_refresh_name` | `Refresh Events` | Entity name |

```yaml
packages:
  events: github://romkey/pdxhackerspace-events-eink-sign/packages/events.yaml@v0.1.0
```

## `packages/events-ui-800x480.yaml` and `packages/events-ui-1600x1200.yaml`

LVGL layouts for the sign: a header, the upcoming events (cancelled ones in
red), a 5-day forecast row with Material Design weather icons, and a QR code.
`800x480` is for 7.3" panels; `1600x1200` is for 1200x1600 13.3" panels,
rotated 90° to landscape, with a full-panel LVGL buffer (PSRAM required).
Colors are limited to what Spectra6 panels show; there is no gray.

**Requires:** `packages/events.yaml`; a display (`update_interval: never`)
with id `events_ui_display_id`; internet access at build time for Google
Fonts and the MDI font on jsDelivr. Include only one UI package.

| Substitution | Default | Meaning |
|--------------|---------|---------|
| `events_ui_display_id` | `epaper_display` | Display to draw on |
| `events_ui_qr_image` | `../images/events-qr.png` (800x480), `../images/events-qr-13.png` (1600x1200) | QR code image, relative to your config file. Set it when using the package remotely. |

```yaml
substitutions:
  events_ui_qr_image: images/my-qr.png

packages:
  events: github://romkey/pdxhackerspace-events-eink-sign/packages/events.yaml@v0.1.0
  events_ui: github://romkey/pdxhackerspace-events-eink-sign/packages/events-ui-800x480.yaml@v0.1.0

display:
  - platform: epaper_spi
    id: epaper_display
    model: 7.3in-spectra-e6
    # pins...
    update_interval: never
```

## `packages/battery.yaml`

Single-cell LiPo voltage through a resistor divider, plus a coarse charge
level. Defines the divider's enable output but doesn't turn it on; do that
in `on_boot`.

**Requires:** `battery_adc_pin`, `battery_enable_pin`.

| Substitution | Default | Meaning |
|--------------|---------|---------|
| `battery_adc_pin` | (required) | ADC GPIO |
| `battery_enable_pin` | (required) | GPIO that enables the divider |
| `battery_divider` | `2.0` | Divider ratio |
| `battery_attenuation` | `12db` | ADC attenuation |
| `battery_update_interval` | `60s` | Sampling interval |
| `battery_filter_window` | `5` | Moving-average window, in samples |
| `battery_voltage_name` | `Battery Voltage` | Entity name |
| `battery_voltage_id` | `battery_voltage` | Sensor id |
| `battery_voltage_entity_category` | `diagnostic` | `""` for the main device card |
| `battery_level_name` | `Battery Level` | Entity name |
| `battery_level_id` | `battery_level` | Sensor id |
| `battery_enable_id` | `battery_enable` | Output id |

```yaml
esphome:
  on_boot:
    - priority: 600
      then:
        - output.turn_on: battery_enable

packages:
  battery:
    url: https://github.com/romkey/pdxhackerspace-events-eink-sign
    ref: v0.1.0
    files:
      - path: packages/battery.yaml
        vars:
          battery_adc_pin: GPIO1
          battery_enable_pin: GPIO21
```

## `components/epaper_spi`

ESPHome's `epaper_spi` display with the T133A01 13.3" Spectra6 controller
from [esphome/esphome#13860](https://github.com/esphome/esphome/pull/13860)
(model `Seeed-ee02-color-13.3`) and LVGL hardware rotation. It replaces the
built-in component, so only use it where you need that model.

```yaml
external_components:
  - source: github://romkey/pdxhackerspace-events-eink-sign@v0.1.0
    components: [epaper_spi]
```
