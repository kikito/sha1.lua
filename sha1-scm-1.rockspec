package = "sha1"
version = "scm-1"
source = {
   url = "git+https://github.com/mpeterv/sha1.git",
}
description = {
   summary  = "SHA-1 and HMAC-SHA1 in pure Lua",
   detailed = [[This module implements SHA-1 and HMAC-SHA1 in pure Lua,
using bit operation libraries or Lua 5.3 operators when available.]],
   homepage = "https://github.com/mpeterv/sha1",
   license  = "MIT"
}
dependencies = {
   "lua >= 5.1, < 5.4"
}
build = {
   type = "builtin",
   modules = {
      sha1 = "src/sha1/init.lua",
      ["sha1.bit_ops"] = "src/sha1/bit_ops.lua",
      ["sha1.bit32_ops"] = "src/sha1/bit32_ops.lua",
      ["sha1.lua53_ops"] = "src/sha1/lua53_ops.lua",
      ["sha1.pure_lua_ops"] = "src/sha1/pure_lua_ops.lua"
   }
}
