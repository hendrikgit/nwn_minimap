type
  MagickWand = object

  PixelWand = object

  FilterType = enum
    LanczosFilter

  Wand* = object
    impl: ptr MagickWand

{.push dynlib: "libMagickWand-6(.Q16).so(.6)".}
proc genesis*() {.importc: "MagickWandGenesis".}

proc terminus*() {.importc: "MagickWandTerminus".}

proc newMagickWand(): ptr MagickWand {.importc: "NewMagickWand".}

proc destroyMagickWand(wand: ptr MagickWand): ptr MagickWand {.importc: "DestroyMagickWand", discardable.}

proc clearMagickWand(wand: ptr MagickWand) {.importc: "ClearMagickWand".}

proc magickReadImage(wand: ptr MagickWand, filename: cstring): bool {.importc: "MagickReadImage".}

proc magickWriteImage(wand: ptr MagickWand, filename: cstring): bool {.importc: "MagickWriteImage".}

proc magickGetImageWidth(wand: ptr MagickWand): csize_t {.importc: "MagickGetImageWidth".}

proc magickGetImageHeight(wand: ptr MagickWand): csize_t {.importc: "MagickGetImageHeight".}

proc newPixelWand(): ptr PixelWand {.importc: "NewPixelWand".}

proc destroyPixelWand(wand: ptr PixelWand): ptr PixelWand {.importc: "DestroyPixelWand".}

proc magickRotateImage(wand: ptr MagickWand, background: ptr PixelWand, degrees: cdouble): bool {.importc: "MagickRotateImage".}

proc magickResizeImage(wand: ptr MagickWand, columns, rows: csize_t, filter: FilterType): bool {.importc: "MagickResizeImage".}

proc magickAppendImages(wand: ptr MagickWand, stack: bool): ptr MagickWand {.importc: "MagickAppendImages".}

proc magickAddImage(wand, addWand: ptr MagickWand): bool {.importc: "MagickAddImage".}

proc magickResetIterator(wand: ptr MagickWand) {.importc: "MagickResetIterator".}

proc magickGetIteratorIndex(wand: ptr MagickWand): int {.importc: "MagickGetIteratorIndex".}
{.pop.}

proc newWand*(): Wand =
  result.impl = newMagickWand()

proc `=destroy`(wand: var Wand) =
  wand.impl = destroyMagickWand(wand.impl)

proc clearWand*(wand: Wand) =
  clearMagickWand(wand.impl)

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

proc rotateImage*(wand: Wand, degrees: int) =
  var pw = newPixelWand()
  # todo: use return code for error handling?
  discard magickRotateImage(wand.impl, pw, degrees.toFloat)
  discard pw.destroyPixelWand

proc resizeImage*(wand: Wand, columns, rows: uint) =
  # todo: return code?
  discard magickResizeImage(wand.impl, columns, rows, LanczosFilter)

proc appendImages*(wand: Wand, stack = false): Wand =
  result.impl = magickAppendImages(wand.impl, stack)

proc addImage*(wand, addWand: Wand) =
  discard magickAddImage(wand.impl, addWand.impl)

proc resetIterator*(wand: Wand) =
  magickResetIterator(wand.impl)

proc getIteratorIndex*(wand: Wand): int =
  magickGetIteratorIndex(wand.impl)
