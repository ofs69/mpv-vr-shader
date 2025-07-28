-- VR Shader Script for MPV
-- This script allows you to control VR zoom and rotation.
--
-- Keybindings:
--   k: Toggle VR shader on/off
--   Right-click and drag: Control rotation
--   n: Decrease zoom
--   m: Increase zoom
--   r: Reset view

local rotationX = 0.5
local rotationY = -0.5
local zoom = 0.5

local shader_enabled = false
local is_dragging = false
local last_mouse_pos = nil

local function update_shader_opts()
    local opts = string.format("rotationY=%f,rotationX=%f,zoom=%f", rotationY, rotationX, zoom)
    mp.set_property("glsl-shader-opts", opts)
end

local function decrease_zoom()
    zoom = zoom * 0.95
    if zoom < 0.1 then
        zoom = 0.1
    end
    update_shader_opts()
    mp.osd_message("vr zoom: " .. string.format("%.1f", zoom))
end

local function increase_zoom()
    zoom = zoom * 1.05
    update_shader_opts()
    mp.osd_message("vr zoom: " .. string.format("%.1f", zoom))
end

local function reset_view()
    rotationX = 0.5
    rotationY = -0.5
    zoom = 0.5
    update_shader_opts()
    mp.osd_message("vr view reset")
end

local function toggle_vr()
	if shader_enabled then
		mp.set_property("glsl-shaders", "")
        mp.osd_message("vr shader off")
	else
		mp.set_property("glsl-shaders", "~~/shaders/vr_shader.glsl;")
        mp.osd_message("vr shader on")
	end
    shader_enabled = not shader_enabled
end

function start_drag()
    if shader_enabled then
        is_dragging = not is_dragging
        last_mouse_pos = mp.get_property_native("mouse-pos")
    end
end


function handle_mouse_move(name, pos)
    if is_dragging and shader_enabled and pos and last_mouse_pos then
        local dx = pos.x - last_mouse_pos.x
        local dy = pos.y - last_mouse_pos.y

        -- Adjust sensitivity as needed
        rotationY = rotationY - dy * 0.002
        rotationX = rotationX - dx * 0.002

        update_shader_opts()
        mp.osd_message(string.format("vr rotation: x=%.2f, y=%.2f", rotationX, rotationY))

        last_mouse_pos = pos
    end
end

mp.observe_property("mouse-pos", "native", handle_mouse_move)
mp.add_key_binding("MBTN_RIGHT", "start_drag", start_drag)

mp.add_key_binding("n", "decrease_zoom", decrease_zoom)
mp.add_key_binding("m", "increase_zoom", increase_zoom)
mp.add_key_binding("k", "toggle_vr", toggle_vr)
mp.add_key_binding("r", "reset_view", reset_view)
