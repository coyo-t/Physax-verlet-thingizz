
#macro EPS 0.0000001 // 1.0E-7

///@arg {Array} _array
function array_choose (_array)
{
	return _array[irandom(array_length(_array)-1)]
}
