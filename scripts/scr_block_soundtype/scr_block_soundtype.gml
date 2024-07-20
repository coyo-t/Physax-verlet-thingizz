
function BlockSoundType (_pitch=1, _gain=1, _step_tag=undefined) constructor begin
	
	static step_sounds_generic = get_sound_set("pl_step_generic")
	
	pitch = _pitch
	gain  = _gain
	
	var ss = is_undefined(_step_tag) ? [] : get_sound_set(_step_tag)
	step_sound = array_length(ss) <= 0 ? step_sounds_generic : ss
	
end
