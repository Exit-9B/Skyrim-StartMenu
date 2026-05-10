import Shared.Proxy;
import gfx.events.EventDispatcher;
import gfx.io.GameDelegate;

class SettingsPanel extends MovieClip
{
	var textField: TextField;
	var HelpText: TextField;
	var List_mc: OptionsList;
	var CharacterSelectionHint_mc: MovieClip;
	var StartGamepadButton: MovieClip;
	var BackGamepadButton: MovieClip;
	var StartMouseButton: MovieClip;
	var BackMouseButton: MovieClip;

	var PS3Switch: Boolean;
	var SettingsList_mc: MovieClip;
	var dispatchEvent: Function;
	var iPlatform: Number;

	static var SCREENSHOT_DELAY = 750;
	static var CONTROLLER_PC = 0;
	static var CONTROLLER_PC_GAMEPAD = 1;
	static var CONTROLLER_DURANGO = 2;
	static var CONTROLLER_ORBIS = 3;
	static var CONTROLLER_SCARLETT = 4;
	static var CONTROLLER_PROSPERO = 5;

	function SettingsPanel()
	{
		super();
		EventDispatcher.initialize(this);
		SettingsList_mc = List_mc;
		HelpText.text = "";
		HelpText.verticalAlign = "bottom";
    textField.verticalAlign = "bottom";
	}

	function onLoad()
	{
		SettingsList_mc.addEventListener("itemPress", this, "onSettingsItemPress");
		SettingsList_mc.addEventListener("selectionChange", this, "onSettingsItemHighlight");
		SettingsList_mc.addEventListener("valueChange", this, "onOptionChange");
	}

	function get selectedIndex()
	{
		return SettingsList_mc.selectedIndex;
	}

	function get platform()
	{
		return iPlatform;
	}

	function SetPlatform(aiPlatform, abPS3Switch)
	{
		trace("SettingsPanel::SetPlatform " + aiPlatform.toString() + ", abPS3Switch = " + abPS3Switch.toString());
		iPlatform = aiPlatform;
		PS3Switch = abPS3Switch;
		if (iPlatform == SettingsPanel.CONTROLLER_PC)
		{
			BackMouseButton.SetPlatform(iPlatform);
			StartMouseButton.SetPlatform(iPlatform);
			BackMouseButton.addEventListener("click", Proxy.create(this, OnBackClicked));
			StartMouseButton.addEventListener("click", Proxy.create(this, OnStartClicked));
		}
		else
		{
			BackGamepadButton.SetPlatform(iPlatform, PS3Switch);
			StartGamepadButton.SetPlatform(iPlatform, PS3Switch);
		}

		BackMouseButton._visible =
		StartMouseButton._visible =
			iPlatform == SettingsPanel.CONTROLLER_PC;

		BackGamepadButton._visible =
		StartGamepadButton._visible =
			iPlatform != SettingsPanel.CONTROLLER_PC;
	}

	function get selectedEntry()
	{
		return SettingsList_mc.entryList[SettingsList_mc.selectedIndex];
	}

	function ShowSelectionButtons(show)
	{
		if (iPlatform == SettingsPanel.CONTROLLER_PC)
		{
			StartMouseButton._visible =
			BackMouseButton._visible = show;
		}
		else
		{
			StartGamepadButton._visible =
			BackGamepadButton._visible = show;
		}
		textField._visible = show;
	}

	function InvalidateData(astrConfirmText)
	{
		List_mc.InvalidateData();
		textField.SetText(astrConfirmText);

		var numEntries = List_mc.entryList.length;
		List_mc.selectedIndex = (numEntries == 1 || iPlatform != 0) ? 0 : -1;
		textField._visible = true;
	}

	function ResetSettingsToDefaults()
	{
		for (var i: String in List_mc.entryList) {
			if (List_mc.entryList[i].defaultVal != undefined) {
				List_mc.entryList[i].value = List_mc.entryList[i].defaultVal;
				GameDelegate.call("OptionChange", [List_mc.entryList[i].ID, List_mc.entryList[i].value]);
			}
		}
		List_mc.bAllowValueOverwrite = true;
		List_mc.UpdateList();
		List_mc.bAllowValueOverwrite = false;
	}

	function SaveSettings()
	{
		GameDelegate.call("SaveSettings", []);
	}

	function SetHelpText(aiIndex: Number)
	{
		var help;
		if (aiIndex != -1)
		{
			var entry = SettingsList_mc.EntriesA[aiIndex];
			if (entry.movieType == 1 && entry.help instanceof Array)
			{
				var index = entry.value;
				if (index < entry.help.length)
				{
					help = entry.help[index];
				}
			}
			else
			{
				help = entry.help;
			}
		}

		HelpText.SetText(help != undefined ? help : "");
	}

	function onSettingsItemHighlight(event)
	{
		SetHelpText(event.index);
		dispatchEvent({type:"settingHighlighted", index:SettingsList_mc.selectedIndex});
	}

	function onOptionChange(event)
	{
		if (event.index == SettingsList_mc.selectedIndex)
		{
			SetHelpText(event.index);
		}
	}

	function OnStartClicked()
	{
		dispatchEvent({type:"OnSettingsPanelStartClicked"});
	}

	function OnBackClicked()
	{
		dispatchEvent({type:"OnSettingsPanelBackClicked"});
	}

	function IsPlatformSony()
	{
		return iPlatform == CONTROLLER_ORBIS || iPlatform == CONTROLLER_PROSPERO;
	}

	function IsPlatformXBox()
	{
		return iPlatform == CONTROLLER_DURANGO || iPlatform == CONTROLLER_SCARLETT;
	}
}
