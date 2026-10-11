// Reusable client-side character browser content for both the standalone
// configuration page and the in-match Skins tab.
class SkinBrowserWidget extends GUIPanel
    DependsOn(xUtil);

var automated GUIButton AllSkinsButton;
var automated GUIButton FavoritesViewButton;
var automated GUIButton RecentViewButton;
var automated GUIButton FavoriteButton;
var automated moEditBox SearchBox;
var automated GUIButton ClearSearchButton;
var automated moComboBox SortBox;
var automated moComboBox GroupBox;
var automated GUIListBox CharacterList;
var automated GUIVertImageListBox PortraitGrid;
var automated GUIButton LayoutButton;
var automated GUIButton RandomButton;
var byte DiceFace;
var automated moCheckBox HideBrokenCheck;
var automated GUIImage PreviewPane;
var automated GUIImage PortraitPane;
var automated GUIButton PreviewInput;
var automated GUIButton ViewModeButton;
var automated GUIButton NormalSkinButton;
var automated GUIButton RedSkinButton;
var automated GUIButton BlueSkinButton;
var automated GUIButton ResetViewButton;
var automated moCheckBox AutoRotateCheck;
var automated moCheckBox WeaponCheck;
var automated moCheckBox LoopAnimationCheck;
var automated moComboBox AnimationBox;
var automated moComboBox VoicePackBox;
var automated GUIButton DefaultVoiceButton;
var automated moComboBox VoiceBox;
var automated GUILabel ResultLabel;
var automated GUILabel NameLabel;
var automated GUILabel DetailsLabel;
var automated GUILabel StatusLabel;
var automated GUIButton ApplyButton;
var automated GUIButton CloseButton;
var automated GUILabel TitleLabel;
var automated GUIButton CreditsButton;
var automated GUIButton ShortcutsButton;
var float TitleCenterX, TitleReferenceX;

var array<xUtil.PlayerRecord> PlayerRecords;
var array<int> CharacterOrder;
var array<name> AvailableAnimations;
var array<class<xVoicePack> > VoiceClasses;
var array<Sound> AvailableVoiceSounds;
var int SelectedRecord;
var bool bRebuildingList;
var bool bSyncingGrid;
var array<byte> RecordBroken;
var array<string> SessionCheckedMeshes;
var array<byte> SessionMeshLoadable;
var array<string> GridRowTitles;
var int HiddenBrokenCount;
var bool bUpdatingControls;
var SkinPreviewActor PreviewActor;
var Actor WeaponPreview;
var vector PreviewOffset;
var int PreviewFOV;
var bool bPreviewReady;
var bool bViewportDragging;
var bool bLeftDragTracking;
var bool bViewportPanning;
var bool bRightPanTracking;
var bool bAlignPreviewToCamera;
var float LastPanMouseX;
var float LastPanMouseY;
var float ViewportIdleTime;
var float AutoRotateDelay;
var byte PreviewTeam;
var string PreviewMessage;
var bool bPortraitView;
var bool bBrowserInitialized;
var string EquippedCharacterName;
var string SelectedVoiceClassName;
var bool bUseCharacterDefaultVoice;
var bool bFavoritesOnly;
var bool bRecentOnly;
var float ApplyRequestMessageUntil;

// Match Motorpool's slate-blue cards, using widget bounds so the same frame
// follows both the floating browser and the in-match Skins tab.
function DrawBrowserCard(Canvas C, float Left, float Top, float Width, float Height)
{
    Left = ActualLeft() + ActualWidth() * Left;
    Top = ActualTop() + ActualHeight() * Top;
    Width = ActualWidth() * Width;
    Height = ActualHeight() * Height;

    C.Style = 1;
    C.SetDrawColor(30, 65, 125, 255);
    C.SetPos(Left, Top);
    C.DrawTile(Texture'Engine.WhiteSquareTexture', Width, Height, 0, 0, 2, 2);
    C.Style = 5;
    C.SetDrawColor(88, 152, 225, 210);
    C.SetPos(Left, Top);
    C.DrawTile(Texture'Engine.WhiteSquareTexture', Width, 1, 0, 0, 2, 2);
    C.SetPos(Left, Top + Height - 1);
    C.DrawTile(Texture'Engine.WhiteSquareTexture', Width, 1, 0, 0, 2, 2);
    C.SetPos(Left, Top);
    C.DrawTile(Texture'Engine.WhiteSquareTexture', 1, Height, 0, 0, 2, 2);
    C.SetPos(Left + Width - 1, Top);
    C.DrawTile(Texture'Engine.WhiteSquareTexture', 1, Height, 0, 0, 2, 2);
}

// Give the x button exactly the search field's height and vertical position.
// The dice box is square at any aspect ratio, sits just left of Grid, and
// the result count ends before it.
function AlignRandomButton()
{
    local float Side, Gap;

    if (ActualWidth() <= 0 || ActualHeight() <= 0)
        return;
    Side = LayoutButton.WinHeight * ActualHeight() / ActualWidth();
    Gap = 0.006;
    RandomButton.WinTop = LayoutButton.WinTop;
    RandomButton.WinHeight = LayoutButton.WinHeight;
    RandomButton.WinWidth = Side;
    RandomButton.WinLeft = LayoutButton.WinLeft - Gap - Side;
    ResultLabel.WinWidth = FMax(0.05, RandomButton.WinLeft - Gap - ResultLabel.WinLeft);
}

function AlignClearButton()
{
    local GUIEditBox Field;

    Field = SearchBox.MyEditBox;
    if (Field == None || ActualHeight() <= 0 || Field.ActualHeight() <= 0)
        return;
    ClearSearchButton.WinTop = (Field.ActualTop() - ActualTop()) / ActualHeight();
    ClearSearchButton.WinHeight = Field.ActualHeight() / ActualHeight();
}

function bool DrawBrowserCards(Canvas C)
{
    local byte OldStyle;
    local color OldColor;
    local float OldX, OldY;

    OldStyle = C.Style;
    OldColor = C.DrawColor;
    OldX = C.CurX;
    OldY = C.CurY;
    // Keep the result count with the filters/list and the help/status line
    // with the preview controls. Apply and Close remain outside the cards.
    DrawBrowserCard(C, 0.040, 0.080, 0.400, 0.760);
    DrawBrowserCard(C, 0.500, 0.080, 0.380, 0.760);
    AlignClearButton();
    AlignRandomButton();
    C.Style = OldStyle;
    C.DrawColor = OldColor;
    C.SetPos(OldX, OldY);
    return False;
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
}

event Opened(GUIComponent Sender)
{
    Super.Opened(Sender);
    // GUITabControl sends Opened to inactive panels too. Only restore world
    // preview actors and mode-specific controls when this widget is visible.
    if (bVisible)
    {
        RestorePreviewModeVisibility();
        SetPreviewActorsHidden(False);
    }
}

event Closed(GUIComponent Sender, bool bCancelled)
{
    SetPreviewActorsHidden(True);
    Super.Closed(Sender, bCancelled);
}

function DrawActiveViewMarker(Canvas C, GUIButton Button, bool bActive)
{
    local color OldColor;
    local byte OldStyle;
    local float OldX, OldY;

    if (!bActive)
        return;
    OldColor = C.DrawColor;
    OldStyle = C.Style;
    OldX = C.CurX;
    OldY = C.CurY;
    C.Style = 1;
    C.SetDrawColor(105, 200, 255, 255);
    C.SetPos(Button.ActualLeft() + 2, Button.ActualTop() + Button.ActualHeight() - 3);
    C.DrawTile(Texture'Engine.WhiteSquareTexture', Button.ActualWidth() - 4, 2, 0, 0, 2, 2);
    C.DrawColor = OldColor;
    C.Style = OldStyle;
    C.SetPos(OldX, OldY);
}

function DrawAllViewMarker(Canvas C)
{
    DrawActiveViewMarker(C, AllSkinsButton, !bFavoritesOnly && !bRecentOnly);
}

function DrawFavoritesViewMarker(Canvas C)
{
    DrawActiveViewMarker(C, FavoritesViewButton, bFavoritesOnly);
}

function DrawRecentViewMarker(Canvas C)
{
    DrawActiveViewMarker(C, RecentViewButton, bRecentOnly);
}

function bool IsRecentRecord(int RecordIndex)
{
    return RecordIndex >= 0 && RecordIndex < PlayerRecords.Length &&
        class'SkinBrowserRecent'.static.Find(PlayerRecords[RecordIndex].DefaultName) >= 0;
}

function bool IsFavoriteRecord(int RecordIndex)
{
    return RecordIndex >= 0 && RecordIndex < PlayerRecords.Length &&
        class'SkinBrowserFavorites'.static.Contains(PlayerRecords[RecordIndex].DefaultName);
}

function UpdateFavoriteControls()
{
    local int i, Count;

    for (i = 0; i < PlayerRecords.Length; i++)
        if (IsSelectableRecord(i) && IsFavoriteRecord(i))
            Count++;
    FavoritesViewButton.Caption = "Favorites (" $ Count $ ")";
    Count = 0;
    for (i = 0; i < PlayerRecords.Length; i++)
        if (IsSelectableRecord(i) && IsRecentRecord(i))
            Count++;
    RecentViewButton.Caption = "Recent (" $ Count $ ")";
    if (SelectedRecord >= 0 && SelectedRecord < PlayerRecords.Length)
    {
        FavoriteButton.EnableMe();
        if (IsFavoriteRecord(SelectedRecord))
            FavoriteButton.Caption = "Remove favorite";
        else
            FavoriteButton.Caption = "Add favorite";
    }
    else
    {
        FavoriteButton.Caption = "Add favorite";
        FavoriteButton.DisableMe();
    }
}

// Recent keeps recency order, so Sort and Group do not apply there.
function UpdateOrderingControls()
{
    if (bRecentOnly)
    {
        SortBox.DisableMe();
        GroupBox.DisableMe();
    }
    else
    {
        SortBox.EnableMe();
        GroupBox.EnableMe();
    }
}

function bool ShowAllSkins(GUIComponent Sender)
{
    if (bFavoritesOnly || bRecentOnly)
    {
        bFavoritesOnly = False;
        bRecentOnly = False;
        RebuildCharacterList(True, -1);
    }
    UpdateOrderingControls();
    // A clicked view button keeps focus otherwise, and buttons ignore arrows.
    if (Sender != None)
        FocusSearchKeepText();
    return True;
}

function bool ShowFavorites(GUIComponent Sender)
{
    if (!bFavoritesOnly)
    {
        bFavoritesOnly = True;
        bRecentOnly = False;
        RebuildCharacterList(True, -1);
    }
    UpdateOrderingControls();
    // A clicked view button keeps focus otherwise, and buttons ignore arrows.
    if (Sender != None)
        FocusSearchKeepText();
    return True;
}

// Recently equipped skins, newest first. Search applies; sort and grouping
// do not, because the recency order is the point of this view.
function bool ShowRecent(GUIComponent Sender)
{
    if (!bRecentOnly)
    {
        bRecentOnly = True;
        bFavoritesOnly = False;
        RebuildCharacterList(True, -1);
    }
    UpdateOrderingControls();
    // A clicked view button keeps focus otherwise, and buttons ignore arrows.
    if (Sender != None)
        FocusSearchKeepText();
    return True;
}

function bool ToggleFavorite(GUIComponent Sender)
{
    local int NextRecord, i;
    local GUIList List;
    local bool bRemoving;

    if (SelectedRecord < 0 || SelectedRecord >= PlayerRecords.Length)
        return True;
    List = CharacterList.List;
    bRemoving = IsFavoriteRecord(SelectedRecord);
    NextRecord = -1;
    if (bRemoving && bFavoritesOnly)
    {
        // Prefer the next visible character, or the preceding one at the end.
        // Section headings never become the preview selection.
        for (i = List.Index + 1; i < List.ItemCount; i++)
            if (!List.Elements[i].bSection)
            {
                NextRecord = int(List.GetExtraAtIndex(i));
                break;
            }
        if (NextRecord < 0)
            for (i = List.Index - 1; i >= 0; i--)
                if (!List.Elements[i].bSection)
                {
                    NextRecord = int(List.GetExtraAtIndex(i));
                    break;
                }
    }
    class'SkinBrowserFavorites'.static.SetFavorite(
        PlayerRecords[SelectedRecord].DefaultName, !bRemoving);
    RebuildCharacterList(True, NextRecord);
    return True;
}

function InitializeBrowser()
{
    local int i;

    RefreshEquippedCharacter();
    // Skins equipped elsewhere (stock Player Settings, a previous session)
    // still count as recently used. Uninstalled names are hidden by the view.
    class'SkinBrowserRecent'.static.NoteUsed(EquippedCharacterName);
    if (bBrowserInitialized)
    {
        bUpdatingControls = True;
        HideBrokenCheck.Checked(class'SkinBrowserSettings'.default.bHideBrokenSkins);
        bUpdatingControls = False;
        SyncVoiceSelectionFromPlayer();
        SelectedRecord = FindCharacter(EquippedCharacterName);
        RebuildCharacterList();
        return;
    }
    bBrowserInitialized = True;

    SearchBox.MyEditBox.MaxWidth = 64;
    CharacterList.MyScrollBar.MinGripPixels = 28;
    CharacterList.List.OnDrawItem = DrawCharacterItem;
    CharacterList.List.OnKeyEvent = CharacterListKeyEvent;
    SearchBox.MyEditBox.OnKeyEvent = SearchKeyEvent;
    SearchBox.MyEditBox.OnKeyType = SearchKeyType;
    for (i = 0; i < Controls.Length; i++)
        if ((GUIButton(Controls[i]) != None) && (Controls[i] != PreviewInput))
            Controls[i].OnKeyEvent = BrowserButtonKeyEvent;
    PortraitGrid.List.OnDrawItem = DrawGridItem;
    PortraitGrid.List.OnKeyEvent = GridKeyEvent;
    PortraitGrid.MyScrollBar.MinGripPixels = 28;
    RefreshEquippedCharacter();

    bUpdatingControls = True;
    SortBox.AddItem("Name (A-Z)");
    SortBox.AddItem("Name (Z-A)");
    SortBox.AddItem("Race");
    SortBox.AddItem("Family / package");
    SortBox.AddItem("Sex");
    SortBox.ReadOnly(True);
    SortBox.SetIndex(0);

    GroupBox.AddItem("None");
    GroupBox.AddItem("Race");
    GroupBox.AddItem("Family / package");
    GroupBox.ReadOnly(True);
    GroupBox.SetIndex(0);
    HideBrokenCheck.Checked(class'SkinBrowserSettings'.default.bHideBrokenSkins);
    AutoRotateCheck.Checked(True);
    WeaponCheck.Checked(False);
    LoopAnimationCheck.Checked(False);
    bPortraitView = False;
    RestorePreviewModeVisibility();
    bUpdatingControls = False;

    PreviewTeam = 255;
    UpdateTeamButtons();

    class'xUtil'.static.GetPlayerList(PlayerRecords);
    CheckBrokenRecords();
    LoadVoiceClasses();
    SyncVoiceSelectionFromPlayer();
    BuildCharacterOrder();

    PreviewActor = PlayerOwner().Spawn(class'BetterSkinBrowser.SkinPreviewActor');
    if (PreviewActor != None)
    {
        PreviewActor.SetDrawType(DT_Mesh);
        PreviewActor.SetDrawScale(0.9);
        PreviewActor.SpinRate = 1800;
        // Keep the actor hidden until its owning page or tab is visibly open.
        // DrawActorClipped is deferred by some renderers, so visibility must
        // follow the GUI lifecycle rather than toggling around the draw call.
        PreviewActor.bHidden = True;
    }

    ResetPreviewView(None);
    if (PreviewActor != None)
        ViewportIdleTime = AutoRotateDelay;

    SelectedRecord = FindCharacter(PlayerOwner().GetUrlOption("Character"));
    RebuildCharacterList();
    SearchBox.SetFocus(None);
}

function RefreshEquippedCharacter()
{
    EquippedCharacterName = PlayerOwner().GetUrlOption("Character");
    if (EquippedCharacterName == "" && PlayerOwner().PlayerReplicationInfo != None)
        EquippedCharacterName = PlayerOwner().PlayerReplicationInfo.CharacterName;
    if (NameLabel != None && SelectedRecord >= 0 && SelectedRecord < PlayerRecords.Length)
    {
        NameLabel.Caption = PlayerRecords[SelectedRecord].DefaultName;
        if (NameLabel.Caption ~= EquippedCharacterName)
            NameLabel.Caption = NameLabel.Caption @ "[Equipped]";
    }
}

