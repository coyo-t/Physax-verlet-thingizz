function host_timescale (_value)
{
	if not is_numeric(_value)
	{
		return "Not a number for time scale"
	}
	try
	{
		with Game
		{
			var ot = timer.time_scale
			timer.time_scale = max(_value, 0)

			return $"Changed time scale from {ot} -> {max(_value, 0)}"
		}
	}
	catch (e)
	{
		return $"OOPS, EXCEPTION!!! {e}"
	}
}
