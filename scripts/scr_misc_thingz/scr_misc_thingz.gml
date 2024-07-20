
#macro EPS 0.0000001 // 1.0E-7

///@arg {Array} _array
function array_choose (_array)
{
	return _array[irandom(array_length(_array)-1)]
}

function SimpleCache () constructor begin
	array = []
	cursor = 0
	static reset_cursor = function ()
	{
		cursor = 0
	}
end

// #mfunc iterate(varname, arraylist) as "keyword" \
// begin\
// 	var __ARRAY = (arraylist);\
// 	var iterate_count = array_length(__ARRAY);\
// 	if (iterate_count <> 0){\
// 		varname = __ARRAY[0];\
// 		var iterate_index = 0;\
// 		for (;iterate_index < iterate_count;varname = __ARRAY[iterate_index++])\
// 	}\
// end
