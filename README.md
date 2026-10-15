# Unreal Skin Browser

Formerly **Better Skin Browser**. Search, favorite, preview, and select your installed Unreal Tournament 2004 characters from an in-game **Skins** tab.

Created by **Blue Natto**, known as **CissiaLikesEggs** on GameBanana. Published on GitHub under **NitrogenSulfide**.

**[Download v1.4](https://github.com/NitrogenSulfide/unreal-skin-browser/releases/tag/v1.4)** | **[GameBanana page and screenshots](https://gamebanana.com/mods/714077)** | **[Report a bug](https://github.com/NitrogenSulfide/unreal-skin-browser/issues)**

Players should download `BetterSkinBrowser-v1.4.zip` from the release assets. It is the same file as the download on [GameBanana](https://gamebanana.com/mods/714077). GitHub's automatic source archives are for developers.

## Features

- Search with any words in any order across name, race, sex, mesh, and skin texture package, with a one-click clear button.
- Keyboard navigation: Search is ready when the browser opens, arrows and paging browse skins, and Ctrl+Enter, Ctrl+D, and Ctrl+F apply, favorite, and return to Search. A Shortcuts button lists them.
- Favorites, Recent (the last twelve skins you equipped), and All skins views, saved locally and shared between the menu and the in-match tab.
- A portrait Grid layout as well as the list, remembered between sessions.
- Hide broken skins (on by default) hides installed skins whose model cannot load.
- A dice button previews a random skin from the current view.
- Sorting, plus grouping by race or family/package with gold category headings.
- Interactive 3D and portrait previews, including normal, red-team, and blue-team materials with team-colored buttons.
- Rotation, panning, zoom, animation and voice-line previews.
- Voice-pack selection synchronized with UT2004 Player Settings, plus a Default button.
- Apply a character and voice together; the character appears on your next respawn.
- Layout designed for 1920x1080 through 3840x2160, with a Credits window.

No character packs are included. Custom skins and voices must be installed separately.

## Install and use

1. Close UT2004 and extract the release ZIP into its installation directory. Upgrading from Better Skin Browser? Overwrite the existing files; your favorites and server settings carry over because the package keeps the `BetterSkinBrowser` name.
2. In Instant Action, add **Unreal Skin Browser** from the Mutators tab.
3. Start a match, press **ESC**, and open **Skins**.

You can also open it through **Configure Mutators** without enabling it for a match. With the mutator active, the console command `mutate skinbrowser` opens the standalone browser.

## Compatibility and limitations

Version 1.4 was tested with native OldUnreal UT2004 build 3374 in Instant Action and with automated native checks of the menu adapters and interface at 1920x1080, 2560x1440, and 3840x2160. Its network Apply path is unchanged from 1.2, which was tested in listen-server and separate dedicated-server/client sessions. Classic retail 3369 is expected to work but was not officially tested for this release.

Online servers must install the package and enable the mutator; installing it only on a client does not add the tab to arbitrary servers. Remote servers retain the stock ten-second character-change cooldown; in network play Apply shows a clear request message and a countdown.

Custom replacement ESC menus keep their existing interface; use the console fallback when the mutator is active. Incomplete character packs can have missing previews or voice lines. Advanced filters beyond search, sorting, grouping, Favorites, and Recent are not included yet. The first broken-skin check loads every character model once, which can cause a brief pause.

See [the player README](release/README.txt) for full usage and uninstall instructions and [the changelog](CHANGELOG.md) for release history.

## Build from source

The UnrealScript source is in `BetterSkinBrowser/Classes/`. You need your own native OldUnreal UT2004 installation and compiler; game assets are not included. Builds use a separate temporary tree and write outputs to ignored `dist/` directories. They do not install the result into the live game.

On Linux, with Python 3:

```bash
export UT2004_GAME_DIR="/path/to/native/OldUnreal/UT2004"
export UT2004_CONFIG_DIR="/path/to/writable/UT2004/System"
export UT2004_UCC="$UT2004_GAME_DIR/System/UCC"
bash build.sh
```

On Windows, with PowerShell:

```powershell
.\build.ps1 -GameDir 'C:\path\to\OldUnreal\UT2004' -ConfigDir 'C:\path\to\writable\System'
```

Both entry points compile and round-trip export the classes, then create `dist/BetterSkinBrowser-v1.4.zip` and checksums. Rebuilt packages may differ from the published ZIP because Unreal packages and ZIPs can contain build-specific metadata. Use the published asset for the exact GitHub and GameBanana release.

## Bugs and contributions

Please include your UT2004 build, operating system, game type, whether the match is local or on a remote server, reproduction steps, and relevant log excerpts. Remove personal information from logs before sharing. The issue tracker is for Unreal Skin Browser; character packs have their own authors.

This repository is the public release source. Future releases should use the same version and player ZIP on GitHub and GameBanana.

## License

MIT; see [LICENSE](LICENSE). The existing copyright credit to CissiaLikesEggs is preserved. Third-party game and character assets remain subject to their own terms.
