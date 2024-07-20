


#macro EPS 0.0000001 // 1.0E-7

function draw_text_in_world (_x, _y, _s, _sz=1)
{
	var ss = (1/32)*_sz
	draw_text_ext_transformed(_x, _y, _s, 0, 9999, ss, -ss, 0)
}


///@arg {Array} _array
function array_choose (_array)
{
	return _array[irandom(array_length(_array)-1)]
}

function draw_vertex_3d (_x, _y, _z)
{
	gpu_set_depth(_z)
	draw_vertex(_x, _y)
}

function SimpleCache (_create_item) constructor begin
	array = ds_list_create()
	cursor = 0
	create_item = _create_item
	static reset_cursor = function ()
	{
		cursor = 0
	}
	static get = function ()
	{
		if cursor >= ds_list_size(array)
		{
			ds_list_add(array, create_item())
		}
		return array[| cursor++]
	}
	static clear = function ()
	{
		ds_list_clear(array)
		reset_cursor()
	}
	static free = function ()
	{
		ds_list_destroy(array)
		array = undefined
	}
end

function get_sound_set (tag_name/*String*/)/*Array<Sound>*/
{
	return tag_get_asset_ids(tag_name, asset_sound)
}