// Fill a ten-vertex star with ordinary canvas tiles; no font glyph or asset dependency.
function DrawFavoriteStar(Canvas C, float X, float Y, float Size)
{
    local int i, j, k, Row, Count;
    local float Angle, Radius, ScanY, Temp;
    local float VX[10], VY[10], Crossings[10];

    for (i = 0; i < 10; i++)
    {
        Angle = -1.5707963 + float(i) * 0.6283185;
        if ((i % 2) == 0)
            Radius = Size * 0.5;
        else
            Radius = Size * 0.22;
        VX[i] = X + Size * 0.5 + Cos(Angle) * Radius;
        VY[i] = Y + Size * 0.5 + Sin(Angle) * Radius;
    }
    C.Style = 1;
    C.SetDrawColor(255, 220, 70, 255);
    for (Row = 0; Row < int(Size); Row++)
    {
        ScanY = Y + Row + 0.5;
        Count = 0;
        j = 9;
        for (i = 0; i < 10; i++)
        {
            if ((VY[i] <= ScanY && VY[j] > ScanY) ||
                (VY[j] <= ScanY && VY[i] > ScanY))
            {
                Crossings[Count] = VX[i] + (ScanY - VY[i]) *
                    (VX[j] - VX[i]) / (VY[j] - VY[i]);
                Count++;
            }
            j = i;
        }
        for (i = 1; i < Count; i++)
            for (k = i; k > 0 && Crossings[k] < Crossings[k - 1]; k--)
            {
                Temp = Crossings[k];
                Crossings[k] = Crossings[k - 1];
                Crossings[k - 1] = Temp;
            }
        for (i = 0; i + 1 < Count; i += 2)
        {
            C.SetPos(Crossings[i], Y + Row);
            C.DrawTile(Texture'Engine.WhiteSquareTexture', Crossings[i + 1] - Crossings[i], 1, 0, 0, 2, 2);
        }
    }
}

function DrawCharacterItem(Canvas C, int Item, float X, float Y, float W, float H,
    bool bSelected, bool bPending)
{
    local GUIList List;
    local GUIStyles DrawStyle;
    local color SavedColor, SavedFontColor;
    local byte SavedStyle;
    local bool bEquipped, bFavorite;
    local float MarkerSize, SeparatorHeight, TextWidth, TextHeight, TitleWidth;
    local int RecordIndex;

    List = CharacterList.List;
    if (!List.IsValidIndex(Item))
        return;
    DrawStyle = List.Style;
    if (List.Elements[Item].bSection)
        DrawStyle = List.SectionStyle;
    else
    {
        RecordIndex = int(List.GetExtraAtIndex(Item));
        bEquipped = PlayerRecords[RecordIndex].DefaultName ~= EquippedCharacterName;
        bFavorite = IsFavoriteRecord(RecordIndex);
        if (bSelected && List.SelectedStyle != None)
        {
            DrawStyle = List.SelectedStyle;
            DrawStyle.Draw(C, List.MenuState, X, Y, W, H);
        }
    }
    if (DrawStyle == None)
        return;
    SavedColor = C.DrawColor;
    SavedStyle = C.Style;
    SavedFontColor = DrawStyle.FontColors[List.MenuState];
    if (bEquipped)
    {
        C.Style = 1;
        C.SetDrawColor(135, 38, 48, 255);
        C.SetPos(X, Y);
        C.DrawTile(Texture'Engine.WhiteSquareTexture', W, H, 0, 0, 2, 2);
        DrawStyle.FontColors[List.MenuState].R = 255;
        DrawStyle.FontColors[List.MenuState].G = 255;
        DrawStyle.FontColors[List.MenuState].B = 255;
        DrawStyle.FontColors[List.MenuState].A = 255;
    }
    // A slim cyan edge marks the previewed skin, including keyboard
    // selection on the faint stock highlight and on the red equipped row.
    if (bSelected && !List.Elements[Item].bSection)
    {
        C.Style = 1;
        C.SetDrawColor(105, 200, 255, 255);
        C.SetPos(X, Y);
        C.DrawTile(Texture'Engine.WhiteSquareTexture', FMax(3.0, Round(3.0 * Controller.ResY / 1080.0)),
            H, 0, 0, 2, 2);
    }
    if (List.Elements[Item].bSection)
    {
        // Match Motorpool's category headers: a centered gold title flanked by
        // thin gold rules, kept clear of the scrollbar.
        DrawStyle.FontColors[List.MenuState].R = 255;
        DrawStyle.FontColors[List.MenuState].G = 210;
        DrawStyle.FontColors[List.MenuState].B = 0;
        DrawStyle.FontColors[List.MenuState].A = 255;
        DrawStyle.TextSize(C, List.MenuState, List.GetItemAtIndex(Item), TextWidth, TextHeight, List.FontScale);
        TitleWidth = FMin(W - 24.0, TextWidth + 16.0);
        SeparatorHeight = FMax(1.0, Round(Controller.ResY / 1080.0));
        C.Style = 1;
        C.SetDrawColor(255, 210, 0, 255);
        C.SetPos(X + 3, Y + Round((H - SeparatorHeight) * 0.5));
        C.DrawTile(Texture'Engine.WhiteSquareTexture', (W - TitleWidth) * 0.5 - 3, SeparatorHeight, 0, 0, 2, 2);
        C.SetPos(X + (W + TitleWidth) * 0.5, Y + Round((H - SeparatorHeight) * 0.5));
        C.DrawTile(Texture'Engine.WhiteSquareTexture', (W - TitleWidth) * 0.5 - 3, SeparatorHeight, 0, 0, 2, 2);
        DrawStyle.DrawText(C, List.MenuState, X + (W - TitleWidth) * 0.5, Y, TitleWidth, H,
            TXTA_Center, List.GetItemAtIndex(Item), List.FontScale);
        DrawStyle.FontColors[List.MenuState] = SavedFontColor;
        C.DrawColor = SavedColor;
        C.Style = SavedStyle;
        return;
    }
    MarkerSize = FMin(H * 0.70, 24.0 * Controller.ResX / 1920.0);
    if (bFavorite)
        DrawFavoriteStar(C, X + 7, Y + (H - MarkerSize) * 0.5, MarkerSize);
    // Reserve a symmetric gutter so stars do not overlap centered long names.
    DrawStyle.DrawText(C, List.MenuState, X + MarkerSize + 12, Y, W - 2 * (MarkerSize + 12), H,
        TXTA_Center, List.GetItemAtIndex(Item), List.FontScale);
    DrawStyle.FontColors[List.MenuState] = SavedFontColor;
    C.DrawColor = SavedColor;
    C.Style = SavedStyle;
}

function BuildCharacterOrder()
{
    local int i;

    CharacterOrder.Length = PlayerRecords.Length;
    for (i = 0; i < PlayerRecords.Length; i++)
        CharacterOrder[i] = i;

    if (CharacterOrder.Length > 1)
        SortCharacterOrder(0, CharacterOrder.Length - 1);
}

function bool SortDescending()
{
    return (SortBox != None) && (SortBox.GetIndex() == 1);
}

function string GroupName(int RecordIndex)
{
    local string Value;

    if ((GroupBox == None) || (GroupBox.GetIndex() == 0))
        return "";

    if (GroupBox.GetIndex() == 1)
        Value = PlayerRecords[RecordIndex].Race;
    else
        Value = PackageName(PlayerRecords[RecordIndex].MeshName);

    if (Value == "")
        Value = "Unknown";
    return Value;
}

function SortCharacterOrder(int Low, int High)
{
    local int i, j, Temp;
    local int Pivot;

    i = Low;
    j = High;
    Pivot = CharacterOrder[(Low + High) / 2];

    do
    {
        while ((i <= High) && CharacterComesBefore(CharacterOrder[i], Pivot))
            i++;
        while ((j >= Low) && CharacterComesBefore(Pivot, CharacterOrder[j]))
            j--;

        if (i <= j)
        {
            Temp = CharacterOrder[i];
            CharacterOrder[i] = CharacterOrder[j];
            CharacterOrder[j] = Temp;
            i++;
            j--;
        }
    }
    until (i > j);

    if (Low < j)
        SortCharacterOrder(Low, j);
    if (i < High)
        SortCharacterOrder(i, High);
}

function bool CharacterComesBefore(int A, int B)
{
    if (SortDescending())
        return CharacterSortKey(A) > CharacterSortKey(B);
    return CharacterSortKey(A) < CharacterSortKey(B);
}

function string CharacterSortKey(int RecordIndex)
{
    local string Primary, GroupValue;

    switch (SortBox.GetIndex())
    {
    case 2:
        Primary = PlayerRecords[RecordIndex].Race;
        break;
    case 3:
        Primary = PackageName(PlayerRecords[RecordIndex].MeshName);
        break;
    case 4:
        Primary = PlayerRecords[RecordIndex].Sex;
        break;
    default:
        Primary = PlayerRecords[RecordIndex].DefaultName;
        break;
    }

    GroupValue = GroupName(RecordIndex);
    if (GroupValue != "")
        return Caps(GroupValue $ "|" $ Primary $ "|" $ PlayerRecords[RecordIndex].DefaultName);
    return Caps(Primary $ "|" $ PlayerRecords[RecordIndex].DefaultName $ "|" $ PlayerRecords[RecordIndex].MeshName);
}

function bool IsDuplicateRecord(int RecordIndex)
{
    return InStr(";" $ Caps(PlayerRecords[RecordIndex].Menu) $ ";", ";DUP;") != -1;
}

function bool IsBrokenRecord(int RecordIndex)
{
    return RecordIndex >= 0 && RecordIndex < RecordBroken.Length && RecordBroken[RecordIndex] != 0;
}

function bool IsSelectableRecord(int RecordIndex)
{
    if (IsDuplicateRecord(RecordIndex))
        return False;
    if (PlayerRecords[RecordIndex].DefaultName ~= EquippedCharacterName)
        return True;
    return !(class'SkinBrowserSettings'.default.bHideBrokenSkins && IsBrokenRecord(RecordIndex));
}

// A skin whose mesh cannot load appears in game as the default model. Each
// mesh is load-tested once and remembered in BetterSkinBrowser.ini; meshes
// remembered as broken are tested again once per browser so a reinstalled
// skin reappears. Loading every mesh once costs memory until the next map.
function bool MeshLoadable(string MeshName, out byte bSaveNeeded, optional bool bRetestAll)
{
    local int i;
    local bool bLoadable;

    for (i = 0; i < SessionCheckedMeshes.Length; i++)
        if (SessionCheckedMeshes[i] ~= MeshName)
            return SessionMeshLoadable[i] != 0;
    if (MeshName != "" && !bRetestAll &&
        class'SkinBrowserSettings'.static.FindMesh(class'SkinBrowserSettings'.default.LoadableMeshes, MeshName) >= 0 &&
        class'SkinBrowserSettings'.static.FindMesh(class'SkinBrowserSettings'.default.BrokenMeshes, MeshName) < 0)
        bLoadable = True;
    else
    {
        bLoadable = MeshName != "" && DynamicLoadObject(MeshName, class'Mesh', True) != None;
        if (MeshName != "" && class'SkinBrowserSettings'.static.NoteMeshResult(MeshName, bLoadable))
            bSaveNeeded = 1;
    }
    SessionCheckedMeshes[SessionCheckedMeshes.Length] = MeshName;
    SessionMeshLoadable[SessionMeshLoadable.Length] = byte(bLoadable);
    return bLoadable;
}

function CheckBrokenRecords(optional bool bRetestAll)
{
    local int i;
    local byte bSaveNeeded;

    if (bRetestAll)
    {
        SessionCheckedMeshes.Length = 0;
        SessionMeshLoadable.Length = 0;
    }
    RecordBroken.Length = PlayerRecords.Length;
    for (i = 0; i < PlayerRecords.Length; i++)
    {
        RecordBroken[i] = 0;
        if (!IsDuplicateRecord(i) && !MeshLoadable(PlayerRecords[i].MeshName, bSaveNeeded, bRetestAll))
            RecordBroken[i] = 1;
    }
    if (bSaveNeeded != 0)
        class'SkinBrowserSettings'.static.StaticSaveConfig();
}

function HideBrokenChanged(GUIComponent Sender)
{
    if (bUpdatingControls)
        return;
    class'SkinBrowserSettings'.static.SetHideBrokenSkins(HideBrokenCheck.IsChecked());
    // Turning the filter on re-tests every model, so removed models are found.
    if (HideBrokenCheck.IsChecked())
        CheckBrokenRecords(True);
    RebuildCharacterList(True, -1);
}

function bool CharacterMatches(int RecordIndex, string Query)
{
    local string Searchable, Word, Ch;
    local int i;

    Searchable = Caps(PlayerRecords[RecordIndex].DefaultName @
        PlayerRecords[RecordIndex].Race @ PlayerRecords[RecordIndex].Sex @
        PlayerRecords[RecordIndex].MeshName @
        PackageName(PlayerRecords[RecordIndex].BodySkinName) @
        PackageName(PlayerRecords[RecordIndex].FaceSkinName));
    // Treat ASCII whitespace as word separators, including pasted tabs/newlines.
    for (i = 0; i <= Len(Query); i++)
    {
        Ch = Mid(Query, i, 1);
        if (i == Len(Query) || (Asc(Ch) >= 9 && Asc(Ch) <= 13) || Ch == " ")
        {
            if (Word != "" && InStr(Searchable, Caps(Word)) < 0)
                return False;
            Word = "";
        }
        else
            Word $= Ch;
    }
    return True;
}

function string CharacterListCaption(int RecordIndex)
{
    local string RaceName;

    RaceName = PlayerRecords[RecordIndex].Race;
    if (RaceName == "")
        RaceName = "Unknown race";
    return PlayerRecords[RecordIndex].DefaultName $ "  [" $ RaceName $ "]";
}

function RebuildCharacterList(optional bool bPreservePreview, optional int PreferredRecord)
{
    local GUIList List;
    local int i, RecordIndex, ListIndex, VisibleCount, SelectableCount, FavoriteCount, RecentCount;
    local int PreviousRecord, PreviousTop;
    local string Query, CurrentGroup, LastGroup;
    local array<int> ViewOrder;

    List = CharacterList.List;
    if (List == None)
        return;

    PreviousRecord = SelectedRecord;
    PreviousTop = List.Top;
    Query = SearchBox.GetText();
    HiddenBrokenCount = 0;
    bRebuildingList = True;
    List.Clear();

    for (i = 0; i < CharacterOrder.Length; i++)
    {
        RecordIndex = CharacterOrder[i];
        if (!IsDuplicateRecord(RecordIndex) && !IsSelectableRecord(RecordIndex))
            HiddenBrokenCount++;
        if (!IsSelectableRecord(RecordIndex))
            continue;
        SelectableCount++;
        if (IsFavoriteRecord(RecordIndex))
            FavoriteCount++;
        if (!bFavoritesOnly || IsFavoriteRecord(RecordIndex))
            if (!bRecentOnly)
                ViewOrder[ViewOrder.Length] = RecordIndex;
    }
    // Hand-edited INIs may repeat names or exceed the cap; show each skin once.
    if (bRecentOnly)
        for (i = 0; i < class'SkinBrowserRecent'.default.CharacterNames.Length &&
            RecentCount < class'SkinBrowserRecent'.default.MaxEntries; i++)
        {
            RecordIndex = FindCharacter(class'SkinBrowserRecent'.default.CharacterNames[i]);
            if ((RecordIndex >= 0) && IsSelectableRecord(RecordIndex) &&
                !ViewOrderContains(ViewOrder, RecordIndex))
            {
                ViewOrder[ViewOrder.Length] = RecordIndex;
                RecentCount++;
            }
        }

    for (i = 0; i < ViewOrder.Length; i++)
    {
        RecordIndex = ViewOrder[i];
        if (CharacterMatches(RecordIndex, Query))
        {
            CurrentGroup = "";
            if (!bRecentOnly)
                CurrentGroup = GroupName(RecordIndex);
            if ((CurrentGroup != "") && !(CurrentGroup ~= LastGroup))
            {
                List.Add(CurrentGroup,,, True);
                LastGroup = CurrentGroup;
            }
            List.Add(CharacterListCaption(RecordIndex),, string(RecordIndex));
            VisibleCount++;
        }
    }

    if (bFavoritesOnly)
        ResultLabel.Caption = string(VisibleCount) @ "of" @ string(FavoriteCount) @ "favorite skins";
    else if (bRecentOnly)
        ResultLabel.Caption = string(VisibleCount) @ "of" @ string(RecentCount) @ "recent skins";
    else if (Query == "")
        ResultLabel.Caption = string(SelectableCount) @ "selectable skins";
    else
        ResultLabel.Caption = string(VisibleCount) @ "of" @ string(SelectableCount) @
            "selectable skins";
    if (!bFavoritesOnly && !bRecentOnly && HiddenBrokenCount > 0)
        ResultLabel.Caption = ResultLabel.Caption @ "(" $ HiddenBrokenCount @ "broken hidden)";
    ListIndex = List.FindIndex(string(SelectedRecord), True, True);
    if (ListIndex < 0 && PreferredRecord >= 0 && bPreservePreview)
        ListIndex = List.FindIndex(string(PreferredRecord), True, True);
    if ((ListIndex < 0) && (VisibleCount > 0))
        ListIndex = FindFirstCharacterListIndex(List);

    if (ListIndex >= 0)
    {
        List.SetIndex(ListIndex);
        SelectedRecord = int(List.GetExtra());
    }
    else
        SelectedRecord = -1;

    if (bPreservePreview)
    {
        List.SetTopItem(PreviousTop);
        // Clamp the saved scroll position to keep a newly chosen neighbor visible.
        if (ListIndex >= 0)
            List.SetIndex(ListIndex);
    }
    bRebuildingList = False;
    PopulateGrid();
    UpdateFavoriteControls();
    if (!bPreservePreview || PreviousRecord != SelectedRecord)
        UpdateSelection();
}

