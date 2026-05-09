import Shared.GlobalFunc;
import Shared.Proxy;
import gfx.io.GameDelegate;
import gfx.managers.FocusHandler;
import gfx.ui.NavigationCode;

class StartMenu extends MovieClip
{
	var BottomButtons_mc;
	var ButtonRect;
	var ChangeUserButton;
	var CharacterSelectionHint;
	var ConfirmPanel_mc;
	var DLCList_mc;
	var DLCPanel;
	var DeleteButton;
	var DeleteMouseButton;
	var DeleteSaveButton;
	var Error_AgeRestrictOrbis;
	var Error_NeedUpdateOrbis;
	var Error_NotSignedInOrbis;
	var GamerIconLoader;
	var GamerIconRect;
	var GamerIconSize;
	var GamerIcon_mc;
	var GamerTagWidget_mc;
	var GamerTag_mc;
	var LoadingContentMessage;
	var LoginHolder_mc;
	var Logo_mc;
	var MainList;
	var MainListHolder;
	var MarketplaceButton;
	var MessageOfTheDay_mc;
	var SaveLoadConfirmText;
	var SaveLoadListHolder;
	var SaveLoadPanel_mc;
	var VersionText;
	var _BottomButtons_mc;
	var _Header_tf;
	var _LoginHolder_mc;
	var _LoginMenu;
	var _MessageOfTheDay_mc;
	var _Motd_tf;
	var _NeedsLoginScreen;
	var _Sky10UpSell;
	var _Sky10UpSellBG;
	var _Sky10UpSellText;
	var codeObj;
	var fadeOutParams;
	var hasContinueButton;
	var iLoadDLCContentMessageTimerID;
	var iLoadDLCListTimerID;
	var iPlatform;
	var onEnterFrame;
	var shouldProcessInputs;
	var strCurrentState;
	var strFadeOutCallback;

	static var PRESS_START_STATE = "PressStart";
	static var MAIN_STATE = "Main";
	static var MAIN_CONFIRM_STATE = "MainConfirm";
	static var CHARACTER_LOAD_STATE = "CharacterLoad";
	static var CHARACTER_SELECTION_STATE = "CharacterSelection";
	static var SAVE_LOAD_STATE = "SaveLoad";
	static var SAVE_LOAD_CONFIRM_STATE = "SaveLoadConfirm";
	static var DELETE_SAVE_CONFIRM_STATE = "DeleteSaveConfirm";
	static var DLC_STATE = "DLC";
	static var MARKETPLACE_CONFIRM_STATE = "MarketplaceConfirm";
	static var LOGIN_STATE = "Login";

	static var START_ANIM_STR = "StartAnim";
	static var END_ANIM_STR = "EndAnim";

	static var CONTINUE_INDEX = 0;
	static var NEW_INDEX = 1;
	static var LOAD_INDEX = 2;
	static var DLC_INDEX = 3;
	static var SKY10_UPSELL_INDEX = 4;
	static var CREATION_CLUB_INDEX = 5;
	static var DOWNLOAD_ALL_INDEX = 6;
	static var MOD_INDEX = 7;
	static var CREDITS_INDEX = 8;
	static var QUIT_INDEX = 9;
	static var HELP_INDEX = 10;
	static var PS5_DATA_TRANSFER_INDEX = 11;

	static var LOADING_ICON_OFFSET = 50;
	static var DISABLED_GREY_OUT_ALPHA = 50;

	var PS3Switch = false;
	var _codeObjInitialized = false;

	static var PLATFORM_PC_KBMOUSE = 0;
	static var PLATFORM_PC_GAMEPAD = 1;
	static var PLATFORM_DURANGO = 2;
	static var PLATFORM_ORBIS = 3;
	static var PLATFORM_SCARLETT = 4;
	static var PLATFORM_PROSPERO = 5;
	static var ALPHA_AVAILABLE = 100;
	static var ALPHA_DISABLED = 50;
	static var OUT_OF_THE_STAGE = -10000;

	var _Margin = 60;
	var _UserCanAccessCreationClub = true;
	var _CClubAllowedByBnet = true;
	var _ModsAllowedByBnet = true;

	function StartMenu()
	{
		super();
		hasContinueButton = false;
		MainList = MainListHolder.List_mc;
		SaveLoadListHolder = SaveLoadPanel_mc;
		DLCList_mc = DLCPanel.DLCList;
		_LoginHolder_mc = LoginHolder_mc;
		_Sky10UpSell = MainListHolder.Sky10SelectionHint_mc;
		_Sky10UpSellText = MainListHolder.Sky10Text.EntrySky10;
		_Sky10UpSellBG = MainListHolder.bg_Sky10;
		ShowSky10UpsellBanner(false);
		DeleteSaveButton = DeleteButton;
		ChangeUserButton = ChangeUserButton;
		MarketplaceButton = DLCPanel.MarketplaceButton;
		MarketplaceButton._visible = false;
		_BottomButtons_mc = BottomButtons_mc;
		_MessageOfTheDay_mc = MessageOfTheDay_mc;
		_Header_tf = _MessageOfTheDay_mc.Header_tf;
		_Motd_tf = _MessageOfTheDay_mc.Motd_tf;
		_root.CodeObj = codeObj = new Object();
		_root.ReleaseCodeObject = Proxy.create(this, ReleaseCodeObject);
		_root.onCodeObjectInit = Proxy.create(this, onCodeObjectInit);
		CharacterSelectionHint = SaveLoadListHolder.CharacterSelectionHint_mc;
		ShowCharacterSelectionHint(false);
		_root.Error_NotSignedInOrbis = Error_NotSignedInOrbis.text;
		_root.Error_AgeRestrictOrbis = Error_AgeRestrictOrbis.text;
		_root.Error_NeedUpdateOrbis = Error_NeedUpdateOrbis.text;
		Error_NotSignedInOrbis._x = OUT_OF_THE_STAGE;
		Error_AgeRestrictOrbis._x = OUT_OF_THE_STAGE;
		Error_NeedUpdateOrbis._x = OUT_OF_THE_STAGE;
		var _loc5_ = new Object();
		_loc5_.onLoadInit = Proxy.create(this, OnLoginLoadInit);
		var _loc4_ = new MovieClipLoader();
		_loc4_.addListener(_loc5_);
		_loc4_.loadClip("BethesdaNetLogin.swf", _LoginHolder_mc);
		_Header_tf.textAutoSize = "shrink";
		SetMotd("");
		onEnterFrame = Proxy.create(this, Init);
	}

