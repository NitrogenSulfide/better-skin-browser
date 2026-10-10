# Unreal Skin Browser 1.2

Better Skin Browser is now Unreal Skin Browser. Package, class, favorites, and
server mutator names stay `BetterSkinBrowser`, so existing installs upgrade in
place.

- Search now matches every word in any order, ignoring case, across name, race,
  sex, mesh/model, and BodySkin/FaceSkin texture packages.
- Added an x button that clears search while keeping the view, sort, grouping,
  and visible selection.
- Race and Family / package groups now use centered gold headings with gold
  rules.
- Added a gold Unreal Skin Browser title centered under the menu caption at any
  resolution, and aligned the list and preview panels.
- Added a Credits button and credits window.
- Network Apply now says `Change requested - respawn to apply` and disables
  Apply during the known ten-second window with `Wait N s before changing skin`.
  The server's stock cooldown is unchanged.
- Instant Action keeps its confirmation sound, `Skin active - respawn to apply`
  message, and use on the very next respawn.

# Better Skin Browser 1.1

- Added persistent local favorites, gold row stars, and a Favorites view.
- Kept search, sorting, and grouping available in both browsing views.
- Preserved preview state when bookmarking in All skins.
- Selected the next neighbor when removing a visible favorite.

# Better Skin Browser 1.0

The first stable release makes the browser easier to read at modern
resolutions, expands voice selection, and fixes the Instant Action Apply flow.

- Added slate-blue card frames around the character list and preview controls.
- Made labels and status text fit cleanly from 1920x1080 through 3840x2160.
- Added a red row with white text for the currently equipped character.
- Corrected portrait proportions and disabled model-only controls in portrait
  mode.
- Changed the confirmation to `Skin active - respawn to apply`.
- Fixed Instant Action so an applied skin appears on the very next respawn.
- Fixed custom voice packs being reset to the character's assigned voice at
  match start and after respawning.
- Added a voice-pack selector synchronized with UT2004 Player Settings; the
  preview-line selector now follows the chosen pack.
- Added a compact Default button for restoring the selected skin's assigned
  voice without reopening the list.
- Validated the browser with a separate native OldUnreal dedicated server and
  client.

Remote servers retain UT2004's stock ten-second character-change cooldown.