function bool ViewOrderContains(array<int> ViewOrder, int RecordIndex)
{
    local int i;

    for (i = 0; i < ViewOrder.Length; i++)
        if (ViewOrder[i] == RecordIndex)
            return True;
    return False;
}

// The grid mirrors the filtered, sorted list without its category headings.
function PopulateGrid()
{
    local GUIList List;
    local int i, PreviousTop, Cols;

    List = CharacterList.List;
    PreviousTop = PortraitGrid.List.Top;
    bSyncingGrid = True;
    PortraitGrid.List.bNotify = False;
    PortraitGrid.List.Clear();
    GridRowTitles.Length = 0;
    Cols = Max(1, PortraitGrid.List.NoVisibleCols);
    for (i = 0; i < List.ItemCount; i++)
    {
        if (List.Elements[i].bSection)
        {
            // Each category starts a new row; locked blank cells pad the row.
            while (PortraitGrid.List.ItemCount % Cols != 0)
                PortraitGrid.List.Add(None, -1, 1);
            GridRowTitles[PortraitGrid.List.ItemCount / Cols] = List.GetItemAtIndex(i);
        }
        else
            PortraitGrid.List.Add(PlayerRecords[int(List.GetExtraAtIndex(i))].Portrait,
                int(List.GetExtraAtIndex(i)));
    }
    // Clamp before syncing: an undrawn grid cannot clamp a stale Top itself.
    PortraitGrid.List.Top = Max(0, PreviousTop);
    SkinBrowserPortraitGrid(PortraitGrid.List).MakeIndexVisible();
    PortraitGrid.List.bNotify = True;
    bSyncingGrid = False;
    SyncGridSelection();
}

function SyncGridSelection()
{
    local int GridIndex;

    if (PortraitGrid.List.ItemCount == 0)
        return;
    GridIndex = PortraitGrid.List.FindItem(SelectedRecord);
    if (GridIndex == PortraitGrid.List.Index)
    {
        SkinBrowserPortraitGrid(PortraitGrid.List).MakeIndexVisible();
        return;
    }
    bSyncingGrid = True;
    PortraitGrid.List.bNotify = False;
    PortraitGrid.List.SetIndex(GridIndex);
    PortraitGrid.List.bNotify = True;
    bSyncingGrid = False;
}

function GridChanged(GUIComponent Sender)
{
    local int ListIndex;

    if (bSyncingGrid || bRebuildingList || !PortraitGrid.List.IsValid())
        return;
    SelectedRecord = PortraitGrid.List.GetItem();
    ListIndex = CharacterList.List.FindIndex(string(SelectedRecord), True, True);
    bRebuildingList = True;
    if (ListIndex >= 0)
        CharacterList.List.SetIndex(ListIndex);
    bRebuildingList = False;
    UpdateSelection();
}

function bool GridNavigationKey(Interactions.EInputKey InputKey)
{
    local int Step;

    switch (InputKey)
    {
    case IK_Up:
        Step = -1;
        break;
    case IK_Down:
        Step = 1;
        break;
    case IK_PageUp:
        Step = -SkinBrowserPortraitGrid(PortraitGrid.List).PageItems();
        break;
    case IK_PageDown:
        Step = SkinBrowserPortraitGrid(PortraitGrid.List).PageItems();
        break;
    default:
        return False;
    }
    if (PortraitGrid.List.ItemCount > 0)
        PortraitGrid.List.SetIndex(SkinBrowserPortraitGrid(PortraitGrid.List).NearestUnlocked(
            Clamp(Max(0, PortraitGrid.List.Index) + Step, 0, PortraitGrid.List.ItemCount - 1), Step));
    return True;
}

function bool GridKeyEvent(out byte Key, out byte State, float Delta)
{
    if ((EInputAction(State) == IST_Press) && BrowserShortcutKey(EInputKey(Key)))
        return True;
    return PortraitGrid.List.InternalOnKeyEvent(Key, State, Delta);
}

function ApplyLayoutVisibility()
{
    local bool bGrid;

    bGrid = class'SkinBrowserSettings'.default.bGridView;
    CharacterList.SetVisibility(!bGrid);
    PortraitGrid.SetVisibility(bGrid);
    // The stock image list box keeps its scrollbar visible even while the grid
    // is hidden, and that scrollbar sits over the list's own. It caught the
    // mouse, so the list's grip could not be dragged. Let only the visible
    // layout's scrollbar take input.
    SetScrollBarInput(PortraitGrid.MyScrollBar, bGrid);
    SetScrollBarInput(CharacterList.MyScrollBar, !bGrid);
    if (bGrid)
        LayoutButton.Caption = "List";
    else
        LayoutButton.Caption = "Grid";
}

function SetScrollBarInput(GUIScrollBarBase Bar, bool bAccept)
{
    local int i;

    if (Bar == None)
        return;
    Bar.bAcceptsInput = bAccept;
    for (i = 0; i < Bar.Controls.Length; i++)
        Bar.Controls[i].bAcceptsInput = bAccept;
}

function bool ToggleLayout(GUIComponent Sender)
{
    class'SkinBrowserSettings'.static.SetGridView(!class'SkinBrowserSettings'.default.bGridView);
    ApplyLayoutVisibility();
    SyncGridSelection();
    if (class'SkinBrowserSettings'.default.bGridView)
        PortraitGrid.SetFocus(None);
    else
        CharacterList.SetFocus(None);
    return True;
}

// Shorten a name with ".." until it fits the cell.
function string FitText(Canvas C, GUIStyles DrawStyle, string Text, float Width)
{
    local float TextWidth, TextHeight;
    local string Result;

    if (Width <= 0)
        return "";
    Result = Text;
    DrawStyle.TextSize(C, MSAT_Blurry, Result, TextWidth, TextHeight, FNS_Small);
    while (TextWidth > Width && Len(Text) > 0)
    {
        Text = Left(Text, Len(Text) - 1);
        Result = Text $ "..";
        DrawStyle.TextSize(C, MSAT_Blurry, Result, TextWidth, TextHeight, FNS_Small);
    }
    return Result;
}

function DrawGridFrame(Canvas C, float X, float Y, float W, float H, float Thickness)
{
    C.SetPos(X, Y);
    C.DrawTile(Texture'Engine.WhiteSquareTexture', W, Thickness, 0, 0, 2, 2);
    C.SetPos(X, Y + H - Thickness);
    C.DrawTile(Texture'Engine.WhiteSquareTexture', W, Thickness, 0, 0, 2, 2);
    C.SetPos(X, Y);
    C.DrawTile(Texture'Engine.WhiteSquareTexture', Thickness, H, 0, 0, 2, 2);
    C.SetPos(X + W - Thickness, Y);
    C.DrawTile(Texture'Engine.WhiteSquareTexture', Thickness, H, 0, 0, 2, 2);
}

function DrawGridHeading(Canvas C, float X, float Y, float W, float H, int Row)
{
    local GUIStyles DrawStyle;
    local color SavedColor, SavedFontColor;
    local byte SavedStyle;
    local float TextWidth, TextHeight, TitleWidth, Rule;
    local string Title;

    if (Row < 0 || Row >= GridRowTitles.Length || GridRowTitles[Row] == "")
        return;
    Title = GridRowTitles[Row];
    DrawStyle = CharacterList.List.SectionStyle;
    if (DrawStyle == None)
        DrawStyle = CharacterList.List.Style;
    if (DrawStyle == None)
        return;
    SavedColor = C.DrawColor;
    SavedStyle = C.Style;
    SavedFontColor = DrawStyle.FontColors[0];
    DrawStyle.FontColors[0].R = 255;
    DrawStyle.FontColors[0].G = 210;
    DrawStyle.FontColors[0].B = 0;
    DrawStyle.FontColors[0].A = 255;
    // Match the list headings: a centered gold title flanked by gold rules.
    DrawStyle.TextSize(C, MSAT_Blurry, Title, TextWidth, TextHeight, CharacterList.List.FontScale);
    TitleWidth = FMin(W - 24.0, TextWidth + 16.0);
    Rule = FMax(1.0, Round(Controller.ResY / 1080.0));
    C.Style = 1;
    C.SetDrawColor(255, 210, 0, 255);
    C.SetPos(X + 4, Y + Round((H - Rule) * 0.5));
    C.DrawTile(Texture'Engine.WhiteSquareTexture', (W - TitleWidth) * 0.5 - 4, Rule, 0, 0, 2, 2);
    C.SetPos(X + (W + TitleWidth) * 0.5, Y + Round((H - Rule) * 0.5));
    C.DrawTile(Texture'Engine.WhiteSquareTexture', (W - TitleWidth) * 0.5 - 4, Rule, 0, 0, 2, 2);
    DrawStyle.DrawText(C, MSAT_Blurry, X + (W - TitleWidth) * 0.5, Y, TitleWidth, H,
        TXTA_Center, Title, CharacterList.List.FontScale);
    DrawStyle.FontColors[0] = SavedFontColor;
    C.DrawColor = SavedColor;
    C.Style = SavedStyle;
}

// Grid cell: fitted portrait over a charcoal matte, a name bar, the favorite
// star, a red frame for the equipped skin, and a cyan frame for the preview.
function DrawGridItem(Canvas C, int Item, float X, float Y, float W, float H,
    bool bSelected, bool bPending)
{
    local GUIStyles DrawStyle;
    local Material Portrait;
    local color SavedColor, SavedFontColor;
    local byte SavedStyle;
    local float Pad, Line, NameHeight, ImageWidth, ImageHeight, Scale, AreaW, AreaH;
    local int RecordIndex;
    local bool bEquipped;
    local GUI.eMenuState GridState;
    local float HeadingHeight;

    if (!PortraitGrid.List.IsValidIndex(Item))
        return;
    RecordIndex = PortraitGrid.List.GetItemIntAtIndex(Item);
    // The native image list reports the cell size but not each cell's origin.
    // Place cells exactly as its CalculateIndex hit-testing expects.
    if (Item < PortraitGrid.List.Top || PortraitGrid.List.NoVisibleCols <= 0)
        return;
    W = PortraitGrid.List.ItemWidth;
    H = PortraitGrid.List.ItemHeight;
    X = PortraitGrid.List.ClientBounds[0] +
        ((Item - PortraitGrid.List.Top) % PortraitGrid.List.NoVisibleCols) * W;
    Y = PortraitGrid.List.ClientBounds[1] +
        ((Item - PortraitGrid.List.Top) / PortraitGrid.List.NoVisibleCols) * H;
    if (Y + H > PortraitGrid.List.ClientBounds[3] + 1)
        return;
    // Grouped grids reserve a heading strip at the top of every row so all
    // portraits stay the same size; rows that start a category draw it.
    if (GridRowTitles.Length > 0)
    {
        HeadingHeight = Round(H * 0.14);
        if ((Item - PortraitGrid.List.Top) % PortraitGrid.List.NoVisibleCols == 0)
            DrawGridHeading(C, X, Y, W * PortraitGrid.List.NoVisibleCols, HeadingHeight,
                Item / PortraitGrid.List.NoVisibleCols);
        Y += HeadingHeight;
        H -= HeadingHeight;
    }
    if (RecordIndex < 0 || RecordIndex >= PlayerRecords.Length)
        return;
    bEquipped = PlayerRecords[RecordIndex].DefaultName ~= EquippedCharacterName;
    GridState = MSAT_Blurry;
    SavedColor = C.DrawColor;
    SavedStyle = C.Style;
    Line = FMax(2.0, Round(2.0 * Controller.ResY / 1080.0));
    Pad = Line * 2;
    NameHeight = FMax(14.0, H * 0.13);

    C.Style = 1;
    C.SetDrawColor(24, 24, 28, 255);
    C.SetPos(X + Pad, Y + Pad);
    C.DrawTile(Texture'Engine.WhiteSquareTexture', W - 2 * Pad, H - 2 * Pad, 0, 0, 2, 2);

    Portrait = PlayerRecords[RecordIndex].Portrait;
    AreaW = W - 4 * Pad;
    AreaH = H - 3 * Pad - NameHeight;
    if (Portrait != None)
    {
        ImageWidth = Portrait.MaterialUSize();
        ImageHeight = Portrait.MaterialVSize();
        if (ImageWidth > 0 && ImageHeight > 0)
        {
            Scale = FMin(AreaW / ImageWidth, AreaH / ImageHeight);
            C.SetDrawColor(255, 255, 255, 255);
            C.SetPos(X + 2 * Pad + (AreaW - ImageWidth * Scale) * 0.5,
                Y + 2 * Pad + (AreaH - ImageHeight * Scale) * 0.5);
            C.DrawTile(Portrait, ImageWidth * Scale, ImageHeight * Scale, 0, 0, ImageWidth, ImageHeight);
        }
    }

    if (bEquipped)
        C.SetDrawColor(135, 38, 48, 255);
    else
        C.SetDrawColor(30, 65, 125, 255);
    C.SetPos(X + Pad, Y + H - Pad - NameHeight);
    C.DrawTile(Texture'Engine.WhiteSquareTexture', W - 2 * Pad, NameHeight, 0, 0, 2, 2);
    DrawStyle = CharacterList.List.Style;
    if (DrawStyle != None)
    {
        SavedFontColor = DrawStyle.FontColors[GridState];
        DrawStyle.FontColors[GridState].R = 255;
        DrawStyle.FontColors[GridState].G = 255;
        DrawStyle.FontColors[GridState].B = 255;
        if (!bEquipped)
            DrawStyle.FontColors[GridState].B = 0;
        DrawStyle.FontColors[GridState].A = 255;
        DrawStyle.DrawText(C, MSAT_Blurry, X + 2 * Pad, Y + H - Pad - NameHeight, W - 4 * Pad, NameHeight,
            TXTA_Center, FitText(C, DrawStyle, PlayerRecords[RecordIndex].DefaultName, W - 4 * Pad), FNS_Small);
        DrawStyle.FontColors[GridState] = SavedFontColor;
    }

    if (IsFavoriteRecord(RecordIndex))
        DrawFavoriteStar(C, X + 2 * Pad, Y + 2 * Pad, FMin(W * 0.18, 24.0 * Controller.ResX / 1920.0));

    C.Style = 1;
    if (bEquipped)
    {
        C.SetDrawColor(200, 60, 72, 255);
        DrawGridFrame(C, X + Pad, Y + Pad, W - 2 * Pad, H - 2 * Pad, Line);
    }
    if (bSelected)
    {
        C.SetDrawColor(105, 200, 255, 255);
        DrawGridFrame(C, X + Pad - Line, Y + Pad - Line, W - 2 * Pad + 2 * Line, H - 2 * Pad + 2 * Line, Line);
    }
    C.DrawColor = SavedColor;
    C.Style = SavedStyle;
}

