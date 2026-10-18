// In-game-look preview for characters with their own species class.
//
// The browser's SkinPreviewActor (a SpinnyWeap) keeps driving the preview's
// position, spin and animation. For a record whose species is not a stock
// XGame species, the browser also spawns this hidden, non-colliding pawn,
// runs the record's own species setup on it (Setup and SetTeamSkin: in-game
// skins, shaders, client-side effect drivers such as cloth or attached
// emitters), mirrors the SpinnyWeap's transform and animation onto it every
// frame, and draws it instead. Stock characters keep the plain SpinnyWeap.
//
// It has no controller, no collision and no physics, is never replicated,
// and is drawn only through Canvas.DrawActorClipped (see HideFromWorldView).
class SkinPreviewPawn extends xPawn;

// The SpinnyWeap drives animation; the pawn must not pick its own.
simulated event AnimEnd(int Channel)
{
}

simulated function PlayWaiting()
{
}

simulated function PostBeginPlay()
{
    // Skip xPawn's player shadow projector; the preview is drawn on a canvas.
    Super(Pawn).PostBeginPlay();
    SetPhysics(PHYS_None);
}

simulated function PostNetBeginPlay()
{
}

// Never take part in gameplay.
function TakeDamage(int Damage, Pawn InstigatedBy, vector HitLocation, vector Momentum,
    class<DamageType> DamageType)
{
}

event FellOutOfWorld(eKillZType KillType)
{
}

defaultproperties
{
    Physics=PHYS_None
    bCollideActors=False
    bBlockActors=False
    bBlockPlayers=False
    bCollideWorld=False
    bProjTarget=False
    // The browser sets Owner None, so the level render never draws it.
    bOnlyOwnerSee=True
    RemoteRole=ROLE_None
    bAlwaysRelevant=False
    bGameRelevant=True
    bDontPossess=True
    ControllerClass=None
    bActorShadows=False
    bNoTeamBeacon=True
    // The browser's SkinPreviewActor drives animation, not movement.
    bPhysicsAnimUpdate=False
    bAlwaysTick=True
    PrePivot=(Z=0.0)
    bUnlit=True
}
