# Building Tyberian Remote Support for Windows

Tyberian Remote Support is an attended, incoming-only distribution of RustDesk.
It does not install a service or configure unattended access during this build.
The generated portable executable contains the normal RustDesk helper behavior;
Windows elevation may still be requested by RustDesk when a user explicitly needs
control of elevated applications or secure desktops.

## Prerequisites

Use a 64-bit Windows 10/11 build host with:

- Git (including submodules), Python 3, PowerShell 5.1 or newer, CMake, NASM,
  LLVM/Clang, and Visual Studio 2022 with **Desktop development with C++**.
- The Rust toolchain selected by this repository (`rust-toolchain.toml`, when
  present) plus the MSVC target. Do not substitute a newer nightly without testing.
- Flutter 3.24.5 on `PATH` for the supported x64 build, with Windows desktop
  enabled (`flutter config --enable-windows-desktop`).
- `vcpkg` and `VCPKG_ROOT`, with the dependency set pinned by `vcpkg.json`.
  Bootstrap vcpkg, then run `vcpkg install --triplet x64-windows-static` from
  the repository root. The manifest supplies codecs and native dependencies.
- The repository submodules: `git submodule update --init --recursive`.

See the Windows job in `.github/workflows/flutter-build.yml` for the authoritative
CI tool versions and additional architecture-specific environment variables.

## Build

From a **Developer PowerShell for VS 2022** at the repository root:

```powershell
.\build-tyberian.ps1 `
    -IdServer "remote.tyberian.com" `
    -ServerKey "PUBLIC_SERVER_KEY_HERE" `
    -SourceCodeUrl "https://github.com/OWNER/REPOSITORY"
```

The exact default build command is:

```powershell
.\build-tyberian.ps1
```

`SERVER_PUBLIC_KEY` is the RustDesk server's public key. The script has no private-key
parameter and rejects a `SERVER_PRIVATE_KEY` environment variable. An empty
`-RelayServer` leaves relay choice automatic. Optional parameters include
`-ProductName`, `-CompanyName`, `-SupportUrl`, `-SupportEmail`, `-SourceCodeUrl`,
and `-Icon` (a Windows multi-resolution `.ico`).

The result is `TyberianRemoteSupport.exe` in the repository root. It is the existing
RustDesk portable package: users can run it directly without installation. Build
intermediates remain under `target/release` and `flutter/build/windows`.

## Build configuration

The script enables `QUICK_SUPPORT_MODE=true` using Flutter compile-time defines and
sets `TYBERIAN_QUICK_SUPPORT=1` for CMake metadata/naming. Configuration is centralized
in `flutter/lib/tyberian/distribution_config.dart`:

| Define | Default |
| --- | --- |
| `PRODUCT_NAME` | `Tyberian Remote Support` |
| `COMPANY_NAME` | `Tyberian` |
| `SUPPORT_URL` | `https://remote.tyberian.com` |
| `SUPPORT_EMAIL` | blank |
| `SOURCE_CODE_URL` | upstream RustDesk repository |
| `ID_SERVER` | `remote.tyberian.com` |
| `RELAY_SERVER` | blank/automatic |
| `SERVER_PUBLIC_KEY` | blank (supply for a keyed server) |

The server options and temporary-password verification mode are applied before the
RustDesk service starts. They are deliberately absent from the recipient UI. Normal builds that omit `QUICK_SUPPORT_MODE` use the
unchanged RustDesk home screen and outbound connection path.

## Branding assets

Pass `-Icon C:\path\to\tyberian.ico` to temporarily replace the Windows runner icon
during compilation; the upstream file is restored even if the build fails. The in-app
logo is the isolated mark in `quick_support_page.dart`. Replace that widget if a final
brand asset is supplied. Do not remove `LICENCE`, source links, RustDesk attribution,
or dependency notices.

## Validation still required on Windows

On a test machine and a normal RustDesk technician client configured for the same
server, verify launch without installation, ID registration, public-key validation,
temporary-password authentication, accept/reject prompts, input/audio/clipboard/file
permissions, UAC behavior, connected-state indication, and that closing the portable
application stops registration. Also test a standard `python build.py --flutter` build
to confirm upstream behavior remains available.

## Updating from upstream

1. Commit or stash local work and fetch the upstream remote.
2. Rebase the distribution branch onto the selected upstream tag/branch.
3. Resolve the few hooks listed in `TYBERIAN_CHANGES.md`; prefer keeping new Tyberian
   files intact and reapplying only the small conditional blocks.
4. Update submodules, dependencies, and generated bridge files exactly as upstream
   requires.
5. Build both the standard client and this distribution and repeat the validation list.

The full corresponding source, build instructions, and modifications must be offered
to users as required by GNU AGPL v3. This document is operational guidance, not legal
advice.