function int FindFirstCharacterListIndex(GUIList List)
{
    local int i;

    for (i = 0; i < List.ItemCount; i++)
        if (!List.Elements[i].bSection)
            return i;
    return -1;
}

function int AdjacentSkinIndex(GUIList List, int From, int Direction)
{
    local int i;

    for (i = From + Direction; (i >= 0) && (i < List.ItemCount); i += Direction)
        if (!List.Elements[i].bSection)
            return i;
    return -1;
}

// Keyboard selection moves between skins only. Category headings are never
// selected, but the heading above the new selection is scrolled into view.
function MoveSkinSelection(int Direction, int Distance)
{
    local GUIList List;
    local int Start, Candidate, Target;

    List = CharacterList.List;
    if ((List == None) || (List.ItemCount == 0))
        return;

    // With nothing selected, every key starts from the top of the list.
    Start = Max(-1, List.Index);
    if ((Distance <= 1) && (Start < 0))
        Target = AdjacentSkinIndex(List, -1, 1);
    else if (Distance <= 1)
        Target = AdjacentSkinIndex(List, Start, Direction);
    else
    {
        Candidate = Clamp(Start + Direction * Distance, 0, List.ItemCount - 1);
        Target = Candidate;
        if (List.Elements[Candidate].bSection)
        {
            Target = AdjacentSkinIndex(List, Candidate, Direction);
            if (Target < 0)
                Target = AdjacentSkinIndex(List, Candidate, -Direction);
        }
    }

    if (Target < 0)
    {
        if ((Direction < 0) && (List.Index >= 0) && (List.Index == FindFirstCharacterListIndex(List)))
            List.SetTopItem(0);
    }
    else if (Target != List.Index)
        List.SetIndex(Target);
    if ((Target > 0) && List.Elements[Target - 1].bSection && (Target - 1 < List.Top))
        List.SetTopItem(Target - 1);
    if (CharacterList.MyScrollBar != None)
        CharacterList.MyScrollBar.AlignThumb();
}

function bool ApplyShortcut()
{
    if (ApplyButton.MenuState != MSAT_Disabled)
        ApplyClicked(ApplyButton);
    return True;
}

function bool CanFocusSearch()
{
    return bBrowserInitialized && bVisible && SearchBox.bVisible &&
        SearchBox.MenuState != MSAT_Disabled && SearchBox.MyEditBox.bAcceptsInput;
}

function FocusSearchKeepText()
{
    if (CanFocusSearch())
        SearchBox.SetFocus(None);
}

function bool FocusSearchShortcut()
{
    if (!CanFocusSearch())
        return False;
    SearchBox.SetFocus(None);
    SearchBox.MyEditBox.bAllSelected = True;
    return True;
}

function bool ComboFocused(moComboBox Combo)
{
    return Controller.FocusedControl != None && (Controller.FocusedControl == Combo ||
        Controller.FocusedControl == Combo.MyComboBox || Controller.FocusedControl == Combo.MyComboBox.Edit ||
        Controller.FocusedControl == Combo.MyComboBox.MyShowListBtn);
}

function bool ComboHasFocus()
{
    return ComboFocused(SortBox) || ComboFocused(GroupBox) || ComboFocused(AnimationBox) ||
        ComboFocused(VoicePackBox) || ComboFocused(VoiceBox);
}

function bool AnyComboListOpen()
{
    return SortBox.MyComboBox.MyListBox.bVisible || GroupBox.MyComboBox.MyListBox.bVisible ||
        AnimationBox.MyComboBox.MyListBox.bVisible || VoicePackBox.MyComboBox.MyListBox.bVisible ||
        VoiceBox.MyComboBox.MyListBox.bVisible;
}

// Shortcuts shared by the list, the search box, buttons, and the owning page.
// Windows reports AltGr as Ctrl+Alt, so Alt combinations stay text input.
function bool BrowserShortcutKey(Interactions.EInputKey InputKey)
{
    if (!Controller.CtrlPressed || Controller.AltPressed || AnyComboListOpen())
        return False;
    if (InputKey == IK_Enter)
        return ApplyShortcut();
    if (InputKey == IK_F)
        return FocusSearchShortcut();
    if (InputKey == IK_D)
    {
        if (FavoriteButton.MenuState != MSAT_Disabled)
            ToggleFavorite(FavoriteButton);
        return True;
    }
    return False;
}

// Arrow and paging keys browse skins, skipping category headings.
function bool SkinNavigationKey(Interactions.EInputKey InputKey)
{
    local int PageSize;

    // In the grid, Search arrows and paging move by portraits, not list rows.
    if (class'SkinBrowserSettings'.default.bGridView)
        return GridNavigationKey(InputKey);
    PageSize = Max(1, CharacterList.List.ItemsPerPage - 1);
    switch (InputKey)
    {
    case IK_Up:
        MoveSkinSelection(-1, 1);
        return True;
    case IK_Down:
        MoveSkinSelection(1, 1);
        return True;
    case IK_PageUp:
        MoveSkinSelection(-1, PageSize);
        return True;
    case IK_PageDown:
        MoveSkinSelection(1, PageSize);
        return True;
    }
    return False;
}

function bool CharacterListKeyEvent(out byte Key, out byte State, float Delta)
{
    local Interactions.EInputKey InputKey;

    InputKey = EInputKey(Key);
    if (EInputAction(State) == IST_Press)
    {
        if (BrowserShortcutKey(InputKey) || SkinNavigationKey(InputKey))
            return True;
        if (InputKey == IK_Home)
        {
            MoveSkinSelection(-1, CharacterList.List.ItemCount + 1);
            return True;
        }
        if (InputKey == IK_End)
        {
            MoveSkinSelection(1, CharacterList.List.ItemCount + 1);
            return True;
        }
    }
    return CharacterList.List.InternalOnKeyEvent(Key, State, Delta);
}

// Search keeps keyboard focus while arrows browse results. Enter moves focus
// to the list; Home and End remain text-caret keys here.
function bool SearchKeyEvent(out byte Key, out byte State, float Delta)
{
    local Interactions.EInputKey InputKey;

    InputKey = EInputKey(Key);
    if (EInputAction(State) == IST_Press)
    {
        if (BrowserShortcutKey(InputKey) || SkinNavigationKey(InputKey))
            return True;
        if (InputKey == IK_Enter)
        {
            if (class'SkinBrowserSettings'.default.bGridView)
                PortraitGrid.SetFocus(None);
            else
                CharacterList.SetFocus(None);
            return True;
        }
    }
    return SearchBox.MyEditBox.InternalOnKeyEvent(Key, State, Delta);
}

// Stock buttons click on Enter regardless of Ctrl. Let the browser shortcuts
// win first, then keep the focused button's normal Enter/Space behavior.
function bool BrowserButtonKeyEvent(out byte Key, out byte State, float Delta)
{
    local int i;

    if ((EInputAction(State) == IST_Press) && BrowserShortcutKey(EInputKey(Key)))
        return True;
    for (i = 0; i < Controls.Length; i++)
        if ((GUIButton(Controls[i]) != None) && Controls[i].bHasFocus)
            return GUIButton(Controls[i]).InternalOnKeyEvent(Key, State, Delta);
    return False;
}

// Ctrl+F and Ctrl+D arrive as printable characters on some platforms. Keep
// them out of the search text; Ctrl+C/V/X still use the stock control codes.
function bool SearchKeyType(out byte Key, optional string Unicode)
{
    if (Controller.CtrlPressed && !Controller.AltPressed && (Key >= 32))
        return True;
    return SearchBox.MyEditBox.InternalOnKeyType(Key, Unicode);
}

// Pages and the Skins tab focus their first control when opened. Start in
// Search so typing filters immediately and arrows browse the results.
event bool FocusFirst(GUIComponent Sender)
{
    if (CanFocusSearch())
    {
        SearchBox.SetFocus(None);
        return True;
    }
    return Super.FocusFirst(Sender);
}

function SearchChanged(GUIComponent Sender)
{
    if (!bUpdatingControls)
        RebuildCharacterList(True, -1);
}

function bool ClearSearchClicked(GUIComponent Sender)
{
    bUpdatingControls = True;
    SearchBox.SetText("");
    bUpdatingControls = False;
    RebuildCharacterList(True, -1);
    if (Sender != None)
        FocusSearchKeepText();
    return True;
}

function SortOrGroupChanged(GUIComponent Sender)
{
    if (bUpdatingControls)
        return;
    BuildCharacterOrder();
    RebuildCharacterList();
}

function CharacterChanged(GUIComponent Sender)
{
    if (bRebuildingList || CharacterList.List == None || CharacterList.List.Index < 0 ||
        CharacterList.List.IsSection())
        return;

    SelectedRecord = int(CharacterList.List.GetExtra());
    UpdateSelection();
}

function int FindCharacter(string CharacterName)
{
    local int i;

    for (i = 0; i < PlayerRecords.Length; i++)
        if (PlayerRecords[i].DefaultName ~= CharacterName)
            return i;
    return -1;
}

function string PackageName(string ObjectName)
{
    local int Dot;

    Dot = InStr(ObjectName, ".");
    if (Dot >= 0)
        return Left(ObjectName, Dot);
    return ObjectName;
}

function UpdateSelection()
{
    local xUtil.PlayerRecord Rec;

    UpdateFavoriteControls();
    SyncGridSelection();

    bPreviewReady = False;
    if ((SelectedRecord < 0) || (SelectedRecord >= PlayerRecords.Length))
    {
        NameLabel.Caption = "No matching character";
        if (bRecentOnly && SearchBox.GetText() == "" && CharacterList.List.ItemCount == 0)
            DetailsLabel.Caption = "Skins you apply will appear here.";
        else if (bFavoritesOnly || bRecentOnly)
            DetailsLabel.Caption = "Choose All skins or change the search text.";
        else
            DetailsLabel.Caption = "Clear or change the search text.";
        StatusLabel.Caption = "";
        ApplyButton.DisableMe();
        PortraitPane.Image = None;
        VoicePackBox.ResetComponent();
        ClearPreview();
        return;
    }

    Rec = PlayerRecords[SelectedRecord];
    NameLabel.Caption = Rec.DefaultName;
    if (Rec.DefaultName ~= EquippedCharacterName)
        NameLabel.Caption = NameLabel.Caption @ "[Equipped]";
    DetailsLabel.Caption = Rec.Race @ "|" @ Rec.Sex @ "| package:" @ PackageName(Rec.MeshName);
    PortraitPane.Image = Rec.Portrait;
    ApplyButton.EnableMe();
    LoadPreview(Rec, True);
    if (ApplyWaitSeconds() > 0)
        ShowApplyWait();
}

function ClearPreview()
{
    DestroyWeaponPreview();
    if (PreviewActor != None)
    {
        PreviewActor.LinkMesh(None);
        PreviewActor.Skins.Length = 0;
    }
    AnimationBox.ResetComponent();
    VoiceBox.ResetComponent();
}

function string TeamSuffix()
{
    if (PreviewTeam == 0)
        return "_0";
    if (PreviewTeam == 1)
        return "_1";
    return "";
}

function LoadPreview(xUtil.PlayerRecord Rec, optional bool bResetView)
{
    local Mesh PlayerMesh;
    local Material BodySkin, FaceSkin, NeutralBodySkin, NeutralFaceSkin;
    local string Suffix;

    bPreviewReady = False;
    ClearPreview();
    PopulateVoicePackOptions(Rec);
    PopulateVoiceLines(SelectedVoiceForRecord(Rec));
    PreviewMessage = "";
    if (PreviewActor == None)
    {
        SetPreviewMessage("3D preview actor could not be created.");
        return;
    }

    PlayerMesh = Mesh(DynamicLoadObject(Rec.MeshName, class'Mesh', True));
    NeutralBodySkin = Material(DynamicLoadObject(Rec.BodySkinName, class'Material', True));
    NeutralFaceSkin = Material(DynamicLoadObject(Rec.FaceSkinName, class'Material', True));

    if (PlayerMesh == None)
    {
        SetPreviewMessage("Missing mesh:" @ Rec.MeshName);
        return;
    }
    if (NeutralBodySkin == None)
    {
        SetPreviewMessage("Missing body material:" @ Rec.BodySkinName);
        return;
    }

    Suffix = TeamSuffix();
    BodySkin = NeutralBodySkin;
    FaceSkin = NeutralFaceSkin;
    if (Suffix != "")
    {
        BodySkin = Material(DynamicLoadObject(Rec.BodySkinName $ Suffix, class'Material', True));
        if (BodySkin == None)
        {
            BodySkin = NeutralBodySkin;
            PreviewMessage = "Team body skin unavailable; showing normal skin.";
        }

        if (Rec.TeamFace)
        {
            FaceSkin = Material(DynamicLoadObject(Rec.FaceSkinName $ Suffix, class'Material', True));
            if (FaceSkin == None)
            {
                FaceSkin = NeutralFaceSkin;
                PreviewMessage = "Team face skin unavailable; using normal face.";
            }
        }
    }

    PreviewActor.LinkMesh(PlayerMesh);
    PreviewActor.Skins.Length = 2;
    PreviewActor.Skins[0] = BodySkin;
    if (FaceSkin != None)
        PreviewActor.Skins[1] = FaceSkin;
    else
        PreviewActor.Skins[1] = BodySkin;
    if (!PreviewActor.PlayReturnAnimation('Idle_Rest'))
        PreviewMessage = "Idle_Rest animation unavailable.";

    if (bResetView)
    {
        ResetPreviewView(None);
        if (Rec.Race ~= "Juggernaut")
            PreviewOffset.Z = -24.0;
    }

    bPreviewReady = True;
    PopulateAnimations(Rec);
    if (WeaponCheck.IsChecked())
        AttachShockRifle();
    SetPreviewMessage(PreviewMessage);
}

function SetPreviewMessage(string Message)
{
    PreviewMessage = Message;
    if (bPortraitView)
        StatusLabel.Caption = "Portrait preview";
    else if (Message == "")
        StatusLabel.Caption = "Drag to rotate | Shift/right-drag to pan | Wheel to zoom";
    else
        StatusLabel.Caption = Message;
}

function RestorePreviewModeVisibility()
{
    if (bBrowserInitialized)
        UpdateFavoriteControls();
    PortraitPane.SetVisibility(bPortraitView);
    PreviewInput.SetVisibility(!bPortraitView);
    ApplyLayoutVisibility();
    UpdatePreviewControlAvailability();

    if (bPortraitView)
    {
        ViewModeButton.Caption = "Model";
        ViewModeButton.Hint = "Return to the interactive 3D model preview.";
        if (PreviewActor != None)
            PreviewActor.SpinRate = 0;
        StatusLabel.Caption = "Portrait preview";
    }
    else
    {
        ViewModeButton.Caption = "Portrait";
        ViewModeButton.Hint = "Show the selected skin's portrait.";
        SetPreviewMessage(PreviewMessage);
    }
}

function UpdatePreviewControlAvailability()
{
    if (bPortraitView)
    {
        NormalSkinButton.DisableMe();
        RedSkinButton.DisableMe();
        BlueSkinButton.DisableMe();
        ResetViewButton.DisableMe();
        AutoRotateCheck.DisableMe();
        WeaponCheck.DisableMe();
        LoopAnimationCheck.DisableMe();
        AnimationBox.DisableMe();
    }
    else
    {
        UpdateTeamButtons();
        ResetViewButton.EnableMe();
        AutoRotateCheck.EnableMe();
        WeaponCheck.EnableMe();
        LoopAnimationCheck.EnableMe();
        AnimationBox.EnableMe();
    }
}

function bool ToggleViewMode(GUIComponent Sender)
{
    bPortraitView = !bPortraitView;
    RestorePreviewModeVisibility();
    if (!bPortraitView)
        MarkViewportInput();
    return True;
}

