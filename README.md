# screenshot-basic for FiveM

## Description

screenshot-basic is a basic resource for making screenshots of clients' game render targets using FiveM. The NUI page binds the
game view texture with plain WebGL (the same `glTexParameterf` activation sequence as the `@citizenfx/three` `CfxTexture`, see
`glTexParameterfHook` in citizenfx/fivem `nui-core/src/NUIInitialize.cpp`) and reads it back into a canvas.

Plain Lua + one HTML file: no yarn, no webpack, no build step.

The game frame is copied before NUI is drawn, so screenshots contain the game and the native HUD (minimap, DrawText, notifications)
but not NUI pages (phones, inventories, HTML HUDs).

## Usage

1. Drop the folder into your resources and `ensure screenshot-basic`.
2. Use it through the exports below.

Decoder self-test: `lua tests/base64_test.lua` (any Lua 5.4, from the resource root).

## API

### Client

#### requestScreenshot(options?: any, cb: (result: string) => void)
Takes a screenshot and passes the data URI to a callback. Please don't send this through _any_ server events.

Arguments:
* **options**: An optional object containing options.
  * **encoding**: 'png' | 'jpg' | 'webp' - The target image encoding. Defaults to 'jpg'.
  * **quality**: number - The quality for a lossy image encoder, in the range 0.0-1.0. Defaults to 0.92.
* **cb**: A callback upon result.
  * **result**: A `base64` data URI for the image.

Example:

```lua
exports['screenshot-basic']:requestScreenshot(function(data)
    TriggerEvent('chat:addMessage', { template = '<img src="{0}" style="max-width: 300px;" />', args = { data } })
end)
```

#### requestScreenshotUpload(url: string, field: string, options?: any, cb: (result: string) => void)
Takes a screenshot and uploads it as a file (`multipart/form-data`) to a remote HTTP URL.

Arguments:
* **url**: The URL to a file upload handler.
* **field**: The name for the form field to add the file to.
* **options**: An optional object containing options.
  * **encoding**: 'png' | 'jpg' | 'webp' - The target image encoding. Defaults to 'jpg'.
  * **quality**: number - The quality for a lossy image encoder, in the range 0.0-1.0. Defaults to 0.92.
  * **headers**: table? - Extra HTTP headers for the upload request.
* **cb**: A callback upon result.
  * **result**: The response data for the remote URL, or an empty string if the upload failed.

Example:

```lua
exports['screenshot-basic']:requestScreenshotUpload('https://wew.wtf/upload.php', 'files[]', function(data)
    local resp = json.decode(data)
    TriggerEvent('chat:addMessage', { template = '<img src="{0}" style="max-width: 300px;" />', args = { resp.files[1].url } })
end)
```

### Server
The server can also request a client to take a screenshot. The image is sent back to the server through a latent net event.

#### requestClientScreenshot(player: string | number, options: any, cb: (err: string | boolean, data: string) => void)
Requests the specified client to take a screenshot.

Arguments:
* **player**: The target player's player index.
* **options**: An object containing options.
  * **fileName**: string? - The file name to save the image to, relative to this resource's folder (subfolders are created). If not passed, the callback will get a data URI for the image data.
  * **encoding**: 'png' | 'jpg' | 'webp' - The target image encoding. Defaults to 'jpg'.
  * **quality**: number - The quality for a lossy image encoder, in the range 0.0-1.0. Defaults to 0.92.
* **cb**: A callback upon result.
  * **err**: `false`, or an error string.
  * **data**: The full path of the saved file, or the data URI for the image.

Example:
```lua
exports['screenshot-basic']:requestClientScreenshot(GetPlayers()[1], {
    fileName = 'cache/screenshot.jpg'
}, function(err, data)
    print('err', err)
    print('data', data)
end)
```
