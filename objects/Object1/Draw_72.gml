
var ww = window_get_width()
var wh = window_get_height()

if ww <> room_width or wh <> room_height
{
	room_width = ww
	room_height = wh
	surface_resize(application_surface, ww, wh)
}

matrix_push(matrix_view)
matrix_push(matrix_projection)

cam.aspect = room_width / room_height

var asp = cam.aspect 
var zoom = cam.zoom

var depth_range = 1600

begin
	var tfac = timer.get_tfac()
	var hurt = lerp(player_previous_fall_hurt_time, player_fall_hurt_time, tfac)*timer.get_tps_reciprocal()
	matrix_stack_push(matrix_build(0,0,0, 0,0,hurt*22.5, 1,1,1))
end

matrix_stack_push(matrix_build(-cam.x, -cam.y, depth_range/2, 0,0,0, 1,1,1))

m_view = matrix_stack_top()
matrix_stack_clear()

m_proj = matrix_build_projection_ortho(asp*zoom, 1*zoom, -depth_range, +depth_range)


matrix_set(matrix_view, m_view)
matrix_set(matrix_projection, m_proj)

