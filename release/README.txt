UNREAL SKIN BROWSER 1.2
=======================

Unreal Skin Browser adds a searchable Skins tab to supported UT2004 in-match
ESC menus. It browses the same installed character records used by UT2004's
built-in Player Settings screen; it does not contain or duplicate any skins.

Formerly Better Skin Browser. The package files keep the BetterSkinBrowser
name, so existing favorites and server mutator settings keep working.

FEATURES
--------

- Persistent local favorites with All skins and Favorites views
- Every search word matches in any order across name, race, sex, mesh/model,
  or BodySkin/FaceSkin texture packages (case-insensitive)
- An x button clears search without changing view, sort, grouping, or a visible selection
- Sorting and grouping by name, race, family/package, or sex, with centered
  gold category headings
- A gold Unreal Skin Browser title centered under the menu caption
- A Credits button with a small credits window
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
5. Open Instant Action, select the Mutators tab, and add Unreal Skin Browser.
6. Start a match, press ESC, and select the Skins tab.

The browser can also be opened from Configure Mutators without enabling it for
a match. When the mutator is active, the console fallback is:

   mutate skinbrowser

USAGE
-----

- Select a character from the list to preview it.
- Add favorite / Remove favorite bookmarks the previewed character immediately.
- All skins and Favorites above Search use the same search, sort, and grouping.
- Gold stars identify favorites independently of the red equipped-skin row.
- Favorites are saved locally in BetterSkinBrowser.ini and shared between the
  standalone browser and the in-match tab. Uninstalled skins retain bookmarks.
- Removing a visible favorite selects its next neighbor, or the previous one
  at the end. Favorites never equip a skin or change the player's voice.
- Drag the model to rotate it.
- Hold Shift while dragging, or right-drag, to pan.
- Use the mouse wheel to zoom.
- Choose Character default to use the selected skin's assigned voice, or choose
  another compatible installed voice pack.
- The Default button selects Character default without reopening the list.
- Use Apply to save the selected character and chosen voice together.
- Instant Action confirms "Skin active - respawn to apply" with the usual sound
  and uses the character on the very next respawn. Apply does not force respawn.
- Network play shows "Change requested - respawn to apply". Apply is disabled
  during the known ten-second window and shows "Wait N s before changing skin".
  The server remains authoritative; the stock request has no acknowledgement.
- Portrait mode disables controls that only affect the 3D model.

MULTIPLAYER
-----------

Listen-server play has been tested. For a remote multiplayer server, the
server must install this package and enable the Unreal Skin Browser mutator so
clients can receive and use the matching menu classes. Installing the package
only on a client does not add the Skins tab to arbitrary online servers.

Version 1.0 was tested with a separate native dedicated server and client.
UT2004's stock remote character-change cooldown still applies. Its server
timestamp is not replicated; the browser tracks its own requests locally.
Changes from other menus, a recent join, and dropped requests cannot be
confirmed, so multiplayer feedback never claims server success.

KNOWN LIMITATIONS
-----------------

- Game types using a custom replacement in-match login menu do not receive the
  Skins tab. The console fallback remains available when the mutator is active.
- Custom characters still require their own mesh, texture, portrait, species,
  and voice files. Unreal Skin Browser does not distribute those assets.
- A missing or incomplete custom character may have unavailable preview
  materials, animations, or voice lines.
- Advanced filters beyond search, sorting, grouping, and Favorites are deferred.

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
BetterSkinBrowser-v1.2.zip release.

COPYRIGHT AND LICENSE
---------------------

Unreal Skin Browser code and documentation:
Copyright (c) 2026 CissiaLikesEggs

Licensed under the MIT License. See LICENSE.txt included with this release.

Unreal Skin Browser is an original independent mod by CissiaLikesEggs. It uses
UT2004's normal UnrealScript and GUI extension points and does not distribute
the game's original packages or assets.

Unreal Tournament 2004 and its original code, assets, names, and trademarks
belong to Epic Games and their respective owners. This independent mod is not
affiliated with or endorsed by Epic Games or OldUnreal.

VERSION HISTORY
---------------

1.2
- Renamed from Better Skin Browser to Unreal Skin Browser. Package, favorites,
  and server mutator names are unchanged.
- Added a gold title centered under the menu caption at any resolution and
  aligned the list and preview panels.
- Replaced white group separators with centered gold category headings.
- Added a Credits button and credits window.
- Added honest network Apply feedback and a ten-second request countdown.
- Preserved Instant Action confirmation, sound, and immediate next-respawn use.
- Added multi-word search in any order and skin texture-package matching.
- Added an x button that clears search while preserving browsing choices.

1.1
- Added persistent local favorites, gold row stars, and a Favorites view.
- Kept search, sorting, and grouping available in both browsing views.
- Preserved preview state when bookmarking in All skins.
- Added neighbor selection when removing visible favorites.
- Added white separators beneath Race and Family / package group headings.

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