// Fit in pixel space: normalized GUI dimensions otherwise inherit the
// viewport's aspect ratio and can widen a portrait even at native 4K.
function bool DrawPortrait(Canvas C)
{
    local float ImageWidth, ImageHeight, Scale, SavedX, SavedY;
    local color SavedColor;
    local byte SavedStyle;

    if (!bPortraitView || PortraitPane.Image == None)
        return True;
    ImageWidth = PortraitPane.Image.MaterialUSize();
    ImageHeight = PortraitPane.Image.MaterialVSize();
    if (ImageWidth <= 0 || ImageHeight <= 0)
        return True;
    Scale = FMin(PortraitPane.ActualWidth() / ImageWidth,
        PortraitPane.ActualHeight() / ImageHeight);
    SavedColor = C.DrawColor;
    SavedStyle = C.Style;
    SavedX = C.CurX;
    SavedY = C.CurY;
    C.Style = 1;
    C.SetDrawColor(255, 255, 255, 255);
    C.SetPos(PortraitPane.ActualLeft() + (PortraitPane.ActualWidth() - ImageWidth * Scale) * 0.5,
        PortraitPane.ActualTop() + (PortraitPane.ActualHeight() - ImageHeight * Scale) * 0.5);
    C.DrawTile(PortraitPane.Image, ImageWidth * Scale, ImageHeight * Scale,
        0, 0, ImageWidth, ImageHeight);
    C.DrawColor = SavedColor;
    C.Style = SavedStyle;
    C.SetPos(SavedX, SavedY);
    return True;
}

function UpdateTeamButtons()
{
    if (bPortraitView)
    {
        NormalSkinButton.DisableMe();
        RedSkinButton.DisableMe();
        BlueSkinButton.DisableMe();
        return;
    }
    NormalSkinButton.EnableMe();
    RedSkinButton.EnableMe();
    BlueSkinButton.EnableMe();

    if (PreviewTeam == 0)
        RedSkinButton.DisableMe();
    else if (PreviewTeam == 1)
        BlueSkinButton.DisableMe();
    else
        NormalSkinButton.DisableMe();
}

// Team preview buttons are painted in team colors: dim when available,
// brighter on hover, and full color with a white edge while selected.
function bool DrawTeamButton(Canvas C, GUIButton Button, byte Team)
{
    local color SavedColor;
    local byte SavedStyle, R, G, B;
    local bool bActive, bHover;
    local float Edge;

    SavedColor = C.DrawColor;
    SavedStyle = C.Style;
    bActive = !bPortraitView && PreviewTeam == Team;
    bHover = Button.MenuState == MSAT_Watched || Button.MenuState == MSAT_Focused ||
        Button.MenuState == MSAT_Pressed;
    if (Team == 0)
    {
        R = 150; G = 34; B = 44;
        if (bActive) { R = 214; G = 48; B = 58; }
        else if (bHover) { R = 186; G = 46; B = 56; }
    }
    else
    {
        R = 24; G = 104; B = 214;
        if (bActive) { R = 36; G = 140; B = 255; }
        else if (bHover) { R = 32; G = 124; B = 240; }
    }
    if (bPortraitView)
    {
        R = R / 3; G = G / 3; B = B / 3;
    }
    Edge = FMax(1.0, Round(Controller.ResY / 1080.0));
    C.Style = 1;
    C.SetDrawColor(R, G, B, 255);
    C.SetPos(Button.ActualLeft(), Button.ActualTop());
    C.DrawTile(Texture'Engine.WhiteSquareTexture', Button.ActualWidth(), Button.ActualHeight(), 0, 0, 2, 2);
    if (bActive)
        C.SetDrawColor(255, 255, 255, 255);
    else
        C.SetDrawColor(Min(255, R + 70), Min(255, G + 70), Min(255, B + 70), 255);
    DrawGridFrame(C, Button.ActualLeft(), Button.ActualTop(), Button.ActualWidth(), Button.ActualHeight(),
        Edge * (1 + int(bActive)));
    if (Button.Style != None)
        DrawTeamCaption(C, Button, bPortraitView);
    C.DrawColor = SavedColor;
    C.Style = SavedStyle;
    return True;
}

function DrawTeamCaption(Canvas C, GUIButton Button, bool bDim)
{
    local color SavedFontColor;

    SavedFontColor = Button.Style.FontColors[0];
    Button.Style.FontColors[0].R = 255;
    Button.Style.FontColors[0].G = 255;
    Button.Style.FontColors[0].B = 255;
    Button.Style.FontColors[0].A = 255;
    if (bDim)
        Button.Style.FontColors[0].A = 110;
    Button.Style.DrawText(C, MSAT_Blurry, Button.ActualLeft(), Button.ActualTop(), Button.ActualWidth(),
        Button.ActualHeight(), TXTA_Center, Button.Caption, Button.FontScale);
    Button.Style.FontColors[0] = SavedFontColor;
}

function bool DrawRedButton(Canvas C)
{
    return DrawTeamButton(C, RedSkinButton, 0);
}

function bool DrawBlueButton(Canvas C)
{
    return DrawTeamButton(C, BlueSkinButton, 1);
}

function bool SetNormalSkin(GUIComponent Sender)
{
    return SetPreviewTeam(255);
}

function bool SetRedSkin(GUIComponent Sender)
{
    return SetPreviewTeam(0);
}

function bool SetBlueSkin(GUIComponent Sender)
{
    return SetPreviewTeam(1);
}

function bool SetPreviewTeam(byte NewTeam)
{
    PreviewTeam = NewTeam;
    UpdateTeamButtons();
    if ((SelectedRecord >= 0) && (SelectedRecord < PlayerRecords.Length))
        LoadPreview(PlayerRecords[SelectedRecord], False);
    return True;
}

function PopulateAnimations(xUtil.PlayerRecord Rec)
{
    local int i;
    local name Sequence;
    local string Label;

    bUpdatingControls = True;
    AnimationBox.ResetComponent();
    AvailableAnimations.Length = 0;
    if (PreviewActor.HasAnim('Idle_Rest'))
    {
        AnimationBox.AddItem("Idle",, "Idle_Rest");
        AvailableAnimations[AvailableAnimations.Length] = 'Idle_Rest';
    }
    if (PreviewActor.HasAnim('Idle_Rifle'))
    {
        AnimationBox.AddItem("Weapon idle",, "Idle_Rifle");
        AvailableAnimations[AvailableAnimations.Length] = 'Idle_Rifle';
    }

    if (Rec.Species != None)
    {
        for (i = 0; i < 16; i++)
        {
            Sequence = Rec.Species.default.TauntAnims[i];
            if ((Sequence == '') || !PreviewActor.HasAnim(Sequence) || AnimationAlreadyAdded(Sequence))
                continue;

            Label = Rec.Species.default.TauntAnimNames[i];
            if (Label == "")
                Label = string(Sequence);
            AnimationBox.AddItem(Label,, string(Sequence));
            AvailableAnimations[AvailableAnimations.Length] = Sequence;
        }
    }

    AnimationBox.ReadOnly(True);
    if (AnimationBox.ItemCount() > 0)
        AnimationBox.SetIndex(0);
    bUpdatingControls = False;
}

function bool AnimationAlreadyAdded(name Sequence)
{
    local int i;

    for (i = 0; i < AvailableAnimations.Length; i++)
        if (AvailableAnimations[i] == Sequence)
            return True;
    return False;
}

function AnimationChanged(GUIComponent Sender)
{
    if (!bUpdatingControls)
        PlaySelectedAnimation();
}

function PlaySelectedAnimation()
{
    local name Sequence, ReturnSequence;

    if (!bPreviewReady || (AnimationBox.GetIndex() < 0) ||
        (AnimationBox.GetIndex() >= AvailableAnimations.Length))
        return;

    Sequence = AvailableAnimations[AnimationBox.GetIndex()];
    ReturnSequence = 'Idle_Rest';
    if (WeaponCheck.IsChecked() && PreviewActor.HasAnim('Idle_Rifle'))
        ReturnSequence = 'Idle_Rifle';

    if (Sequence == 'Idle_Rest' || Sequence == 'Idle_Rifle')
        PreviewActor.PlayReturnAnimation(Sequence);
    else if (!PreviewActor.PlayPreviewAnimation(Sequence, ReturnSequence,
        LoopAnimationCheck.IsChecked()))
        SetPreviewMessage("Animation unavailable:" @ string(Sequence));
}

function LoopAnimationChanged(GUIComponent Sender)
{
    local name ReturnSequence;

    if (bUpdatingControls || !bPreviewReady)
        return;

    if (LoopAnimationCheck.IsChecked())
        PlaySelectedAnimation();
    else
    {
        ReturnSequence = 'Idle_Rest';
        if (WeaponCheck.IsChecked() && PreviewActor.HasAnim('Idle_Rifle'))
            ReturnSequence = 'Idle_Rifle';
        PreviewActor.StopPreviewAnimationLoop(ReturnSequence);
    }
}

function AddVoiceLine(string Category, int Slot, Sound LineSound, string LineText)
{
    local string Label;

    if (LineSound == None)
        return;

    Label = LineText;
    if (Label == "")
        Label = Category @ string(Slot + 1);
    else
        Label = Category $ ": " $ Label;

    VoiceBox.AddItem(Label);
    AvailableVoiceSounds[AvailableVoiceSounds.Length] = LineSound;
}

function LoadVoiceClasses()
{
    local array<string> VoiceClassNames;
    local class<xVoicePack> VoiceClass;
    local int i;

    PlayerOwner().GetAllInt("XGame.xVoicePack", VoiceClassNames);
    VoiceClasses.Length = 0;
    for (i = 0; i < VoiceClassNames.Length; i++)
    {
        VoiceClass = class<xVoicePack>(DynamicLoadObject(VoiceClassNames[i],
            class'Class', True));
        if (VoiceClass != None)
            VoiceClasses[VoiceClasses.Length] = VoiceClass;
    }
}

function string CurrentPlayerVoiceClassName()
{
    if ((PlayerOwner().PlayerReplicationInfo != None) &&
        (PlayerOwner().PlayerReplicationInfo.VoiceTypeName != ""))
        return PlayerOwner().PlayerReplicationInfo.VoiceTypeName;
    return PlayerOwner().GetUrlOption("Voice");
}

function SyncVoiceSelectionFromPlayer()
{
    local int EquippedRecord;

    SelectedVoiceClassName = CurrentPlayerVoiceClassName();
    bUseCharacterDefaultVoice = SelectedVoiceClassName == "";
    EquippedRecord = FindCharacter(EquippedCharacterName);
    if ((EquippedRecord >= 0) && (EquippedRecord < PlayerRecords.Length) &&
        (SelectedVoiceClassName ~= CharacterVoiceClassName(
            PlayerRecords[EquippedRecord])))
        bUseCharacterDefaultVoice = True;
}

function string VoicePackDisplayName(class<xVoicePack> VoiceClass)
{
    if (VoiceClass == None)
        return "Unknown voice";
    if (VoiceClass.Default.VoicePackName != "")
        return VoiceClass.Default.VoicePackName;
    return string(VoiceClass);
}

function bool VoiceMatchesRecord(class<xVoicePack> VoiceClass,
    xUtil.PlayerRecord Rec)
{
    return (VoiceClass != None) &&
        class'TeamVoicePack'.static.VoiceMatchesGender(
            VoiceClass.Default.VoiceGender, Rec.Sex);
}

function string SelectedVoiceForRecord(xUtil.PlayerRecord Rec)
{
    local class<xVoicePack> VoiceClass;

    if (!bUseCharacterDefaultVoice && (SelectedVoiceClassName != ""))
    {
        VoiceClass = class<xVoicePack>(DynamicLoadObject(SelectedVoiceClassName,
            class'Class', True));
        if (VoiceMatchesRecord(VoiceClass, Rec))
            return SelectedVoiceClassName;
    }
    return CharacterVoiceClassName(Rec);
}

function PopulateVoicePackOptions(xUtil.PlayerRecord Rec)
{
    local class<xVoicePack> DefaultVoiceClass;
    local string DefaultVoiceClassName;
    local int i, SelectedIndex;

    bUpdatingControls = True;
    VoicePackBox.ResetComponent();
    DefaultVoiceClassName = CharacterVoiceClassName(Rec);
    if (DefaultVoiceClassName != "")
        DefaultVoiceClass = class<xVoicePack>(DynamicLoadObject(
            DefaultVoiceClassName, class'Class', True));
    VoicePackBox.AddItem("Character default (" $
        VoicePackDisplayName(DefaultVoiceClass) $ ")");

    for (i = 0; i < VoiceClasses.Length; i++)
        if (VoiceMatchesRecord(VoiceClasses[i], Rec))
            VoicePackBox.AddItem(VoicePackDisplayName(VoiceClasses[i]),
                VoiceClasses[i], string(VoiceClasses[i]));

    SelectedIndex = 0;
    if (!bUseCharacterDefaultVoice && (SelectedVoiceClassName != ""))
    {
        i = VoicePackBox.FindIndex(SelectedVoiceClassName,, True);
        if (i >= 0)
            SelectedIndex = i;
    }
    VoicePackBox.ReadOnly(True);
    VoicePackBox.SetIndex(SelectedIndex);
    bUpdatingControls = False;
}

function VoicePackChanged(GUIComponent Sender)
{
    if (bUpdatingControls || (SelectedRecord < 0) ||
        (SelectedRecord >= PlayerRecords.Length))
        return;

    if (VoicePackBox.GetIndex() <= 0)
    {
        bUseCharacterDefaultVoice = True;
        SelectedVoiceClassName = "";
    }
    else
    {
        bUseCharacterDefaultVoice = False;
        SelectedVoiceClassName = VoicePackBox.GetExtra();
    }
    PopulateVoiceLines(SelectedVoiceForRecord(PlayerRecords[SelectedRecord]));
}

function bool DefaultVoiceClicked(GUIComponent Sender)
{
    if ((SelectedRecord < 0) || (SelectedRecord >= PlayerRecords.Length))
        return True;

    bUseCharacterDefaultVoice = True;
    SelectedVoiceClassName = "";
    PopulateVoicePackOptions(PlayerRecords[SelectedRecord]);
    PopulateVoiceLines(SelectedVoiceForRecord(PlayerRecords[SelectedRecord]));
    return True;
}

function string CharacterVoiceClassName(xUtil.PlayerRecord Rec)
{
    if (Rec.VoiceClassName != "")
        return Rec.VoiceClassName;

    if (Rec.Species != None)
        return Rec.Species.static.GetVoiceType(Rec.Sex ~= "Female",
            PlayerOwner().Level);

    if (Rec.Sex ~= "Female")
        return "XGame.MercFemaleVoice";
    return "XGame.MercMaleVoice";
}

function PopulateVoiceLines(string VoiceClassName)
{
    local class<TeamVoicePack> VoiceClass;
    local int i;

    bUpdatingControls = True;
    VoiceBox.ResetComponent();
    AvailableVoiceSounds.Length = 0;

    if (VoiceClassName != "")
        VoiceClass = class<TeamVoicePack>(DynamicLoadObject(VoiceClassName,
            class'Class', True));

    if (VoiceClass != None)
    {
        for (i = 0; i < 16; i++)
            AddVoiceLine("Ack", i, VoiceClass.Default.AckSound[i],
                VoiceClass.Default.AckString[i]);
        for (i = 0; i < 16; i++)
            AddVoiceLine("Friendly fire", i, VoiceClass.Default.FFireSound[i],
                VoiceClass.Default.FFireString[i]);
        for (i = 0; i < 48; i++)
            AddVoiceLine("Taunt", i, VoiceClass.Default.TauntSound[i],
                VoiceClass.Default.TauntString[i]);
        for (i = 0; i < 16; i++)
            AddVoiceLine("Order", i, VoiceClass.Default.OrderSound[i],
                VoiceClass.Default.OrderString[i]);
        for (i = 0; i < 48; i++)
            AddVoiceLine("Other", i, VoiceClass.Default.OtherSound[i],
                VoiceClass.Default.OtherString[i]);
    }

    VoiceBox.ReadOnly(True);
    if (VoiceBox.ItemCount() > 0)
        VoiceBox.SetIndex(0);
    else
        VoiceBox.AddItem("No previewable voice lines");
    bUpdatingControls = False;
}

function VoiceChanged(GUIComponent Sender)
{
    local int VoiceIndex;

    if (bUpdatingControls)
        return;

    VoiceIndex = VoiceBox.GetIndex();
    if ((VoiceIndex >= 0) && (VoiceIndex < AvailableVoiceSounds.Length) &&
        (AvailableVoiceSounds[VoiceIndex] != None))
        PlayerOwner().ClientPlaySound(AvailableVoiceSounds[VoiceIndex], False,
            1.0, SLOT_Interface);
}

