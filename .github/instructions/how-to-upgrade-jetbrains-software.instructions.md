---
applyTo: 'rider*,datagrip*,rustrover*'
---
When upgrading JetBrains software, follow these steps:

1. **Check for Updates**: Get the latest version from the JetBrains website.

Use the following command to get the latest version:
```bash
curl -s -I "https://data.services.jetbrains.com/products/download?code=RD&platform=linux" | grep -i location
```
> Note: Change the `code=RD` to `code=DG` or `code=RR` for DataGrip or RustRover respectively.

2. **Carefully check if the version number is the same**: The version number in our container file may not match the version number on the JetBrains website. If the version number is the same, you can skip the next step. If the version number is different, proceed to the next step.

Jetbrains Containerfiles:
- #rider.Containerfile
- #datagrip.Containerfile
- #rustrover.Containerfile

3. **Update the version number in our Containerfile**: Open the Containerfiles and update the version number in the `ARG {{SOFTWARE}}_VERSION={{version}}` line. For example, change `ARG RUSTROVER_VERSION=2024.3.7` to `ARG RUSTROVER_VERSION=2025.1`.`

After that, DO NOT BUILD THE CONTAINER.

3. **Git Commit**: Commit the changes to the Containerfiles. 

Check the changes with `git status` and `git --no-pager diff` to see the changes.

Use the following commit message:

```
chore: bump Rider to 2024.3.7

Signed-off-by: CHEN, CHUN <jim60105@gmail.com>
```
> Note: The version number in the commit message should match the version number in the Containerfile.
> Write the software name in the commit title. Or write `bump Jetbrains to 2024.3.7` if you are updating multiple JetBrains software.

Let's do this step by step.
