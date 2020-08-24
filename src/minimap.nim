import os, tables, strutils
import neverwinter/[erf, gff, key, resfile, resman]
import regex
#import magickwand

proc readTileTable(tileset: string): Table[int, string] =
  var currentTileNr = 0
  for l in tileset.splitLines:
    if l.match(re"\[TILE\d+\]"):
      currentTileNr = l[5 .. ^2].parseInt
    elif l.startsWith("ImageMap2D="):
      result[currentTileNr] = l[11 .. ^1].toLowerAscii

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
        echo "Error: Tileset not found: " & tileset
      let tt = rm.demand(tilesetResRef).readAll.readTileTable

#genesis()
main()
#terminus()
