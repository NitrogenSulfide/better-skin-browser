// Passive registration shell. UT2004's Mutators tab uses ConfigMenuClassName
// to open the browser without requiring a travel-only GameInfo.
class BetterSkinBrowserMutator extends Mutator;

var string OriginalLoginMenuClass;
var bool bInstalledSkinsTab;

function string IntegratedLoginMenuClass(string MenuClassName)
{
    if (MenuClassName ~= "GUI2K4.UT2K4PlayerLoginMenu")
        return "BetterSkinBrowser.SkinBrowserLoginMenu";
    if (MenuClassName ~= "GUI2K4.UT2K4OnslaughtLoginMenu")
        return "BetterSkinBrowser.SkinBrowserOnslaughtLoginMenu";
    if (MenuClassName ~= "GUI2K4.UT2K4InvasionLoginMenu")
        return "BetterSkinBrowser.SkinBrowserInvasionLoginMenu";
    if (MenuClassName ~= "GUI2K4.UT2K4SinglePlayerLoginMenu")
        return "BetterSkinBrowser.SkinBrowserSinglePlayerLoginMenu";
    return "";
}

function PostBeginPlay()
{
    local DeathMatch DM;
    local string ReplacementClass;

    Super.PostBeginPlay();

    DM = DeathMatch(Level.Game);
    if (DM == None)
    {
        Log("Skins tab unavailable: game is not based on DeathMatch");
        return;
    }

    OriginalLoginMenuClass = DM.LoginMenuClass;
    ReplacementClass = IntegratedLoginMenuClass(OriginalLoginMenuClass);
    if (ReplacementClass == "")
    {
        Log("Skins tab left disabled for custom login menu" @
            OriginalLoginMenuClass);
        return;
    }

    DM.LoginMenuClass = ReplacementClass;
    bInstalledSkinsTab = True;
    Log("Skins tab installed:" @ OriginalLoginMenuClass @ "->" @
        ReplacementClass);
}

function Mutate(string MutateString, PlayerController Sender)
{
    if (MutateString ~= "SkinBrowser")
    {
        if (Sender != None)
            Sender.ClientOpenMenu("BetterSkinBrowser.SkinBrowserPage");
        return;
    }

    Super.Mutate(MutateString, Sender);
}

defaultproperties
{
    ConfigMenuClassName="BetterSkinBrowser.SkinBrowserPage"
    IconMaterialName="MutatorArt.nosym"
    FriendlyName="Better Skin Browser"
    Description="Adds a Skins tab to supported in-match ESC menus for browsing, previewing, and activating installed player skins with matching voices."
    bAddToServerPackages=True
}
