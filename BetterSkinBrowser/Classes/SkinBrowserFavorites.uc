// Local character bookmarks shared by every browser widget in this client.
// Names are the same stable identifiers used by ChangeCharacter, not list indices.
class SkinBrowserFavorites extends Object config(BetterSkinBrowser);

var config array<string> CharacterNames;

static function bool Contains(string CharacterName)
{
    local int i;

    if (CharacterName == "")
        return False;
    for (i = 0; i < default.CharacterNames.Length; i++)
        if (default.CharacterNames[i] ~= CharacterName)
            return True;
    return False;
}

static function SetFavorite(string CharacterName, bool bFavorite)
{
    local int i;
    local bool bChanged;

    if (CharacterName == "")
        return;
    if (bFavorite)
    {
        if (Contains(CharacterName))
            return;
        default.CharacterNames[default.CharacterNames.Length] = CharacterName;
        bChanged = True;
    }
    else
    {
        // Remove every matching entry, including duplicates in a hand-edited INI.
        for (i = default.CharacterNames.Length - 1; i >= 0; i--)
            if (default.CharacterNames[i] ~= CharacterName)
            {
                default.CharacterNames.Remove(i, 1);
                bChanged = True;
            }
    }
    if (bChanged)
        StaticSaveConfig();
}
