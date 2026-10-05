// Keep secondary information readable across viewport sizes and GUI font settings.
class SkinBrowserFitLabel extends GUILabel;

function bool DrawFittedLabel(Canvas C)
{
    local font SavedFont;
    local color SavedColor;
    local byte SavedStyle;
    local float SavedScaleX, SavedScaleY, SavedX, SavedY;
    local float TextWidth, TextHeight, Scale, X;

    if (Caption == "")
        return True;
    SavedFont = C.Font;
    SavedColor = C.DrawColor;
    SavedStyle = C.Style;
    SavedScaleX = C.FontScaleX;
    SavedScaleY = C.FontScaleY;
    SavedX = C.CurX;
    SavedY = C.CurY;
    C.Font = Controller.GetMenuFont(TextFont).GetFontB(C.SizeX, C.SizeY);
    C.FontScaleX = 1;
    C.FontScaleY = 1;
    C.TextSize(Caption, TextWidth, TextHeight);
    Scale = FMin(1.0, FMin((ActualWidth() - 4) / FMax(1, TextWidth),
        ActualHeight() * 0.85 / FMax(1, TextHeight)));
    C.FontScaleX = FMax(0.01, Scale);
    C.FontScaleY = C.FontScaleX;
    X = ActualLeft() + 2;
    if (TextAlign == TXTA_Center)
        X = ActualLeft() + (ActualWidth() - TextWidth * Scale) * 0.5;
    else if (TextAlign == TXTA_Right)
        X = ActualLeft() + ActualWidth() - TextWidth * Scale - 2;
    C.SetPos(X, ActualTop() + (ActualHeight() - TextHeight * Scale) * 0.5);
    C.DrawColor = TextColor;
    C.Style = 1;
    C.DrawTextClipped(Caption);
    C.Font = SavedFont;
    C.DrawColor = SavedColor;
    C.Style = SavedStyle;
    C.FontScaleX = SavedScaleX;
    C.FontScaleY = SavedScaleY;
    C.SetPos(SavedX, SavedY);
    return True;
}

defaultproperties
{
    OnDraw=SkinBrowserFitLabel.DrawFittedLabel
}
