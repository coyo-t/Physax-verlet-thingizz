function Camera () constructor begin
	
	///@type {Real}
	x = 0
	///@type {Real}
	y = 0
	///@type {Real}
	zoom = 25
	///@type {Real}
	rcpzoom = 1 / zoom
	///@type {Real}
	aspect = 1
	
	///@func set_zoom(_zoom)
	///@arg {Real} _zoom
	static set_zoom = function (_zoom)
	{
		zoom = _zoom
		rcpzoom = 1 / _zoom
	}
	
	///@func get_rcp_zoom
	static get_rcp_zoom = function () { return rcpzoom }

end
