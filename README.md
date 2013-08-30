sha1.lua
========

This pure-Lua module computes SHA-1 and HMAC-SHA1 signature computations in Lua 5.1.

Usage
=====

    local sha1 = require 'sha1'

    local hash_as_hex   = sha1(message)            -- returns a hex string
    local hash_as_data  = sha1.binary(message)     -- returns raw bytes

    local hmac_as_hex   = sha1.hmac(key, message)        -- hex string
    local hmac_as_data  = sha1.hmac_binary(key, message) -- raw bytes

Credits
=======

This is a cleanup of an implementation by Eike Decker - http://cube3d.de/uploads/Main/sha1.txt,

Which in turn was based on an original implementation by Jeffrey Friedl - http://regex.info/blog/lua/sha1

The original algorithm is http://www.itl.nist.gov/fipspubs/fip180-1.htm

License
=======

This version, as well as all the previous ones in which is based, are implemented under the MIT license (See license file for details).

Specs
=====

The specs for this library are implemented with [busted](http://ovinelabs.com/busted/). In order to run them, install busted and then:

    cd path/to/where/the/spec/folder/is
    busted




