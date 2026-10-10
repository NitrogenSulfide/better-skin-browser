#exec TEXTURE IMPORT FILE=../BetterSkinBrowser/Textures/BlueNattoAvatar.tga NAME=BlueNattoAvatar MIPS=OFF LODSET=5
// Small credits popup opened from the browser's bottom-left Credits button.
class SkinBrowserCreditsPage extends LockedFloatingWindow;

var automated GUIImage AvatarImage;
var automated GUILabel AuthorLabel;
var automated GUILabel RoleLabel;
var automated GUILabel ThanksLabel;
var automated GUIButton CloseCreditsButton;
var localized string AlsoKnownAs;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    sb_Main.SetVisibility(False);
    b_OK.SetVisibility(False);
    b_OK.DisableMe();
    b_Cancel.SetVisibility(False);
    b_Cancel.DisableMe();
}

// Keep the avatar square at any aspect ratio and frame it with the gold accent
// used by the browser's category headers.
function bool DrawAvatar(Canvas C)
{
    local float Size, X, Y, Edge;
    local byte SavedStyle;
    local color SavedColor;

    if (AvatarImage.Image == None)
        return True;
    SavedStyle = C.Style;
    SavedColor = C.DrawColor;
    Size = FMin(AvatarImage.ActualWidth(), AvatarImage.ActualHeight());
    X = Round(AvatarImage.ActualLeft() + (AvatarImage.ActualWidth() - Size) * 0.5);
    Y = Round(AvatarImage.ActualTop() + (AvatarImage.ActualHeight() - Size) * 0.5);
    Edge = FMax(2.0, Round(Controller.ResY / 540.0));
    C.Style = 1;
    C.SetDrawColor(255, 210, 0, 255);
    C.SetPos(X - Edge, Y - Edge);
    C.DrawTile(Texture'Engine.WhiteSquareTexture', Size + Edge * 2, Size + Edge * 2, 0, 0, 2, 2);
    C.SetDrawColor(255, 255, 255, 255);
    C.SetPos(X, Y);
    C.DrawTile(AvatarImage.Image, Size, Size, 0, 0,
        AvatarImage.Image.MaterialUSize(), AvatarImage.Image.MaterialVSize());
    C.Style = SavedStyle;
    C.DrawColor = SavedColor;
    return True;
}

// Draw the gold name with a smaller alias beside it, centered as one line and
// scaled down together if the pair is wider than the window.
function bool DrawAuthor(Canvas C)
{
    local font SavedFont, NameFont, AkaFont;
    local color SavedColor;
    local byte SavedStyle;
    local float SavedScaleX, SavedScaleY, NameW, NameH, AkaW, AkaH, Gap, Scale, X, Y;

    SavedFont = C.Font;
    SavedColor = C.DrawColor;
    SavedStyle = C.Style;
    SavedScaleX = C.FontScaleX;
    SavedScaleY = C.FontScaleY;
    NameFont = Controller.GetMenuFont(AuthorLabel.TextFont).GetFontB(C.SizeX, C.SizeY);
    AkaFont = Controller.GetMenuFont(RoleLabel.TextFont).GetFontB(C.SizeX, C.SizeY);
    C.FontScaleX = 1;
    C.FontScaleY = 1;
    C.Font = NameFont;
    C.TextSize(AuthorLabel.Caption, NameW, NameH);
    C.Font = AkaFont;
    C.TextSize(AlsoKnownAs, AkaW, AkaH);
    Gap = AkaH * 0.5;
    Scale = FMin(1.0, FMin((AuthorLabel.ActualWidth() - 4) / FMax(1, NameW + Gap + AkaW),
        AuthorLabel.ActualHeight() / FMax(1, NameH)));
    X = Round(AuthorLabel.ActualLeft() + (AuthorLabel.ActualWidth() - (NameW + Gap + AkaW) * Scale) * 0.5);
    Y = Round(AuthorLabel.ActualTop() + (AuthorLabel.ActualHeight() - NameH * Scale) * 0.5);
    C.Style = 1;
    C.FontScaleX = Scale;
    C.FontScaleY = Scale;
    C.Font = NameFont;
    C.DrawColor = AuthorLabel.TextColor;
    C.SetPos(X, Y);
    C.DrawText(AuthorLabel.Caption);
    C.Font = AkaFont;
    C.DrawColor = RoleLabel.TextColor;
    // Share the name's baseline so the alias reads as part of the same line.
    C.SetPos(X + (NameW + Gap) * Scale, Y + (NameH - AkaH) * Scale * 0.75);
    C.DrawText(AlsoKnownAs);
    C.Font = SavedFont;
    C.DrawColor = SavedColor;
    C.Style = SavedStyle;
    C.FontScaleX = SavedScaleX;
    C.FontScaleY = SavedScaleY;
    return True;
}

