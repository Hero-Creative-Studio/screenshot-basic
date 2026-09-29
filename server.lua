local resourceName = GetCurrentResourceName()
local timeoutMs = 45000
local maxFileSize = 10 * 1024 * 1024
local extensions = { ['image/jpeg'] = 'jpg', ['image/png'] = 'png', ['image/webp'] = 'webp' }

local pending = {}
local nextId = 0

local function parseDataUri(data)
    local mime, pos = data:match('^data:(image/%a+);base64,()')
    if extensions[mime] then
        return mime, pos
    end
end

local function saveFile(fileName, bytes)
    if type(fileName) ~= 'string' then
        return nil, 'Invalid target path'
    end

    local rel = fileName:gsub('\\', '/'):gsub('^/+', '')
    if rel == '' or rel:find(':', 1, true) or rel:sub(1, 1) == '@' then
        return nil, 'Invalid target path'
    end
    for segment in rel:gmatch('[^/]+') do
        if segment == '..' then
            return nil, 'Invalid target path'
        end
    end

    local dir = ''
    for segment in rel:gmatch('([^/]+)/') do
        dir = dir .. segment .. '/'
        os.createdir(('@%s/%s'):format(resourceName, dir))
    end

    if not SaveResourceFile(resourceName, rel, bytes, #bytes) then
        return nil, 'Failed to write file'
    end

    return GetResourcePath(resourceName) .. '/' .. rel
end

local function finish(request, data)
    if type(data) ~= 'string' or data == '' then
        return request.cb('Screenshot failed', '')
    end

    if #data * 3 / 4 > maxFileSize then
        return request.cb('File too large', '')
    end

    local _, pos = parseDataUri(data)
    if not pos then
        return request.cb('Invalid file type', '')
    end

    if not request.fileName then
        return request.cb(false, data)
    end

    local bytes = Base64Decode(data:sub(pos))
    if not bytes then
        return request.cb('Invalid image data', '')
    end

    local path, err = saveFile(request.fileName, bytes)
    if not path then
        return request.cb(err, '')
    end

    request.cb(false, path)
end

local function requestClientScreenshot(player, options, cb)
    options = type(options) == 'table' and options or {}

    nextId = nextId + 1
    local id = nextId
    pending[id] = { player = tonumber(player), fileName = options.fileName, cb = cb }

    SetTimeout(timeoutMs, function()
        local request = pending[id]
        if request then
            pending[id] = nil
            request.cb('Upload timeout', '')
        end
    end)

    TriggerClientEvent('screenshot_basic:request', player, id, {
        encoding = options.encoding,
        quality = options.quality
    })
end

exports('requestClientScreenshot', requestClientScreenshot)

RegisterNetEvent('screenshot_basic:result', function(requestId, data)
    local src = tonumber(source)
    local request = type(requestId) == 'number' and pending[requestId]

    if not request or request.player ~= src then
        return
    end

    pending[requestId] = nil
    finish(request, data)
end)
