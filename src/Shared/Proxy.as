class Shared.Proxy
{
	function Proxy()
	{
	}

	static function create(oTarget, fFunction)
	{
		var aParameters = new Array();
		for (var _loc2_ = 2; _loc2_ < arguments.length; _loc2_++)
		{
			aParameters[_loc2_ - 2] = arguments[_loc2_];
		}
		var _loc4_ = function()
		{
			var _loc2_ = arguments.concat(aParameters);
			fFunction.apply(oTarget, _loc2_);
		};
		return _loc4_;
	}
}
