type
  MagickWand {.importc: "struct MagickWand".} = object

  Wand* = object
    impl: ptr MagickWand

{.push dynlib: "libMagickWand-6.Q16.so".}
proc genesis*() {.importc: "MagickWandGenesis".}

proc terminus*() {.importc: "MagickWandTerminus".}

proc newMagickWand(): ptr MagickWand {.importc: "NewMagickWand".}

proc destroyMagickWand(wand: ptr MagickWand): ptr MagickWand {.importc: "DestroyMagickWand", discardable.}
{.pop.}

proc newWand*(): Wand =
  result.impl = newMagickWand()

proc `=destroy`*(wand: var Wand) =
  wand.impl = destroyMagickWand(wand.impl)
