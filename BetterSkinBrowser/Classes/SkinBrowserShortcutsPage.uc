// Popup listing the browser's keyboard and mouse controls, opened from the
// Shortcuts button beside Credits.
class SkinBrowserShortcutsPage extends LockedFloatingWindow;

var automated GUILabel ShortcutTable;
var automated GUIButton CloseShortcutsButton;
var localized array<string> ShortcutKeys;
var localized array<string> ShortcutActions;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    sb_Main.SetVisibility(False);
    b_OK.SetVisibility(False);
    b_OK.DisableMe();
    b_Cancel.SetVisibility(False);
    b_Cancel.DisableMe();
}

// Two columns: gold keys right-aligned against white actions, on faint row
// stripes. Both columns shrink together if a row is too wide.
function bool DrawShortcuts(Canvas C)
{
    local font SavedFont;
    local color SavedColor;
    local byte SavedStyle;
    local float SavedScaleX, SavedScaleY, RowH, KeyW, ActW, W, H, Scale, Gap, X, Y, MaxKey, MaxAct;
    local int i, Rows;

    Rows = Min(ShortcutKeys.Length, ShortcutActions.Length);
    if (Rows == 0)
        return True;
    SavedFont = C.Font;
    SavedColor = C.DrawColor;
    SavedStyle = C.Style;
    SavedScaleX = C.FontScaleX;
    SavedScaleY = C.FontScaleY;
    C.Font = Controller.GetMenuFont(ShortcutTable.TextFont).GetFontB(C.SizeX, C.SizeY);
    C.FontScaleX = 1;
    C.FontScaleY = 1;
    for (i = 0; i < Rows; i++)
    {
        C.TextSize(ShortcutKeys[i], W, H);
        MaxKey = FMax(MaxKey, W);
        C.TextSize(ShortcutActions[i], W, H);
        MaxAct = FMax(MaxAct, W);
    }
    RowH = ShortcutTable.ActualHeight() / Rows;
    Gap = H * 1.2;
    Scale = FMin(1.0, FMin((ShortcutTable.ActualWidth() - 8) / FMax(1, MaxKey + Gap + MaxAct),
        RowH * 0.8 / FMax(1, H)));
    KeyW = MaxKey * Scale;
    ActW = MaxAct * Scale;
    X = Round(ShortcutTable.ActualLeft() + (ShortcutTable.ActualWidth() - (KeyW + Gap * Scale + ActW)) * 0.5);
    C.Style = 1;
    for (i = 0; i < Rows; i++)
    {
        Y = ShortcutTable.ActualTop() + RowH * i;
        if (i % 2 == 0)
        {
            C.SetDrawColor(255, 255, 255, 18);
            C.Style = 5;
            C.SetPos(ShortcutTable.ActualLeft(), Y);
            C.DrawTile(Texture'Engine.WhiteSquareTexture', ShortcutTable.ActualWidth(), RowH, 0, 0, 2, 2);
            C.Style = 1;
        }
        C.FontScaleX = Scale;
        C.FontScaleY = Scale;
        C.TextSize(ShortcutKeys[i], W, H);
        C.SetDrawColor(255, 210, 0, 255);
        C.SetPos(X + KeyW - W, Y + (RowH - H) * 0.5);
        C.DrawText(ShortcutKeys[i]);
        C.SetDrawColor(225, 235, 255, 255);
        C.SetPos(X + KeyW + Gap * Scale, Y + (RowH - H) * 0.5);
        C.DrawText(ShortcutActions[i]);
    }
    C.Font = SavedFont;
    C.DrawColor = SavedColor;
    C.Style = SavedStyle;
    C.FontScaleX = SavedScaleX;
    C.FontScaleY = SavedScaleY;
    return True;
}

function bool CloseShortcutsClicked(GUIComponent Sender)
{
    Controller.CloseMenu(False);
    return True;
}

defaultproperties
{
    Begin Object Class=GUILabel Name=ShortcutRows
        TextFont="UT2MenuFont"
        WinTop=0.120000
        WinLeft=0.050000
        WinWidth=0.900000
        WinHeight=0.660000
        bBoundToParent=True
        bScaleToParent=True
        OnDraw=SkinBrowserShortcutsPage.DrawShortcuts
    End Object
    ShortcutTable=GUILabel'BetterSkinBrowser.SkinBrowserShortcutsPage.ShortcutRows'

    Begin Object Class=GUIButton Name=ShortcutsClose
        Caption="Close"
        Hint="Return to Unreal Skin Browser."
        WinTop=0.815000
        WinLeft=0.320000
        WinWidth=0.360000
        WinHeight=0.100000
        TabOrder=0
        bBoundToParent=True
        bScaleToParent=True
        OnClick=SkinBrowserShortcutsPage.CloseShortcutsClicked
    End Object
    CloseShortcutsButton=GUIButton'BetterSkinBrowser.SkinBrowserShortcutsPage.ShortcutsClose'

    ShortcutKeys(0)="Up / Down"
    ShortcutActions(0)="Previous / next skin"
    ShortcutKeys(1)="Page Up / Down"
    ShortcutActions(1)="Jump a page"
    ShortcutKeys(2)="Home / End"
    ShortcutActions(2)="First / last skin (list or grid)"
    ShortcutKeys(3)="Left / Right"
    ShortcutActions(3)="Previous / next portrait (grid)"
    ShortcutKeys(4)="Enter"
    ShortcutActions(4)="From Search, go to the list or grid"
    ShortcutKeys(5)="Ctrl+Enter"
    ShortcutActions(5)="Apply the selected skin"
    ShortcutKeys(6)="Ctrl+D"
    ShortcutActions(6)="Add or remove favorite"
    ShortcutKeys(7)="Ctrl+F"
    ShortcutActions(7)="Back to Search"
    WindowName="Keyboard shortcuts"
    DefaultLeft=0.290000
    DefaultTop=0.260000
    DefaultWidth=0.420000
    DefaultHeight=0.480000
    WinLeft=0.290000
    WinTop=0.260000
    WinWidth=0.420000
    WinHeight=0.480000
}
