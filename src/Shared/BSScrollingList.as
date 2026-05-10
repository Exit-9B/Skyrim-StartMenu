import Shared.GlobalFunc;
import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;

class Shared.BSScrollingList extends MovieClip
{
	var EntriesA;
	var ListScrollbar;
	var ScrollDown;
	var ScrollUp;
	var bDisableInput;
	var bDisableSelection;
	var bListAnimating;
	var bMouseDrivenNav;
	var border;
	var dispatchEvent;
	var fListHeight;
	var iListItemsShown;
	var iMaxItemsShown;
	var iMaxScrollPosition;
	var iPlatform;
	var iScrollPosition;
	var iScrollbarDrawTimerID;
	var iSelectedIndex;
	var iTextOption;
	var itemIndex;
	var onMousePress;
	var scrollbar;

	static var TEXT_OPTION_NONE = 0;
	static var TEXT_OPTION_SHRINK_TO_FIT = 1;
	static var TEXT_OPTION_MULTILINE = 2;

	function BSScrollingList()
	{
		super();
		this.EntriesA = new Array();
		this.bDisableSelection = false;
		this.bDisableInput = false;
		this.bMouseDrivenNav = false;
		EventDispatcher.initialize(this);
		Mouse.addListener(this);
		this.iSelectedIndex = -1;
		this.iScrollPosition = 0;
		this.iMaxScrollPosition = 0;
		this.iListItemsShown = 0;
		this.iPlatform = 1;
		this.fListHeight = this.border._height;
		this.ListScrollbar = this.scrollbar;
		this.iMaxItemsShown = 0;
		var _loc3_ = this.GetClipByIndex(this.iMaxItemsShown);
		while (_loc3_ != undefined)
		{
			_loc3_.clipIndex = this.iMaxItemsShown;
			_loc3_.onRollOver = function()
			{
				if (!this._parent.listAnimating && !this._parent.bDisableInput && this.itemIndex != undefined)
				{
					this._parent.doSetSelectedIndex(this.itemIndex, 0);
					this._parent.bMouseDrivenNav = true;
				}
			};
			_loc3_.onPress = function(aiMouseIndex, aiKeyboardOrMouse)
			{
				if (this.itemIndex != undefined)
				{
					this._parent.onItemPress(aiKeyboardOrMouse);
					if (!this._parent.bDisableInput && this.onMousePress != undefined)
					{
						this.onMousePress();
					}
				}
			};
			_loc3_.onPressAux = function(aiMouseIndex, aiKeyboardOrMouse, aiButtonIndex)
			{
				if (this.itemIndex != undefined)
				{
					this._parent.onItemPressAux(aiKeyboardOrMouse, aiButtonIndex);
				}
			};
			_loc3_ = this.GetClipByIndex(++this.iMaxItemsShown);
		}
	}

	function onLoad()
	{
		if (this.ListScrollbar != undefined)
		{
			this.ListScrollbar.position = 0;
			this.ListScrollbar.addEventListener("scroll", this, "onScroll");
		}
	}

	function ClearList()
	{
		this.EntriesA.splice(0, this.EntriesA.length);
	}

	function GetClipByIndex(aiIndex)
	{
		return this["Entry" + aiIndex];
	}

	function handleInput(details, pathToFocus)
	{
		var _loc2_ = false;
		var _loc4_;
		if (!this.bDisableInput)
		{
			_loc4_ = this.GetClipByIndex(this.selectedIndex - this.scrollPosition);
			_loc2_ = _loc4_ != undefined && _loc4_.handleInput != undefined && _loc4_.handleInput(details, pathToFocus.slice(1));
			if (!_loc2_ && GlobalFunc.IsKeyPressed(details))
			{
				if (details.navEquivalent == NavigationCode.UP)
				{
					this.moveSelectionUp();
					_loc2_ = true;
				}
				else if (details.navEquivalent == NavigationCode.DOWN)
				{
					this.moveSelectionDown();
					_loc2_ = true;
				}
				else if (!this.bDisableSelection && details.navEquivalent == NavigationCode.ENTER)
				{
					this.onItemPress();
					_loc2_ = true;
				}
			}
		}
		return _loc2_;
	}

	function onMouseWheel(delta)
	{
		var _loc2_;
		if (!this.bDisableInput)
		{
			for (_loc2_ = Mouse.getTopMostEntity(); _loc2_ && _loc2_ != undefined; _loc2_ = _loc2_._parent)
			{
				if (_loc2_ == this)
				{
					this.doSetSelectedIndex(-1, 0);
					if (delta < 0)
					{
						this.scrollPosition += 1;
					}
					else if (delta > 0)
					{
						this.scrollPosition -= 1;
					}
				}
			}
		}
	}

	function get selectedIndex()
	{
		return this.iSelectedIndex;
	}

	function set selectedIndex(aiNewIndex)
	{
		this.doSetSelectedIndex(aiNewIndex);
	}

	function get length()
	{
		return this.EntriesA.length;
	}

	function get listAnimating()
	{
		return this.bListAnimating;
	}

