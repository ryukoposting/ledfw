# Repo Structure

| Directory/File | Description                                                             |
|:---------------|:------------------------------------------------------------------------|
| `./src`        | Firmware source code                                                    |
| `./misc`       | Miscellaneous firmware things (bootloader hex file, linker script, etc) |
| `./scripts`    | Ruby scripts used when building the firmware                            |
| `./tools`      | Tools that work with the firmware                                       |
| `build.yaml`   | Firmware build configuration |

# Using this Repo

## Building

You need the following software in order to compile the firmware:

- Make
- GCC+binutils for arm-none-eabi - any version supporting C17 and C++17.
- Ruby - any recent version (>=2.5-ish) should be fine.
- nrfutil - version 6.1.6 or newer will work.

With those programs installed, simply run `make debug -j4` to run a build.

`build.yaml` is where the build is configured. You should never need to edit
the makefiles directly.

## Components

The path to each "component" of the project is listed in the `components:`
section of `build.yaml`. In each "component" folder, there is a `component.yaml`
file that lists the source files and include directories provided by that
component.

## VS Code

Modify sure the `compilerPath` field in `c_cpp_properties.json` is

When you run `make`, the makefiles (with the help of some ruby scripts) will
automatically update the `includePath` and `defines` fields in 
`c_cpp_properties.json`.


# Architecture

## Rendering Pipeline

```
┌───────────────┐
│User App       │  Sets color values & color mode.
└───────┬───────┘
        │
┌───────▼───────┐  Transforms HSV/HSL data into RGB.
│led::renderer  │  Relays new data to the transcoder on each refresh interval.
└───────┬───────┘  Checks for configuration changes, saves them to Flash.
        │
┌───────▼───────┐  Calls the renderer on each refresh interval.
│led::thread    │  Tells the renderer to save its configuration periodically.
└───────┬───────┘  Double-buffers transcoded data.
        │
┌───────▼───────┐
│led::transcode │  Transforms RGB data into a hardware-compatible bitstream.
└───────┬───────┘
        │
┌───────▼───────┐
│led::transport │  Transmits bitstream to LEDs asynchronously.
└───────────────┘
```
