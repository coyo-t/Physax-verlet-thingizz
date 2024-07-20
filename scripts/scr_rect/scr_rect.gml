

enum Rect
{
	x0,
	y0,
	x1,
	y1,
	sizeof
}

function __rect_get_cache ()
{
	static CACHE = new SimpleCache()
	return CACHE
}

function rect_create (_x0=0/*:Val*/, _y0=0/*:Val*/, _x1=1/*:Val*/, _y1=1/*:Val*/) /*-> Rect*/
{
	return [_x0, _y0, _x1, _y1]
}

///@returns {Array<Real>
function rect_get_temp (_x0=0, _y0=0, _x1=1, _y1=1)
{
	var cache = __rect_get_cache()
	var ca = cache.array
	if cache.cursor >= array_length(cache.array)
	{
		array_push(ca, rect_create(0,0,0,0))
	}
	return rect_set_corners(ca[cache.cursor++], _x0, _y0, _x1, _y1)
}

function rect_copy (_self/*:Rect*/) /*-> Rect*/
{
	return rect_create(_self[Rect.x0], _self[Rect.y0], _self[Rect.x1], _self[Rect.y1])
}

function rect_copy_temp (_self/*Rect*/)
{
	return rect_get_temp(_self[0], _self[1], _self[2], _self[3])
}

function rect_normalize (_self/*Rect*/)/*Rect*/
{
	var x0 = _self[0]
	var y0 = _self[1]
	var x1 = _self[2]
	var y1 = _self[3]
	
	return rect_set_corners(
		_self,
		min(x0, x1),
		min(y0, y1),
		max(x0, x1),
		max(y0, y1)
	)
}

function rect_get_min_corner (_self/*:Rect*/) /*-> Vec*/
{
	return vec_create(_self[Rect.x0], _self[Rect.y0])
}

function rect_get_max_corner (_self/*:Rect*/) /*-> Vec*/
{
	return vec_create(_self[Rect.x1], _self[Rect.y1])
}

function rect_get_x0 (_self/*:Rect*/) /*-> number*/
{
	return _self[Rect.x0]
}

function rect_get_y0 (_self/*:Rect*/) /*-> number*/
{
	return _self[Rect.y0]
}

function rect_get_x1 (_self/*:Rect*/) /*-> number*/
{
	return _self[Rect.x1]
}

function rect_get_y1 (_self/*:Rect*/) /*-> number*/
{
	return _self[Rect.y1]
}

function rect_set_x0 (_self/*:Rect*/, v/*:number*/) /*-> Rect*/
{
	_self[@Rect.x0] = v
	return _self
}

function rect_set_y0 (_self/*:Rect*/, v/*:number*/) /*-> Rect*/
{
	_self[@Rect.y0] = v
	return _self
}

function rect_set_x1 (_self/*:Rect*/, v/*:number*/) /*-> Rect*/
{
	_self[@Rect.x1] = v
	return _self
}

function rect_set_y1 (_self/*:Rect*/, v/*:number*/) /*-> Rect*/
{
	_self[@Rect.y1] = v
	return _self
}

function rect_set_corners (_self/*:Rect*/, _x0/*:Val*/, _y0/*:Val*/, _x1/*:Val*/, _y1/*:Val*/)/*->Rect*/
{
	_self[@Rect.x0] = _x0
	_self[@Rect.y0] = _y0
	_self[@Rect.x1] = _x1
	_self[@Rect.y1] = _y1
	return _self
}

function rect_set_from (_self/*:Rect*/, _other/*:Rect*/) /*-> Rect*/
{
	return rect_set_corners(_self, _other[Rect.x0], _other[Rect.y0], _other[Rect.x1], _other[Rect.y1])
}

function rect_get_wide (_self/*:Rect*/) /*-> number*/
{
	return _self[Rect.x1] - _self[Rect.x0]
}

function rect_get_tall (_self/*:Rect*/) /*-> number*/
{
	return _self[Rect.y1] - _self[Rect.y0]
}

function rect_get_centre_x (_self/*:Rect*/) /*-> number*/
{
	return (_self[Rect.x0] + _self[Rect.x1]) * 0.5
}

