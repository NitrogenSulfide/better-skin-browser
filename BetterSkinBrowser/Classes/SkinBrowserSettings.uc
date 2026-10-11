// Client-local browser preferences shared by every browser widget, plus the
// remembered result of checking which character meshes can be loaded.
class SkinBrowserSettings extends Object config(BetterSkinBrowser);

var config bool bGridView;
var config bool bHideBrokenSkins;
var config array<string> LoadableMeshes;
var config array<string> BrokenMeshes;

static function SetGridView(bool bNewGridView)
{
    if (default.bGridView == bNewGridView)
        return;
    default.bGridView = bNewGridView;
    StaticSaveConfig();
}

static function SetHideBrokenSkins(bool bHide)
{
    if (default.bHideBrokenSkins == bHide)
        return;
    default.bHideBrokenSkins = bHide;
    StaticSaveConfig();
}

static function int FindMesh(array<string> Meshes, string MeshName)
{
    local int i;

    for (i = 0; i < Meshes.Length; i++)
        if (Meshes[i] ~= MeshName)
            return i;
    return -1;
}

// Record one load result. Returns True when the saved lists changed.
static function bool NoteMeshResult(string MeshName, bool bLoadable)
{
    local int i;
    local bool bChanged;

    i = FindMesh(default.BrokenMeshes, MeshName);
    if (bLoadable && i >= 0)
    {
        default.BrokenMeshes.Remove(i, 1);
        bChanged = True;
    }
    else if (!bLoadable && i < 0)
    {
        default.BrokenMeshes[default.BrokenMeshes.Length] = MeshName;
        bChanged = True;
    }
    i = FindMesh(default.LoadableMeshes, MeshName);
    if (bLoadable && i < 0)
    {
        default.LoadableMeshes[default.LoadableMeshes.Length] = MeshName;
        bChanged = True;
    }
    else if (!bLoadable && i >= 0)
    {
        default.LoadableMeshes.Remove(i, 1);
        bChanged = True;
    }
    return bChanged;
}

defaultproperties
{
    bHideBrokenSkins=True
}
