//
//  VideoCall.m
//  leadsecure
//
//  Created by Angel Terziev on 8/12/15.
//  Copyright (c) 2015 SoftAvail. All rights reserved.
//

#import "LSCall.h"

#import "RefCountPtr.h"
#import "ICall.h"

@interface LSCall ()
{
    instac::RefCountPtr<instac::ICall> _call;
}

@end


@implementation LSCall

- (id) initWithModel: (const void *) modelPtr
{
    if (nil != (self = [super init]))
    {
        ASSERT_AND_LOG(modelPtr != NULL, "Call Model pointer should not be NULL", 0);
        
        if (modelPtr == NULL)
        {
            IMLogErr("Cannot instantiate LSCall, modelPtr is NULL.", 0);
            return nil;
        }
        
        instac::RefCountPtr<instac::ICall> *pcall = (instac::RefCountPtr<instac::ICall> *) modelPtr;
        _call = *pcall;
        
        ASSERT_AND_LOG(_call != NULL, "Call Model should not be NULL", 0);
        
        if (_call == NULL)
        {
            IMLogErr("Cannot instantiate LSCall, _call is NULL.", 0);
            return nil;
        }
    }
    
    return self;
}

- (NSString *) callId
{
    if (_call != NULL)
    {
        return OBJCStringA(_call->callId());
    }
    
    return @"";
}

- (NSString *) clientCallId
{
    if (_call != NULL)
    {
        return OBJCStringA(_call->clientCallId());
    }
    
    return @"";
}

- (NSString *) participantId
{
    if (_call != NULL)
    {
        return OBJCStringA(_call->participantId());
    }
    
    return @"";
}

- (LSCallType)callType
{
    switch (_call->callType())
    {
        case instac::CallTypeVideo:
            return LSCallTypeVideo;
        case instac::CallTypeChat:
            return LSCallTypeChat;
        case instac::CallTypeScreenShare:
            return LSCallTypeScreenShare;
        default:
            return LSCallTypeUnknown;
    }
    
    return LSCallTypeUnknown;
}

- (LSCallDirection)callDirection
{
    switch (_call->callDirection())
    {
        case instac::ICall::CallDirectionUnknown:
            return LSCallDirectionUnknown;
        case instac::ICall::CallDirectionIncoming:
            return LSCallDirectionIncoming;
        case instac::ICall::CallDirectionOutgoing:
            return LSCallDirectionOutgoing;
    }
}

- (LSCallState)callState
{
    switch (_call->callState())
    {
        case instac::CallStateRinging:
            return LSCallStateRinging;
        case instac::CallStateAccepted:
            return LSCallStateAccepted;
        case instac::CallStateEnded:
        default:
            return LSCAllStateEnded;
            break;
    }

    return LSCAllStateEnded;
}

- (BOOL)isOnHold
{
    return _call->isOnHold();
}

- (BOOL)isTransfer
{
    return _call->isTransfer();
}

- (BOOL)isConnectedToThisDevice
{
    return _call->isConnectedToThisDevice();
}

- (BOOL)isAnsweredByMe
{
    return _call->isAnsweredByMe();
}

- (NSString*)answeredByUser
{
    return OBJCStringA(_call->answeredByUser());
}

- (BOOL) isMuted
{
    if (_call != NULL)
    {
        return _call->isMuted();
    }
    
    return NO;
}

- (void) setMute: (BOOL) mute
{
    if (_call != NULL)
    {
        _call->setMuted(mute == YES ? true : false);
    }
}

- (NSTimeInterval)answerTime
{
    if (_call != NULL)
    {
        return _call->answerTime();
    }
    
    return 0;
}

- (NSString*)transferRefId
{
    if (_call != NULL)
    {
        return OBJCStringA(_call->transferRefId());
    }
    
    return @"";
}

@end
