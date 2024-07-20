event_inherited();

matrix_push(matrix_view)
matrix_push(matrix_projection)

cam.aspect = room_width / room_height

var asp = cam.aspect 
var zoom = cam.zoom

var depth_range = 1600

matrix_stack_push(matrix_build(-cam.x, -cam.y, depth_range/2, 0,0,0, 1,1,1))

m_view = matrix_stack_top()
matrix_stack_clear()

m_proj = matrix_build_projection_ortho(asp*zoom, 1*zoom, -depth_range, +depth_range)


matrix_set(matrix_view, m_view)
matrix_set(matrix_projection, m_proj)




