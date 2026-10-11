// Locally equipped characters, most recent first, shared by every browser
// widget in this client. Names match ChangeCharacter identifiers.
class SkinBrowserRecent extends Object config(BetterSkinBrowser);

var config array<string> CharacterNames;
var int MaxEntries;

static function int Find(string CharacterName)
{
    local int i;

    if (CharacterName == "")
        return -1;
    for (i = 0; i < default.CharacterNames.Length; i++)
        if (default.CharacterNames[i] ~= CharacterName)
            return i;
    return -1;
}

static function int LastIndex(string CharacterName)
{
    local int i;

    for (i = default.CharacterNames.Length - 1; i >= 0; i--)
        if (default.CharacterNames[i] ~= CharacterName)
            return i;
    return -1;
}

// Move a character to the front, dropping duplicates and the oldest entries.
static function NoteUsed(string CharacterName)
{
    local int i;

    if (CharacterName == "")
        return;
    if ((default.CharacterNames.Length > 0) && (default.CharacterNames[0] ~= CharacterName) &&
        (default.CharacterNames.Length <= default.MaxEntries) && (Find(CharacterName) == 0) &&
        (LastIndex(CharacterName) == 0))
        return;
    for (i = default.CharacterNames.Length - 1; i >= 0; i--)
        if (default.CharacterNames[i] ~= CharacterName)
            default.CharacterNames.Remove(i, 1);
    default.CharacterNames.Insert(0, 1);
    default.CharacterNames[0] = CharacterName;
    if (default.CharacterNames.Length > default.MaxEntries)
        default.CharacterNames.Remove(default.MaxEntries,
            default.CharacterNames.Length - default.MaxEntries);
    StaticSaveConfig();
}

defaultproperties
{
    MaxEntries=12
}
