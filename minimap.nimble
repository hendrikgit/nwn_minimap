# Package
version       = "0.2.0"
author        = "Hendrik Albers"
description   = "nwn minimap generator"
license       = "MIT"
srcDir        = "src"
bin           = @["minimap"]

# Dependencies
requires "nim >= 1.4.8"
requires "neverwinter == 1.4.2"
requires "regex == 0.19.0"
requires "https://github.com/hendrikgit/nimtga#0.2.0"