function WeaponChanged(GUIComponent Sender)
{
    if (bUpdatingControls || !bPreviewReady)
        return;

    if (WeaponCheck.IsChecked())
        AttachShockRifle();
    else
    {
        DestroyWeaponPreview();
        PreviewActor.PlayReturnAnimation('Idle_Rest');
        SetPreviewMessage("");
    }
}

function AttachShockRifle()
{
    DestroyWeaponPreview();
    if (!PreviewActor.HasAnim('Idle_Rifle'))
    {
        SetPreviewMessage("Idle_Rifle animation unavailable; weapon stance disabled.");
        return;
    }

    WeaponPreview = PlayerOwner().Spawn(class'XWeapons.ShockAttachment');
    if (WeaponPreview == None)
    {
        SetPreviewMessage("Weapon preview actor could not be created.");
        return;
    }

    if (!PreviewActor.AttachToBone(WeaponPreview, 'righthand'))
    {
        WeaponPreview.Destroy();
        WeaponPreview = None;
        SetPreviewMessage("Weapon attachment failed: missing or invalid righthand bone.");
        return;
    }

    // The previous negative X correction visibly moved this attachment farther
    // left. Keep the established height and move it back across the hand.
    WeaponPreview.SetDrawScale(0.27);
    WeaponPreview.SetRelativeLocation(vect(6,0,10));
    WeaponPreview.SetRelativeRotation(rot(32768,0,0));
    WeaponPreview.bHidden = PreviewActor.bHidden;

    PreviewActor.PlayReturnAnimation('Idle_Rifle');
    SetPreviewMessage("");
}

function DestroyWeaponPreview()
{
    if (WeaponPreview != None)
    {
        if (PreviewActor != None)
            PreviewActor.DetachFromBone(WeaponPreview);
        WeaponPreview.Destroy();
    }
    WeaponPreview = None;
}

function AutoRotateChanged(GUIComponent Sender)
{
    if (bUpdatingControls)
        return;

    if (!AutoRotateCheck.IsChecked() && (PreviewActor != None))
        PreviewActor.SpinRate = 0;
}

function MarkViewportInput()
{
    if (PreviewActor != None)
    {
        ViewportIdleTime = 0.0;
        PreviewActor.SpinRate = 0;
    }
}

function SetPreviewActorsHidden(bool bHide)
{
    if (PreviewActor != None)
        PreviewActor.bHidden = bHide;
    if (WeaponPreview != None)
        WeaponPreview.bHidden = bHide;
}

function bool PreviewKeyEvent(out byte Key, out byte State, float Delta)
{
    local Interactions.EInputKey InputKey;

    InputKey = EInputKey(Key);
    if ((InputKey == IK_MouseWheelUp) && (EInputAction(State) == IST_Release))
    {
        PreviewOffset.X = FMax(110.0, PreviewOffset.X - 18.0);
        MarkViewportInput();
        return True;
    }
    if ((InputKey == IK_MouseWheelDown) && (EInputAction(State) == IST_Release))
    {
        PreviewOffset.X = FMin(500.0, PreviewOffset.X + 18.0);
        MarkViewportInput();
        return True;
    }

    if ((InputKey == IK_LeftMouse) || (InputKey == IK_RightMouse))
    {
        if (EInputAction(State) == IST_Press)
        {
            if (InputKey == IK_LeftMouse)
                bLeftDragTracking = True;
            bViewportDragging = True;
            bViewportPanning = (InputKey == IK_RightMouse);
            MarkViewportInput();
        }
        else if (EInputAction(State) == IST_Release)
        {
            if (InputKey == IK_LeftMouse)
                bLeftDragTracking = False;
            else
            {
                bViewportPanning = False;
                bRightPanTracking = False;
            }
            bViewportDragging = bLeftDragTracking || bRightPanTracking;
            MarkViewportInput();
        }
        return True;
    }
    return False;
}

function bool PageKeyEvent(out byte Key, out byte State, float Delta)
{
    if ((EInputAction(State) == IST_Press) && bBrowserInitialized &&
        BrowserShortcutKey(EInputKey(Key)))
        return True;
    // Arrows and paging browse skins when the focused control ignores them,
    // for example a just-clicked button or checkbox.
    if ((EInputAction(State) == IST_Press) && bBrowserInitialized && bVisible &&
        !AnyComboListOpen() && !ComboHasFocus() && SkinNavigationKey(EInputKey(Key)))
        return True;
    if (PreviewInput == None || bPortraitView)
        return False;

    if (PreviewInput.IsInBounds() &&
        ((EInputKey(Key) == IK_MouseWheelUp) ||
        (EInputKey(Key) == IK_MouseWheelDown)))
        return PreviewKeyEvent(Key, State, Delta);

    if ((EInputKey(Key) == IK_RightMouse) &&
        (PreviewInput.IsInBounds() || bViewportPanning))
        return PreviewKeyEvent(Key, State, Delta);

    return False;
}

function PreviewMousePressed(GUIComponent Sender, bool bRepeat)
{
    if (bRepeat)
        return;

    PreviewInput.SetFocus(None);
    bLeftDragTracking = True;
    bViewportDragging = True;
    bViewportPanning = False;
    MarkViewportInput();
}

function ApplyViewportPan(float DeltaX, float DeltaY)
{
    PreviewOffset.Y += DeltaX * 0.30;
    PreviewOffset.Z -= DeltaY * 0.30;
    PreviewOffset.Y = FClamp(PreviewOffset.Y, -100.0, 100.0);
    PreviewOffset.Z = FClamp(PreviewOffset.Z, -120.0, 100.0);
}

function UpdateRightMousePan()
{
    local float DeltaX, DeltaY;

    if ((Controller == None) || (PreviewInput == None))
        return;

    if (!Controller.KeyPressed(IK_RightMouse))
    {
        if (bRightPanTracking || bViewportPanning)
        {
            bRightPanTracking = False;
            bViewportPanning = False;
            MarkViewportInput();
        }
        bViewportDragging = bLeftDragTracking;
        return;
    }

    if (!bRightPanTracking)
    {
        if (!PreviewInput.IsInBounds())
            return;

        PreviewInput.SetFocus(None);
        bRightPanTracking = True;
        bViewportDragging = True;
        bViewportPanning = True;
        LastPanMouseX = Controller.MouseX;
        LastPanMouseY = Controller.MouseY;
        MarkViewportInput();
        return;
    }

    DeltaX = Controller.MouseX - LastPanMouseX;
    DeltaY = Controller.MouseY - LastPanMouseY;
    LastPanMouseX = Controller.MouseX;
    LastPanMouseY = Controller.MouseY;
    if ((DeltaX != 0.0) || (DeltaY != 0.0))
    {
        ApplyViewportPan(DeltaX, DeltaY);
        MarkViewportInput();
    }
}

function bool PreviewCapturedMouseMove(float DeltaX, float DeltaY)
{
    local rotator R;

    if (PreviewActor == None)
        return False;

    if (!Controller.KeyPressed(IK_RightMouse))
        bLeftDragTracking = True;
    bViewportDragging = True;
    MarkViewportInput();
    if (Controller.KeyPressed(IK_RightMouse))
        return True;

    if (Controller.ShiftPressed)
    {
        bViewportPanning = True;
        ApplyViewportPan(DeltaX, DeltaY);
        return True;
    }

    bViewportPanning = False;
    R = PreviewActor.Rotation;
    R.Yaw -= 256 * DeltaX;
    R.Pitch = Clamp(R.Pitch - (128 * DeltaY), -12000, 12000);
    PreviewActor.SetRotation(R);
    return True;
}

function PreviewMouseReleased(GUIComponent Sender)
{
    bLeftDragTracking = False;
    bViewportDragging = bRightPanTracking;
    if (!bRightPanTracking)
        bViewportPanning = False;
    MarkViewportInput();
}

function bool ResetPreviewView(GUIComponent Sender)
{
    PreviewOffset = vect(500.0, 1.0, -14.0);
    // Resolve the actual camera-relative front direction in DrawPreview.
    // Absolute world yaw is wrong whenever the match camera faces elsewhere.
    bAlignPreviewToCamera = True;
    MarkViewportInput();
    return True;
}

function bool DrawPreview(Canvas C)
{
    local vector CamPos, X, Y, Z;
    local rotator CamRot, PreviewRot;
    local float Left, Top, Width, Height;
    local float OldOrgX, OldOrgY, OldClipX, OldClipY;
    local byte OldStyle;
    local color OldColor;

    Left = PreviewPane.ActualLeft();
    Top = PreviewPane.ActualTop();
    Width = PreviewPane.ActualWidth();
    Height = PreviewPane.ActualHeight();

    OldStyle = C.Style;
    OldColor = C.DrawColor;
    C.Style = 1;
    C.SetDrawColor(18, 18, 20, 255);
    C.SetPos(Left, Top);
    C.DrawTile(Texture'Engine.WhiteSquareTexture', Width, Height, 0, 0, 2, 2);
    C.Style = OldStyle;
    C.DrawColor = OldColor;

    if (!bPortraitView)
        UpdateRightMousePan();
    if (!bPortraitView && bPreviewReady && PreviewActor != None)
    {
        if (!bViewportDragging && (Controller != None))
            ViewportIdleTime = FMin(AutoRotateDelay,
                ViewportIdleTime + FMax(0.0, Controller.RenderDelta));

        if (AutoRotateCheck.IsChecked() && !bViewportDragging &&
            (ViewportIdleTime >= AutoRotateDelay))
            PreviewActor.SpinRate = 1800;
        else
            PreviewActor.SpinRate = 0;

        C.GetCameraLocation(CamPos, CamRot);
        GetAxes(CamRot, X, Y, Z);
        if (bAlignPreviewToCamera)
        {
            PreviewRot.Yaw = CamRot.Yaw + 32768;
            PreviewActor.SetRotation(PreviewRot);
            bAlignPreviewToCamera = False;
        }
        PreviewActor.SetLocation(CamPos + (PreviewOffset.X * X) +
            (PreviewOffset.Y * Y) + (PreviewOffset.Z * Z));

        // Match the stock player-settings renderer: constrain the canvas as
        // well as DrawActorClipped so attached weapon geometry cannot paint
        // over neighboring controls.
        OldOrgX = C.OrgX;
        OldOrgY = C.OrgY;
        OldClipX = C.ClipX;
        OldClipY = C.ClipY;
        C.OrgX = Left;
        C.OrgY = Top;
        C.ClipX = Width;
        C.ClipY = Height;
        C.DrawActorClipped(PreviewActor, False, Left + 2, Top + 2,
            Width - 4, Height - 4, True, PreviewFOV);
        C.OrgX = OldOrgX;
        C.OrgY = OldOrgY;
        C.ClipX = OldClipX;
        C.ClipY = OldClipY;
    }

    // The preview background and model were both drawn above. Suppress
    // GUIImage's native draw or it will paint over the deferred actor pass.
    return True;
}

// Controller replicates SetPawnClass to the server unreliably, but does not
// replicate SPCTimeStamp. xPlayer enforces TimeSeconds + 10.0 on authority.
// On NM_Client this field tracks our own request window across browser widgets;
// it cannot acknowledge a server outcome or detect changes from other menus.
function int ApplyWaitSeconds()
{
    local float Remaining;
    local int Seconds;
    local PlayerController PC;

    PC = PlayerOwner();
    if (PC == None || PC.Level.NetMode == NM_Standalone)
        return 0;
    Remaining = FMax(0.0, PC.SPCTimeStamp - PC.Level.TimeSeconds);
    Seconds = int(Remaining);
    if (Remaining > float(Seconds))
        Seconds++;
    return Seconds;
}

function ShowApplyWait()
{
    ApplyButton.DisableMe();
    ApplyRequestMessageUntil = 0;
    StatusLabel.Caption = "Wait " $ ApplyWaitSeconds() $ " s before changing skin";
    StatusLabel.KillTimer();
    StatusLabel.SetTimer(0.25, True);
}

function bool ApplyClicked(GUIComponent Sender)
{
    local PlayerController PC;
    local xUtil.PlayerRecord Rec;
    local string VoiceClassName;

    if ((SelectedRecord < 0) || (SelectedRecord >= PlayerRecords.Length))
        return True;

    PC = PlayerOwner();
    if (ApplyWaitSeconds() > 0)
    {
        ShowApplyWait();
        return True;
    }
    Rec = PlayerRecords[SelectedRecord];
    // The stock SetPawnClass anti-spam timestamp is also used in standalone
    // play, where it can reject a legitimate menu selection before respawn.
    // There is no remote client to protect in Instant Action, so allow this
    // explicit local Apply to take effect immediately.
    if ((PC.Level.NetMode == NM_Standalone) && (xPlayer(PC) != None))
        xPlayer(PC).SPCTimeStamp = 0;
    PC.ConsoleCommand("ChangeCharacter" @ Rec.DefaultName);
    if (PC.Level.NetMode == NM_Client)
        PC.SPCTimeStamp = PC.Level.TimeSeconds + 10.0;
    if (!PC.IsA('xPlayer'))
        PC.UpdateURL("Character", Rec.DefaultName, True);
    if (Rec.Sex ~= "Female")
        PC.UpdateURL("Sex", "F", True);
    else
        PC.UpdateURL("Sex", "M", True);

    VoiceClassName = SelectedVoiceForRecord(Rec);
    PC.SetVoice(VoiceClassName);
    RefreshEquippedCharacter();
    class'SkinBrowserRecent'.static.NoteUsed(Rec.DefaultName);
    if (bRecentOnly)
        RebuildCharacterList(True, SelectedRecord);
    else
        UpdateFavoriteControls();
    if (Rec.DefaultName ~= EquippedCharacterName)
        NameLabel.Caption = Rec.DefaultName @ "[Equipped]";

    if (PC.Level.NetMode == NM_Standalone)
    {
        PC.ClientPlaySound(sound'MenuSounds.selectJ', False, 1.0, SLOT_Interface);
        StatusLabel.Caption = "Skin active - respawn to apply";
    }
    else
    {
        StatusLabel.Caption = "Change requested - respawn to apply";
        ApplyButton.DisableMe();
    }
    StatusLabel.KillTimer();
    if (PC.Level.NetMode == NM_Standalone)
        StatusLabel.SetTimer(2.0, False);
    else
    {
        ApplyRequestMessageUntil = PC.Level.TimeSeconds + 2.0;
        StatusLabel.SetTimer(0.25, True);
    }
    return True;
}

function ApplyStatusTimer(GUIComponent Sender)
{
    if (ApplyWaitSeconds() > 0 && SelectedRecord >= 0)
    {
        ApplyButton.DisableMe();
        if (PlayerOwner().Level.TimeSeconds >= ApplyRequestMessageUntil)
            StatusLabel.Caption = "Wait " $ ApplyWaitSeconds() $ " s before changing skin";
        return;
    }
    StatusLabel.KillTimer();
    if (SelectedRecord < 0)
    {
        StatusLabel.Caption = "";
        return;
    }
    ApplyButton.EnableMe();
    if (bPortraitView)
        StatusLabel.Caption = "Portrait preview";
    else
        SetPreviewMessage(PreviewMessage);
}

