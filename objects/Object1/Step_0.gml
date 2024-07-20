
var mdelta = mouse_wheel_down() - mouse_wheel_up()

if mdelta <> 0
{
	if keyboard_check(vk_shift)
	{
		current_paint++
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

if mouse_check_button(mb_middle)
{
	var mxd = +window_mouse_get_delta_x()
	var myd = -window_mouse_get_delta_y()
	
	var ss = 1/window_get_height()*cam.zoom
	
	cam.x -= mxd * ss
	cam.y -= myd * ss
}



begin
	var zoom = cam.zoom

	var mx = display_mouse_get_x()-window_get_x()
	var my = display_mouse_get_y()-window_get_y()

	mx = (mx / window_get_width())*2-1
	my = (1-my / window_get_height())*2-1

	mx = mx * (zoom*0.5) * cam.aspect + cam.x
	my = my * (zoom*0.5) + cam.y

	//update_player_co(mx, my)
	
	cursor_x = floor(mx)
	cursor_y = floor(my)

end


if mouse_check_button(mb_left)
{
	map.set_block(cursor_x, cursor_y, global.air)
}
else if mouse_check_button(mb_right)
{
	map.set_block(cursor_x, cursor_y, palette[current_paint])
}

begin
	var hinp = keyboard_check(ord("D"))-keyboard_check(ord("A"))
	var vinp = keyboard_check(ord("W"))-keyboard_check(ord("S"))
	var dt = delta_time / 1000000
	var spd = 5
	
	wish_xdirection = (wish_xdirection + hinp) * 0.5
	//wish_xdirection = hinp
	wish_ydirection |= keyboard_check(vk_space)
	
	//speed_x = hinp*spd
	//speed_y = vinp*spd
	//move(hinp*dt*spd, vinp*dt*spd)
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
}

