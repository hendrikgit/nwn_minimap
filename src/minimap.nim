import colors, os, tables, sequtils, strutils
import neverwinter/[erf, gff, key, resfile, resman]
import regex
import nimtga

type
  Tile = tuple
    id, orientation: int

proc readTileTable(tileset: string): Table[int, string] =
  var currentTileNr = 0
  for l in tileset.splitLines:
    if l.match(re"\[TILE\d+\]"):
      currentTileNr = l[5 .. ^2].parseInt
    elif l.startsWith("ImageMap2D="):
      result[currentTileNr] = l[11 .. ^1].toLowerAscii

proc generateMap(rm: ResMan, tiles: seq[Tile], width, height: int, tt: Table[int, string], tileset, filename: string) =
  var
    errorTga = initTga(16, 16, color = colRed)
    minSize = int.high
    map = newSeq[seq[Tga]]()
  for h in 0 ..< height:
    var row = newSeq[Tga]()
    var tileTga: Tga
    for w in 0 ..< width:
      let t = tiles[h * width + w]
      if t.id in tt:
        let tgaName = tt[t.id]
        if tgaName.len > 0:
          let tgaResRef = newResRef(tgaName, "tga".getResType)
          if rm.contains(tgaResRef):
            let tgaData = rm.demand(tgaResRef).readAll
            try:
              tileTga = tgaData.readTga
            except:
              echo "Error: " & filename & ": " & tileset & ": could not read tga: " & tgaName
              echo "The tga file might be empty if it is from the nwserver key/bif or in an unsupported format."
              tileTga = errorTga
            if t.orientation == 1: tileTga = tileTga.rotate90cw.rotate90cw.rotate90cw
            elif t.orientation == 2: tileTga = tileTga.rotate90cw.rotate90cw
            elif t.orientation == 3: tileTga = tileTga.rotate90cw
          else:
            echo "Warning: " & filename & ": " & tileset & ": tga not found: " & tgaName
            tileTga = errorTga
        else:
          echo "Warning: " & filename & ": " & tileset & ": No tga (ImageMap2D entry) found for tile: " & $t.id
          tileTga = errorTga
      else:
        echo "Warning: " & filename & ": " & tileset & ": tile not found: " & $t.id
        tileTga = errorTga
      if tileTga.width < minSize:
        minSize = tileTga.width
      row &= tileTga
    map &= row
  for row in map.mitems:
    for tileTga in row.mitems:
      if tileTga.width > minSize:
        tileTga = tileTga.scale(minSize, minSize)
  let rowTgas = map.mapIt(it[0].concatR(it[1 .. it.high]))
  let mapTga = rowTgas[0].concatB(rowTgas[1 .. rowTgas.high])
  try:
    mapTga.write(filename & ".tga")
    echo "File written: " & filename & ".tga"
  except:
    echo "Error: Could not write image: " & filename & ".tga"

if paramCount() == 0:
  echo """As parameters please provide paths to files of type are, hak, mod or key.
Add nwn_base.key and your tilest haks or the output maps won't be complete (showing red tiles)."""

let rm = newResMan()
# load key/bif first, then mod, hak, single are files
for p in commandLineParams().filterIt it.endsWith(".key"):
  let dir = p.splitFile.dir
  rm.add p.openFileStream.readKeyTable(label = p, proc (fn: string): Stream =
    joinPath(dir, fn.splitPath.tail).openFileStream
  )
for p in commandLineParams().filterIt it.endsWith(".mod"):
  rm.add p.openFileStream.readErf(p)
for p in commandLineParams().filterIt it.endsWith(".hak"):
  rm.add p.openFileStream.readErf(p)
for p in commandLineParams().filterIt it.endsWith(".are"):
  rm.add newResFile(p)

for c in rm.contents:
  if $c.resType == "are":
    let
      are = rm.demand(c).readAll.newStringStream.readGffRoot
      width = are["Width", GffInt].int
      height = are["Height", GffInt].int
      tileset = $are["Tileset", GffResRef]
      tilesetResRef = newResRef(tileset, "set".getResType)
    if not rm.contains(tilesetResRef):
      echo "Warning: " & $c & ": Tileset not found: " & tileset
      continue
    let tt = rm.demand(tilesetResRef).readAll.readTileTable
    let tiles = are["Tile_List", GffList]
      .mapIt (it.get("Tile_ID", GffInt).int, it.get("Tile_Orientation", GffInt).int)
    generateMap(rm, tiles, width, height, tt, tileset, c.resRef)
