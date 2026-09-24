# Tyberian distribution changes

## Files added

- `IMPLEMENTATION_PLAN.md` — repository analysis and low-divergence design.
- `flutter/lib/tyberian/distribution_config.dart` — compile-time branding/server values
  and secret/config validation.
- `flutter/lib/tyberian/quick_support_page.dart` — incoming-only credential, status,
  permissions, and AGPL/RustDesk attribution UI.
- `build-tyberian.ps1` — reproducible branded Windows portable build.
- `BUILD-TYBERIAN.md` — dependencies, build/configuration, validation, and update guide.
- `TYBERIAN_CHANGES.md` — this merge inventory.

## Upstream files modified

- `flutter/lib/main.dart` — validate/apply the branded public server settings before
  service startup and select the branded application/window title.
- `flutter/lib/common.dart` — reject calls through the central outbound-session API
  when QuickSupport mode is compiled in.
- `flutter/lib/desktop/pages/desktop_tab_page.dart` — select the dedicated support page
  instead of the standard home/outbound UI in QuickSupport builds.
- `flutter/lib/desktop/widgets/tabbar_widget.dart` — make the main-window close action
  terminate the portable QuickSupport process instead of leaving support running hidden.
- `flutter/windows/CMakeLists.txt` — choose the branded executable name only when the
  Tyberian build environment flag is present.
- `flutter/windows/runner/CMakeLists.txt` and `Runner.rc` — select branded Windows
  version-resource metadata while retaining the upstream copyright notice.
- `build.py` — forward optional Flutter build arguments and teach the existing Windows
  portable packager the conditional executable/output name.

No RustDesk license, copyright, translation, protocol, authentication, encryption,
incoming connection, or permission-enforcement implementation was removed or weakened.
No `hbb_common` submodule change is required.

## Merge/rebase considerations

- Keep QuickSupport-specific Dart implementation in `flutter/lib/tyberian`; do not fold
  the normal home UI into it.
- If `connect` moves, retain its early QuickSupport rejection before ID parsing or any
  native window/session creation.
- If main initialization changes, keep server-option application after FFI initialization
  but before `mainCheckConnectStatus` and `startService`.
- If Windows packaging paths change, update both `flutter_build_dir_2` use in `build.py`
  and the PowerShell output assertion.
- Recheck `ServerModel.connectStatus` meanings and incoming `Client` lifecycle after
  upstream connection-manager changes.

## Regression surface

- **Normal desktop/mobile/web builds:** compile-time mode defaults to false, so the
  existing pages, titles, server settings, and outbound connection implementation run.
- **All Flutter calls to `connect`:** only branded QuickSupport builds now return before
  session creation. This guard is necessary to make hidden outbound functionality inert.
- **QuickSupport main startup:** explicitly overwrites only the public rendezvous, relay,
  and public-key options before starting service. This is necessary to prevent recipients
  redirecting the distribution through its UI.
- **QuickSupport main-window close:** exits rather than hiding in the tray, ensuring the
  portable attended-support endpoint is unavailable after the recipient closes it.
- **Windows portable packaging:** behavior changes only while
  `TYBERIAN_QUICK_SUPPORT=1`; normal filenames and resources remain on the old branch.