	function Init()
	{
		trace("StartMenu::Init" + iPlatform.toString() + ", PS3Switch = " + PS3Switch.toString());
		_BottomButtons_mc.SetPlatform(iPlatform, PS3Switch);
		_BottomButtons_mc.Margin = _Margin;
		onEnterFrame = null;
	}

	function OnLoginLoadInit(mc)
	{
		mc._visible = false;
		mc.onEnterFrame = Proxy.create(this, OnLoginLoadInitFinished, mc);
	}

	function OnLoginLoadInitFinished(mc)
	{
		trace("StartMenu::OnLoginLoadInitFinished" + iPlatform.toString() + ", PS3Switch = " + PS3Switch.toString());
		if (_LoginHolder_mc.LoginMenu_mc.Constructed)
		{
			_LoginHolder_mc.onEnterFrame = null;
			_LoginHolder_mc._visible = strCurrentState == LOGIN_STATE;
			_LoginMenu = _LoginHolder_mc.LoginMenu_mc;
			_LoginMenu.ShowLoadOrderButton = false;
			_LoginMenu.InitView();
			_LoginMenu.CodeObject = codeObj;
			_LoginMenu.SetPlatform(iPlatform, PS3Switch);
			_LoginMenu.SetBottomButtons(_BottomButtons_mc);
			_LoginMenu.addEventListener(BethesdaNetLogin.LOGIN_CANCELED, Proxy.create(this, onLoginCanceled));
			_LoginMenu.addEventListener(BethesdaNetLogin.LOGIN_ERROR, Proxy.create(this, onLoginError));
			codeObj.initLogin(this, _LoginMenu);
			if (strCurrentState == LOGIN_STATE)
			{
				codeObj.BeginLogin();
			}
			else
			{
				codeObj.GetBnetUpdate();
			}
		}
	}

	function onCodeObjectInit()
	{
		_codeObjInitialized = true;
	}

	function ReleaseCodeObject()
	{
		_LoginMenu.Destroy();
		delete codeObj;
		delete _root.CodeObj;
	}

	function InitExtensions()
	{
		trace("StartMenu::InitExtensions");
		GlobalFunc.SetLockFunction();
		_parent.Lock("BR");
		Logo_mc.Lock("BL");
		Logo_mc._y -= 80;
		GamerTagWidget_mc.Lock("TL");
		GamerTag_mc = GamerTagWidget_mc.GamerTag_mc;
		GamerIcon_mc = GamerTagWidget_mc.GamerIcon_mc;
		GamerIconSize = GamerIcon_mc._width;
		GamerIconLoader = new MovieClipLoader();
		GamerIconLoader.addListener(this);
		GameDelegate.addCallBack("sendMenuProperties", this, "setupMainMenu");
		GameDelegate.addCallBack("ConfirmNewGame", this, "ShowConfirmScreen");
		GameDelegate.addCallBack("ConfirmContinue", this, "ShowConfirmScreen");
		GameDelegate.addCallBack("FadeOutMenu", this, "DoFadeOutMenu");
		GameDelegate.addCallBack("FadeInMenu", this, "DoFadeInMenu");
		GameDelegate.addCallBack("onProfileChange", this, "onProfileChange");
		GameDelegate.addCallBack("StartLoadingDLC", this, "StartLoadingDLC");
		GameDelegate.addCallBack("DoneLoadingDLC", this, "DoneLoadingDLC");
		GameDelegate.addCallBack("ShowGamerTagAndIcon", this, "ShowGamerTagAndIcon");
		GameDelegate.addCallBack("OnDeleteSaveUISanityCheck", this, "OnDeleteSaveUISanityCheck");
		GameDelegate.addCallBack("OnSaveDataEventLoadSUCCESS", this, "OnSaveDataEventLoadSUCCESS");
		GameDelegate.addCallBack("OnSaveDataEventLoadCANCEL", this, "OnSaveDataEventLoadCANCEL");
		GameDelegate.addCallBack("onStartButtonProcessFinished", this, "onStartButtonProcessFinished");
		MainList.addEventListener("itemPress", this, "onMainButtonPress");
		MainList.addEventListener("listPress", this, "onMainListPress");
		MainList.addEventListener("listMovedUp", this, "onMainListMoveUp");
		MainList.addEventListener("listMovedDown", this, "onMainListMoveDown");
		MainList.addEventListener("selectionChange", this, "onMainListMouseSelectionChange");
		ButtonRect.handleInput = function()
		{
			return false;
		};
		ButtonRect.AcceptMouseButton.addEventListener("click", this, "onAcceptMousePress");
		ButtonRect.CancelMouseButton.addEventListener("click", this, "onCancelMousePress");
		ButtonRect.AcceptMouseButton.SetPlatform(0, false);
		ButtonRect.CancelMouseButton.SetPlatform(0, false);
		SaveLoadListHolder.addEventListener("loadGameSelected", this, "ConfirmLoadGame");
		SaveLoadListHolder.addEventListener("saveListPopulated", this, "OnSaveListOpenSuccess");
		SaveLoadListHolder.addEventListener("saveListCharactersPopulated", this, "OnsaveListCharactersOpenSuccess");
		SaveLoadListHolder.addEventListener("saveListOnBatchAdded", this, "OnSaveListBatchAdded");
		SaveLoadListHolder.addEventListener("OnCharacterSelected", this, "OnCharacterSelected");
		SaveLoadListHolder.addEventListener("saveHighlighted", this, "onSaveHighlight");
		SaveLoadListHolder.addEventListener("OnSaveLoadPanelBackClicked", Proxy.create(this, OnSaveLoadPanelBackClicked));
		SaveLoadListHolder.List_mc.addEventListener("listPress", this, "onSaveLoadListPress");
		DeleteSaveButton._alpha = ALPHA_AVAILABLE;
		DeleteMouseButton._alpha = ALPHA_AVAILABLE;
		MarketplaceButton._alpha = ALPHA_DISABLED;
		DeleteSaveButton._x = - DeleteSaveButton.textField.textWidth - LOADING_ICON_OFFSET;
		DeleteMouseButton._x = DeleteSaveButton._x;
		ChangeUserButton._x = - ChangeUserButton.textField.textWidth - LOADING_ICON_OFFSET;
		DLCList_mc._visible = false;
		CharacterSelectionHint.addEventListener("OnMousePressCharacterChange", Proxy.create(this, OnMousePressCharacterChange));
	}

