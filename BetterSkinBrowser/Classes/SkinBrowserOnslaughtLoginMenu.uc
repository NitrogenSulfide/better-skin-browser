// Preserves Onslaught's Map tab while adding Better Skin Browser.
class SkinBrowserOnslaughtLoginMenu extends UT2K4OnslaughtLoginMenu;

var() GUITabItem SkinBrowserTab;

function AddPanels()
{
    Panels[Panels.Length] = SkinBrowserTab;
    Super.AddPanels();
}

defaultproperties
{
    SkinBrowserTab=(ClassName="BetterSkinBrowser.SkinBrowserPanel",Caption="Skins",Hint="Browse and activate installed player skins")
}
