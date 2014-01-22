package = "sha1"
version = "0.5-0"
source = {
  url = "https://github.com/kikito/sha1.lua/archive/v0.5.0.tar.gz",
  dir = "sha1.lua-0.5.0"
}
description = {
   summary  = "SHA-1 secure hash computation, and HMAC-SHA1 signature computation in Lua (5.1)",
   detailed = "This pure-Lua module computes SHA-1 and HMAC-SHA1 signature computations in Lua 5.1.",
   homepage = "https://github.com/kikito/sha1.lua",
   license  = "MIT"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      sha1 = "sha1.lua"
   }
}
