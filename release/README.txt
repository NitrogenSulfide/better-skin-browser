BETTER SKIN BROWSER 1.0
=======================

Better Skin Browser adds a searchable Skins tab to supported UT2004 in-match
ESC menus. It browses the same installed character records used by UT2004's
built-in Player Settings screen; it does not contain or duplicate any skins.

FEATURES
--------

- Live search by character name, race, sex, mesh, or package
- Sorting and grouping by name, race, family/package, or sex
- Interactive 3D model and portrait previews
- Normal, red-team, and blue-team material previews
- Mouse rotation, panning, zoom, reset, and automatic rotation
- A voice-pack selector synchronized with UT2004 Player Settings
- A one-click Default button for the selected character's assigned voice
- Animation and selected-voice-line previews
- Optional weapon-holding preview
- Character and matching voice selection through UT2004's normal settings
- Resolution-aware layout from 1920x1080 through 3840x2160
- A red and white marker for the currently equipped character

REQUIREMENTS AND TESTED CONFIGURATION
-------------------------------------

- Unreal Tournament 2004 build 3369, or OldUnreal UT2004 3374 or later
- Officially tested with OldUnreal UT2004 3374
- Tested in Instant Action, listen-server, and dedicated-server matches

The classic retail 3369 build is expected to work, but it has not been
officially tested for this release.

INSTALLATION
------------

1. Close UT2004.
2. Extract this ZIP into the UT2004 installation directory.
3. Confirm that these files are present:

   System/BetterSkinBrowser.u
   System/BetterSkinBrowser.int
   System/BetterSkinBrowser.ucl

4. Start UT2004.
5. Open Instant Action, select the Mutators tab, and add Better Skin Browser.
6. Start a match, press ESC, and select the Skins tab.

The browser can also be opened from Configure Mutators without enabling it for
a match. When the mutator is active, the console fallback is:

   mutate skinbrowser

USAGE
-----

- Select a character from the list to preview it.
- Drag the model to rotate it.
- Hold Shift while dragging, or right-drag, to pan.
- Use the mouse wheel to zoom.
- Choose Character default to use the selected skin's assigned voice, or choose
  another compatible installed voice pack.
- The Default button selects Character default without reopening the list.
- Use Apply to save the selected character and chosen voice together.
- The selected character appears on the next respawn. Apply does not force a
  suicide or immediate respawn.
- Portrait mode disables controls that only affect the 3D model.

MULTIPLAYER
-----------

Listen-server play has been tested. For a remote multiplayer server, the
server must install this package and enable the Better Skin Browser mutator so
clients can receive and use the matching menu classes. Installing the package
only on a client does not add the Skins tab to arbitrary online servers.

Version 1.0 was tested with a separate native dedicated server and client.
UT2004's stock remote character-change cooldown still applies, so wait ten
seconds after joining before applying a skin on a remote server.

KNOWN LIMITATIONS
-----------------

- Game types using a custom replacement in-match login menu do not receive the
  Skins tab. The console fallback remains available when the mutator is active.
- Custom characters still require their own mesh, texture, portrait, species,
  and voice files. Better Skin Browser does not distribute those assets.
- A missing or incomplete custom character may have unavailable preview
  materials, animations, or voice lines.
- Favorites and advanced filters are not included in version 1.0.

UNINSTALLATION
--------------

Close UT2004 and remove only these files from its System directory:

   BetterSkinBrowser.u
   BetterSkinBrowser.int
   BetterSkinBrowser.ucl

SOURCE CODE
-----------

"Source code" means the human-readable UnrealScript .uc files used to build
BetterSkinBrowser.u. Players do not need the source code to install or use the
mod. The compiled .u file is the version UT2004 loads.

GitHub automatically offers "Source code (zip)" and "Source code (tar.gz)"
downloads. Those are repository snapshots for developers who want to read or
build the code. Regular players should download the separately attached
BetterSkinBrowser-v1.0.zip release.

COPYRIGHT AND LICENSE
---------------------

Better Skin Browser code and documentation:
Copyright (c) 2026 CissiaLikesEggs

Licensed under the MIT License. See LICENSE.txt included with this release.

Better Skin Browser is an original independent mod by CissiaLikesEggs. It uses
UT2004's normal UnrealScript and GUI extension points and does not distribute
the game's original packages or assets.

Unreal Tournament 2004 and its original code, assets, names, and trademarks
belong to Epic Games and their respective owners. This independent mod is not
affiliated with or endorsed by Epic Games or OldUnreal.

VERSION HISTORY
---------------

1.0
- Added slate-blue card frames around the browser and preview sections.
- Made labels and status text fit from 1920x1080 through 3840x2160.
- Added a red row with white text for the currently equipped character.
- Corrected portrait aspect ratio and disabled model-only controls in portrait
  mode.
- Changed the Apply message to "Skin active - respawn to apply".
- Made Instant Action Apply take effect on the very next respawn.
- Preserved independently selected voice packs across match starts and respawns.
- Added a voice-pack selector synchronized with UT2004 Player Settings and made
  the existing voice-line preview follow that selection.
- Added a compact Default button beside the voice-pack selector.
- Validated the browser with a separate native dedicated server and client.

0.9 Beta
- Initial public beta release.
- Searchable installed-character browser and enhanced previews.
- Integrated Skins tab for supported live-match ESC menus.