	function setupMainMenu()
	{
		trace("StartMenu::setupMainMenu" + iPlatform.toString() + ", PS3Switch = " + PS3Switch.toString());
		var _loc11_ = 0;
		var _loc5_ = 1;
		var _loc7_ = 2;
		var _loc14_ = 3;
		var _loc8_ = 4;
		var _loc16_ = 5;
		var _loc13_ = 6;
		var _loc9_ = 7;
		var _loc10_ = 8;
		var _loc12_ = 9;
		var _loc15_ = 10;
		var _loc18_ = 11;
		var _loc17_ = 12;
		var _loc6_ = 13;
		var _loc4_ = NEW_INDEX;
		if (MainList.entryList.length > 0)
		{
			_loc4_ = MainList.centeredEntry.index;
		}
		MainList.ClearList();
		if (arguments[_loc5_])
		{
			hasContinueButton = true;
			MainList.entryList.push({text:"$CONTINUE", index:CONTINUE_INDEX, disabled:false, showIcon:false});
			if (_loc4_ == NEW_INDEX)
			{
				_loc4_ = CONTINUE_INDEX;
			}
		}
		MainList.entryList.push({text:"$NEW", index:NEW_INDEX, disabled:false, showIcon:false});
		MainList.entryList.push({text:"$LOAD", disabled:!arguments[_loc5_], index:LOAD_INDEX, showIcon:false});
		if (arguments[_loc18_] && iPlatform == PLATFORM_PROSPERO)
		{
			MainList.entryList.push({text:"$TRANSFER DATA", index:PS5_DATA_TRANSFER_INDEX, disabled:false, showIcon:false});
		}
		if (arguments[_loc16_] == true)
		{
			MainList.entryList.push({text:"$DOWNLOADABLE CONTENT", index:DLC_INDEX, disabled:false, showIcon:false});
		}
		if (arguments[_loc10_])
		{
			MainList.entryList.push({text:"$CREATIONS",disabled:!arguments[_loc6_], index:CREATION_CLUB_INDEX, showIcon:arguments[_loc17_]});
		}
		_UserCanAccessCreationClub = arguments[_loc6_];
		trace("StartMenu::setupMainMenu Can access Marketplace = " + _UserCanAccessCreationClub.toString());
		MainList.GetClipByIndex(CREATION_CLUB_INDEX).alpha = !(_UserCanAccessCreationClub && this._CClubAllowedByBnet) ? DISABLED_GREY_OUT_ALPHA : 100;
		ShowSky10UpsellBanner(false);
		if (arguments[_loc8_] == true)
		{
			ShowSky10UpsellBanner(true);
		}
		if (!arguments[_loc15_])
		{
		}
		if (arguments[_loc9_])
		{
			MainList.entryList.push({text:"$MOD MANAGER", disabled:false, index:MOD_INDEX, showIcon:false});
		}
		MainList.entryList.push({text:"$CREDITS", index:CREDITS_INDEX, disabled:false, showIcon:false});
		if (arguments[_loc11_])
		{
			MainList.entryList.push({text:"$QUIT", index:QUIT_INDEX, disabled:false, showIcon:false});
		}
		if (arguments[_loc13_])
		{
			MainList.entryList.push({text:"$HELP", index:HELP_INDEX, disabled:false, showIcon:false});
		}
		for (var _loc3_ = 0; _loc3_ < MainList.entryList.length; _loc3_++)
		{
			if (MainList.entryList[_loc3_].index == _loc4_)
			{
				MainList.RestoreScrollPosition(_loc3_, false);
			}
		}
		MainList.InvalidateData();
		_NeedsLoginScreen = !arguments[_loc12_];
		if (currentState == undefined)
		{
			if (arguments[_loc14_])
			{
				StartState(PRESS_START_STATE);
			}
			else if (_NeedsLoginScreen)
			{
				StartState(LOGIN_STATE);
			}
			else
			{
				StartState(MAIN_STATE);
			}
		}
		else if (currentState == SAVE_LOAD_STATE || currentState == SAVE_LOAD_CONFIRM_STATE || currentState == DELETE_SAVE_CONFIRM_STATE)
		{
			StartState(MAIN_STATE);
		}
		if (arguments[_loc7_] != undefined)
		{
			VersionText.SetText("v " + arguments[_loc7_]);
		}
		else
		{
			VersionText.SetText(" ");
		}
	}

