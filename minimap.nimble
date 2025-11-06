# Package
version       = "0.2.0"
author        = "Hendrik Albers"
description   = "nwn minimap generator"
license       = "MIT"
srcDir        = "src"
bin           = @["minimap"]

# Dependencies
requires "nim >= 2.2.6"
requires "neverwinter >= 2.1.2"
requires "regex >= 0.26.3"
requires "https://github.com/hendrikgit/nimtga#0.2.0"
