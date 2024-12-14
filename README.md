# My Personal Fedora Toolbox

[![CodeFactor](https://www.codefactor.io/repository/github/jim60105/toolbx/badge?style=for-the-badge)](https://www.codefactor.io/repository/github/jim60105/toolbx) [![GitHub Workflow Status (with event)](https://img.shields.io/github/actions/workflow/status/jim60105/toolbx/scan.yml?label=IMAGE%20SCAN&style=for-the-badge)](https://github.com/jim60105/toolbx/actions/workflows/scan.yml)

This is a Fedora Toolbox image with some additional tools installed.

Get the Containerfile at [GitHub](https://github.com/jim60105/toolbx), or pull the image from [ghcr.io](https://ghcr.io/jim60105/toolbx) or [quay.io](https://quay.io/repository/jim60105/toolbx?tab=tags).

## Setup

Following this guide to setup os keyring to use gnome-libsecret: <https://code.visualstudio.com/docs/editor/settings-sync#_recommended-configure-the-keyring-to-use-with-vs-code>

## Installed Tools

- Gnome Seahorse
- VSCode
- .NET SDK 8.0
- Git Credential Manager
- Sourcegit
- Fonts
  - Noto Sans CJK

## Usage Command

1. Make sure you have the toolbox installed

   ```bash
   sudo dnf install toolbox
   ```

2. Create the toolbox container

   ```bash
   toolbox create -i ghcr.io/jim60105/toolbx -c fedora-toolbox-41
   ```

3. Start the toolbox container

   ```bash
    toolbox enter -c fedora-toolbox-41
    ```

4. Or, execute the application directly

   ```bash
   toolbox run code
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
