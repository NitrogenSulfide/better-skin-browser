// Standard Deathmatch, Team Deathmatch, CTF, and compatible stock login menu.
class SkinBrowserLoginMenu extends UT2K4PlayerLoginMenu;

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