	function set listAnimating(abFlag)
	{
		this.bListAnimating = abFlag;
	}

	function doSetSelectedIndex(aiNewIndex, aiKeyboardOrMouse)
	{
		var _loc2_;
		if (!this.bDisableSelection && aiNewIndex != this.iSelectedIndex)
		{
			_loc2_ = this.iSelectedIndex;
			this.iSelectedIndex = aiNewIndex;
			if (_loc2_ != -1)
			{
				this.SetEntry(this.GetClipByIndex(this.EntriesA[_loc2_].clipIndex), this.EntriesA[_loc2_]);
			}
			if (this.iSelectedIndex != -1)
			{
				if (this.iPlatform != 0)
				{
					if (this.iSelectedIndex < this.iScrollPosition)
					{
						this.scrollPosition = this.iSelectedIndex;
					}
					else if (this.iSelectedIndex >= this.iScrollPosition + this.iListItemsShown)
					{
						this.scrollPosition = Math.min(this.iSelectedIndex - this.iListItemsShown + 1, this.iMaxScrollPosition);
					}
					else
					{
						this.SetEntry(this.GetClipByIndex(this.EntriesA[this.iSelectedIndex].clipIndex), this.EntriesA[this.iSelectedIndex]);
					}
				}
				else
				{
					this.SetEntry(this.GetClipByIndex(this.EntriesA[this.iSelectedIndex].clipIndex), this.EntriesA[this.iSelectedIndex]);
				}
			}
			this.dispatchEvent({type:"selectionChange", index:this.iSelectedIndex, keyboardOrMouse:aiKeyboardOrMouse});
		}
	}

	function get scrollPosition()
	{
		return this.iScrollPosition;
	}

	function get maxScrollPosition()
	{
		return this.iMaxScrollPosition;
	}

	function set scrollPosition(aiNewPosition)
	{
		if (aiNewPosition != this.iScrollPosition && aiNewPosition >= 0 && aiNewPosition <= this.iMaxScrollPosition)
		{
			if (this.ListScrollbar != undefined)
			{
				this.ListScrollbar.position = aiNewPosition;
			}
			else
			{
				this.updateScrollPosition(aiNewPosition);
			}
		}
	}

	function updateScrollPosition(aiPosition)
	{
		this.iScrollPosition = aiPosition;
		this.UpdateList();
	}

	function get selectedEntry()
	{
		return this.EntriesA[this.iSelectedIndex];
	}

	function get entryList()
	{
		return this.EntriesA;
	}

	function set entryList(anewArray)
	{
		this.EntriesA = anewArray;
	}

	function get disableSelection()
	{
		return this.bDisableSelection;
	}

	function set disableSelection(abFlag)
	{
		this.bDisableSelection = abFlag;
	}

	function get disableInput()
	{
		return this.bDisableInput;
	}

	function set disableInput(abFlag)
	{
		this.bDisableInput = abFlag;
	}

	function get maxEntries()
	{
		return this.iMaxItemsShown;
	}

	function get textOption()
	{
		return this.iTextOption;
	}

	function set textOption(strNewOption)
	{
		if (strNewOption == "None")
		{
			this.iTextOption = TEXT_OPTION_NONE;
		}
		else if (strNewOption == "Shrink To Fit")
		{
			this.iTextOption = TEXT_OPTION_SHRINK_TO_FIT;
		}
		else if (strNewOption == "Multi-Line")
		{
			this.iTextOption = TEXT_OPTION_MULTILINE;
		}
	}

	function UpdateList()
	{
		var y_start = this.GetClipByIndex(0)._y;
		for (var i = 0; i < this.iScrollPosition; i++)
		{
			this.EntriesA[i].clipIndex = undefined;
		}
		this.iListItemsShown = 0;
		var y_offset = 0;
		for (var i = this.iScrollPosition;
			i < this.EntriesA.length && this.iListItemsShown < this.iMaxItemsShown && y_offset <= this.fListHeight;
			i++)
		{
			var entryClip = this.GetClipByIndex(this.iListItemsShown);
			this.SetEntry(entryClip,this.EntriesA[i]);
			this.EntriesA[i].clipIndex = this.iListItemsShown;
			entryClip.itemIndex = i;
			entryClip._y = y_start + y_offset;
			entryClip._visible = true;
			y_offset += entryClip._height;
			if (y_offset <= this.fListHeight && this.iListItemsShown < this.iMaxItemsShown)
			{
				this.iListItemsShown++;
			}
		}
		for (var i = this.iListItemsShown; i < this.iMaxItemsShown; i++)
		{
			this.GetClipByIndex(i)._visible = false;
		}
		if (this.ScrollUp != undefined)
		{
			this.ScrollUp._visible = this.scrollPosition > 0;
		}
		if (this.ScrollDown != undefined)
		{
			this.ScrollDown._visible = this.scrollPosition < this.iMaxScrollPosition;
		}
	}

