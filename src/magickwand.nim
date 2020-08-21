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

proc magickGetImageWidth(wand: ptr MagickWand): csize_t {.importc: "MagickGetImageWidth".}

proc magickGetImageHeight(wand: ptr MagickWand): csize_t {.importc: "MagickGetImageHeight".}
{.pop.}

proc newWand*(): Wand =
  result.impl = newMagickWand()

proc `=destroy`(wand: var Wand) =
  wand.impl = destroyMagickWand(wand.impl)

proc readImage*(wand: Wand, filename: string) =
  if not magickReadImage(wand.impl, filename):
    raise newException(IOError, "Could not read image: " & filename)

proc writeImage*(wand: Wand, filename: string) =
  if not magickWriteImage(wand.impl, filename):
    raise newException(IOError, "Could not write image: " & filename)

proc width*(wand: Wand): uint =
  magickGetImageWidth(wand.impl)

proc height*(wand: Wand): uint =
  magickGetImageHeight(wand.impl)

proc size*(wand: Wand): tuple[width, height: uint] =
  (wand.width, wand.height)