	function ShowGamerTagAndIcon(strGamerTag)
	{
		if (strGamerTag.length > 0)
		{
			GlobalFunc.MaintainTextFormat();
			GamerTag_mc.GamerTagText_tf.text = strGamerTag;
			GamerTag_mc.visible = true;
			GamerIconRect = GamerIcon_mc.createEmptyMovieClip("GamerIconRect", getNextHighestDepth());
			GamerIconLoader.loadClip("img://BGSUserIcon", GamerIconRect);
		}
		else
		{
			GamerTag_mc.visible = false;
			GamerIcon_mc.visible = false;
		}
	}

	function onLoadInit(aTargetClip)
	{
		aTargetClip._width = GamerIconSize;
		aTargetClip._height = GamerIconSize;
	}

	function OnDeleteSaveUISanityCheck(aHasRecentSave, aCanLoadGame)
	{
		var _loc8_ = false;
		if (hasContinueButton)
		{
			if (!aHasRecentSave)
			{
				if (MainList.entryList[0].index == CONTINUE_INDEX)
				{
					MainList.entryList.shift();
				}
				MainList.RestoreScrollPosition(1, true);
				_loc8_ = true;
			}
		}
		if (!aCanLoadGame)
		{
			for (var _loc2_ = 0; _loc2_ < MainList.maxEntries; _loc2_++)
			{
				if (MainList.entryList[_loc2_].index == LOAD_INDEX)
				{
					MainList.entryList.splice(_loc2_, 1, {text:"$LOAD", disabled:true, index:LOAD_INDEX, textColor:0x606060, showIcon:false});
					_loc8_ = true;
					MainList.RestoreScrollPosition(0, false);
					break;
				}
			}
		}
		if (_loc8_)
		{
			MainList.InvalidateData();
		}
	}

	function ShowCharacterSelectionHint(abFlag)
	{
		CharacterSelectionHint._visible = false;
	}

	function ShowSky10UpsellBanner(abFlag)
	{
		_Sky10UpSellText.SetText("$Skyrim 10th Anniversary Available Now!");
		_Sky10UpSell._visible = abFlag;
		_Sky10UpSellText._visible = abFlag;
		_Sky10UpSellBG._visible = abFlag;
	}

	function OnSaveDataEventLoadSUCCESS()
	{
		ShowCharacterSelectionHint(false);
		if (IsPlatformSony())
		{
			onCancelPress();
		}
	}

	function OnSaveDataEventLoadCANCEL()
	{
		if (IsPlatformSony())
		{
			RequestCharacterListLoad();
		}
	}

	function get currentState()
	{
		return strCurrentState;
	}

	function set currentState(strNewState)
	{
		GameDelegate.call("currentState", [strNewState]);
		if (strNewState == MAIN_STATE)
		{
			MainList.disableSelection = false;
		}
		if (strNewState != strCurrentState)
		{
			ShouldProcessInputs = true;
		}
		if (IsPlatformSony())
		{
			ShowDeleteButtonHelp(strNewState == CHARACTER_SELECTION_STATE);
		}
		else
		{
			ShowDeleteButtonHelp(strNewState == SAVE_LOAD_STATE);
		}
		ShowChangeUserButtonHelp(strNewState == MAIN_STATE);
		ShowCharacterSelectionHint(strNewState == SAVE_LOAD_STATE);
		SaveLoadListHolder.ShowSelectionButtons(strNewState == SAVE_LOAD_STATE || strNewState == CHARACTER_SELECTION_STATE);
		strCurrentState = strNewState;
		ChangeStateFocus(strNewState);
	}

	function get ShouldProcessInputs()
	{
		return shouldProcessInputs;
	}

	function set ShouldProcessInputs(abFlag)
	{
		shouldProcessInputs = abFlag;
	}

	function handleInput(details, pathToFocus)
	{
		var _loc5_;
		var _loc4_;
		var _loc3_;
		if (IsPlatformSony() && currentState == PRESS_START_STATE)
		{
			if (GlobalFunc.IsKeyPressed(details))
			{
				GameDelegate.call("EndPressStartState", []);
			}
		}
		else if (pathToFocus.length > 0 && !pathToFocus[0].handleInput(details, pathToFocus.slice(1)))
		{
			if (GlobalFunc.IsKeyPressed(details) && ShouldProcessInputs)
			{
				if (details.navEquivalent == NavigationCode.ENTER)
				{
					onAcceptPress();
				}
				else if (details.navEquivalent == NavigationCode.TAB)
				{
					onCancelPress();
				}
				else if ((details.navEquivalent == NavigationCode.GAMEPAD_X || details.code == 88) && DeleteSaveButton._visible && DeleteSaveButton._alpha == ALPHA_AVAILABLE)
				{
					if (IsPlatformSony())
					{
						_loc5_ = SaveLoadListHolder.selectedEntry;
						if (_loc5_ != undefined)
						{
							_loc4_ = _loc5_.flags;
							if (_loc4_ == undefined)
							{
								_loc4_ = 0;
							}
							_loc3_ = _loc5_.id;
							if (_loc3_ == undefined)
							{
								_loc3_ = 4294967295;
							}
						}
						GameDelegate.call("ORBISDeleteSave", [_loc3_, _loc4_]);
					}
					else
					{
						ConfirmDeleteSave();
					}
				}
				else if ((details.navEquivalent == NavigationCode.GAMEPAD_Y || details.code == 84) && strCurrentState == SAVE_LOAD_STATE && !SaveLoadListHolder.isSaving)
				{
					GameDelegate.call("PlaySound", ["UIMenuCancel"]);
					EndState();
				}
				else if ((details.navEquivalent == NavigationCode.GAMEPAD_X || details.code == 88) && currentState == MAIN_STATE)
				{
					GameDelegate.call("Sky10DLCPressed", []);
				}
				else if (details.navEquivalent == NavigationCode.GAMEPAD_Y && currentState == DLC_STATE && MarketplaceButton._visible && MarketplaceButton._alpha == ALPHA_AVAILABLE)
				{
					SaveLoadConfirmText.textField.SetText("$Open Xbox LIVE Marketplace?");
					SetPlatform(iPlatform, PS3Switch);
					StartState(MARKETPLACE_CONFIRM_STATE);
				}
				else if (details.navEquivalent == NavigationCode.GAMEPAD_Y && currentState == MAIN_STATE && ChangeUserButton._visible)
				{
					GameDelegate.call("ChangeUser", []);
				}
			}
		}
		return true;
	}

