# minimap
A standalone tool to generate map images of [Neverwinter Nights](https://www.beamdog.com/games/neverwinter-nights-enhanced/) areas. Written in [Nim](https://nim-lang.org/) and using the [neverwinter.nim](https://github.com/niv/neverwinter.nim) library.

The resulting map images will look like the minimap in game, the tool composes the tile images specified in the tileset.

## Binaries
Binaries are available under [Releases](https://github.com/hendrikgit/nwn_minimap/releases).

## Usage
Call the minimap binary and as parameters please provide paths to files of type are, hak, mod or key.
Add nwn_base.key (from your game client installation) and your tilest haks or the output maps won't be complete (showing red tiles).

Whenever there is an error a message with details will be shown but the program will continue and use a completly red image for the tile with the error.

For each area (.are) found, either given as a parameter directly or contained in a .mod, a TGA image will be written to the current working directory. The name of the TGA image will be that of the area (resref).
