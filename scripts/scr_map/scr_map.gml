//!#import array.* in Array
//!#import ds_grid.* in DsGrid
//!#import rect.* in Rect

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
	
	static fill_region = function (_x0/*:int*/, _y0/*:int*/, _x1/*:int*/, _y1/*:int*/, _type/*:Block*/)
	{
		ds_grid_set_region(blocks, _x0, _y0, _x1-1, _y1-1, _type.runtime_id)
	}

	static set_block = function (_x/*:int*/, _y/*:int*/, _type/*: Block*/) /*-> bool*/
	{
		var cur = get_block(_x, _y)
		if cur == _type
		{
			return false
		}
		blocks[# _x, _y] = _type.runtime_id
		dirty = true
		return true
	}

	static get_out_of_bounds_type = function (_x/*:int*/, _y/*:int*/) /*-> Block*/
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

	static get_block = function (_x/*:int*/, _y/*:int*/) /*-> Block*/
	{
		if _x < 0 or _x >= wide or _y < 0 or _y >= tall
		{
			return get_out_of_bounds_type(_x, _y)
		}
		return block_by_id_mf0 blocks[# _x, _y] block_by_id_mf1
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
				var block/*:Block*/ = get_block(xx, yy)
				if not block_is_renderable(block)
				{
					continue
				}
				var shapes/*:Array<Rect>*/ = block.get_render_shapes()
				var cbasecol = block.colour
				var c = ((xx&1)^(yy&1)==0) ? cbasecol : merge_color(cbasecol, c_black, 0.1)
				for (var i = array_length(shapes); i > 0;)
				{
					var shape/*:Rect*/ = shapes[--i]
					var x0 = xx+shape[Rect.x0]
					var y0 = yy+shape[Rect.y0]
					var x1 = xx+shape[Rect.x1]
					var y1 = yy+shape[Rect.y1]
					
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
	
	static get_colliders = function (box/*:Rect*/) /*-> array<Rect>*/
	{
		static TEMP = rect_create(0,0,0,0)

		var x0 = floor(box[Rect.x0]+EPS-1)
		var x1 = floor(box[Rect.x1]+1+EPS)
		
		var y0 = floor(box[Rect.y0]+EPS-1)
		var y1 = floor(box[Rect.y1]+1+EPS)
		
		var outs/*: Array<Rect>*/ = []
		for (var yy = y0; yy < y1; yy++)
		{
			for (var xx = x0; xx < x1; xx++)
			{
				var bloc/*:Block*/ = get_block(xx, yy)
				if not bloc.collideable()
				{
					continue
				}
				var shapes/*: Array<Rect>*/ = bloc.get_colliders(xx, yy)
				
				for (var bb = array_length(shapes); bb > 0;)
				{
					var shape/*:Rect*/ = shapes[--bb]
					if rect_overlapping(shape, box)
					{
						array_push(outs, shape)
					}
				}
			}
			
		}
		return outs
	}
	
	static point_in_bounds = function (_x/*:number*/, _y/*:number*/) /*-> bool*/
	{
		return 0 <= _x and _x < wide and 0 <= _y and _y < tall
	}
end
