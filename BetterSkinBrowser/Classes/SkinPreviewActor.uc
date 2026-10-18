// Preview-only skeletal actor with a controllable return pose.
class SkinPreviewActor extends SpinnyWeap;

var name ReturnAnimation;
var name ActivePreviewAnimation;
var bool bLoopPreviewAnimation;
// Species preview (SkinPreviewPawn): plays the same animations as this actor.
var Actor Mirror;
// The model's rotation relative to the camera (Yaw 32768 faces it). Spin and
// drag change this; the browser derives the drawn world rotation from it
// every frame, so the model stays upright on screen whichever way the
// player's camera points.
var rotator PreviewRotation;

// SpinnyWeap spins the world Rotation; spin the camera-relative one instead.
function Tick(float Delta)
{
    PreviewRotation.Yaw += Delta * SpinRate / Level.TimeDilation;
}

// World rotation that shows PreviewRotation from a camera at CamRot.
static function rotator ViewRotation(rotator Local, rotator CamRot)
{
    local vector X, Y, Z;

    GetAxes(Local, X, Y, Z);
    return OrthoRotation(X >> CamRot, Y >> CamRot, Z >> CamRot);
}

function MirrorAnim(name Sequence, bool bLoop)
{
    if ((Mirror == None) || Mirror.bDeleteMe || !Mirror.HasAnim(Sequence))
        return;
    if (bLoop)
        Mirror.LoopAnim(Sequence, 1.0 / Level.TimeDilation, 0.20 / Level.TimeDilation);
    else
        Mirror.PlayAnim(Sequence, 1.0 / Level.TimeDilation, 0.20 / Level.TimeDilation);
}

function bool PlayPreviewAnimation(name Sequence, optional name NewReturnAnimation,
    optional bool bLoop)
{
    if ((Mesh == None) || !HasAnim(Sequence))
        return False;

    if (NewReturnAnimation != '')
        ReturnAnimation = NewReturnAnimation;

    ActivePreviewAnimation = Sequence;
    bLoopPreviewAnimation = bLoop;
    if (bLoop)
        LoopAnim(Sequence, 1.0 / Level.TimeDilation, 0.20 / Level.TimeDilation);
    else
        PlayAnim(Sequence, 1.0 / Level.TimeDilation, 0.20 / Level.TimeDilation);
    MirrorAnim(Sequence, bLoop);
    return True;
}

function bool PlayReturnAnimation(name Sequence)
{
    if ((Mesh == None) || !HasAnim(Sequence))
        return False;

    ReturnAnimation = Sequence;
    ActivePreviewAnimation = '';
    bLoopPreviewAnimation = False;
    LoopAnim(Sequence, 1.0 / Level.TimeDilation, 0.20 / Level.TimeDilation);
    MirrorAnim(Sequence, True);
    return True;
}

function StopPreviewAnimationLoop(name ReturnSequence)
{
    bLoopPreviewAnimation = False;
    ActivePreviewAnimation = '';
    PlayReturnAnimation(ReturnSequence);
}

event AnimEnd(int Channel)
{
    if (bLoopPreviewAnimation && (Mesh != None) && HasAnim(ActivePreviewAnimation))
    {
        LoopAnim(ActivePreviewAnimation, 1.0 / Level.TimeDilation,
            0.20 / Level.TimeDilation);
        MirrorAnim(ActivePreviewAnimation, True);
    }
    else if ((Mesh != None) && HasAnim(ReturnAnimation))
    {
        LoopAnim(ReturnAnimation, 1.0 / Level.TimeDilation, 0.20 / Level.TimeDilation);
        MirrorAnim(ReturnAnimation, True);
    }
}

defaultproperties
{
    ReturnAnimation="Idle_Rest"
    PreviewRotation=(Yaw=32768)
    bPlayRandomAnims=False
    // SpinnyWeap's stock removal loop increments instead of decrementing and
    // runs forever when this is False. Random preview animations are disabled,
    // so leaving crouches enabled does not affect our controlled animation list.
    bPlayCrouches=True
}
