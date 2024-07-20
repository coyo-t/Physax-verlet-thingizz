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

ray.x1 = mx
ray.y1 = my

if mouse_check_button(mb_left)
{
	ray.x0 = mx
	ray.y0 = my
}
else
{
	var dt = delta_time / 1000000
	var xd = (keyboard_check(ord("D"))-keyboard_check(ord("A")))*10*dt
	var yd = (keyboard_check(ord("S"))-keyboard_check(ord("W")))*10*dt

	ray.x0 += xd
	ray.y0 += yd
}


hit.did = trace(method(self, function (_x, _y) {
	var type = map.get(_x, _y)
	var cc = type.collider_count()
	if cc <= 0
	{
		return false
	}
	
	var any = false
	var nearest = infinity
	var colliders = type.collision_shapes
	
	for (var i = cc; --i >= 0;)
	{
		var collider = colliders[i]
		var test = boxcast_context.test(
			_x+rect_x0(collider),
			_y+rect_y0(collider),
			_x+rect_x1(collider),
			_y+rect_y1(collider)
		)
		if test
		{
			any = true
			nearest = min(boxcast_context.hit_time, nearest)
		}
	}
	
	if nearest <> infinity
	{
		hit.time = nearest
	}
	
	return any
}))

