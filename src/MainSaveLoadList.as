import Shared.BSScrollingList;
import gfx.io.GameDelegate;

class MainSaveLoadList extends BSScrollingList
{
	function MainSaveLoadList()
	{
		super();
	}

	function SetEntry(aEntryClip, aEntryObject)
	{
		super.SetEntry(aEntryClip, aEntryObject);
		if (aEntryObject.fileNum != undefined)
		{
			if (aEntryObject.fileNum < 10)
			{
				aEntryClip.SaveNumber.SetText("00" + aEntryObject.fileNum);
			}
			else if (aEntryObject.fileNum < 100)
			{
				aEntryClip.SaveNumber.SetText("0" + aEntryObject.fileNum);
			}
			else
			{
				aEntryClip.SaveNumber.SetText(aEntryObject.fileNum);
			}
		}
		else
		{
			aEntryClip.SaveNumber.SetText(" ");
		}
	}

	function moveSelectionUp()
	{
		super.moveSelectionUp();
		GameDelegate.call("PlaySound", ["UIMenuFocus"]);
	}

	function moveSelectionDown()
	{
		super.moveSelectionDown();
		GameDelegate.call("PlaySound", ["UIMenuFocus"]);
	}
}
