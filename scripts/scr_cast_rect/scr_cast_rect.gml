
function RayRectContext () constructor begin
	
	origin_x = 0
	origin_y = 0
	
	direction_x = 0
	direction_y = 0
	inv_direction_x = 1
	inv_direction_y = 1
	inv_x_infinite = false
	inv_y_infinite = false
	
	inflate_x = 0
	inflate_y = 0
	
	sign_x = 0
	sign_y = 0
	
	near_time = 1.0
	far_time = 1.0
	hit_time = 1.0
	did_hit = false
	
	hit_normal_x = 0
	hit_normal_y = 0
	
	static setup_ray = function (_x, _y, _xd, _yd)
	{
		origin_x = _x
		origin_y = _y
		
		direction_x = _xd
		direction_y = _yd
		
		inv_x_infinite = _xd == 0
		inv_y_infinite = _yd == 0
		inv_direction_x = 1 / _xd
		inv_direction_y = 1 / _yd
		
		sign_x = _xd < 0 ? -1 : +1// sign(_xd)
		sign_y = _yd < 0 ? -1 : +1//sign(_yd)
		//sign_x = sign(_xd)
		//sign_y = sign(_yd)
	}
	
	static setup_box_ray = function (_x0, _y0, _x1, _y1, _xdirection, _ydirection)
	{
		var xx = (_x0+_x1) * 0.5
		var yy = (_y0+_y1) * 0.5
		setup_ray(xx, yy, _xdirection, _ydirection)
		inflate_x = xx-_x0
		inflate_y = yy-_y0
	}
	
	static setup_endpoints = function (_xstart, _ystart, _xend, _yend)
	{
		setup_ray(_xstart, _ystart, _xend-_xstart, _yend-_ystart)
	}
	
	static test_rect = function (_rect)
	{
		return test(
			rect_get_x0(_rect),
			rect_get_y0(_rect),
			rect_get_x1(_rect),
			rect_get_y1(_rect)
		)
	}
	
	static test = function (_x0, _y0, _x1, _y1)/*Number*/
	{
		did_hit = false
		hit_time = 1

		if _x0 <= origin_x and origin_x <= _x1 and _y0 <= origin_y and origin_y <= _y1
		{
			return false
		}
		
		near_time = +infinity
		far_time  = -infinity
		
		var hw = (_x1-_x0) * 0.5
		var hh = (_y1-_y0) * 0.5
		var cx = _x0 + hw
		var cy = _y0 + hh
		
		var vfx = (hw + inflate_x) * sign_x
		var vfy = (hh + inflate_y) * sign_y
		
		var near_time_x = (cx - vfx - origin_x) * inv_direction_x
		var near_time_y = (cy - vfy - origin_y) * inv_direction_y
		var far_time_x  = (cx + vfx - origin_x) * inv_direction_x
		var far_time_y  = (cy + vfy - origin_y) * inv_direction_y
		
		if near_time_x > far_time_y or near_time_y > far_time_x
		{
			return false
		}
		
		near_time = max(near_time_x, near_time_y)
		far_time  = min(far_time_x, far_time_y)
		
		
		if near_time >= 1 or far_time <= 0
		{
			return false
		}
		
		if near_time_x > near_time_y
		{
			hit_normal_x = -sign_x
			hit_normal_y = 0
		}
		else
		{
			hit_normal_x = 0
			hit_normal_y = -sign_y
		}
		
		did_hit = true
		hit_time = clamp(near_time, 0, 1)
		
		return true
	}
	
end


