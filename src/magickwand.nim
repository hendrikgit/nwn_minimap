type
  MagickWand {.importc: "struct MagickWand".} = object

  Wand* = object
    impl: ptr MagickWand

{.push dynlib: "libMagickWand-6.Q16.so".}
proc genesis*() {.importc: "MagickWandGenesis".}

proc terminus*() {.importc: "MagickWandTerminus".}

proc newMagickWand(): ptr MagickWand {.importc: "NewMagickWand".}

proc destroyMagickWand(wand: ptr MagickWand): ptr MagickWand {.importc: "DestroyMagickWand", discardable.}

proc magickReadImage(wand: ptr MagickWand, filename: cstring): bool {.importc: "MagickReadImage".}

proc magickWriteImage(wand: ptr MagickWand, filename: cstring): bool {.importc: "MagickWriteImage".}
{.pop.}

proc newWand*(): Wand =
  result.impl = newMagickWand()

proc `=destroy`*(wand: var Wand) =
  wand.impl = destroyMagickWand(wand.impl)

proc readImage*(wand: Wand, filename: string) =
  if not magickReadImage(wand.impl, filename):
    raise newException(IOError, "Could not read image: " & filename)

proc writeImage*(wand: Wand, filename: string) =
  if not magickWriteImage(wand.impl, filename):
    raise newException(IOError, "Could not write image: " & filename)
