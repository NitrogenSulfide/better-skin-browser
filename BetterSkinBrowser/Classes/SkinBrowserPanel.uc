// Actual Better Skin Browser tab used by the stock in-match login menus.
class SkinBrowserPanel extends MidGamePanel;

var automated SkinBrowserWidget Browser;

function ShowPanel(bool bShow)
{
    Super.ShowPanel(bShow);
    if (bShow)
    {
        Browser.InitializeBrowser();
        Browser.CloseButton.SetVisibility(False);
        // ShowPanel propagates visibility to every child, including the
        // portrait and model input controls. Restore the selected mode.
        Browser.RestorePreviewModeVisibility();
        Browser.SetPreviewActorsHidden(False);
    }
    else
        Browser.SetPreviewActorsHidden(True);
}

function bool PanelKeyEvent(out byte Key, out byte State, float Delta)
{
    return Browser.PageKeyEvent(Key, State, Delta);
}

defaultproperties
{
    Begin Object Class=SkinBrowserWidget Name=BrowserContent
        bBoundToParent=True
        bScaleToParent=True
    End Object
    Browser=SkinBrowserWidget'BetterSkinBrowser.SkinBrowserPanel.BrowserContent'
    PanelCaption="Skins"
    OnKeyEvent=SkinBrowserPanel.PanelKeyEvent
}
