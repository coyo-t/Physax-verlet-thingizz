
vertex_format_begin()
vertex_format_add_position_3d()
vertex_format_add_color()
global.__CHUNK_VERTEX_FORMAT = vertex_format_end()

#macro CHUNK_LAYER_DIRTY (0b01)
#macro CHUNK_LAYER_EMPTY (0b10)

function ChunkLayer () constructor begin
	flags = CHUNK_LAYER_DIRTY
	vb = vertex_create_buffer()
	
	static mark_dirty = function ()
	{
		flags |= CHUNK_LAYER_DIRTY
	}
	
	static is_dirty = function ()
	{
		return (flags & CHUNK_LAYER_DIRTY) <> 0
	}
	
	static mark_empty_if_dirty = function ()
	{
		flags |= CHUNK_LAYER_EMPTY * is_dirty()
	}
	
	static submit = function (_texture=-1)
	{
		if (flags & CHUNK_LAYER_EMPTY) == 0
		{
			vertex_submit(vb, pr_trianglelist, _texture)
		}
	}
	
	static vb_begin = function ()
	{
		vertex_begin(vb, global.__CHUNK_VERTEX_FORMAT)
	}
	
	static vb_end = function ()
	{
		vertex_end(vb)
	}
end

function MapRenderer (_map/*:Map*/) constructor begin
	
	map = _map
	
	
	var lc = BlockRenderLayerIndex.SIZEOF
	var cb = function () {
		var outs = new ChunkLayer()
		outs.flags = CHUNK_LAYER_DIRTY
		return outs
	}
	layers = array_create_ext(lc, cb)
	
	dirty = true
	
	current_colour/*:Colour*/ = c_white
	current_alpha/*:Number*/ = 1.0
	current_layer/*:VertexBuffer*/ = -1

	
	current_x/*:Number*/ = 0
	current_y/*:Number*/ = 0
	current_z/*:Number*/ = 0
	
	static block_changed = function (_x/*:Int*/, _y/*:Int*/, _from/*:Block*/, _to/*:Block*/)
	{
		layers[_from.render_layer_index].mark_dirty()
		layers[_to.render_layer_index].mark_dirty()
		dirty = true
	}
	
	static draw = function ()
	{
		rebuild()

		for (var i =  array_length(layers); i > 0;)
		{
			layers[--i].submit()
		}
	}
	
	static rebuild = function ()
	{
		if not dirty
		{
			return
		}
		
		var lc = array_length(layers)
		for (var i = lc; i > 0;)
		{
			layers[--i].mark_empty_if_dirty()
		}
		
		current_colour = c_white
		current_alpha  = 1.0
		current_depth  = 0
		var wide = map.wide
		var tall = map.tall
		
		for (var yy = 0; yy < tall; yy++)
		{
			for (var xx = 0; xx < wide; xx++)
			{
				var block = map.fastget_block(xx, yy)
				if not block.drawable()
				{
					continue
				}
				var li = block.render_layer_index
				var l = layers[li]
				if (l.flags & CHUNK_LAYER_DIRTY) == 0
				{
					continue
				}
				
				current_layer = l.vb
				if (l.flags & CHUNK_LAYER_EMPTY) <> 0
				{
					l.flags ^= CHUNK_LAYER_EMPTY
					l.vb_begin()
				}
				
				current_x = xx
				current_y = yy
				var shapes = block.get_render_shapes()
				var cbasecol = block.colour
				current_colour = ((xx&1)^(yy&1)==0) ? cbasecol : merge_color(cbasecol, c_black, 0.1)
				for (var i = array_length(shapes); i > 0;)
				{
					var shape = shapes[--i]
					quad(shape)
				}
			}
		}
		for (var i = lc; i > 0;)
		{
			var l = layers[--i]
			// if dirty and not empty
			if (l.flags & (CHUNK_LAYER_EMPTY | CHUNK_LAYER_DIRTY)) == CHUNK_LAYER_DIRTY
			{
				l.vb_end()
				l.flags ^= CHUNK_LAYER_DIRTY
			}
		}
		dirty = false
	}
	
	static get_layer_flag = function (_layer/*:Int*/, _flag)/*->Boolean*/
	{
		return (layer_flags[_layer] & _flag) <> 0
	}
	
	static quad = function (shape/*:Rect*/)
	{
		var x0 = current_x+rect_get_x0(shape)
		var y0 = current_y+rect_get_y0(shape)
		var x1 = current_x+rect_get_x1(shape)
		var y1 = current_y+rect_get_y1(shape)
		vertex(x0, y0)
		vertex(x1, y0)
		vertex(x0, y1)
		
		vertex(x1, y0)
		vertex(x1, y1)
		vertex(x0, y1)
	}
	
	static vertex = function (_x, _y)
	{
		vertex_position_3d(current_layer, _x, _y, current_z)
		vertex_color(current_layer, current_colour, current_alpha)
	}
	
end

/*typealias BlockAreaPredicate = (_block:Block, _shape:Rect, _x:Int, _y:Int) -> Boolean*/

function Map (_wide/*:Int*/, _tall/*:Int*/) constructor begin

	wide/*:Int*/ = _wide;
	tall/*:Int*/ = _tall;
	blocks/*:Grid<Int>*/ = ds_grid_create(_wide, _tall);
	__temp_colliders/*:Array<Rect>*/ = []
	
	listener = undefined
	
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
		var cur = fastget_block(_x, _y)
		if cur == _type
		{
			return false
		}
		blocks[# _x, _y] = _type.runtime_id
		if listener <> undefined
		{
			listener.block_changed(_x, _y, cur, _type)
		}
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

	static fastget_block = function (_x/*:Int*/, _y/*:Int*/)/*->Block*/
	{
		return blocks_get_by_id(blocks[# _x, _y])
	}

	static get_block = function (_x/*:Int*/, _y/*:Int*/) /*-> Block*/
	{
		if _x < 0 or _x >= wide or _y < 0 or _y >= tall
		{
			return get_out_of_bounds_type(_x, _y)
		}
		return fastget_block(_x, _y)
	}
	
	static get_colliders = function (box/*:Rect*/, predicate=undefined) /*-> Array<Rect>*/
	{
		static TEMP = rect_create(0,0,0,0)
		static DEFAULT_PREDICATE = function () { return true }
		
		predicate ??= DEFAULT_PREDICATE
		
		var x0 = floor(rect_get_x0(box)+EPS)
		var x1 = floor(rect_get_x1(box)+1+EPS)
		
		var y0 = floor(rect_get_y0(box)+EPS)
		var y1 = floor(rect_get_y1(box)+1+EPS)
		
		var outs/*: Array<Rect>*/ = []
		for (var yy = y0-1; yy < y1; yy++)
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
					if rect_overlapping(shape, box) and predicate(bloc, shape, xx, yy)
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
