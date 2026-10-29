local timeoutMs = 30000
local bytesPerSecond = 5000000

local pending = {}
local nextId = 0

local function isCallable(v)
    return type(v) == 'function' or (type(v) == 'table' and rawget(v, '__cfx_functionReference') ~= nil)
end

local function capture(request, cb)
    nextId = nextId + 1
    local id = nextId
    pending[id] = cb

    SetTimeout(timeoutMs + (request.duration or 0) * 1000, function()
        local timedOut = pending[id]
        if timedOut then
            pending[id] = nil
            print(('^3screenshot-basic: timed out waiting for screenshot result (%d)^7'):format(id))
            timedOut('')
        end
    end)

    request.id = id
    SendNUIMessage({ request = request })
end

local function videoRequest(options)
    return {
        video = true,
        duration = math.min(math.max(tonumber(options.duration) or 5, 1), 15),
        fps = options.fps,
        bitrate = options.bitrate
    }
end

RegisterNUICallback('screenshot_created', function(body, cb)
    cb(true)

    local id = type(body) == 'table' and tonumber(body.id)
    local done = id and pending[id]
    if not done then
        return
    end

    pending[id] = nil
    done(type(body.data) == 'string' and body.data or '')
end)

exports('requestScreenshot', function(options, cb)
    if isCallable(options) then
        options, cb = nil, options
    end

    if not isCallable(cb) then
        print('^1requestScreenshot: callback is required^7')
        return
    end

    options = type(options) == 'table' and options or {}

    capture({
        encoding = options.encoding,
        quality = options.quality
    }, cb)
end)

exports('requestScreenshotUpload', function(url, field, options, cb)
    if isCallable(options) then
        options, cb = nil, options
    end

    if not isCallable(cb) then
        print('^1requestScreenshotUpload: callback is required^7')
        return
    end

    if type(url) ~= 'string' or url == '' or type(field) ~= 'string' or field == '' then
        print('^1requestScreenshotUpload: url and field are required^7')
        return
    end

    options = type(options) == 'table' and options or {}

    capture({
        encoding = options.encoding,
        quality = options.quality,
        headers = options.headers,
        targetURL = url,
        targetField = field
    }, cb)
end)

exports('requestVideo', function(options, cb)
    if isCallable(options) then
        options, cb = nil, options
    end

    if not isCallable(cb) then
        print('^1requestVideo: callback is required^7')
        return
    end

    capture(videoRequest(type(options) == 'table' and options or {}), cb)
end)

exports('requestVideoUpload', function(url, field, options, cb)
    if isCallable(options) then
        options, cb = nil, options
    end

    if not isCallable(cb) then
        print('^1requestVideoUpload: callback is required^7')
        return
    end

    if type(url) ~= 'string' or url == '' or type(field) ~= 'string' or field == '' then
        print('^1requestVideoUpload: url and field are required^7')
        return
    end

    options = type(options) == 'table' and options or {}

    local request = videoRequest(options)
    request.headers = options.headers
    request.targetURL = url
    request.targetField = field
    capture(request, cb)
end)

RegisterNetEvent('screenshot_basic:request', function(requestId, options)
    options = type(options) == 'table' and options or {}

    capture(options.video and videoRequest(options) or {
        encoding = options.encoding,
        quality = options.quality
    }, function(data)
        TriggerLatentServerEvent('screenshot_basic:result', bytesPerSecond, requestId, data)
    end)
end)
