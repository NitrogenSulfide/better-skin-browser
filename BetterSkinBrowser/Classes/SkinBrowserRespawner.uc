// Client-local helper for "Respawn on Apply". Online the skin request goes to
// the server unreliably (SetPawnClass) while Suicide is reliable, so the
// suicide waits until the server echoes the new character name back through
// PlayerReplicationInfo; if that never happens no point is spent. It is an
// actor rather than a GUI timer so it still runs after the menu closes.
class SkinBrowserRespawner extends Info;

var string RequestedCharacter;
var Pawn OldPawn;
var bool bSuicideSent;
var float Deadline;
var float ConfirmTimeout;
var float DeathTimeout;
var localized string UnconfirmedMessage;
var localized string RefusedMessage;

static function bool CanRespawn(PlayerController PC)
{
    if ((PC == None) || (PC.Pawn == None) || (Vehicle(PC.Pawn) != None))
        return False;
    if ((PC.PlayerReplicationInfo == None) || PC.PlayerReplicationInfo.bOnlySpectator
        || (PC.PlayerReplicationInfo.HasFlag != None))
        return False;
    // Never spend a life in Last Man Standing, Invasion or similar modes.
    if ((PC.GameReplicationInfo != None) && (PC.GameReplicationInfo.MaxLives > 0))
        return False;
    return True;
}

// Standalone: returns True only if the pawn actually died (stock Suicide
// refuses within a second of spawning). Online: returns True when a respawn
// was scheduled; the outcome is reported later in the console if it fails.
static function bool Request(PlayerController PC, string CharacterName)
{
    local SkinBrowserRespawner R;
    local Pawn Before;

    if (!CanRespawn(PC))
        return False;
    if (PC.Level.NetMode == NM_Standalone)
    {
        Before = PC.Pawn;
        PC.ConsoleCommand("Suicide");
        return PC.Pawn != Before;
    }
    foreach PC.DynamicActors(class'SkinBrowserRespawner', R)
        R.Destroy();
    R = PC.Spawn(class'SkinBrowserRespawner', PC);
    if (R == None)
        return False;
    R.RequestedCharacter = CharacterName;
    R.Deadline = PC.Level.TimeSeconds + default.ConfirmTimeout;
    R.SetTimer(0.1, True);
    return True;
}

function Timer()
{
    local PlayerController PC;

    PC = PlayerController(Owner);
    if (PC == None)
    {
        Destroy();
        return;
    }
    if (bSuicideSent)
    {
        if (PC.Pawn != OldPawn)
            Destroy();
        else if (Level.TimeSeconds > Deadline)
        {
            // Stock Suicide ignores players within ten seconds of spawning.
            PC.ClientMessage(RefusedMessage);
            Destroy();
        }
        return;
    }
    // Conditions may change while waiting (flag taken, died, entered a vehicle).
    if (!CanRespawn(PC))
    {
        Destroy();
        return;
    }
    if (PC.PlayerReplicationInfo.CharacterName ~= RequestedCharacter)
    {
        OldPawn = PC.Pawn;
        bSuicideSent = True;
        Deadline = Level.TimeSeconds + DeathTimeout;
        PC.ConsoleCommand("Suicide");
    }
    else if (Level.TimeSeconds > Deadline)
    {
        PC.ClientMessage(UnconfirmedMessage);
        Destroy();
    }
}

defaultproperties
{
    ConfirmTimeout=3.000000
    DeathTimeout=2.000000
    UnconfirmedMessage="Respawn on Apply: the server did not confirm the skin change; no respawn sent."
    RefusedMessage="Respawn on Apply: the server refused the respawn (too soon after spawning). Respawn manually to see the new skin."
    bHidden=True
}