	function InvalidateData()
	{
		var _loc2_ = this.iMaxScrollPosition;
		this.fListHeight = this.border._height;
		this.CalculateMaxScrollPosition();
		if (this.ListScrollbar != undefined)
		{
			if (_loc2_ != this.iMaxScrollPosition)
			{
				this.ListScrollbar._visible = false;
				this.ListScrollbar.setScrollProperties(this.iMaxItemsShown, 0, this.iMaxScrollPosition);
				if (this.iScrollbarDrawTimerID != undefined)
				{
					clearInterval(this.iScrollbarDrawTimerID);
				}
				this.iScrollbarDrawTimerID = setInterval(this, "SetScrollbarVisibility", 50);
			}
			else
			{
				this.SetScrollbarVisibility();
			}
		}
		if (this.iSelectedIndex >= this.EntriesA.length)
		{
			this.iSelectedIndex = this.EntriesA.length - 1;
		}
		if (this.iScrollPosition > this.iMaxScrollPosition)
		{
			this.iScrollPosition = this.iMaxScrollPosition;
		}
		this.UpdateList();
	}

	function SetScrollbarVisibility()
	{
		clearInterval(this.iScrollbarDrawTimerID);
		this.iScrollbarDrawTimerID = undefined;
		this.ListScrollbar._visible = this.iMaxScrollPosition > 0;
	}

	function CalculateMaxScrollPosition()
	{
		var _loc3_ = 0;
		var _loc2_ = this.EntriesA.length - 1;
		while (_loc2_ >= 0 && _loc3_ <= this.fListHeight)
		{
			_loc3_ += this.GetEntryHeight(_loc2_);
			if (_loc3_ <= this.fListHeight)
			{
				_loc2_--;
			}
		}
		this.iMaxScrollPosition = _loc2_ + 1;
	}

	function GetEntryHeight(aiEntryIndex)
	{
		var _loc2_ = this.GetClipByIndex(0);
		this.SetEntry(_loc2_, this.EntriesA[aiEntryIndex]);
		return _loc2_._height;
	}

	function moveSelectionUp()
	{
		if (this.EntriesA.length != 1)
		{
			if (!this.bDisableSelection)
			{
				if (this.selectedIndex > 0)
				{
					this.selectedIndex -= 1;
				}
			}
			else
			{
				this.scrollPosition -= 1;
			}
		}
	}

	function moveSelectionDown()
	{
		if (this.EntriesA.length != 1)
		{
			if (!this.bDisableSelection)
			{
				if (this.selectedIndex < this.EntriesA.length - 1)
				{
					this.selectedIndex += 1;
				}
			}
			else
			{
				this.scrollPosition += 1;
			}
		}
	}

	function onItemPress(aiKeyboardOrMouse)
	{
		if (!this.bDisableInput && !this.bDisableSelection && this.iSelectedIndex != -1)
		{
			this.dispatchEvent({type:"itemPress", index:this.iSelectedIndex, entry:this.EntriesA[this.iSelectedIndex], keyboardOrMouse:aiKeyboardOrMouse});
		}
		else
		{
			this.dispatchEvent({type:"listPress"});
		}
	}

	function onItemPressAux(aiKeyboardOrMouse, aiButtonIndex)
	{
		if (!this.bDisableInput && !this.bDisableSelection && this.iSelectedIndex != -1 && aiButtonIndex == 1)
		{
			this.dispatchEvent({type:"itemPressAux", index:this.iSelectedIndex, entry:this.EntriesA[this.iSelectedIndex], keyboardOrMouse:aiKeyboardOrMouse});
		}
	}

	function SetEntry(aEntryClip, aEntryObject)
	{
		if (aEntryClip != undefined)
		{
			if (aEntryObject == this.selectedEntry)
			{
				aEntryClip.gotoAndStop("Selected");
			}
			else
			{
				aEntryClip.gotoAndStop("Normal");
			}
			this.SetEntryText(aEntryClip, aEntryObject);
		}
	}

	function SetEntryText(aEntryClip, aEntryObject)
	{
		if (aEntryClip.textField != undefined)
		{
			if (this.textOption == TEXT_OPTION_SHRINK_TO_FIT)
			{
				aEntryClip.textField.textAutoSize = "shrink";
			}
			else if (this.textOption == TEXT_OPTION_MULTILINE)
			{
				aEntryClip.textField.verticalAutoSize = "top";
			}
			if (aEntryObject.text != undefined)
			{
				aEntryClip.textField.SetText(aEntryObject.text);
			}
			else
			{
				aEntryClip.textField.SetText(" ");
			}
			if (aEntryObject.enabled != undefined)
			{
				aEntryClip.textField.textColor = aEntryObject.enabled == false ? 6316128 : 16777215;
			}
			if (aEntryObject.disabled != undefined)
			{
				aEntryClip.textField.textColor = aEntryObject.disabled == true ? 6316128 : 16777215;
			}
		}
	}

	function SetPlatform(aiPlatform, abPS3Switch)
	{
		this.iPlatform = aiPlatform;
		this.bMouseDrivenNav = this.iPlatform == 0;
	}

	function onScroll(event)
	{
		this.updateScrollPosition(Math.floor(event.position + 0.5));
	}
}
