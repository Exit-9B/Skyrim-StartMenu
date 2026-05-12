import Shared.GlobalFunc;
import gfx.ui.InputDetails;

class OptionsList extends Shared.BSScrollingList
{
	var bAllowValueOverwrite: Boolean;

	function OptionsList()
	{
		super();
		bAllowValueOverwrite = false;
	}

	function GetEntryHeight(aiEntryIndex: Number): Number
	{
		var entry: MovieClip = GetClipByIndex(0);
		return entry._height;
	}

	function SetEntry(aEntryClip: MovieClip, aEntryObject: Object): Void
	{
		if (aEntryClip != undefined) {
			aEntryClip.selected = aEntryObject == selectedEntry;
			if (bAllowValueOverwrite || aEntryClip.ID != aEntryObject.ID) {
				aEntryClip.movieType = aEntryObject.movieType;
				switch (aEntryObject.movieType) {
					case 0:
						aEntryClip.SetSliderProperties(aEntryObject.minimum, aEntryObject.maximum, aEntryObject.interval);
						break;

					case 1:
						aEntryClip.SetOptionStepperOptions(aEntryObject.options);
						break;
				}

				aEntryClip.ID = aEntryObject.ID;
				aEntryClip.value = aEntryObject.value;
				aEntryClip.text = aEntryObject.text;
			}
		}
	}

	function onValueChange(aiItemIndex: Number, aiNewValue: Number): Void
	{
		if (aiItemIndex != undefined) {
			EntriesA[aiItemIndex].value = aiNewValue;
		}
		dispatchEvent({type:"valueChange", index: aiItemIndex, value: aiNewValue});
	}

	function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (GlobalFunc.IsKeyPressed(details)) {
			if (details.code == Key.SPACE) {
				_parent.OnStartClicked();
				return true;
			}
		}

		return super.handleInput(details, pathToFocus);
	}
}
