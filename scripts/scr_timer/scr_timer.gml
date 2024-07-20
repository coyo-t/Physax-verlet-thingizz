function Timer (_tps/*: int*/) constructor begin
	static MICROS_PER_SECOND = 1000000
	
	ticksPerSecond = 0
	rcpTps = 0
	pevTime = get_timer()
	ticksPerNs = 0
	wipTick = 0
	deltaTime = 1
	tfac = 0;
	
	time_scale = 1
	
	set_tps(_tps)
	
	static set_tps = function (tps/*:int*/)
	{
		ticksPerSecond = tps
		rcpTps = 1.0 / tps
		ticksPerNs = tps/MICROS_PER_SECOND
	}
	
	static step = function () /*-> int*/
	{
		var now = get_timer()
		deltaTime = (now-pevTime)*ticksPerNs
		pevTime = now
		wipTick += deltaTime * time_scale
		var ticks = floor(wipTick)
		wipTick -= ticks;
		tfac = wipTick
		return ticks
	}
	
	static get_tps = function () /*-> number*/
	{
		return ticksPerSecond
	}
	
	static get_tps_reciprocal = function () /*-> number*/
	{
		return rcpTps
	}
	
	static get_tfac = function () /*-> number*/
	{
		return tfac
	}
end
