// Preserves the tournament-specific Game tab while adding Better Skin Browser.
class SkinBrowserSinglePlayerLoginMenu extends UT2K4SinglePlayerLoginMenu;

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
