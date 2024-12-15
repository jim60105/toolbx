# My Personal Fedora Toolbox

[![CodeFactor](https://www.codefactor.io/repository/github/jim60105/toolbx/badge?style=for-the-badge)](https://www.codefactor.io/repository/github/jim60105/toolbx)

This is the Fedora Toolbox images with some additional tools installed.

> [!NOTE]  
> toolbx is not a typo, check <https://containertoolbx.org/>

Get the Containerfile at [GitHub](https://github.com/jim60105/toolbx), or pull the image from [ghcr.io](https://github.com/jim60105?tab=packages&repo_name=toolbx) or [quay.io](https://quay.io/repository/jim60105/fedora-toolbox-41).

## fedora toolbox

This image is for my main development environment. It contains the tools I use for my coding and development.

```bash
toolbox create -i quay.io/jim60105/toolbx:latest fedora-toolbox-41
```

> [!IMPORTANT]  
> Following this guide to setup os keyring to use `gnome-libsecret`:  
> <https://code.visualstudio.com/docs/editor/settings-sync#_recommended-configure-the-keyring-to-use-with-vs-code>

- Gnome Seahorse (for os keyring)
- Git Credential Manager
- .NET SDK 8.0
- Fonts
  - Noto Sans CJK
- [**Sourcegit**](https://github.com/sourcegit-scm/sourcegit)
- **VSCode**

## video toolbox

This image is for my video editing and video player.

```bash
toolbox create -i quay.io/jim60105/toolbx-video:latest vid
```

- Fonts
  - Noto Sans CJK
  - [Iansui 芫荽](https://github.com/ButTaiwan/iansui)
- mpv
  - vapoursynth + mvtools + [motion interpolation (to 60fps)](https://gist.github.com/phiresky/4bfcfbbd05b3c2ed8645)
  - [uosc (Nice UI for mpv)](https://github.com/tomasklaen/uosc)
- yt-dlp
- ffmpeg

## Toolbox cheat sheet

- Remove and recreate the main toolbox

  ```bash
  toolbox rm -f fedora-toolbox-41 && \
  toolbox create -i quay.io/jim60105/fedora-toolbox-41:latest fedora-toolbox-41
  ```

- Remove all toolboxes

  ```bash
  toolbox rm -a
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
