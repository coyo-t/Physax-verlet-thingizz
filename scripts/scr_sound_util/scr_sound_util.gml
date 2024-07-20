

function get_sound_set (tag_name/*:string*/) /*-> array<sound>*/
{
	return tag_get_asset_ids(tag_name, asset_sound)
}

