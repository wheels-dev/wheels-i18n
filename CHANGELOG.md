# Changelog

All notable changes to this package will be documented in this file.

## [2.0.0] — 2026-04-24

### Breaking — converted to Wheels 4.0 package format

The 3.x plugin format is no longer supported. Wheels 4.0 introduced a new package
system ([#2231](https://github.com/wheels-dev/wheels/issues/2231)) that replaces
`plugins/` with `vendor/`, requires a `package.json` manifest, and demands explicit
mixin-target declarations. This release converts `wheels-i18n` to that format.

### Added
- `package.json` manifest declaring `wheelsVersion: ">=4.0"` and
  `provides.mixins: "controller"`. The `controller` target covers both
  controllers and views (Wheels views execute in the controller's
  variables scope).
- `tests/I18nSpec.cfc` WheelsTest BDD suite covering `LocalizationService`
  JSON loading, nested-key flattening, pluralization, caching, and missing-key
  handling, plus fixture locales at `tests/_fixtures/locales/{en,es}/common.json`.
- `CHANGELOG.md` (this file).

### Changed
- Renamed main CFC `i18n.cfc` → `I18n.cfc` (PascalCase, matching other
  first-party packages like `wheels-sentry`).
- Changed `mixin` attribute from `"global"` to `"controller"` — the 3.x default
  of injecting everywhere is no longer a 4.0 default and would be over-broad.
- Updated internal service path from `"plugins.I18n.lib.LocalizationService"` to
  `"vendor.wheels-i18n.lib.LocalizationService"`.
- Bumped `this.version` to `"2.0.0"`.
- Rewrote the installation section of `README.md` to document
  `wheels packages add wheels-i18n` (was `wheels plugin install wheels-i18n`).

### Removed
- `box.json` (CommandBox / ForgeBox manifest — replaced by `package.json`).
- `index.cfm` (3.x plugin homepage — 4.0 has no equivalent, and the file
  was documentation rather than runtime bootstrap).
- `scripts/build-i18n.sh`, `scripts/prepare-i18n.sh`,
  `scripts/publish-to-forgebox.sh` — ForgeBox is not used in 4.0; distribution
  is handled by the `wheels-dev/wheels-packages` registry.
- `assets/translation-via-json.mp4`, `assets/translation-via-database.mp4`
  — `.mp4` is not on the `wheels-packages` registry file-type allowlist
  (`.cfc`, `.cfm`, `.md`, `.json`, `.js`, `.css`, `.sql`, `.yml`, etc.), so
  keeping the videos in the tarball would block the mirror CI. Videos can be
  re-attached as GitHub release assets on the `v2.0.0` release without
  re-entering the tarball.

### Migration
All user-visible APIs (`t()`, `tp()`, `currentLocale()`, `changeLocale()`,
`availableLocales()`) and configuration settings (`i18n_defaultLocale`,
`i18n_translationSource`, etc.) are unchanged. Existing `app/locales/*.json`
files and database translations continue to work without modification. To
upgrade, delete `plugins/i18n/` and run `wheels packages add wheels-i18n`.

## [1.0.0] — earlier

Initial release as a Wheels 3.x plugin. See pre-2.0.0 git history for details.
