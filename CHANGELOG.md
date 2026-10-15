# Unreal Skin Browser 1.4

- Fixed a faint ghost copy of the preview character, and its held weapon,
  showing through translucent parts of the browser outside the preview window.

# Unreal Skin Browser 1.3

- Keyboard navigation: Search is focused when the browser opens. Up/Down and
  Page Up/Down browse skins from Search or the list, Home/End jump to the first
  or last skin, and category headings are skipped. Enter moves from Search to
  the list or grid. Ctrl+Enter applies, Ctrl+D toggles the favorite, and Ctrl+F
  returns to Search.
- Added a Shortcuts button and keyboard shortcuts window.
- Added a Recent view of the last twelve skins you equipped, newest first.
  Sort and Group are disabled there.
- Added a portrait Grid layout with names, favorite stars, and equipped and
  preview frames. With grouping on, each category starts its own row under a
  gold heading. The choice is remembered and shared with the in-match tab.
- Added Hide broken skins, on by default, for installed skins whose model
  cannot be loaded. The result count shows how many are hidden, and the
  equipped skin always stays listed.
- Added a dice button that previews a random skin from the current view.
- Red and Blue preview buttons now use team colors, Credits is gold, the search
  x button lines up with the search field, and the preview controls have more
  room.
- Fixed the list scrollbar grip not dragging right after switching views.

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
