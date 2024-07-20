var mdelta = mouse_wheel_down() - mouse_wheel_up()

trace_draw_debug ^= keyboard_check_pressed(vk_f3)

if mdelta <> 0
{
	cam.set_zoom(cam.zoom * exp(mdelta * (1/16)))	
}

if mouse_check_button(mb_middle)
{
	var mxd = +window_mouse_get_delta_x()
	var myd = -window_mouse_get_delta_y()
	
	var ss = 1/window_get_height()*cam.zoom
	
	cam.x -= mxd * ss
	cam.y -= myd * ss
}

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
	
end

var map_wide = map.wide
var map_tall = map.tall

var map_x0 = rect_x0(map.bounds)
var map_y0 = rect_y0(map.bounds)
var map_x1 = rect_x1(map.bounds)
var map_y1 = rect_y1(map.bounds)

var win_mouse_x = (display_mouse_get_x()-window_get_x())/window_get_width()*room_width
var win_mouse_y = (display_mouse_get_y()-window_get_y())/window_get_height()*room_height

var mx = (win_mouse_x - map_x0) / (map_x1-map_x0)*map_wide
var my = (win_mouse_y - map_y0) / (map_y1-map_y0)*map_tall

mouse.x = win_mouse_x
mouse.y = win_mouse_y

mouse.map_x = mx
mouse.map_y = my

ray.set_end(
	mouse.world_x,
	mouse.world_y
)

var pev_rx0 = ray.start_point[Vec.x]
var pev_ry0 = ray.start_point[Vec.y]

if mouse_check_button(mb_left)
{
	ray.set_start(
		mouse.world_x,
		mouse.world_y
	)
}
else
{
	var dt = delta_time / 1000000
	var xd = (keyboard_check(ord("D"))-keyboard_check(ord("A")))*10*dt
	var yd = (keyboard_check(ord("W"))-keyboard_check(ord("S")))*10*dt

	vec_add_xy(ray.start_point, xd, yd)
}

if keyboard_check_pressed(vk_control)
{
	vec_floor(ray.start_point)
}

if keyboard_check(vk_shift)
{
	var sp = ray.start_point
	var ep = ray.end_point
	var axis
	if abs(ep[Vec.x]-sp[Vec.x]) > abs(ep[Vec.y]-sp[Vec.y])
	{
		axis = Vec.y
	}
	else
	{
		axis = Vec.x
	}
	ep[axis] = sp[axis]
}

ray.update_box()

