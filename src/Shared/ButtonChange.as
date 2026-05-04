import gfx.events.EventDispatcher;

class Shared.ButtonChange extends EventDispatcher
{
	var dispatchEvent;

	static var PLATFORM_PC = 0;
	static var PLATFORM_PC_GAMEPAD = 1;
	static var PLATFORM_360 = 2;
	static var PLATFORM_PS3 = 3;
	static var PLATFORM_SCARLETT = 4;
	static var PLATFORM_PROSPERO = 5;

	var iCurrPlatform = PLATFORM_360;

	function ButtonChange()
	{
		super();
		EventDispatcher.initialize(this);
	}

	function get Platform()
	{
		return this.iCurrPlatform;
	}

	function IsGamepadConnected()
	{
		return this.iCurrPlatform == PLATFORM_PC_GAMEPAD || this.iCurrPlatform == PLATFORM_360 || this.iCurrPlatform == PLATFORM_PS3 || this.iCurrPlatform == PLATFORM_SCARLETT || this.iCurrPlatform == PLATFORM_PROSPERO;
	}

	function SetPlatform(aSetPlatform, aSetSwapPS3)
	{
		this.iCurrPlatform = aSetPlatform;
		this.dispatchEvent({target:this, type:"platformChange", aPlatform:aSetPlatform, aSwapPS3:aSetSwapPS3});
	}

	function SetPS3Swap(aSwap)
	{
		this.dispatchEvent({target:this, type:"SwapPS3Button", Boolean:aSwap});
	}
}
