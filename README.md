# My Personal Fedora Toolbox

[![CodeFactor](https://www.codefactor.io/repository/github/jim60105/toolbx/badge?style=for-the-badge)](https://www.codefactor.io/repository/github/jim60105/toolbx)

> [!NOTE]  
> toolbx is not a typo, check <https://containertoolbx.org/>

Toolbx is a tool for Linux, which allows the use of interactive command line environments for software development and troubleshooting the host operating system, without having to install software on the host. These are my personal Fedora toolbox images, which I use for development and daily usage.

Get the Containerfile at [GitHub](https://github.com/jim60105/toolbx), or pull the image from [ghcr.io](https://github.com/jim60105?tab=packages&repo_name=toolbx) or [quay.io](https://quay.io/search?q=jim60105%2Ftoolbx).

## base toolbox

This is the base toolbox image for all the other toolboxes.

> [!NOTE]  
> This base image includes many development dependencies, making it quite large.  
> Even though some tools don't use these dependencies, I still include them in the base image. For example, sourcegit toolbox doesn't need Java, and video toolbox doesn't require most of the development tools.  
> The reason for this design is that my computer always runs all toolboxes simultaneously on Fedora using Podman; in theory, there is no extra overhead when sharing base image layers.

```bash
toolbox create -i quay.io/jim60105/toolbx:latest fedora-toolbox-42
toolbox run sh -c 'cp /copy-to-host/* ~/.local/bin/'
```

- zsh
- Fonts
  - Noto Sans CJK
  - Noto Color Emoji
  - Cascadia Code
  - Hina Mincho
  - [Iansui 芫荽](https://github.com/ButTaiwan/iansui)
  - [Hack Nerd Font](https://github.com/ryanoasis/nerd-fonts)
- Gnome Seahorse (OS keyring)
- Git Credential Manager
- .NET SDK 8.0 and 9.0
- Java 21 (JetBrains loves this 😆)
- Node.js, npm, yarn
- aria2
- jq
- vim
- gh cli
- Development Tools (@development-tools @c-development openssl-devel cmake ninja-build pkg-config)

## [Sourcegit](https://github.com/sourcegit-scm/sourcegit) toolbox

```bash
toolbox create -i quay.io/jim60105/toolbx-sourcegit:latest sourcegit
toolbox run -c sourcegit cp /usr/share/icons/sourcegit.png ~/.local/share/icons/
toolbox run -c sourcegit cp /usr/share/applications/sourcegit.desktop ~/.local/share/applications/
toolbox run -c sourcegit sh -c 'cp /copy-to-host/* ~/.local/bin/'
```

## [VSCode Insiders](https://code.visualstudio.com/insiders/) toolbox

```bash
toolbox create -i quay.io/jim60105/toolbx-vscode:latest vscode
toolbox run -c vscode cp /usr/share/icons/vscode.png ~/.local/share/icons/
toolbox run -c vscode cp /usr/share/icons/vscode-insiders.png ~/.local/share/icons/
toolbox run -c vscode cp /usr/share/applications/code.desktop ~/.local/share/applications/
toolbox run -c vscode cp /usr/share/applications/code-url-handler.desktop ~/.local/share/applications/
toolbox run -c vscode cp /usr/share/applications/code-insiders.desktop ~/.local/share/applications/
toolbox run -c vscode cp /usr/share/applications/code-insiders-url-handler.desktop ~/.local/share/applications/
toolbox run -c vscode sh -c 'cp /copy-to-host/* ~/.local/bin/'
```

> [!NOTE]  
> The regular `code` command and desktop entries are bridged to VSCode Insiders for compatibility with other applications and XDG.

> [!IMPORTANT]  
> Following this guide to setup os keyring to use `gnome-libsecret`:  
> <https://code.visualstudio.com/docs/editor/settings-sync#_recommended-configure-the-keyring-to-use-with-vs-code>

## [RustRover](https://www.jetbrains.com/rust/) toolbox

```bash
toolbox create -i quay.io/jim60105/toolbx-rustrover:latest rustrover
toolbox run -c rustrover cp /usr/share/icons/rustrover.svg ~/.local/share/icons/
toolbox run -c rustrover cp /usr/share/applications/jetbrains-rustrover.desktop ~/.local/share/applications/
toolbox run -c rustrover sh -c 'cp /copy-to-host/* ~/.local/bin/'
```

## [Rider](https://www.jetbrains.com/rider/) toolbox

```bash
toolbox create -i quay.io/jim60105/toolbx-rider:latest rider
toolbox run -c rider cp /usr/share/icons/rider.svg ~/.local/share/icons/
toolbox run -c rider cp /usr/share/applications/jetbrains-rider.desktop ~/.local/share/applications/
toolbox run -c rider sh -c 'cp /copy-to-host/* ~/.local/bin/'
```

## [DataGrip](https://www.jetbrains.com/datagrip/) toolbox

```bash
toolbox create -i quay.io/jim60105/toolbx-datagrip:latest datagrip
toolbox run -c datagrip cp /usr/share/icons/datagrip.svg ~/.local/share/icons/
toolbox run -c datagrip cp /usr/share/applications/jetbrains-datagrip.desktop ~/.local/share/applications/
toolbox run -c datagrip sh -c 'cp /copy-to-host/* ~/.local/bin/'
```

## video toolbox

This toolbox is for video processing and mpv player.

```bash
toolbox create -i quay.io/jim60105/toolbx-video:latest video
toolbox run -c video cp /usr/share/icons/mpv.svg ~/.local/share/icons/
toolbox run -c video cp /usr/share/icons/obs.svg ~/.local/share/icons/
toolbox run -c video cp /usr/share/applications/mpv.desktop ~/.local/share/applications/
toolbox run -c video cp /usr/share/applications/obs.desktop ~/.local/share/applications/
toolbox run -c video sh -c 'cp /copy-to-host/* ~/.local/bin/'
```

- OBS Studio
- ImageMagick
- ExifTool
- yt-dlp
- ffmpeg
- [mpv](https://mpv.io/manual/stable/)
  - vapoursynth + mvtools + [motion interpolation (to 60fps)](https://gist.github.com/phiresky/4bfcfbbd05b3c2ed8645)
  - [uosc (Nice UI for mpv)](https://github.com/tomasklaen/uosc) + [thumbfast](https://github.com/po5/thumbfast)
  - [Anime4K](https://github.com/bloc97/Anime4K)

> [!NOTE]  
> Trigger mpv motion interpolation by pressing `b` key.

### Open youtube video in mpv

Execute this script on the youtube video page:

```javascript
(function() {
  function getYouTubeVideoId(url) {
    const regex = /(?:https?:\/\/)?(?:www\.)?youtu(?:\.be\/|be\.com\/(?:v\/|embed\/|watch\?v=|watch\?.+?&v=|live\/))((\w|-){11})(?:\S+)?/;
    const match = url.match(regex);
    
    return match ? match[1] : null;
  }

  function openInMPV(videoId) {
    window.open(`ytdl://${videoId}`, '_blank');
  }

  function stopVideo() {
    var video = document.querySelector('video');
    if (video) video.pause();
  }

  const url = window.location.href;
  const videoId = getYouTubeVideoId(url);

  if (!videoId) {
    console.log("Invalid YouTube URL");
    return;
  } 

  console.log(`The video ID is: ${videoId}`);

  openInMPV(videoId);

  stopVideo();
})();
```

> [!TIP]  
> I'm using [Enhancer for YouTube™](https://chromewebstore.google.com/detail/Enhancer%20for%20YouTube%E2%84%A2/ponfpcnoihfmfllpaingbgckeeldkhle) to run this script on the youtube page.  
> It provides a button so I don't have to implement it myself.

## Kubernetes toolbox

This toolbox is for kubernetes related tools.

```bash
toolbox create -i quay.io/jim60105/toolbx-kubernetes:latest kubernetes
toolbox run -c kubernetes cp /usr/share/icons/lens.png ~/.local/share/icons/
toolbox run -c kubernetes cp /usr/share/applications/open-lens.desktop ~/.local/share/applications/
toolbox run -c kubernetes sh -c 'cp /copy-to-host/* ~/.local/bin/'
```

- [OpenLens](https://github.com/MuhammedKalkan/OpenLens)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [helm](https://helm.sh/)
- [talosctl](https://www.talos.dev/v1.9/talos-guides/install/talosctl/)

## Toolbox cheat sheet

- Recreate all the toolboxes

  ```bash
  podman pull quay.io/jim60105/toolbx:latest \
              quay.io/jim60105/toolbx-vscode:latest \
              quay.io/jim60105/toolbx-rustrover:latest \
              quay.io/jim60105/toolbx-rider:latest \
              quay.io/jim60105/toolbx-datagrip:latest \
              quay.io/jim60105/toolbx-sourcegit:latest \
              quay.io/jim60105/toolbx-video:latest \
              quay.io/jim60105/toolbx-kubernetes:latest && \
  toolbox rm -af && \
  toolbox create -i quay.io/jim60105/toolbx:latest fedora-toolbox-42 && \
  toolbox create -i quay.io/jim60105/toolbx-vscode:latest vscode && \
  toolbox create -i quay.io/jim60105/toolbx-rustrover:latest rustrover && \
  toolbox create -i quay.io/jim60105/toolbx-rider:latest rider && \
  toolbox create -i quay.io/jim60105/toolbx-datagrip:latest datagrip && \
  toolbox create -i quay.io/jim60105/toolbx-sourcegit:latest sourcegit && \
  toolbox create -i quay.io/jim60105/toolbx-video:latest video && \
  toolbox create -i quay.io/jim60105/toolbx-kubernetes:latest kubernetes
  ```

- Recreate video toolbox

  ```bash
  podman pull quay.io/jim60105/toolbx-video:latest && \
  toolbox rm -f video && \
  toolbox create -i quay.io/jim60105/toolbx-video:latest video
  ```

> [!NOTE]
> The `toolbox create` command will always use the existing image.  
> Remember to manually run `podman pull` before recreating the toolbox!

## Troubleshooting

### Random freezes in VSCode/JetBrains IDE

Set `/etc/hosts` to include `toolbx` in localhost. [ref][1]

```hostname
# Loopback entries; do not change.
# For historical reasons, localhost precedes localhost.localdomain:
127.0.0.1   toolbx localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         toolbx localhost localhost.localdomain localhost6 localhost6.localdomain6
```

[1]: https://github.com/containers/toolbox/issues/1059#issuecomment-1135307025

## LICENSE

> [!CAUTION]
> A GPLv3 licensed Containerfile means that you _**MUST**_ **distribute the source code with the same license**, if you
>
> - Re-distribute the image. (You can simply point to this GitHub repository if you doesn't made any code changes.)
> - Distribute an image that uses code from this repository.
> - Or **distribute an image based on this image**. (`FROM ghcr.io/jim60105/toolbx` in your Containerfile)
>
> "Distribute" means to make the image available for other people to download, usually by pushing it to a public registry. If you are solely using it for your personal purposes, this has no impact on you.
>
> Please consult the [LICENSE](LICENSE) for more details.

<img src="https://github.com/user-attachments/assets/77148063-7bd8-4c07-a776-ec297d2f6ad8" alt="gplv3" width="300" />

[GNU GENERAL PUBLIC LICENSE Version 3](LICENSE)

Copyright (C) 2024 Jim Chen <Jim@ChenJ.im>.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
