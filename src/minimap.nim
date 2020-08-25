import os, tables, sequtils, strutils
import neverwinter/[erf, gff, key, resfile, resman]
import regex
import magickwand

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

proc generateMap(rm: ResMan, tiles: seq[Tile], width, height: int, tt: Table[int, string], filename: string) =
  var map = newWand()
  var row = newWand()
  for h in 0 ..< height:
    row.setFormat("TGA") # otherwise tga blobs can not be recognized
    for w in 0 ..< width:
      let t = tiles[h * width + w]
      let tgaName = tt[t.id]
      if tgaName.len > 0:
        let tgaResRef = newResRef(tgaName, "tga".getResType)
        if rm.contains(tgaResRef):
          let tga = rm.demand(tgaResRef).readAll
          row.readImageBlob(tga)
          row.rotateImage(t.orientation * 90)
        else:
          echo "Warning: tga not found: " & tgaName
          row.readImage("canvas:red")
      else:
        echo "Warning: No tga (ImageMap2D entry) found for tile: " & $t.id
        row.readImage("canvas:red")
      if row.width < 16:
        row.resizeImage(16, 16)
    row.resetIterator
    row = row.appendImages
    map.addImage(row)
    row.clearWand
  map.resetIterator
  map = map.appendImages(true)
  map.setFormat("JPG")
  map.writeImage(filename & ".jpg")

proc main() =
  let rm = newResMan()
  for p in commandLineParams():
    let ext = p.splitFile.ext
    case ext
    of ".are":
      rm.add newResFile(p)
    of ".hak":
      rm.add p.openFileStream.readErf(p)
    of ".key":
      let dir = p.splitFile.dir
      rm.add p.openFileStream.readKeyTable(label = p, proc (fn: string): Stream =
        joinPath(dir, fn.splitPath.tail).openFileStream
      )

  for c in rm.contents:
    if $c.resType == "are":
      echo c
      let
        are = rm.demand(c).readAll.newStringStream.readGffRoot
        width = are["Width", GffInt].int
        height = are["Height", GffInt].int
        tileset = $are["Tileset", GffResRef]
        tilesetResRef = newResRef(tileset, "set".getResType)
      echo are["Name", GffCExoLocString]
      echo $width & "x" & $height
      echo tileset
      if not rm.contains(tilesetResRef):
        echo "Warning: Tileset not found: " & tileset
        continue
      let tt = rm.demand(tilesetResRef).readAll.readTileTable
      let tiles = are["Tile_List", GffList]
        .mapIt (it.get("Tile_ID", GffInt).int, it.get("Tile_Orientation", GffInt).int)
      generateMap(rm, tiles, width, height, tt, c.resRef)

genesis()
main()
terminus()
