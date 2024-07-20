function Camera () constructor begin
	
	x = 0; ///@is {number}
	y = 0; ///@is {number}
	zoom = 25; ///@is {number}
	rcpzoom = 1 / zoom; ///@is {number}
	aspect = 1; ///@is {number}
	
	static set_zoom = function (_zoom/*:number*/) /*-> void*/
	{
		zoom = _zoom
		rcpzoom = 1 / _zoom
	}
	
	static get_rcp_zoom = function () /*-> number*/
	{
		return rcpzoom
	}

end
