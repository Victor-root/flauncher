# FLauncher (fork)
#### This is a fork of the GitLab repository at: https://gitlab.com/flauncher/flauncher.

FLauncher is an open-source alternative launcher for Android TV, built with [Flutter](https://flutter.dev).

## Download
Get the latest build from the [releases](https://github.com/osrosal/flauncher/releases) page, you can look for older builds on the [actions](https://github.com/CocoCR300/flauncher/actions) tab, where they are uploaded as artifacts.

## Features
For a list of the changes introduced by this fork from the original, see the [CHANGELOG](CHANGELOG.md) file.

- [x] No ads
- [x] Customizable categories
- [x] Manually reorder apps within categories
- [x] Wallpaper support
- [x] Open "Android Settings"
- [x] Open "App info"
- [x] Uninstall app
- [x] Clock
- [x] Switch between row and grid for categories
- [x] Support for non-TV (sideloaded) apps
- [x] Navigation sound feedback
- [ ] Force stop app

## Screenshots
|  |  |  |
|--|--|--|
| ![](screenshots/Screenshot_1624378896.png) | ![](screenshots/Screenshot_1624378921.png) | ![](screenshots/Screenshot_1624378938.png) |

## Set FLauncher as default launcher

### Method 1: remap the Home button
This is the "safer" and easiest way. Use [Button Mapper](https://play.google.com/store/apps/details?id=flar2.homebutton) to remap the Home button of the remote to launch FLauncher.

### Method 2: disable the default launcher
**:warning: Disclaimer :warning:**

**You are doing this at your own risk, and you'll be responsible in any case of malfunction on your device.**

The stock launcher package name differs between devices, so the exact commands depend on your device. Once the default launcher is disabled, press the Home button on the remote, and you'll be prompted by the system to choose which app to set as default.

#### Find your launcher package

The easiest way is the built-in assistant: open FLauncher's settings, go to "Default launcher", and it detects your device's home launcher and shows the exact command to run. If Shizuku is set up on the device, that same screen can disable the launcher for you, without a computer.

To find the package manually from a computer:
```shell
$ adb shell cmd package resolve-activity --brief -c android.intent.category.HOME
```
This prints something like `com.google.android.tvlauncher/.MainActivity`; the part before the `/` is the package to disable.

#### Disable default launcher

On Nvidia Shield and classic Android TV devices, the stock launcher is usually `com.google.android.tvlauncher`:
```shell
$ adb shell pm disable-user --user 0 com.google.android.tvlauncher
```

On Chromecast with Google TV and other recent Google TV devices, it is `com.google.android.apps.tv.launcherx`, and `com.google.android.tungsten.setupwraith` will otherwise re-enable it, so disable both:
```shell
$ adb shell pm disable-user --user 0 com.google.android.apps.tv.launcherx
$ adb shell pm disable-user --user 0 com.google.android.tungsten.setupwraith
```

#### Re-enable default launcher

Run `pm enable` with the same package(s) you disabled. For example, on Nvidia Shield and classic Android TV:
```shell
$ adb shell pm enable com.google.android.tvlauncher
```
Or on Chromecast with Google TV and other recent Google TV devices:
```shell
$ adb shell pm enable com.google.android.apps.tv.launcherx
$ adb shell pm enable com.google.android.tungsten.setupwraith
```

#### Known issues
On Chromecast with Google TV (maybe others), the "YouTube" remote button will stop working if the default launcher is disabled. As a workaround, you can use [Button Mapper](https://play.google.com/store/apps/details?id=flar2.homebutton) to remap it correctly.

## Wallpaper
Because Android's `WallpaperManager` is not available on some Android TV devices, FLauncher implements its own wallpaper management method.

Please note that changing wallpaper requires a file explorer to be installed on the device in order to pick a file.

## Support the original author: [etienn01](https://github.com/etienn01)
<a href="https://www.buymeacoffee.com/etienn01" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" width="200"></a>
