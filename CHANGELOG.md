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
