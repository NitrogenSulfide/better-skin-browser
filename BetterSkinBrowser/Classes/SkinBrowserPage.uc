// Standalone wrapper used by Configure Mutators and mutate skinbrowser.
class SkinBrowserPage extends LockedFloatingWindow;

var automated SkinBrowserWidget Browser;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    // The shared widget frames its list and preview in both entry points.
    sb_Main.SetVisibility(False);
    b_OK.SetVisibility(False);
    b_OK.DisableMe();
    b_Cancel.SetVisibility(False);
    b_Cancel.DisableMe();

    Browser.CloseButton.SetVisibility(True);
    Browser.CloseButton.EnableMe();
    Browser.InitializeBrowser();
}

function bool PageKeyEvent(out byte Key, out byte State, float Delta)
{
    return Browser.PageKeyEvent(Key, State, Delta);
}

defaultproperties
{
    Begin Object Class=SkinBrowserWidget Name=BrowserContent
        bBoundToParent=True
        bScaleToParent=True
    End Object
    Browser=SkinBrowserWidget'BetterSkinBrowser.SkinBrowserPage.BrowserContent'

    // This page can be opened directly from an in-match mutate command. Let
    // the GUI stack become empty when it closes so ESC returns to gameplay.
    bAllowedAsLast=True
    SubCaption="Installed skins"
    WindowName="Unreal Skin Browser"
    DefaultLeft=0.050000
    DefaultTop=0.060000
    DefaultWidth=0.900000
    DefaultHeight=0.880000
    WinLeft=0.050000
    WinTop=0.060000
    WinWidth=0.900000
    WinHeight=0.880000
    OnKeyEvent=SkinBrowserPage.PageKeyEvent
}