// Center the title under the owning window's caption (map name in match menus,
// window name in the standalone page) rather than over the cards, at any size.
function bool DrawCenteredTitle(Canvas C)
{
    local GUIComponent Owner;
    local FloatingWindow Window;
    local font SavedFont;
    local color SavedColor;
    local byte SavedStyle;
    local float SavedScaleX, SavedScaleY, TextWidth, TextHeight, Scale, MaxWidth;

    if (TitleLabel.Caption == "")
        return True;
    Owner = MenuOwner;
    while (Owner != None && FloatingWindow(Owner) == None)
        Owner = Owner.MenuOwner;
    Window = FloatingWindow(Owner);
    if (Window != None && Window.t_WindowTitle != None)
    {
        TitleReferenceX = Window.t_WindowTitle.ActualLeft() + Window.t_WindowTitle.ActualWidth() * 0.5;
        MaxWidth = Window.ActualWidth() - 16;
    }
    else
    {
        TitleReferenceX = ActualLeft() + ActualWidth() * 0.5;
        MaxWidth = ActualWidth() - 16;
    }
    SavedFont = C.Font;
    SavedColor = C.DrawColor;
    SavedStyle = C.Style;
    SavedScaleX = C.FontScaleX;
    SavedScaleY = C.FontScaleY;
    C.Font = Controller.GetMenuFont(TitleLabel.TextFont).GetFontB(C.SizeX, C.SizeY);
    C.FontScaleX = 1;
    C.FontScaleY = 1;
    C.TextSize(TitleLabel.Caption, TextWidth, TextHeight);
    Scale = FMin(1.0, FMin(MaxWidth / FMax(1, TextWidth),
        TitleLabel.ActualHeight() / FMax(1, TextHeight)));
    C.FontScaleX = FMax(0.01, Scale);
    C.FontScaleY = C.FontScaleX;
    TitleCenterX = Round(TitleReferenceX - TextWidth * Scale * 0.5) + TextWidth * Scale * 0.5;
    C.SetPos(TitleCenterX - TextWidth * Scale * 0.5,
        Round(TitleLabel.ActualTop() + (TitleLabel.ActualHeight() - TextHeight * Scale) * 0.5));
    C.DrawColor = TitleLabel.TextColor;
    C.Style = 1;
    C.DrawText(TitleLabel.Caption);
    C.Font = SavedFont;
    C.DrawColor = SavedColor;
    C.Style = SavedStyle;
    C.FontScaleX = SavedScaleX;
    C.FontScaleY = SavedScaleY;
    return True;
}

function bool CreditsClicked(GUIComponent Sender)
{
    Controller.OpenMenu("BetterSkinBrowser.SkinBrowserCreditsPage");
    return True;
}

// Preview a random skin from the current view, search, and filters. A
// different skin is chosen whenever more than one is visible.
function bool RandomClicked(GUIComponent Sender)
{
    local GUIList List;
    local array<int> Choices;
    local int i, Pick, Skins;

    List = CharacterList.List;
    for (i = 0; i < List.ItemCount; i++)
        if (!List.Elements[i].bSection)
            Skins++;
    for (i = 0; i < List.ItemCount; i++)
        if (!List.Elements[i].bSection && (int(List.GetExtraAtIndex(i)) != SelectedRecord || Skins == 1))
            Choices[Choices.Length] = i;
    if (Choices.Length == 0)
        return True;
    Pick = Choices[Rand(Choices.Length)];
    DiceFace = 1 + Rand(6);
    // SetIndex notifies CharacterChanged, which previews and syncs the grid.
    List.SetIndex(Pick);
    if (Pick > 0 && List.Elements[Pick - 1].bSection && Pick - 1 < List.Top)
        List.SetTopItem(Pick - 1);
    if (CharacterList.MyScrollBar != None)
        CharacterList.MyScrollBar.AlignThumb();
    return True;
}

function DrawPip(Canvas C, float X, float Y, float Size)
{
    // A plus-shaped pip reads as round at button sizes.
    C.SetPos(X - Size * 0.5, Y - Size * 0.3);
    C.DrawTile(Texture'Engine.WhiteSquareTexture', Size, Size * 0.6, 0, 0, 2, 2);
    C.SetPos(X - Size * 0.3, Y - Size * 0.5);
    C.DrawTile(Texture'Engine.WhiteSquareTexture', Size * 0.6, Size, 0, 0, 2, 2);
}

// Brown metallic die with gold pips over the stock blue button, showing the
// face of the last roll (five before the first roll).
function DrawRandomButton(Canvas C)
{
    local color SavedColor;
    local byte SavedStyle, Face;
    local float Side, X, Y, Cut, Pip, Q;
    local bool bHover;

    SavedColor = C.DrawColor;
    SavedStyle = C.Style;
    bHover = RandomButton.MenuState == MSAT_Watched || RandomButton.MenuState == MSAT_Focused ||
        RandomButton.MenuState == MSAT_Pressed;
    Side = Round(FMin(RandomButton.ActualWidth(), RandomButton.ActualHeight()) * 0.8);
    X = Round(RandomButton.ActualLeft() + (RandomButton.ActualWidth() - Side) * 0.5);
    Y = Round(RandomButton.ActualTop() + (RandomButton.ActualHeight() - Side) * 0.5);
    Cut = FMax(1.0, Round(Side * 0.12));
    C.Style = 1;
    // Dark rim, then body with a lighter top band and darker bottom band.
    C.SetDrawColor(46, 28, 14, 255);
    C.SetPos(X + Cut, Y);
    C.DrawTile(Texture'Engine.WhiteSquareTexture', Side - Cut * 2, Side, 0, 0, 2, 2);
    C.SetPos(X, Y + Cut);
    C.DrawTile(Texture'Engine.WhiteSquareTexture', Side, Side - Cut * 2, 0, 0, 2, 2);
    if (bHover)
        C.SetDrawColor(140, 92, 50, 255);
    else
        C.SetDrawColor(116, 74, 40, 255);
    C.SetPos(X + Cut, Y + 1);
    C.DrawTile(Texture'Engine.WhiteSquareTexture', Side - Cut * 2, Side - 2, 0, 0, 2, 2);
    C.SetPos(X + 1, Y + Cut);
    C.DrawTile(Texture'Engine.WhiteSquareTexture', Side - 2, Side - Cut * 2, 0, 0, 2, 2);
    C.SetDrawColor(170, 118, 66, 255);
    C.SetPos(X + Cut, Y + 1);
    C.DrawTile(Texture'Engine.WhiteSquareTexture', Side - Cut * 2, Round(Side * 0.18), 0, 0, 2, 2);
    C.SetDrawColor(78, 48, 24, 255);
    C.SetPos(X + Cut, Y + Side - 1 - Round(Side * 0.14));
    C.DrawTile(Texture'Engine.WhiteSquareTexture', Side - Cut * 2, Round(Side * 0.14), 0, 0, 2, 2);
    // Gold pips.
    Face = DiceFace;
    if (Face < 1 || Face > 6)
        Face = 5;
    Pip = FMax(2.0, Round(Side * 0.2));
    Q = Side * 0.27;
    C.SetDrawColor(255, 205, 40, 255);
    if (Face == 1 || Face == 3 || Face == 5)
        DrawPip(C, X + Side * 0.5, Y + Side * 0.5, Pip);
    if (Face >= 2)
    {
        DrawPip(C, X + Q, Y + Q, Pip);
        DrawPip(C, X + Side - Q, Y + Side - Q, Pip);
    }
    if (Face >= 4)
    {
        DrawPip(C, X + Side - Q, Y + Q, Pip);
        DrawPip(C, X + Q, Y + Side - Q, Pip);
    }
    if (Face == 6)
    {
        DrawPip(C, X + Q, Y + Side * 0.5, Pip);
        DrawPip(C, X + Side - Q, Y + Side * 0.5, Pip);
    }
    C.DrawColor = SavedColor;
    C.Style = SavedStyle;
}

function bool ShortcutsClicked(GUIComponent Sender)
{
    Controller.OpenMenu("BetterSkinBrowser.SkinBrowserShortcutsPage");
    return True;
}

// Credits is the one inverted button: gold fill with light-blue text, a lighter
// gold on hover, and a pale edge, so it stands apart from blue/gold buttons.
function bool DrawCreditsButton(Canvas C)
{
    local color SavedColor, SavedFontColor;
    local byte SavedStyle, R, G, B;
    local bool bHover;
    local float Shadow;

    SavedColor = C.DrawColor;
    SavedStyle = C.Style;
    bHover = CreditsButton.MenuState == MSAT_Watched || CreditsButton.MenuState == MSAT_Focused;
    R = 214; G = 168; B = 34;
    if (CreditsButton.MenuState == MSAT_Pressed)
    {
        R = 190; G = 146; B = 26;
    }
    else if (bHover)
    {
        R = 240; G = 196; B = 62;
    }
    C.Style = 1;
    C.SetDrawColor(R, G, B, 255);
    C.SetPos(CreditsButton.ActualLeft(), CreditsButton.ActualTop());
    C.DrawTile(Texture'Engine.WhiteSquareTexture', CreditsButton.ActualWidth(), CreditsButton.ActualHeight(),
        0, 0, 2, 2);
    C.SetDrawColor(255, 236, 160, 255);
    if (bHover)
        C.SetDrawColor(255, 250, 220, 255);
    DrawGridFrame(C, CreditsButton.ActualLeft(), CreditsButton.ActualTop(), CreditsButton.ActualWidth(),
        CreditsButton.ActualHeight(), FMax(1.0, Round(Controller.ResY / 1080.0)));
    if (CreditsButton.Style != None)
    {
        SavedFontColor = CreditsButton.Style.FontColors[0];
        // The preview hint line's light blue, over a thin navy shadow so it
        // stays legible on gold.
        Shadow = FMax(1.0, Round(Controller.ResY / 1080.0));
        CreditsButton.Style.FontColors[0].R = 18;
        CreditsButton.Style.FontColors[0].G = 34;
        CreditsButton.Style.FontColors[0].B = 82;
        CreditsButton.Style.FontColors[0].A = 255;
        CreditsButton.Style.DrawText(C, MSAT_Blurry, CreditsButton.ActualLeft() + Shadow,
            CreditsButton.ActualTop() + Shadow, CreditsButton.ActualWidth(), CreditsButton.ActualHeight(),
            TXTA_Center, CreditsButton.Caption, CreditsButton.FontScale);
        CreditsButton.Style.FontColors[0].R = 190;
        CreditsButton.Style.FontColors[0].G = 220;
        CreditsButton.Style.FontColors[0].B = 255;
        CreditsButton.Style.DrawText(C, MSAT_Blurry, CreditsButton.ActualLeft(), CreditsButton.ActualTop(),
            CreditsButton.ActualWidth(), CreditsButton.ActualHeight(), TXTA_Center, CreditsButton.Caption,
            CreditsButton.FontScale);
        CreditsButton.Style.FontColors[0] = SavedFontColor;
    }
    C.DrawColor = SavedColor;
    C.Style = SavedStyle;
    return True;
}

function bool CloseClicked(GUIComponent Sender)
{
    Controller.CloseMenu(True);
    return True;
}

function Free()
{
    DestroyWeaponPreview();
    if (PreviewActor != None)
        PreviewActor.Destroy();
    PreviewActor = None;
    Super.Free();
}

