__DEBUG_STRING = ""

var mdelta = mouse_wheel_down() - mouse_wheel_up()

if mdelta <> 0
{
	if keyboard_check(vk_shift)
	{
		current_paint += mdelta
		if current_paint >= array_length(palette)
		{
			current_paint = 0
		}
		else if current_paint < 0
		{
			current_paint = array_length(palette) - 1
		}
	}
	else
	{
		cam.set_zoom(cam.zoom * exp(mdelta * (1/16)))
	}
}

if keyboard_check_pressed(vk_f3)
{
	show_debug_overlay(!is_debug_overlay_open(), true)
}

if mouse_check_button(mb_middle)
{
	var mxd = +window_mouse_get_delta_x()
	var myd = -window_mouse_get_delta_y()
	
	var ss = 1/window_get_height()*cam.zoom
	
	cam.x -= mxd * ss
	cam.y -= myd * ss
}
audio_listener_orientation(0, 0, -1, 0, 1, 0)
audio_listener_position(cam.x, cam.y, 0)

var cursor_moved = false
begin
	var zoom = cam.zoom

	var mx = display_mouse_get_x()-window_get_x()
	var my = display_mouse_get_y()-window_get_y()

	mx = (mx / window_get_width())*2-1
	my = (1-my / window_get_height())*2-1

	mx = mx * (zoom*0.5) * cam.aspect + cam.x
	my = my * (zoom*0.5) + cam.y
	
	mouse.world_x = mx
	mouse.world_y = my
	
	var omx = mouse.block_x
	var omy = mouse.block_y
	mouse.block_x = floor(mx)
	mouse.block_y = floor(my)
	cursor_moved |= mouse.block_x <> omx or mouse.block_y <> omy
end

var cursor_x = mouse.block_x
var cursor_y = mouse.block_y

if mouse_check_button(mb_left)
{
	var did = map.set_block(cursor_x, cursor_y, global.air)
	if mouse_check_button_pressed(mb_left) or cursor_moved
	{
		if did and map.point_in_bounds(cursor_x, cursor_y)
		{
			audio_play_sound_at(sfx_break_bloc, cursor_x+0.5, cursor_y+0.5, 0, 8, 16, 1, false, 1)
		}
	}
}
else if mouse_check_button(mb_right)
{
	var did = map.set_block(cursor_x, cursor_y, palette[current_paint])
	if mouse_check_button_pressed(mb_right) or cursor_moved
	{
		var ib = map.point_in_bounds(cursor_x, cursor_y)
		if did and ib
		{
			audio_play_sound_at(sfx_put_bloc, cursor_x+0.5, cursor_y+0.5, 0, 8, 16, 1, false, 1)
		}
	}
}

if keyboard_check(ord("C"))
{
	viewcast_x = mouse.world_x
	viewcast_y = mouse.world_y
}

begin
	var hinp = keyboard_check(ord("D"))-keyboard_check(ord("A"))
	var vinp = keyboard_check(ord("W"))-keyboard_check(ord("S"))
	var spd = 5
	
	wish_xdirection = (wish_xdirection + hinp) * 0.5
	//wish_xdirection = hinp
	wish_ydirection |= keyboard_check(vk_space)
	
	wish_sneak = (wish_sneak + keyboard_check(vk_shift)) * 0.5
	
end

var ticks = timer.step()
for (var i = ticks; i-- > 0;)
{
	tick()
	wish_xdirection -= wish_xdirection / (ticks-i)*0.5
}

if ticks <> 0
{
	wish_xdirection = 0
	wish_ydirection = 0
	wish_sneak = 0
}

paint_changed = current_paint <> previous_paint
previous_paint = current_paint


