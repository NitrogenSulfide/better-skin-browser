// Preserves Invasion's specialized Game tab while adding Unreal Skin Browser.
class SkinBrowserInvasionLoginMenu extends UT2K4InvasionLoginMenu;

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
