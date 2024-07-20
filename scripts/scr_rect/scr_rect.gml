
enum Rect
{
	x0,
	y0,
	x1,
	y1,
	sizeof
}

function rect_create (_x0/*:number*/, _y0/*:number*/, _x1/*:number*/, _y1/*:number*/) /*-> Rect*/
{
	return [_x0, _y0, _x1, _y1]
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

function rect_set_corners (_self/*:Rect*/, _x0/*:number*/, _y0/*:number*/, _x1/*:number*/, _y1/*:number*/) /*-> Rect*/
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

function rect_overlapping (_self/*:Rect*/, _other/*:Rect*/) /*-> bool*/
{
	return _other[Rect.x1]>_self[Rect.x0]&&_other[Rect.x0]<_self[Rect.x1]&&_other[Rect.y1]>_self[Rect.y0]&&_other[Rect.y0]<_self[Rect.y1]
}

function rect_copy (_self/*:Rect*/) /*-> Rect*/
{
	return rect_create(_self[Rect.x0], _self[Rect.y0], _self[Rect.x1], _self[Rect.y1])
}

function rect_expand (_self/*:Rect*/, xofs/*:number*/, yofs/*:number*/) /*-> Rect*/
{
	return rect_create(
		_self[Rect.x0] + (xofs < 0 ? xofs : 0),
		_self[Rect.y0] + (yofs < 0 ? yofs : 0),
		_self[Rect.x1] + (xofs > 0 ? xofs : 0),
		_self[Rect.y1] + (yofs > 0 ? yofs : 0)
	)
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
	if c[Rect.y1] <= _self[Rect.y0] or c[Rect.y0] >= _self[Rect.y1]
	{
		return xa
	}
	if xa > 0 and c[Rect.x1] <= _self[Rect.x0]
	{
		xa = min(xa, _self[Rect.x0] - c[Rect.x1])
	}
	if xa < 0 and c[Rect.x0] >= _self[Rect.x1]
	{
		xa = max(xa, _self[Rect.x1] - c[Rect.x0])
	}
	return xa
}

function rect_clip_y_collide (_self/*:Rect*/, c/*:Rect*/, ya/*:number*/) /*-> number*/
{
	if c[Rect.x1] <= _self[Rect.x0] or c[Rect.x0] >= _self[Rect.x1]
	{
		return ya
	}
	if ya > 0 and c[Rect.y1] <= _self[Rect.y0]
	{
		ya = min(ya, _self[Rect.y0] - c[Rect.y1])
	}
	if ya < 0 and c[Rect.y0] >= _self[Rect.y1]
	{
		ya = max(ya, _self[Rect.y1] - c[Rect.y0])
	}
	return ya
}

function rect_draw (_self/*:Rect*/)
{
	var x0 = _self[0]
	var y0 = _self[1]
	var x1 = _self[2]
	var y1 = _self[3]
	draw_primitive_begin(pr_linestrip)
	draw_vertex(x0, y0)
	draw_vertex(x1, y0)
	draw_vertex(x1, y1)
	draw_vertex(x0, y1)
	draw_vertex(x0, y0)
	draw_primitive_end()
}
