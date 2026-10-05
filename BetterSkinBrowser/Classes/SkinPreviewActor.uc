// Preview-only skeletal actor with a controllable return pose.
class SkinPreviewActor extends SpinnyWeap;

var name ReturnAnimation;
var name ActivePreviewAnimation;
var bool bLoopPreviewAnimation;

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
        LoopAnim(ActivePreviewAnimation, 1.0 / Level.TimeDilation,
            0.20 / Level.TimeDilation);
    else if ((Mesh != None) && HasAnim(ReturnAnimation))
        LoopAnim(ReturnAnimation, 1.0 / Level.TimeDilation, 0.20 / Level.TimeDilation);
}

defaultproperties
{
    ReturnAnimation="Idle_Rest"
    bPlayRandomAnims=False
    // SpinnyWeap's stock removal loop increments instead of decrementing and
    // runs forever when this is False. Random preview animations are disabled,
    // so leaving crouches enabled does not affect our controlled animation list.
    bPlayCrouches=True
}
