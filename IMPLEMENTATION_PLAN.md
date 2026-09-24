# Tyberian Remote Support implementation plan

## Repository findings

- The native Rust client, rendezvous registration, incoming connection handling, and
  permission enforcement live under `src/`; shared client configuration keys live in
  `libs/base/src/config/keys.rs` while the persisted `Config` implementation remains in
  the `hbb_common` submodule.
- The current desktop UI is Flutter. Its main window is assembled by
  `flutter/lib/desktop/pages/desktop_tab_page.dart`, credentials and connection state
  are maintained by `flutter/lib/models/server_model.dart`, and outbound sessions pass
  through `connect` in `flutter/lib/common.dart`.
- Windows executable naming and metadata are in `flutter/windows/CMakeLists.txt` and
  `flutter/windows/runner/Runner.rc`; the icon is
  `flutter/windows/runner/resources/app_icon.ico`.
- Translations are sourced from `src/lang`. The branded view will use isolated English
  distribution strings rather than modifying every upstream translation catalog.

## Approach

1. Add one Dart compile-time distribution configuration module. Flutter `--dart-define`
   values will control QuickSupport mode, branding, support/source links, and the
   public self-hosted server settings. No private-key input will exist.
2. Add a dedicated desktop QuickSupport page that consumes the existing `ServerModel`
   ID, temporary password, rendezvous state, and incoming-client state. Select it only
   in QuickSupport builds; leave the upstream home page untouched otherwise.
3. Apply the public server settings before the existing service starts and reject all
   calls through Flutter's central outbound `connect` API in QuickSupport mode.
4. Parameterize only the Windows executable name and version-resource branding through
   CMake cache variables, retaining RustDesk copyright and AGPL attribution in the UI.
5. Add a PowerShell build wrapper and documentation. The wrapper will generate the
   branded icon only when an explicit replacement is supplied, build the existing Rust
   library and Flutter runner, and stage `TyberianRemoteSupport.exe` with its required
   runtime files as a portable directory.

This keeps normal builds on their existing paths and confines distribution-specific
logic to new files plus small selection/configuration guards in upstream entry points.
