import os
import neverwinter/[erf, gff, key, resfile, resman]
#import magickwand

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
        tileset = are["Tileset", GffResRef]
      echo are["Name", GffCExoLocString]
      echo $width & "x" & $height
      echo tileset

#genesis()
main()
#terminus()
