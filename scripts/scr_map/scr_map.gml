///@arg {Real} _wide
///@arg {Real} _tall
function Map (_wide, _tall) constructor begin
	static format = (function () {
		vertex_format_begin()
		vertex_format_add_position_3d()
		vertex_format_add_color()
		return vertex_format_end()
	})()
	
	///@type {Real}
	wide = _wide
	///@type {Real}
	tall = _tall
	///@type {Id.DsGrid<Real>}
	blocks = ds_grid_create(_wide, _tall)
	///@type {Bool}
	dirty = true

	ds_grid_set_region(blocks, 0, 0, wide-1, 0, global.stone.id)

	vb = vertex_create_buffer()

	///@arg {Real} _x
	///@arg {Real} _y
	///@arg {Struct.Block} _type
	static set_block = function (_x, _y, _type)
	{
		var cur = get_block(_x, _y)
		if cur == _type
		{
			return false
		}
		blocks[# _x, _y] = _type.id
		dirty = true
		return true
	}

	///@arg {Real} _x
	///@arg {Real} _y
	///@returns {Struct.Block}
	static get_block = function (_x, _y)
	{
		if _x < 0 or _x >= wide or _y < 0 or _y >= tall
		{
			if _y < 0
			{
				return global.out_of_bounds
			}
			else
			{
				return global.air
			}
		}
		return global.blocks_all[blocks[# _x, _y]]
	}

	static rebuild = function ()
	{
		if not dirty
		{
			return
		}
		
		vertex_begin(vb, format)
		for (var yy = 0; yy < tall; yy++)
		{
			for (var xx = 0; xx < wide; xx++)
			{
				var block = get_block(xx, yy)
				if not block.drawable()
				{
					continue
				}
				var sh = block.shape
				var x0 = xx+sh.x0
				var y0 = yy+sh.y0
				var x1 = xx+sh.x1
				var y1 = yy+sh.y1
				var cbasecol = block.colour
				var c = ((xx&1)^(yy&1)==0) ? cbasecol : merge_color(cbasecol, c_black, 0.1)
				vertex_position_3d(vb, x0, y0, 0)
				vertex_color(vb, c, 1)
				vertex_position_3d(vb, x1, y0, 0)
				vertex_color(vb, c, 1)
				vertex_position_3d(vb, x0, y1, 0)
				vertex_color(vb, c, 1)

				vertex_position_3d(vb, x1, y0, 0)
				vertex_color(vb, c, 1)
				vertex_position_3d(vb, x1, y1, 0)
				vertex_color(vb, c, 1)
				vertex_position_3d(vb, x0, y1, 0)
				vertex_color(vb, c, 1)

			}
		}
		vertex_end(vb)
		dirty = false
	}


	static draw = function ()
	{
		rebuild()
		
		vertex_submit(vb, pr_trianglelist, -1)
	}
	
	///@arg {Struct.Rect} box
	///@returns {Array<Struct.Rect>}
	static get_colliders = function (box)
	{
		static TEMP = new Rect(0,0,0,0)

		var x0 = floor(box.x0+EPS-1)
		var x1 = floor(box.x1+1+EPS)
		
		var y0 = floor(box.y0+EPS-1)
		var y1 = floor(box.y1+1+EPS)
		
		var outs = []
		for (var yy = y0; yy < y1; yy++)
		{
			for (var xx = x0; xx < x1; xx++)
			{
				var bloc = get_block(xx, yy)
				if not bloc.collideable()
				{
					continue
				}
				var shapes = bloc.get_colliders(xx, yy)
				
				for (var bb = array_length(shapes); bb > 0;)
				{
					var shape = shapes[--bb]
					if shape.overlapping(box)
					{
						array_push(outs, shape)
					}
				}
			}
			
		}
		return outs
	}
	
	static point_in_bounds = function (_x, _y)
	{
		return 0 <= _x and _x < wide and 0 <= _y and _y < tall
	}
end