defaultproperties
{
    Begin Object Class=GUILabel Name=BrowserTitle
        Caption="Unreal Skin Browser"
        TextAlign=TXTA_Center
        TextColor=(R=255,G=210,B=0,A=255)
        TextFont="UT2HeaderFont"
        WinTop=0.012000
        WinLeft=0.040000
        WinWidth=0.840000
        WinHeight=0.060000
        bBoundToParent=True
        bScaleToParent=True
        OnDraw=SkinBrowserWidget.DrawCenteredTitle
    End Object
    TitleLabel=GUILabel'BetterSkinBrowser.SkinBrowserWidget.BrowserTitle'
    Begin Object Class=GUIButton Name=AllCharacterSkins
        Caption="All skins"
        Hint="Browse all installed selectable skins."
        WinTop=0.095000
        WinLeft=0.055000
        WinWidth=0.112000
        WinHeight=0.044000
        TabOrder=0
        bBoundToParent=True
        OnClick=SkinBrowserWidget.ShowAllSkins
        OnRendered=SkinBrowserWidget.DrawAllViewMarker
    End Object
    AllSkinsButton=GUIButton'BetterSkinBrowser.SkinBrowserWidget.AllCharacterSkins'

    Begin Object Class=GUIButton Name=FavoriteCharacterSkins
        Caption="Favorites (0)"
        Hint="Browse favorite skins using the current search, sort, and grouping."
        WinTop=0.095000
        WinLeft=0.175000
        WinWidth=0.130000
        WinHeight=0.044000
        TabOrder=1
        bBoundToParent=True
        OnClick=SkinBrowserWidget.ShowFavorites
        OnRendered=SkinBrowserWidget.DrawFavoritesViewMarker
    End Object
    FavoritesViewButton=GUIButton'BetterSkinBrowser.SkinBrowserWidget.FavoriteCharacterSkins'

    Begin Object Class=GUIButton Name=RecentCharacterSkins
        Caption="Recent (0)"
        Hint="Browse recently equipped skins, newest first. Search applies; sort and grouping do not."
        WinTop=0.095000
        WinLeft=0.313000
        WinWidth=0.112000
        WinHeight=0.044000
        TabOrder=19
        bBoundToParent=True
        OnClick=SkinBrowserWidget.ShowRecent
        OnRendered=SkinBrowserWidget.DrawRecentViewMarker
    End Object
    RecentViewButton=GUIButton'BetterSkinBrowser.SkinBrowserWidget.RecentCharacterSkins'

    Begin Object Class=GUIButton Name=ToggleCharacterFavorite
        Caption="Add favorite"
        Hint="Save or remove this character as a local favorite immediately."
        WinTop=0.855000
        WinLeft=0.515000
        WinWidth=0.185000
        WinHeight=0.050000
        TabOrder=20
        bBoundToParent=True
        OnClick=SkinBrowserWidget.ToggleFavorite
    End Object
    FavoriteButton=GUIButton'BetterSkinBrowser.SkinBrowserWidget.ToggleCharacterFavorite'

    Begin Object Class=moEditBox Name=CharacterSearch
        Caption="Search:"
        CaptionWidth=0.180000
        Hint="Match every search word in any order: name, race, sex, mesh, or skin texture package. Up/Down browse results; Enter moves to the list."
        OnCreateComponent=CharacterSearch.InternalOnCreateComponent
        WinTop=0.150000
        WinLeft=0.055000
        WinWidth=0.326000
        WinHeight=0.050000
        TabOrder=2
        bBoundToParent=True
        OnChange=SkinBrowserWidget.SearchChanged
    End Object
    SearchBox=moEditBox'BetterSkinBrowser.SkinBrowserWidget.CharacterSearch'

    Begin Object Class=GUIButton Name=ClearCharacterSearch
        Caption="x"
        Hint="Clear search while keeping the current view, sort, grouping, and visible selection."
        WinTop=0.150000
        WinLeft=0.389000
        WinWidth=0.036000
        WinHeight=0.050000
        TabOrder=3
        bBoundToParent=True
        OnClick=SkinBrowserWidget.ClearSearchClicked
    End Object
    ClearSearchButton=GUIButton'BetterSkinBrowser.SkinBrowserWidget.ClearCharacterSearch'

    Begin Object Class=moComboBox Name=CharacterSort
        Caption="Sort:"
        CaptionWidth=0.180000
        Hint="Choose the order used within each group."
        OnCreateComponent=CharacterSort.InternalOnCreateComponent
        WinTop=0.205000
        WinLeft=0.055000
        WinWidth=0.370000
        WinHeight=0.045000
        TabOrder=4
        bBoundToParent=True
        OnChange=SkinBrowserWidget.SortOrGroupChanged
    End Object
    SortBox=moComboBox'BetterSkinBrowser.SkinBrowserWidget.CharacterSort'

    Begin Object Class=moComboBox Name=CharacterGroup
        Caption="Group:"
        CaptionWidth=0.180000
        Hint="Group matching characters by race or inferred mesh family."
        OnCreateComponent=CharacterGroup.InternalOnCreateComponent
        WinTop=0.255000
        WinLeft=0.055000
        WinWidth=0.370000
        WinHeight=0.045000
        TabOrder=5
        bBoundToParent=True
        OnChange=SkinBrowserWidget.SortOrGroupChanged
    End Object
    GroupBox=moComboBox'BetterSkinBrowser.SkinBrowserWidget.CharacterGroup'

    Begin Object Class=GUIListBox Name=InstalledCharacterList
        OnCreateComponent=InstalledCharacterList.InternalOnCreateComponent
        StyleName="ServerBrowserGrid"
        Hint="Up/Down, Page Up/Down, Home/End browse skins. Ctrl+Enter applies, Ctrl+D toggles favorite, Ctrl+F searches."
        FontScale=FNS_Medium
        WinTop=0.310000
        WinLeft=0.055000
        WinWidth=0.370000
        WinHeight=0.455000
        TabOrder=6
        bBoundToParent=True
        OnChange=SkinBrowserWidget.CharacterChanged
    End Object
    CharacterList=GUIListBox'BetterSkinBrowser.SkinBrowserWidget.InstalledCharacterList'

    Begin Object Class=GUIVertImageListBox Name=InstalledCharacterGrid
        DefaultListClass="BetterSkinBrowser.SkinBrowserPortraitGrid"
        CellStyle=CELL_FixedCount
        NoVisibleRows=2
        NoVisibleCols=4
        OnCreateComponent=InstalledCharacterGrid.InternalOnCreateComponent
        Hint="Arrow keys move through portraits. Ctrl+Enter applies, Ctrl+D toggles favorite, Ctrl+F searches."
        WinTop=0.310000
        WinLeft=0.055000
        WinWidth=0.370000
        WinHeight=0.455000
        TabOrder=6
        bVisible=False
        bBoundToParent=True
        OnChange=SkinBrowserWidget.GridChanged
    End Object
    PortraitGrid=GUIVertImageListBox'BetterSkinBrowser.SkinBrowserWidget.InstalledCharacterGrid'

    Begin Object Class=GUIButton Name=CharacterLayoutToggle
        Caption="Grid"
        Hint="Switch between the text list and a portrait grid."
        WinTop=0.785000
        WinLeft=0.335000
        WinWidth=0.090000
        WinHeight=0.040000
        TabOrder=25
        bBoundToParent=True
        OnClick=SkinBrowserWidget.ToggleLayout
    End Object
    LayoutButton=GUIButton'BetterSkinBrowser.SkinBrowserWidget.CharacterLayoutToggle'

    Begin Object Class=GUIButton Name=RandomCharacterSkin
        Caption=""
        Hint="Preview a random skin from the current view and search."
        WinTop=0.785000
        WinLeft=0.300000
        WinWidth=0.030000
        WinHeight=0.040000
        TabOrder=24
        bBoundToParent=True
        OnClick=SkinBrowserWidget.RandomClicked
        OnRendered=SkinBrowserWidget.DrawRandomButton
    End Object
    RandomButton=GUIButton'BetterSkinBrowser.SkinBrowserWidget.RandomCharacterSkin'

    Begin Object Class=moCheckBox Name=HideBrokenCharacterSkins
        Caption="Hide broken skins"
        CaptionWidth=0.820000
        LabelJustification=TXTA_Right
        Hint="Hide installed skins whose model cannot be loaded; in a match they appear as the default model. Each model is checked once and remembered."
        OnCreateComponent=HideBrokenCharacterSkins.InternalOnCreateComponent
        WinTop=0.860000
        WinLeft=0.245000
        WinWidth=0.180000
        WinHeight=0.036000
        TabOrder=27
        bBoundToParent=True
        OnChange=SkinBrowserWidget.HideBrokenChanged
    End Object
    HideBrokenCheck=moCheckBox'BetterSkinBrowser.SkinBrowserWidget.HideBrokenCharacterSkins'

    Begin Object Class=SkinBrowserFitLabel Name=CharacterResultLabel
        Caption="0 skins"
        TextAlign=TXTA_Left
        TextColor=(R=255,G=255,B=0,A=255)
        WinTop=0.785000
        WinLeft=0.055000
        WinWidth=0.275000
        WinHeight=0.040000
        bBoundToParent=True
    End Object
    ResultLabel=GUILabel'BetterSkinBrowser.SkinBrowserWidget.CharacterResultLabel'

    Begin Object Class=GUIImage Name=CharacterPreviewPane
        Image=Texture'Engine.WhiteSquareTexture'
        ImageColor=(R=18,G=18,B=20,A=255)
        ImageStyle=ISTY_Stretched
        ImageRenderStyle=MSTY_Normal
        WinTop=0.095000
        WinLeft=0.515000
        WinWidth=0.350000
        WinHeight=0.285000
        RenderWeight=0.520000
        bBoundToParent=True
        OnDraw=SkinBrowserWidget.DrawPreview
    End Object
    PreviewPane=GUIImage'BetterSkinBrowser.SkinBrowserWidget.CharacterPreviewPane'

    Begin Object Class=GUIImage Name=CharacterPortraitPane
        ImageStyle=ISTY_Scaled
        ImageRenderStyle=MSTY_Normal
        AspectRatioScale=True
        WinTop=0.095000
        WinLeft=0.515000
        WinWidth=0.350000
        WinHeight=0.285000
        RenderWeight=0.525000
        bVisible=False
        bBoundToParent=True
        OnDraw=SkinBrowserWidget.DrawPortrait
    End Object
    PortraitPane=GUIImage'BetterSkinBrowser.SkinBrowserWidget.CharacterPortraitPane'

    Begin Object Class=GUIButton Name=CharacterPreviewInput
        StyleName="NoBackground"
        Hint="Drag to rotate, Shift-drag or right-drag to pan, and use the wheel to zoom."
        WinTop=0.095000
        WinLeft=0.515000
        WinWidth=0.350000
        WinHeight=0.285000
        RenderWeight=0.530000
        MouseCursorIndex=5
        bTabStop=False
        bCaptureMouse=True
        bBoundToParent=True
        OnKeyEvent=SkinBrowserWidget.PreviewKeyEvent
        OnMousePressed=SkinBrowserWidget.PreviewMousePressed
        OnCapturedMouseMove=SkinBrowserWidget.PreviewCapturedMouseMove
        OnMouseRelease=SkinBrowserWidget.PreviewMouseReleased
    End Object
    PreviewInput=GUIButton'BetterSkinBrowser.SkinBrowserWidget.CharacterPreviewInput'

    Begin Object Class=GUIButton Name=CharacterViewMode
        Caption="Portrait"
        Hint="Show the selected skin's portrait."
        WinTop=0.465000
        WinLeft=0.705000
        WinWidth=0.086000
        WinHeight=0.040000
        RenderWeight=0.550000
        TabOrder=10
        bBoundToParent=True
        OnClick=SkinBrowserWidget.ToggleViewMode
    End Object
    ViewModeButton=GUIButton'BetterSkinBrowser.SkinBrowserWidget.CharacterViewMode'

    Begin Object Class=SkinBrowserFitLabel Name=SelectedCharacterName
        Caption="Select a character"
        TextAlign=TXTA_Center
        TextColor=(R=255,G=255,B=0,A=255)
        WinTop=0.385000
        WinLeft=0.515000
        WinWidth=0.350000
        WinHeight=0.040000
        FontScale=FNS_Large
        RenderWeight=0.540000
        bBoundToParent=True
    End Object
    NameLabel=GUILabel'BetterSkinBrowser.SkinBrowserWidget.SelectedCharacterName'

    Begin Object Class=SkinBrowserFitLabel Name=SelectedCharacterDetails
        Caption="Race | sex | package"
        TextAlign=TXTA_Center
        TextColor=(R=190,G=220,B=255,A=255)
        WinTop=0.425000
        WinLeft=0.515000
        WinWidth=0.350000
        WinHeight=0.035000
        bBoundToParent=True
    End Object
    DetailsLabel=GUILabel'BetterSkinBrowser.SkinBrowserWidget.SelectedCharacterDetails'

    Begin Object Class=GUIButton Name=NormalCharacterSkin
        Caption="Normal"
        Hint="Preview the normal character materials."
        WinTop=0.465000
        WinLeft=0.515000
        WinWidth=0.062000
        WinHeight=0.040000
        TabOrder=7
        bBoundToParent=True
        OnClick=SkinBrowserWidget.SetNormalSkin
    End Object
    NormalSkinButton=GUIButton'BetterSkinBrowser.SkinBrowserWidget.NormalCharacterSkin'

    Begin Object Class=GUIButton Name=RedCharacterSkin
        Caption="Red"
        Hint="Preview UT2004's red-team materials."
        WinTop=0.465000
        WinLeft=0.583000
        WinWidth=0.055000
        WinHeight=0.040000
        TabOrder=8
        bBoundToParent=True
        OnClick=SkinBrowserWidget.SetRedSkin
        OnDraw=SkinBrowserWidget.DrawRedButton
    End Object
    RedSkinButton=GUIButton'BetterSkinBrowser.SkinBrowserWidget.RedCharacterSkin'

    Begin Object Class=GUIButton Name=BlueCharacterSkin
        Caption="Blue"
        Hint="Preview UT2004's blue-team materials."
        WinTop=0.465000
        WinLeft=0.644000
        WinWidth=0.055000
        WinHeight=0.040000
        TabOrder=9
        bBoundToParent=True
        OnClick=SkinBrowserWidget.SetBlueSkin
        OnDraw=SkinBrowserWidget.DrawBlueButton
    End Object
    BlueSkinButton=GUIButton'BetterSkinBrowser.SkinBrowserWidget.BlueCharacterSkin'

    Begin Object Class=GUIButton Name=ResetCharacterView
        Caption="Reset"
        Hint="Restore the default camera and model rotation."
        WinTop=0.465000
        WinLeft=0.797000
        WinWidth=0.062000
        WinHeight=0.040000
        TabOrder=11
        bBoundToParent=True
        OnClick=SkinBrowserWidget.ResetPreviewView
    End Object
    ResetViewButton=GUIButton'BetterSkinBrowser.SkinBrowserWidget.ResetCharacterView'

    Begin Object Class=moCheckBox Name=CharacterAutoRotate
        Caption="Auto rotate"
        CaptionWidth=0.750000
        Hint="Resume automatic rotation after a short period without viewport input."
        OnCreateComponent=CharacterAutoRotate.InternalOnCreateComponent
        WinTop=0.517000
        WinLeft=0.515000
        WinWidth=0.350000
        WinHeight=0.036000
        TabOrder=12
        bBoundToParent=True
        OnChange=SkinBrowserWidget.AutoRotateChanged
    End Object
    AutoRotateCheck=moCheckBox'BetterSkinBrowser.SkinBrowserWidget.CharacterAutoRotate'

    Begin Object Class=moCheckBox Name=CharacterShockRifle
        Caption="Hold weapon"
        CaptionWidth=0.750000
        Hint="Preview the default weapon-holding stance."
        OnCreateComponent=CharacterShockRifle.InternalOnCreateComponent
        WinTop=0.561000
        WinLeft=0.515000
        WinWidth=0.350000
        WinHeight=0.036000
        TabOrder=13
        bBoundToParent=True
        OnChange=SkinBrowserWidget.WeaponChanged
    End Object
    WeaponCheck=moCheckBox'BetterSkinBrowser.SkinBrowserWidget.CharacterShockRifle'

    Begin Object Class=moCheckBox Name=CharacterLoopAnimation
        Caption="Loop animation"
        CaptionWidth=0.750000
        Hint="Repeat the selected preview animation until another is selected."
        OnCreateComponent=CharacterLoopAnimation.InternalOnCreateComponent
        WinTop=0.605000
        WinLeft=0.515000
        WinWidth=0.350000
        WinHeight=0.036000
        TabOrder=14
        bBoundToParent=True
        OnChange=SkinBrowserWidget.LoopAnimationChanged
    End Object
    LoopAnimationCheck=moCheckBox'BetterSkinBrowser.SkinBrowserWidget.CharacterLoopAnimation'

    Begin Object Class=moComboBox Name=CharacterAnimation
        Caption="Animation:"
        CaptionWidth=0.230000
        Hint="Preview compatible idle and species taunt animations."
        OnCreateComponent=CharacterAnimation.InternalOnCreateComponent
        WinTop=0.652000
        WinLeft=0.515000
        WinWidth=0.350000
        WinHeight=0.040000
        TabOrder=15
        bAlwaysNotify=True
        bBoundToParent=True
        OnChange=SkinBrowserWidget.AnimationChanged
    End Object
    AnimationBox=moComboBox'BetterSkinBrowser.SkinBrowserWidget.CharacterAnimation'

    Begin Object Class=moComboBox Name=CharacterVoicePack
        Caption="Voice pack:"
        CaptionWidth=0.288000
        Hint="Choose the voice saved with this character; Character default uses the skin's assigned voice."
        OnCreateComponent=CharacterVoicePack.InternalOnCreateComponent
        WinTop=0.700000
        WinLeft=0.515000
        WinWidth=0.280000
        WinHeight=0.040000
        TabOrder=16
        bBoundToParent=True
        OnChange=SkinBrowserWidget.VoicePackChanged
    End Object
    VoicePackBox=moComboBox'BetterSkinBrowser.SkinBrowserWidget.CharacterVoicePack'

    Begin Object Class=GUIButton Name=DefaultCharacterVoice
        Caption="Default"
        Hint="Select this character's assigned default voice pack. Press Apply to save it."
        WinTop=0.700000
        WinLeft=0.800000
        WinWidth=0.065000
        WinHeight=0.040000
        TabOrder=17
        bBoundToParent=True
        OnClick=SkinBrowserWidget.DefaultVoiceClicked
    End Object
    DefaultVoiceButton=GUIButton'BetterSkinBrowser.SkinBrowserWidget.DefaultCharacterVoice'

    Begin Object Class=moComboBox Name=CharacterVoiceLine
        Caption="Preview line:"
        CaptionWidth=0.230000
        Hint="Preview lines from the voice pack selected above."
        OnCreateComponent=CharacterVoiceLine.InternalOnCreateComponent
        WinTop=0.748000
        WinLeft=0.515000
        WinWidth=0.350000
        WinHeight=0.040000
        TabOrder=18
        bAlwaysNotify=True
        bBoundToParent=True
        OnChange=SkinBrowserWidget.VoiceChanged
    End Object
    VoiceBox=moComboBox'BetterSkinBrowser.SkinBrowserWidget.CharacterVoiceLine'

    Begin Object Class=SkinBrowserFitLabel Name=PreviewStatus
        Caption="3D preview"
        TextAlign=TXTA_Center
        TextColor=(R=190,G=220,B=255,A=255)
        WinTop=0.797000
        WinLeft=0.515000
        WinWidth=0.350000
        WinHeight=0.033000
        bBoundToParent=True
        OnTimer=SkinBrowserWidget.ApplyStatusTimer
    End Object
    StatusLabel=GUILabel'BetterSkinBrowser.SkinBrowserWidget.PreviewStatus'

    Begin Object Class=GUIButton Name=ActivateCharacterButton
        Caption="Apply"
        Hint="Activate the selected character and chosen voice pack."
        WinTop=0.855000
        WinLeft=0.715000
        WinWidth=0.130000
        WinHeight=0.050000
        TabOrder=21
        bBoundToParent=True
        OnClick=SkinBrowserWidget.ApplyClicked
    End Object
    ApplyButton=GUIButton'BetterSkinBrowser.SkinBrowserWidget.ActivateCharacterButton'

    Begin Object Class=GUIButton Name=ShowCreditsButton
        Caption="Credits"
        Hint="Show who made Unreal Skin Browser."
        WinTop=0.855000
        WinLeft=0.040000
        WinWidth=0.090000
        WinHeight=0.050000
        TabOrder=23
        bBoundToParent=True
        OnClick=SkinBrowserWidget.CreditsClicked
        OnDraw=SkinBrowserWidget.DrawCreditsButton
    End Object
    CreditsButton=GUIButton'BetterSkinBrowser.SkinBrowserWidget.ShowCreditsButton'

    Begin Object Class=GUIButton Name=ShowShortcutsButton
        Caption="Shortcuts"
        Hint="List the keyboard shortcuts."
        WinTop=0.855000
        WinLeft=0.136000
        WinWidth=0.100000
        WinHeight=0.050000
        TabOrder=26
        bBoundToParent=True
        OnClick=SkinBrowserWidget.ShortcutsClicked
    End Object
    ShortcutsButton=GUIButton'BetterSkinBrowser.SkinBrowserWidget.ShowShortcutsButton'

    Begin Object Class=GUIButton Name=CloseBrowserButton
        Caption="Close"
        Hint="Close Unreal Skin Browser without applying the preview selection."
        WinTop=0.855000
        WinLeft=0.850000
        WinWidth=0.100000
        WinHeight=0.050000
        TabOrder=22
        bVisible=False
        bBoundToParent=True
        OnClick=SkinBrowserWidget.CloseClicked
    End Object
    CloseButton=GUIButton'BetterSkinBrowser.SkinBrowserWidget.CloseBrowserButton'

    PreviewFOV=15
    AutoRotateDelay=3.000000
    PreviewTeam=255
    SelectedRecord=-1
    PropagateVisibility=True
    WinLeft=0.000000
    WinTop=0.000000
    WinWidth=1.000000
    WinHeight=1.000000
    OnKeyEvent=SkinBrowserWidget.PageKeyEvent
    OnDraw=SkinBrowserWidget.DrawBrowserCards
}