function rect_get_centre_y (_self/*:Rect*/) /*-> number*/
{
	return (_self[Rect.y0] + _self[Rect.y1]) * 0.5
}

function rect_add_corners (_self/*Rect*/, _x0, _y0, _x1, _y1)/*->Rect*/
{
	_self[0] += _x0
	_self[1] += _y0
	_self[2] += _x1
	_self[3] += _y1
	return _self
}

function rect_overlapping (_self/*:Rect*/, _other/*:Rect*/) /*-> bool*/
{
	return (
		_other[Rect.x1]>_self[Rect.x0] and
		_other[Rect.x0]<_self[Rect.x1] and
		_other[Rect.y1]>_self[Rect.y0] and
		_other[Rect.y0]<_self[Rect.y1]
	)
}

function rect_expand (_self/*:Rect*/, xofs/*:number*/, yofs/*:number*/) /*-> Rect*/
{
	_self[Rect.x0] += (xofs < 0 ? xofs : 0)
	_self[Rect.y0] += (yofs < 0 ? yofs : 0)
	_self[Rect.x1] += (xofs > 0 ? xofs : 0)
	_self[Rect.y1] += (yofs > 0 ? yofs : 0)
	return _self
}

function rect_expanded (_self/*:Rect*/, xofs/*:number*/, yofs/*:number*/) /*-> Rect*/
{
	return rect_expand(rect_copy(_self), xofs, yofs)
}

function rect_move (_self/*:Rect*/, _x/*:number*/, _y/*:number*/) /*-> Rect*/
{
	_self[@Rect.x0] += _x
	_self[@Rect.y0] += _y
	_self[@Rect.x1] += _x
	_self[@Rect.y1] += _y
	return _self
}

function rect_moved (_self/*:Rect*/, _x/*:number*/, _y/*:number*/) /*-> Rect*/
{
	return rect_create(
		_self[Rect.x0]+_x,
		_self[Rect.y0]+_y,
		_self[Rect.x1]+_x,
		_self[Rect.y1]+_y
	)
}


function rect_clip_x_collide (_self/*:Rect*/, c/*:Rect*/, xa/*:number*/) /*-> number*/
{
	var y0 = _self[Rect.y0]
	var y1 = _self[Rect.y1]
	if y0 <= -infinity or y1 >= +infinity or c[Rect.y1] <= y0 or c[Rect.y0] >= y1
	{
		return xa
	}
	var x0 = min(_self[Rect.x0], _self[Rect.x1])
	var x1 = max(_self[Rect.x0], _self[Rect.x1])
	if xa > 0 and x0 > -infinity and c[Rect.x1] <= x0
	{
		xa = min(xa, x0 - c[Rect.x1])
	}
	if xa < 0 and x1 < infinity and c[Rect.x0] >= x1
	{
		xa = max(xa, x1 - c[Rect.x0])
	}
	return xa
}

function rect_clip_y_collide (_self/*:Rect*/, c/*:Rect*/, ya/*:number*/) /*-> number*/
{
	var x0 = _self[Rect.x0]
	var x1 = _self[Rect.x1]
	if x0 <= -infinity or x1 >= +infinity or c[Rect.x1] <= x0 or c[Rect.x0] >= x1
	{
		return ya
	}
	var y0 = min(_self[Rect.y0], _self[Rect.y1])
	var y1 = max(_self[Rect.y0], _self[Rect.y1])
	if ya > 0 and y0 > -infinity and c[Rect.y1] <= y0
	{
		ya = min(ya, y0 - c[Rect.y1])
	}
	if ya < 0 and y1 < infinity and c[Rect.y0] >= y1
	{
		ya = max(ya, y1 - c[Rect.y0])
	}
	return ya
}

function rect_draw (_self/*Rect*/, _x/*Val*/=0, _y/*Val*/=0)
{
	var x0 = _self[0]+_x
	var y0 = _self[1]+_y
	var x1 = _self[2]+_x
	var y1 = _self[3]+_y
	draw_primitive_begin(pr_linestrip)
	draw_vertex(x0, y0)
	draw_vertex(x1, y0)
	draw_vertex(x1, y1)
	draw_vertex(x0, y1)
	draw_vertex(x0, y0)
	draw_primitive_end()
}