	function onMouseButtonDeleteSaveClick()
	{
		if (DeleteSaveButton._alpha == ALPHA_AVAILABLE)
		{
			ConfirmDeleteSave();
		}
	}

	function onMouseButtonDeleteRollOver()
	{
		GameDelegate.call("PlaySound", ["UIMenuFocus"]);
	}

	function onStartButtonProcessFinished()
	{
		EndState(PRESS_START_STATE);
	}

	function onAcceptPress()
	{
		switch (strCurrentState)
		{
			case MAIN_CONFIRM_STATE:
				if (MainList.selectedEntry.index == NEW_INDEX)
				{
					GameDelegate.call("PlaySound", ["UIStartNewGame"]);
					FadeOutAndCall("StartNewGame");
				}
				else if (MainList.selectedEntry.index == CONTINUE_INDEX)
				{
					GameDelegate.call("PlaySound", ["UIMenuOK"]);
					FadeOutAndCall("ContinueLastSavedGame");
				}
				else if (MainList.selectedEntry.index == QUIT_INDEX)
				{
					GameDelegate.call("PlaySound", ["UIMenuOK"]);
					GameDelegate.call("QuitToDesktop", []);
				}
				break;
			case CHARACTER_SELECTION_STATE:
				GameDelegate.call("PlaySound", ["UIMenuOK"]);
				break;
			case SAVE_LOAD_CONFIRM_STATE:
				GameDelegate.call("PlaySound", ["UIMenuOK"]);
				FadeOutAndCall("LoadGame", [SaveLoadListHolder.selectedIndex]);
				break;
			case DELETE_SAVE_CONFIRM_STATE:
				SaveLoadListHolder.DeleteSelectedSave();
				if (SaveLoadListHolder.numSaves == 0)
				{
					GameDelegate.call("DoDeleteSaveUISanityCheck", []);
					StartState(MAIN_STATE);
				}
				else
				{
					EndState();
				}
				break;
			case MARKETPLACE_CONFIRM_STATE:
				GameDelegate.call("PlaySound", ["UIMenuOK"]);
				GameDelegate.call("OpenMarketplace", []);
				StartState(MAIN_STATE);
			default:
				return;
		}
	}

	function isConfirming()
	{
		return strCurrentState == DEFAULT_SETTINGS_CONFIRM_STATE || strCurrentState == SAVE_LOAD_CONFIRM_STATE || strCurrentState == DELETE_SAVE_CONFIRM_STATE || strCurrentState == MARKETPLACE_CONFIRM_STATE || strCurrentState == MAIN_CONFIRM_STATE;
	}

	function onAcceptMousePress()
	{
		if (isConfirming())
		{
			onAcceptPress();
		}
	}

	function OnMousePressCharacterChange(evt)
	{
		GameDelegate.call("PlaySound", ["UIMenuCancel"]);
		EndState();
	}

	function onCancelMousePress()
	{
		if (isConfirming())
		{
			onCancelPress();
		}
	}

	function onCancelPress()
	{
		switch (strCurrentState)
		{
			case SAVE_LOAD_STATE:
				currentState = CHARACTER_SELECTION_STATE;
				EndState();
				SaveLoadListHolder.ForceStopLoading();
				SaveLoadListHolder.RemoveScreenshot();
				break;
			case CHARACTER_SELECTION_STATE:
			case MAIN_CONFIRM_STATE:
			case SAVE_LOAD_CONFIRM_STATE:
			case DELETE_SAVE_CONFIRM_STATE:
			case DLC_STATE:
			case MARKETPLACE_CONFIRM_STATE:
				GameDelegate.call("PlaySound", ["UIMenuCancel"]);
				EndState();
			default:
				return;
		}
	}

