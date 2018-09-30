local ops = {}

function ops.uint32_lrot(a, bits)
   return ((a << bits) & 0xFFFFFFFF) | (a >> (32 - bits))
end

function ops.byte_xor(a, b)
   return a ~ b
end

function ops.uint32_xor_3(a, b, c)
   return a ~ b ~ c
end

function ops.uint32_xor_4(a, b, c, d)
   return a ~ b ~ c ~ d
end

-- (B AND C) OR ((NOT B) AND D)
function ops.loop_op_1(B, C, D)
   return (B & C) | (~B & D)
end

-- (B AND C) OR (B AND D) OR (C AND D) = (B AND (C OR D)) OR (C AND D)
function ops.loop_op_3(B, C, D)
   return (B & (C | D)) | (C & D)
end

return ops