function bool CloseCreditsClicked(GUIComponent Sender)
{
    Controller.CloseMenu(False);
    return True;
}

defaultproperties
{
    Begin Object Class=GUIImage Name=CreditsAvatar
        Image=Texture'BetterSkinBrowser.BlueNattoAvatar'
        WinTop=0.110000
        WinLeft=0.100000
        WinWidth=0.800000
        WinHeight=0.500000
        bBoundToParent=True
        bScaleToParent=True
        OnDraw=SkinBrowserCreditsPage.DrawAvatar
    End Object
    AvatarImage=GUIImage'BetterSkinBrowser.SkinBrowserCreditsPage.CreditsAvatar'

    Begin Object Class=SkinBrowserFitLabel Name=CreditsAuthor
        Caption="Blue Natto"
        TextAlign=TXTA_Center
        TextColor=(R=255,G=210,B=0,A=255)
        TextFont="UT2HeaderFont"
        WinTop=0.640000
        WinLeft=0.050000
        WinWidth=0.900000
        WinHeight=0.080000
        bBoundToParent=True
        bScaleToParent=True
        OnDraw=SkinBrowserCreditsPage.DrawAuthor
    End Object
    AuthorLabel=GUILabel'BetterSkinBrowser.SkinBrowserCreditsPage.CreditsAuthor'

    Begin Object Class=SkinBrowserFitLabel Name=CreditsRole
        Caption="Creator of Unreal Skin Browser"
        TextAlign=TXTA_Center
        TextColor=(R=225,G=235,B=255,A=255)
        WinTop=0.715000
        WinLeft=0.050000
        WinWidth=0.900000
        WinHeight=0.050000
        bBoundToParent=True
        bScaleToParent=True
    End Object
    RoleLabel=GUILabel'BetterSkinBrowser.SkinBrowserCreditsPage.CreditsRole'

    Begin Object Class=SkinBrowserFitLabel Name=CreditsThanks
        Caption="Thank you for your support!  \\(^o^)/"
        TextAlign=TXTA_Center
        TextColor=(R=255,G=210,B=0,A=255)
        WinTop=0.765000
        WinLeft=0.050000
        WinWidth=0.900000
        WinHeight=0.050000
        bBoundToParent=True
        bScaleToParent=True
    End Object
    ThanksLabel=GUILabel'BetterSkinBrowser.SkinBrowserCreditsPage.CreditsThanks'

    Begin Object Class=GUIButton Name=CreditsClose
        Caption="Close"
        Hint="Return to Unreal Skin Browser."
        WinTop=0.850000
        WinLeft=0.320000
        WinWidth=0.360000
        WinHeight=0.070000
        TabOrder=0
        bBoundToParent=True
        bScaleToParent=True
        OnClick=SkinBrowserCreditsPage.CloseCreditsClicked
    End Object
    CloseCreditsButton=GUIButton'BetterSkinBrowser.SkinBrowserCreditsPage.CreditsClose'

    AlsoKnownAs="(aka CissiaLikesEggs)"
    WindowName="Credits"
    DefaultLeft=0.330000
    DefaultTop=0.170000
    DefaultWidth=0.340000
    DefaultHeight=0.660000
    WinLeft=0.330000
    WinTop=0.170000
    WinWidth=0.340000
    WinHeight=0.660000
}