	function onMainButtonPress(event)
	{
		if (strCurrentState == MAIN_STATE || iPlatform == 0)
		{
			switch (event.entry.index)
			{
				case CONTINUE_INDEX:
					GameDelegate.call("CONTINUE",[]);
					GameDelegate.call("PlaySound",["UIMenuOK"]);
					return;
				case NEW_INDEX:
					GameDelegate.call("NEW",[]);
					GameDelegate.call("PlaySound",["UIMenuOK"]);
					return;
				case QUIT_INDEX:
					ShowConfirmScreen("$Quit to desktop?  Any unsaved progress will be lost.");
					GameDelegate.call("PlaySound",["UIMenuOK"]);
					return;
				case LOAD_INDEX:
					if (!event.entry.disabled)
					{
						SaveLoadListHolder.isSaving = false;
						RequestCharacterListLoad();
					}
					else
					{
						GameDelegate.call("OnDisabledLoadPress", []);
					}
					return;
				case PS5_DATA_TRANSFER_INDEX:
					GameDelegate.call("OnPS5DataTransfer", []);
					GameDelegate.call("PlaySound", ["UIMenuOK"]);
					return;
				case DLC_INDEX:
					this.StartState(DLC_STATE);
					return;
				case CREDITS_INDEX:
					this._MessageOfTheDay_mc.visible = false;
					this.FadeOutAndCall("OpenCreditsMenu");
					return;
				case HELP_INDEX:
					GameDelegate.call("HELP", []);
					GameDelegate.call("PlaySound", ["UIMenuOK"]);
					return;
				case MOD_INDEX:
					if (this._ModsAllowedByBnet)
					{
						this._MessageOfTheDay_mc.visible = false;
						GameDelegate.call("MOD", []);
						GameDelegate.call("PlaySound", ["UIMenuOK"]);
					}
					else
					{
						this.codeObj.ModsBlockedByBnet();
						GameDelegate.call("PlaySound", ["UIMenuCancel"]);
					}
					return;
				case SKY10_UPSELL_INDEX:
					GameDelegate.call("Sky10DLCPressed", []);
					return;
				case CREATION_CLUB_INDEX:
					if (_CClubAllowedByBnet)
					{
						if (_UserCanAccessCreationClub)
						{
							_MessageOfTheDay_mc.visible = false;
							GameDelegate.call("CreationClub", []);
							GameDelegate.call("PlaySound", ["UIMenuOK"]);
						}
						else
						{
							this.codeObj.CClubBlockedByPermissions();
							GameDelegate.call("PlaySound", ["UIMenuCancel"]);
						}
					}
					else
					{
						this.codeObj.CClubBlockedByBnet();
						GameDelegate.call("PlaySound", ["UIMenuCancel"]);
					}
					return;
				case DOWNLOAD_ALL_INDEX:
					if (!event.entry.disabled)
					{
						GameDelegate.call("DownloadAll", []);
					}
					GameDelegate.call("PlaySound", ["UIMenuOK"]);
					return;
				default:
					GameDelegate.call("PlaySound", ["UIMenuCancel"]);
					return;
			}
		}
	}

	function RequestCharacterListLoad()
	{
		GameDelegate.call("PopulateCharacterList", [SaveLoadListHolder.List_mc.entryList, SaveLoadListHolder.batchSize]);
		StartState(CHARACTER_LOAD_STATE);
	}

	function onMainListPress(event)
	{
		onCancelPress();
	}

	function onPCQuitButtonPress(event)
	{
		if (event.index == 0)
		{
			GameDelegate.call("QuitToMainMenu", []);
		}
		else if (event.index == 1)
		{
			GameDelegate.call("QuitToDesktop", []);
		}
	}

	function onSaveLoadListPress()
	{
		onAcceptPress();
	}

