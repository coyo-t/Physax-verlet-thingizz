
vertex_format_begin()
vertex_format_add_position_3d()
vertex_format_add_color()
global.__CHUNK_VERTEX_FORMAT = vertex_format_end() ///@is{vertex_format}

function Map (_wide/*:int*/, _tall/*:int*/) constructor begin

	wide = _wide; ///@is{int}
	tall = _tall; ///@is{int}
	blocks = ds_grid_create(_wide, _tall); /// @is {ds_grid<int>}
	dirty = true; ///@is{bool}
	vb = vertex_create_buffer(); ///@is{vertex_buffer}
	
	static fill_region = function (_x0/*:Int*/, _y0/*:Int*/, _x1/*:Int*/, _y1/*:Int*/, _type/*:Block*/)
	{
		ds_grid_set_region(blocks, _x0, _y0, _x1-1, _y1-1, _type.runtime_id)
	}

	static set_block = function (_x/*:Int*/, _y/*:Int*/, _type/*:Block*/) /*-> Boolean*/
	{
		if not point_in_bounds(_x, _y)
		{
			return false
		}
		var cur = get_block(_x, _y)
		if cur == _type
		{
			return false
		}
		blocks[# _x, _y] = _type.runtime_id
		dirty = true
		return true
	}

	static get_out_of_bounds_type = function (_x/*:Int*/, _y/*:Int*/) /*-> Block*/
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

	static get_block = function (_x/*:Int*/, _y/*:Int*/) /*-> Block*/
	{
		if _x < 0 or _x >= wide or _y < 0 or _y >= tall
		{
			return get_out_of_bounds_type(_x, _y)
		}
		return blocks_get_by_id(blocks[# _x, _y])
	}

	static rebuild = function ()
	{
		if not dirty
		{
			return
		}
		
		vertex_begin(vb, global.__CHUNK_VERTEX_FORMAT)
		for (var yy = 0; yy < tall; yy++)
		{
			for (var xx = 0; xx < wide; xx++)
			{
				var block = get_block(xx, yy)
				if not block.drawable()
				{
					continue
				}
				var shapes = block.get_render_shapes()
				var cbasecol = block.colour
				var c = ((xx&1)^(yy&1)==0) ? cbasecol : merge_color(cbasecol, c_black, 0.1)
				for (var i = array_length(shapes); i > 0;)
				{
					var shape = shapes[--i]
					var x0 = xx+rect_get_x0(shape)
					var y0 = yy+rect_get_y0(shape)
					var x1 = xx+rect_get_x1(shape)
					var y1 = yy+rect_get_y1(shape)
					
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
		}
		vertex_end(vb)
		dirty = false
	}


	static draw = function ()
	{
		rebuild()
		
		vertex_submit(vb, pr_trianglelist, -1)
	}
	
	static get_colliders = function (box/*:Rect*/) /*-> Array<Rect>*/
	{
		static TEMP = rect_create(0,0,0,0)

		var x0 = floor(rect_get_x0(box)+EPS-1)
		var x1 = floor(rect_get_x1(box)+1+EPS)
		
		var y0 = floor(rect_get_y0(box)+EPS-1)
		var y1 = floor(rect_get_y1(box)+1+EPS)
		
		var outs/*: Array<Rect>*/ = []
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
					if rect_overlapping(shape, box)
					{
						array_push(outs, shape)
					}
				}
			}
			
		}
		return outs
	}
	
	static point_in_bounds = function (_x/*:Number*/, _y/*:Number*/) /*-> Boolean*/
	{
		return 0 <= _x and _x < wide and 0 <= _y and _y < tall
	}
end
