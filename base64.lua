local ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local lookup = {}
for i = 1, #ALPHABET do
    lookup[ALPHABET:byte(i)] = i - 1
end

function Base64Decode(data)
    data = data:gsub('[%s=]', '')
    if data:find('[^A-Za-z0-9%+/]') then
        return nil
    end

    local rem = #data % 4
    if rem == 1 then
        return nil
    end

    local out, n = {}, 0
    for i = 1, #data - rem, 4 do
        local a, b, c, d = data:byte(i, i + 3)
        local v = (lookup[a] << 18) | (lookup[b] << 12) | (lookup[c] << 6) | lookup[d]
        n = n + 1
        out[n] = string.char(v >> 16, (v >> 8) & 0xFF, v & 0xFF)
    end

    if rem > 0 then
        local a, b, c = data:byte(#data - rem + 1, #data)
        local v = (lookup[a] << 18) | (lookup[b] << 12) | ((c and lookup[c] or 0) << 6)
        out[n + 1] = rem == 2 and string.char(v >> 16) or string.char(v >> 16, (v >> 8) & 0xFF)
    end

    return table.concat(out)
end