	function onMainListMoveUp(event)
	{
		GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true)
		{
			MainList._parent.gotoAndPlay("moveUp");
		}
	}

	function onMainListMoveDown(event)
	{
		GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true)
		{
			MainList._parent.gotoAndPlay("moveDown");
		}
	}

	function onMainListMouseSelectionChange(event)
	{
		if (event.keyboardOrMouse == 0 && event.index != -1)
		{
			GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		}
	}

	function SetPlatform(aiPlatform, abPS3Switch)
	{
		ButtonRect.AcceptGamepadButton._visible = aiPlatform != 0;
		ButtonRect.CancelGamepadButton._visible = aiPlatform != 0;
		ButtonRect.AcceptMouseButton._visible = aiPlatform == 0;
		ButtonRect.CancelMouseButton._visible = aiPlatform == 0;
		_Sky10UpSell.SetPlatform(aiPlatform, abPS3Switch);
		var _loc4_ = DeleteSaveButton._visible;
		if (aiPlatform == PLATFORM_PC_KBMOUSE)
		{
			DeleteSaveButton._visible = false;
			DeleteMouseButton.label = DeleteSaveButton.label;
			DeleteMouseButton._x = DeleteButton._x;
			DeleteMouseButton.trackAsMenu = true;
			DeleteSaveButton = DeleteMouseButton;
			DeleteSaveButton.onPress = Proxy.create(this, onMouseButtonDeleteSaveClick);
			DeleteSaveButton.addEventListener("rollOver", Proxy.create(this, onMouseButtonDeleteRollOver));
		}
		else if (aiPlatform == PLATFORM_PC_GAMEPAD && DeleteSaveButton == DeleteMouseButton)
		{
			DeleteSaveButton._visible = false;
			DeleteSaveButton = DeleteButton;
			DeleteSaveButton.onPress = undefined;
			DeleteMouseButton.removeEventListeners("rollOver", Proxy.create(this, onMouseButtonDeleteRollOver));
		}
		else
		{
			DeleteMouseButton._visible = false;
		}
		ShowDeleteButtonHelp(_loc4_);
		DeleteSaveButton.SetPlatform(aiPlatform, abPS3Switch);
		ChangeUserButton.SetPlatform(aiPlatform, abPS3Switch);
		MarketplaceButton.SetPlatform(aiPlatform, abPS3Switch);
		MainListHolder.SelectionArrow._visible = aiPlatform != 0;
		if (aiPlatform != 0)
		{
			ButtonRect.AcceptGamepadButton.SetPlatform(aiPlatform, abPS3Switch);
			ButtonRect.CancelGamepadButton.SetPlatform(aiPlatform, abPS3Switch);
		}
		CharacterSelectionHint.SetPlatform(aiPlatform, abPS3Switch);
		MarketplaceButton._visible = false;
		if (iPlatform == undefined)
		{
			DLCPanel.warningText.SetText("$Loading downloadable content..." + (!IsPlatformSony() ? "" : "_PS3"));
			LoadingContentMessage.Message_mc.textField.SetText("$Loading extra content." + (!IsPlatformSony() ? "" : "_PS3"));
		}
		iPlatform = aiPlatform;
		SaveLoadListHolder.SetPlatform(aiPlatform, abPS3Switch);
		PS3Switch = abPS3Switch;
		MainList.SetPlatform(aiPlatform, abPS3Switch);
	}

	function DoFadeOutMenu()
	{
		FadeOutAndCall();
	}

	function DoFadeInMenu()
	{
		_parent.gotoAndPlay("fadeIn");
		EndState();
	}

	function FadeOutAndCall(strCallback, paramList)
	{
		strFadeOutCallback = strCallback;
		fadeOutParams = paramList;
		_parent.gotoAndPlay("fadeOut");
		GameDelegate.call("fadeOutStarted", []);
	}

	function onFadeOutCompletion()
	{
		if (strFadeOutCallback != undefined && strFadeOutCallback.length > 0)
		{
			if (fadeOutParams != undefined)
			{
				GameDelegate.call(strFadeOutCallback, fadeOutParams);
			}
			else
			{
				GameDelegate.call(strFadeOutCallback, []);
			}
		}
	}

	function StartState(strStateName)
	{
		GameDelegate.call("StartState", [strStateName]);
		ShouldProcessInputs = false;
		if (strStateName == LOGIN_STATE)
		{
			strCurrentState = strStateName;
			if (_LoginMenu != null)
			{
				_LoginHolder_mc._visible = true;
				codeObj.BeginLogin();
			}
			return undefined;
		}
		if (strStateName == CHARACTER_SELECTION_STATE)
		{
			SaveLoadListHolder.isShowingCharacterList = true;
		}
		else if (strStateName == SAVE_LOAD_STATE)
		{
			SaveLoadListHolder.isShowingCharacterList = false;
		}
		else if (strStateName == DLC_STATE)
		{
			ShowMarketplaceButtonHelp(false);
		}
		if (strCurrentState == MAIN_STATE)
		{
			MainList.disableSelection = true;
			_MessageOfTheDay_mc.visible = _Motd_tf.text.length > 1;
		}
		ShowDeleteButtonHelp(false);
		ShowChangeUserButtonHelp(false);
		SaveLoadListHolder.ShowSelectionButtons(false);
		strCurrentState = strStateName + START_ANIM_STR;
		gotoAndPlay(strCurrentState);
		FocusHandler.instance.setFocus(this, 0);
	}

	function EndState()
	{
		if (strCurrentState == DLC_STATE)
		{
			ShowMarketplaceButtonHelp(false);
		}
		if (strCurrentState == LOGIN_STATE)
		{
			_LoginHolder_mc._visible = false;
			_BottomButtons_mc._visible = false;
			return undefined;
		}
		if (strCurrentState == PRESS_START_STATE && _NeedsLoginScreen)
		{
			StartState(LOGIN_STATE);
		}
		else if (strCurrentState != MAIN_STATE)
		{
			strCurrentState += END_ANIM_STR;
			gotoAndPlay(strCurrentState);
		}
		if (strCurrentState == SAVE_LOAD_CONFIRM_STATE || strCurrentState == DELETE_SAVE_CONFIRM_STATE)
		{
			SaveLoadListHolder.ShowSelectionButtons(true);
		}
	}

	function ChangeStateFocus(strNewState)
	{
		switch (strNewState)
		{
			case MAIN_STATE:
				FocusHandler.instance.setFocus(MainList, 0);
				break;
			case CHARACTER_SELECTION_STATE:
			case SAVE_LOAD_STATE:
				FocusHandler.instance.setFocus(SaveLoadListHolder.List_mc, 0);
				SaveLoadListHolder.List_mc.disableSelection = false;
				break;
			case DLC_STATE:
				this.iLoadDLCListTimerID = setInterval(this, "DoLoadDLCList", 500);
				FocusHandler.instance.setFocus(DLCList_mc, 0);
				break;
			case MAIN_CONFIRM_STATE:
			case SAVE_LOAD_CONFIRM_STATE:
			case DELETE_SAVE_CONFIRM_STATE:
			case PRESS_START_STATE:
			case MARKETPLACE_CONFIRM_STATE:
				FocusHandler.instance.setFocus(ButtonRect, 0);
			default:
				return;
		}
	}

	function ShowConfirmScreen(astrConfirmText)
	{
		ConfirmPanel_mc.textField.SetText(astrConfirmText);
		SetPlatform(iPlatform, PS3Switch);
		StartState(MAIN_CONFIRM_STATE);
	}

	function OnSaveListOpenSuccess()
	{
		if (SaveLoadListHolder.numSaves > 0 && strCurrentState.indexOf(SAVE_LOAD_STATE) == -1)
		{
			GameDelegate.call("PlaySound", ["UIMenuOK"]);
			StartState(SAVE_LOAD_STATE);
		}
		else
		{
			GameDelegate.call("PlaySound", ["UIMenuCancel"]);
		}
	}

	function OnsaveListCharactersOpenSuccess()
	{
		if (strCurrentState == CHARACTER_LOAD_STATE || strCurrentState == "CharacterLoadStartAnim")
		{
			SaveLoadListHolder.isShowingCharacterList = true;
			ShowCharacterSelectionHint(false);
			GameDelegate.call("PlaySound", ["UIMenuOK"]);
			StartState(CHARACTER_SELECTION_STATE);
		}
		else
		{
			GameDelegate.call("PlaySound", ["UIMenuCancel"]);
		}
	}

	function OnSaveListBatchAdded()
	{
		if (SaveLoadListHolder.numSaves > 0 && strCurrentState == SAVE_LOAD_STATE)
		{
			ShowCharacterSelectionHint(true);
		}
	}

	function OnCharacterSelected()
	{
		if (!IsPlatformSony())
		{
			StartState(SAVE_LOAD_STATE);
		}
	}

	function onSaveHighlight(event)
	{
		DeleteSaveButton._alpha = event.index != -1 ? ALPHA_AVAILABLE : ALPHA_DISABLED;
		if (iPlatform == 0)
		{
			GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		}
	}

	function ConfirmLoadGame(event)
	{
		SaveLoadListHolder.List_mc.disableSelection = true;
		SaveLoadConfirmText.textField.SetText("$Load this game?");
		SetPlatform(iPlatform, PS3Switch);
		StartState(SAVE_LOAD_CONFIRM_STATE);
	}

	function ConfirmDeleteSave()
	{
		SaveLoadListHolder.List_mc.disableSelection = true;
		SaveLoadConfirmText.textField.SetText("$Delete this save?");
		SetPlatform(iPlatform, PS3Switch);
		StartState(DELETE_SAVE_CONFIRM_STATE);
	}

	function ShowDeleteButtonHelp(abFlag)
	{
		DeleteSaveButton.disabled = !abFlag;
		DeleteSaveButton._visible = abFlag;
		VersionText._visible = !abFlag;
	}

	function ShowChangeUserButtonHelp(abFlag)
	{
		if (IsPlatformXBox())
		{
			ChangeUserButton.disabled = !abFlag;
			ChangeUserButton._visible = abFlag;
			VersionText._visible = !abFlag;
		}
		else
		{
			ChangeUserButton.disabled = true;
			ChangeUserButton._visible = false;
		}
	}

	function ShowMarketplaceButtonHelp(abFlag)
	{
		if (IsPlatformXBox())
		{
			MarketplaceButton._visible = abFlag;
			VersionText._visible = !abFlag;
		}
		else
		{
			MarketplaceButton._visible = false;
		}
	}

	function ShowPressStartState()
	{
		if (strCurrentState != PRESS_START_STATE)
		{
			StartState(PRESS_START_STATE);
		}
	}

	function StartLoadingDLC()
	{
		LoadingContentMessage.gotoAndPlay("startFadeIn");
		clearInterval(iLoadDLCContentMessageTimerID);
		iLoadDLCContentMessageTimerID = setInterval(this, "onLoadingDLCMessageFadeCompletion", 1000);
	}

	function onLoadingDLCMessageFadeCompletion()
	{
		clearInterval(iLoadDLCContentMessageTimerID);
		GameDelegate.call("DoLoadDLCPlugins", []);
	}

	function DoneLoadingDLC()
	{
		LoadingContentMessage.gotoAndPlay("startFadeOut");
	}

	function DoLoadDLCList()
	{
		clearInterval(iLoadDLCListTimerID);
		DLCList_mc.entryList.splice(0, DLCList_mc.entryList.length);
		GameDelegate.call("LoadDLC", [DLCList_mc.entryList], this, "UpdateDLCPanel");
	}

	function UpdateDLCPanel(abMarketplaceAvail, abNewDLCAvail)
	{
		if (DLCList_mc.entryList.length > 0)
		{
			DLCList_mc._visible = true;
			DLCPanel.warningText.SetText(" ");
			if (iPlatform != 0)
			{
				DLCList_mc.selectedIndex = 0;
			}
			DLCList_mc.InvalidateData();
		}
		else
		{
			DLCList_mc._visible = false;
			DLCPanel.warningText.SetText("$No content downloaded" + (!IsPlatformSony() ? "" : "_PS3"));
		}
		MarketplaceButton._visible = false;
		if (abNewDLCAvail == true)
		{
			DLCPanel.NewContentAvail.SetText("$New content available");
		}
	}

	function OnSaveLoadPanelSelectClicked()
	{
		onAcceptPress();
	}

	function OnSaveLoadPanelBackClicked()
	{
		onCancelPress();
	}

	function onLoginCanceled(event)
	{
		if (strCurrentState == LOGIN_STATE)
		{
			EndState();
			StartState(MAIN_STATE);
		}
	}

	function onLoginError(event)
	{
	}

	function OnLoginSuccess()
	{
		EndState();
		StartState(MAIN_STATE);
	}

	function SetMotd(motdText)
	{
		_Motd_tf.text = motdText;
		_MessageOfTheDay_mc._visible = _Motd_tf.text.length > 1;
	}

	function UpdateBnetStatus(cclubUp, modsUp)
	{
		trace("StartMenu::UpdateBnetStatus:  CC = " + cclubUp.toString() + ", Mods = " + modsUp.toString());
		_CClubAllowedByBnet = cclubUp;
		_ModsAllowedByBnet = modsUp;
		MainList.GetClipByIndex(CREATION_CLUB_INDEX).alpha = !(_UserCanAccessCreationClub && _CClubAllowedByBnet) ? DISABLED_GREY_OUT_ALPHA : 100;
		MainList.GetClipByIndex(MOD_INDEX).alpha = !_ModsAllowedByBnet ? DISABLED_GREY_OUT_ALPHA : 100;
	}

	function IsPlatformSony()
	{
		return iPlatform == PLATFORM_ORBIS || iPlatform == PLATFORM_PROSPERO;
	}

	function IsPlatformXBox()
	{
		return iPlatform == PLATFORM_DURANGO || iPlatform == PLATFORM_SCARLETT;
	}
}
