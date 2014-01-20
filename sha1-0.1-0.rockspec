package = "sha1"
version = "0.1-0"
source = {
  url = "",
  dir = "."
}
description = {
  summary = "",
  detailed = [[
  ]]
}
dependencies = {
  "lua >= 5.1",
  "busted >= 1.5.0",
}
build = {
  type = "builtin",
  modules = {
    ['sha1'] = "sha1.lua",
  },
}
