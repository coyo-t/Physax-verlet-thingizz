
var ww = max(window_get_width(), 1)
var wh = max(window_get_height(), 1)

if room_width <> ww or room_height <> wh
{
	room_width = ww
	room_height = wh
	surface_resize(application_surface, ww, wh)
}
