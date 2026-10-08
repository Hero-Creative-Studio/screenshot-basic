<p align="center">
  <img src="https://herocreative.de/images/hero-creative-studio-logo.webp?v=2" alt="Hero Creative Studio" />
</p>

<p align="center">
  <img src="https://img.shields.io/github/downloads/Hero-Creative-Studio/screenshot-basic/total?logo=github" alt="Downloads" />
</p>

As a sign of our commitment to supporting FiveM server owners, we fork and improve well-known but poorly maintained repositories and release them for free. Enjoy the scripts, and feel free to contribute yourself. If you find any bugs or have ideas for improvements, please let us know!

---

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

#### requestScreenshot(options?: table, cb: fun(result: string))
Takes a screenshot and passes the data URI to a callback. Please don't send this through _any_ server events.
If the NUI page does not answer within 30 seconds, the callback receives an empty string.

Arguments:
* **options**: An optional table containing options.
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

#### requestScreenshotUpload(url: string, field: string, options?: table, cb: fun(result: string))
Takes a screenshot and uploads it as a file (`multipart/form-data`) to a remote HTTP URL.
`url` and `field` are required. The callback also receives an empty string after the 30 second timeout.

Arguments:
* **url**: The URL to a file upload handler.
* **field**: The name for the form field to add the file to.
* **options**: An optional table containing options.
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

#### requestClientScreenshot(player: string | number, options: table, cb: fun(err: string | boolean, data: string))
Requests the specified client to take a screenshot. Requests time out after 45 seconds, and images larger than 10 MB are rejected.

Arguments:
* **player**: The target player's player index.
* **options**: A table containing options.
  * **fileName**: string? - The file name to save the image to, relative to this resource's folder (subfolders are created). Absolute paths, drive letters and `..` segments are rejected. If not passed, the callback will get a data URI for the image data.
  * **encoding**: 'png' | 'jpg' | 'webp' - The target image encoding. Defaults to 'jpg'.
  * **quality**: number - The quality for a lossy image encoder, in the range 0.0-1.0. Defaults to 0.92.
* **cb**: A callback upon result.
  * **err**: `false`, or an error string (`Upload timeout`, `File too large`, `Invalid file type`, `Invalid image data`, `Invalid target path`, `Failed to write file`, `Screenshot failed`).
  * **data**: The full path of the saved file, or the data URI for the image. Empty string on error.

Example:
```lua
exports['screenshot-basic']:requestClientScreenshot(GetPlayers()[1], {
    fileName = 'cache/screenshot.jpg'
}, function(err, data)
    print('err', err)
    print('data', data)
end)
```
