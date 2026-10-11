// Portrait grid list. The stock image list reads outside Elements when it is
// cleared, deselected, or moved past a short last row, and its paging scrolls
// by rows-as-items without moving the selection. Keep the stock grid
// behavior with bounds checks and whole-page selection paging.
class SkinBrowserPortraitGrid extends GUIVertImageList;

function int PageItems()
{
    return Max(1, NoVisibleRows * NoVisibleCols);
}

function int SetIndex(int NewIndex)
{
    if (NewIndex >= 0 && NewIndex < Elements.Length && Elements[NewIndex].Locked == 1)
        return Index;
    Super(GUIVertList).SetIndex(NewIndex);
    MakeIndexVisible();
    return Index;
}

// Scroll whole rows so the selection is visible, even before the first draw
// has set ItemsPerPage.
function MakeIndexVisible()
{
    local int Row, TopRow, MaxTop;

    if (NoVisibleCols <= 0 || NoVisibleRows <= 0)
        return;
    if (Index >= 0)
    {
        Row = Index / NoVisibleCols;
        TopRow = Top / NoVisibleCols;
        if (Row < TopRow)
            Top = Row * NoVisibleCols;
        else if (Row >= TopRow + NoVisibleRows)
            Top = (Row - NoVisibleRows + 1) * NoVisibleCols;
        else if (Top % NoVisibleCols != 0)
            Top = TopRow * NoVisibleCols;
    }
    // Never leave empty rows below the last portrait, so short results that
    // fit on one page always start at the top.
    MaxTop = Max(0, ((ItemCount + NoVisibleCols - 1) / NoVisibleCols - NoVisibleRows) * NoVisibleCols);
    Top = Clamp(Top, 0, MaxTop);
    if (MyScrollBar != None)
        MyScrollBar.AlignThumb();
}

function bool IsLockedCell(int i)
{
    return i >= 0 && i < Elements.Length && Elements[i].Locked == 1;
}

// Grouped grids pad each category's last row with locked blank cells.
// Return i, or the nearest real portrait in Direction, then the other way.
function int NearestUnlocked(int i, int Direction)
{
    local int j;

    if (Direction == 0)
        Direction = 1;
    else
        Direction = Clamp(Direction, -1, 1);
    for (j = i; j >= 0 && j < ItemCount; j += Direction)
        if (!IsLockedCell(j))
            return j;
    for (j = i; j >= 0 && j < ItemCount; j -= Direction)
        if (!IsLockedCell(j))
            return j;
    return Index;
}

// Up/Down keep the column; in a padded row, use the row's last portrait.
function int RowTarget(int Target)
{
    local int RowStart;

    if (Target < 0 || Target >= ItemCount)
        return -1;
    RowStart = Target - Target % NoVisibleCols;
    while (Target >= RowStart && IsLockedCell(Target))
        Target--;
    if (Target < RowStart)
        return -1;
    return Target;
}

function bool Up()
{
    local int Target;

    if (Index < 0)
        return True;
    Target = RowTarget(Index - NoVisibleCols);
    if (Target < 0)
        Target = RowTarget(Index - 2 * NoVisibleCols);
    if (Target >= 0)
        SetIndex(Target);
    return True;
}

function bool Down()
{
    local int Target, NextRow;

    if (Index < 0)
        return True;
    NextRow = Index - Index % NoVisibleCols + NoVisibleCols;
    if (NextRow >= ItemCount)
        return True;
    Target = RowTarget(Min(Index + NoVisibleCols, ItemCount - 1));
    if (Target < NextRow)
        Target = RowTarget(Min(NextRow + NoVisibleCols - 1, ItemCount - 1));
    if (Target >= NextRow)
        SetIndex(Target);
    return True;
}

function bool MoveRight()
{
    if (Index < 0 || Index + 1 >= ItemCount || (Index + 1) % NoVisibleCols == 0 ||
        IsLockedCell(Index + 1))
        return True;
    SetIndex(Index + 1);
    return True;
}

function bool MoveLeft()
{
    if (Index <= 0 || Index % NoVisibleCols == 0)
        return True;
    SetIndex(Index - 1);
    return True;
}

function PgUp()
{
    if (ItemCount > 0)
        SetIndex(NearestUnlocked(Max(0, Index - PageItems()), -1));
}

function PgDn()
{
    if (ItemCount > 0)
        SetIndex(NearestUnlocked(Min(ItemCount - 1, Index + PageItems()), 1));
}

defaultproperties
{
    bAllowEmptyItems=True
}
