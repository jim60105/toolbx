# My Personal Fedora Toolbox

[![CodeFactor](https://www.codefactor.io/repository/github/jim60105/toolbx/badge?style=for-the-badge)](https://www.codefactor.io/repository/github/jim60105/toolbx)

This is the Fedora Toolbox images with some additional tools installed.

> [!NOTE]  
> toolbx is not a typo, check <https://containertoolbx.org/>

Get the Containerfile at [GitHub](https://github.com/jim60105/toolbx), or pull the image from [ghcr.io](https://github.com/jim60105?tab=packages&repo_name=toolbx) or [quay.io](https://quay.io/repository/jim60105/toolbx).

## base toolbox

This image is for the basic of the other toolboxes.

```bash
toolbox create -i quay.io/jim60105/toolbx:latest fedora-toolbox-41
```

> [!IMPORTANT]  
> Following this guide to setup os keyring to use `gnome-libsecret`:  
> <https://code.visualstudio.com/docs/editor/settings-sync#_recommended-configure-the-keyring-to-use-with-vs-code>

- Fonts
  - Noto Sans CJK
  - Cascadia Code
  - [Iansui 芫荽](https://github.com/ButTaiwan/iansui)
  - Hina Mincho
- Gnome Seahorse (for os keyring)
- Git Credential Manager
- .NET SDK 8.0
- Rust
  - rustup
  - cargo

## sourcegit toolbox

```bash
toolbox create -i quay.io/jim60105/toolbx-sourcegit:latest sourcegit
```

- [**Sourcegit**](https://github.com/sourcegit-scm/sourcegit)

## vscode toolbox

```bash
toolbox create -i quay.io/jim60105/toolbx-vscode:latest vscode
```

- **VSCode**

## rustrover toolbox

```bash
toolbox create -i quay.io/jim60105/toolbx-rustrover:latest rustrover
```

- **RustRover**

## video toolbox

This image is for my video editing and video player.

```bash
toolbox create -i quay.io/jim60105/toolbx-video:latest video
```

> [!TIP]  
> Trigger mpv motion interpolation by pressing `b` key.

- yt-dlp
- ffmpeg
- mpv
  - vapoursynth + mvtools + [motion interpolation (to 60fps)](https://gist.github.com/phiresky/4bfcfbbd05b3c2ed8645)
  - [uosc (Nice UI for mpv)](https://github.com/tomasklaen/uosc) + [thumbfast](https://github.com/po5/thumbfast)
  - [mpv-opener](./video/mpv-opener.sh)  
    Execute this script on the youtube video page:

    ```javascript
    (function () {
        window.open(window.location.href.replace(/^https?:/, 'mpv:'), '_blank');
        var video = document.querySelector('video');
        if (video) {
            video.pause();
        }
    })();
    ```

## Toolbox cheat sheet

- Recreate all the toolboxes

  ```bash
  podman pull quay.io/jim60105/toolbx:latest \
              quay.io/jim60105/toolbx-vscode:latest \
              quay.io/jim60105/toolbx-rustrover:latest \
              quay.io/jim60105/toolbx-sourcegit:latest \
              quay.io/jim60105/toolbx-video:latest && \
  toolbox rm -af && \
  toolbox create -i quay.io/jim60105/toolbx:latest fedora-toolbox-41 && \
  toolbox create -i quay.io/jim60105/toolbx-vscode:latest vscode && \
  toolbox create -i quay.io/jim60105/toolbx-rustrover:latest rustrover && \
  toolbox create -i quay.io/jim60105/toolbx-sourcegit:latest sourcegit && \
  toolbox create -i quay.io/jim60105/toolbx-video:latest video
  ```

- Recreate video toolbox

  ```bash
  toolbox rm -f video && \
  toolbox create -i quay.io/jim60105/toolbx-video:latest video
  ```

## Troubleshooting

### Random freezes in VSCode/JetBrains IDE

Set `/etc/hosts` to include `toolbx` in localhost. [ref](https://github.com/containers/toolbox/issues/1059#issuecomment-1135307025)

```hostname
# Loopback entries; do not change.
# For historical reasons, localhost precedes localhost.localdomain:
127.0.0.1   toolbx localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         toolbx localhost localhost.localdomain localhost6 localhost6.localdomain6
```

## LICENSE

<img src="https://github.com/user-attachments/assets/77148063-7bd8-4c07-a776-ec297d2f6ad8" alt="gplv3" width="300" />

[GNU GENERAL PUBLIC LICENSE Version 3](LICENSE)

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

> [!CAUTION]
> A GPLv3 licensed Containerfile means that you _**MUST**_ **distribute the source code with the same license**, if you
>
> - Re-distribute the image. (You can simply point to this GitHub repository if you doesn't made any code changes.)
> - Distribute a image that uses code from this repository.
> - Or **distribute a image based on this image**. (`FROM ghcr.io/jim60105/toolbx` in your Containerfile)
>
> "Distribute" means to make the image available for other people to download, usually by pushing it to a public registry. If you are solely using it for your personal purposes, this has no impact on you.
>
> Please consult the [LICENSE](LICENSE) for more details.
