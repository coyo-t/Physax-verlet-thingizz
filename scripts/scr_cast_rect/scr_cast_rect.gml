
function RayRectContext2 () constructor begin
	
	origin_x = 0
	origin_y = 0
	
	end_x = 0
	end_y = 0
	
	direction_x = 0
	direction_y = 0
	inv_direction_x = 1
	inv_direction_y = 1
	
	sign_x_less_than = false
	sign_y_less_than = false
	sign_x = 1
	sign_y = 1
	
	did_hit = false
	
	near_time = 1
	far_time = 1
	
	inflate_x = 0
	inflate_y = 0
	
	normal_x = 0
	normal_y = 0
	
	static __direct_comp = function (_v)
	{
		// abs should account for +0 and -0?
		return abs(_v) == 0.0 ? infinity : 1.0 / _v
	}
	
	static __setup_direction_values = function ()
	{
		sign_x_less_than = direction_x < 0
		sign_y_less_than = direction_y < 0
		
		sign_x = sign_x_less_than ? -1 : +1
		sign_y = sign_y_less_than ? -1 : +1
		
		inv_direction_x = __direct_comp(direction_x)
		inv_direction_y = __direct_comp(direction_y)
	}
	
	static setup = function (_origin_x, _origin_y, _direction_x, _direction_y)
	{
		origin_x = _origin_x
		origin_y = _origin_y
		
		end_x = _origin_x + _direction_x
		end_y = _origin_y + _direction_y
		
		direction_x = _direction_x
		direction_y = _direction_y
		
		__setup_direction_values()
		
		inflate_x = 0
		inflate_y = 0
	}
	
	static setup_endpoints = function (_start_x, _start_y, _end_x, _end_y)
	{
		origin_x = _start_x
		origin_y = _start_y
		
		end_x = _end_x
		end_y = _end_y
		
		direction_x = _end_x - _start_x
		direction_y = _end_y - _start_y
		
		__setup_direction_values()
		
		inflate_x = 0
		inflate_y = 0
	}
	
	static setup_with_corners = function (_x0, _y0, _x1, _y1, _direction_x, _direction_y)
	{
		setup((_x0 + _x1) * 0.5, (_y0 + _y1) * 0.5, _direction_x, _direction_y)
		
		inflate_x = (_x1 - _x0) * 0.5
		inflate_y = (_y1 - _y0) * 0.5
		
	}
	
	static test = function (_x0, _y0, _x1, _y1)
	{
		did_hit = false
		
		_x0 -= inflate_x
		_y0 -= inflate_y
		_x1 += inflate_x
		_y1 += inflate_y
		
		if _x0 <= origin_x and origin_x <= _x1 and _y0 <= origin_y and origin_y <= _y1
		{
			return false
		}
		
		var e = math_get_epsilon()
		
		_x0 -= e
		_y0 -= e
		_x1 += e
		_y1 += e
		
		var txmin = ((sign_x_less_than ? _x1 : _x0) - origin_x) * inv_direction_x
		var tymax = ((sign_y_less_than ? _y0 : _y1) - origin_y) * inv_direction_y
		
		if txmin > tymax
		{
			return false
		}

		var txmax = ((sign_x_less_than ? _x0 : _x1) - origin_x) * inv_direction_x
		var tymin = ((sign_y_less_than ? _y1 : _y0) - origin_y) * inv_direction_y
		
		if tymin > txmax
		{
			return false
		}
		
		near_time = max(tymin, txmin)
		far_time  = min(tymax, txmax)
		
		if txmin > tymin
		{
			normal_x = -sign_x
			normal_y = 0
		}
		else
		{
			normal_x = 0
			normal_y = -sign_y
		}
		
		did_hit = 1 > near_time and far_time > 0
		
		return did_hit
	}
end

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
		
		inflate_x = 0
		inflate_y = 0
		
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
			show_debug_message($"Inside {get_timer()}")
			return false
		}
		
		_x0 -= math_get_epsilon()
		_y0 -= math_get_epsilon()
		_x1 += math_get_epsilon()
		_y1 += math_get_epsilon()
		
		near_time = +infinity
		far_time  = infinity
		
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


