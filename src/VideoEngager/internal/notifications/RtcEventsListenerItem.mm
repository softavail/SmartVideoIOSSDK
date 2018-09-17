//
//  RtcEventsListenerItem.m
//  leadsecure
//
//  Created by ivan shulev on 1/13/16.
//  Copyright © 2016 SoftAvail. All rights reserved.
//

#import "RtcEventsListenerItem.h"

@implementation RtcEventsListenerItem
{
    NSArray* _eventActions;
    RtcEventCompletionHandler _completionHandler;
    NSTimer* _timer;
}

- (instancetype)initWithIdentifier:(NSString*)identifier
                      eventActions:(NSArray*)eventActions
                           timeout:(NSTimeInterval)timeout
                 completionHandler:(RtcEventCompletionHandler)completionHandler
{
    self = [super init];
    
    if (self == nil)
    {
        return nil;
    }
    
    _identifier = identifier;
    _eventActions = eventActions;
    _timeout = timeout;
    _completionHandler = completionHandler;
    
    return self;
}

- (void)dealloc
{
    [_timer invalidate];
    _timer = nil;
    
    _completionHandler = nil;
}

- (NSString*) printableEventActions
{
    NSMutableString* s = [NSMutableString new];
    
    for (NSNumber* eventActionNumber in _eventActions)
    {
        instac::IRTCManager::Action eventAction = (instac::IRTCManager::Action)[eventActionNumber unsignedIntegerValue];
        
        if (s.length)
            [s appendString: @", "];
        
        [s appendFormat: @"%lu", (unsigned long)[eventActionNumber unsignedIntegerValue]];
        
        switch (eventAction)
        {
            case instac::IRTCManager::ActionNone:
                break;
            case instac::IRTCManager::ActionDidEstablishCommunicationChannel:
                break;
            case instac::IRTCManager::ActionDidRestoreCommunicationChannel:
                break;
            case instac::IRTCManager::ActionDidCloseCommunicationChannel:
                break;
            case instac::IRTCManager::ActionCommunicationChannelDidFail:
                break;
            case instac::IRTCManager::ActionCommunicationChannelDidEnd:
                break;
            case instac::IRTCManager::ActionCommunicationChannelDidSuspend:
                break;
            case instac::IRTCManager::ActionDidReceiveLocalVideoTrack:
                break;
            case instac::IRTCManager::ActionDidReceiveRemoteVideoTrack:
                break;
            case instac::IRTCManager::ActionWillRemoveLocalVideoTrack:
                break;
            case instac::IRTCManager::ActionWillRemoveRemoteVideoTrack:
                break;
            case instac::IRTCManager::ActionDidSetVideoRoute:
                break;
            case instac::IRTCManager::ActionDidClosePeerConnection:
                break;
            case instac::IRTCManager::ActionStartCall:
                break;
            case instac::IRTCManager::ActionSetRemoteSdp:
                break;
            case instac::IRTCManager::ActionDidReceiveIceCandidate:
                break;
            case instac::IRTCManager::ActionCloseWebRTConnections:
                break;
            case instac::IRTCManager::ActionDidReceiveRemoteClose:
                break;
            case instac::IRTCManager::ActionDidReceiveVideoStarted:
                break;
            case instac::IRTCManager::ActionDidReceiveVideoStopped:
                break;
            case instac::IRTCManager::ActiondidReceiveCallMuted:
                break;
            case instac::IRTCManager::ActiondidReceiveCallUnmuted:
                break;
            case instac::IRTCManager::ActiondidReceiveCallHold:
                break;
            case instac::IRTCManager::ActiondidReceiveCallResume:
                break;
            case instac::IRTCManager::ActionDidReceiveCallAnswerTime:
                break;
            case instac::IRTCManager::ActionDidReceivePoorNetwork:
                break;
            case instac::IRTCManager::ActionDidReceiveClearPoorNetwork:
                break;
            case instac::IRTCManager::ActionIncomingCallRequest:
                break;
            case instac::IRTCManager::ActionOutgoingCallRequest:
                break;
            case instac::IRTCManager::ActionHangupCall:
                break;
            case instac::IRTCManager::ActionCallAnswered:
                break;
            case instac::IRTCManager::ActionCallConnected:
                break;
            case instac::IRTCManager::ActionCallEnded:
                break;
            case instac::IRTCManager::ActionCallInitiated:
                break;
            case instac::IRTCManager::ActionCallFailed:
                break;
            case instac::IRTCManager::ActionCallAcceptFailed:
                break;
            case instac::IRTCManager::ActionCallDeleted:
                break;
            case instac::IRTCManager::ActionCallDidSentReject:
                break;
            case instac::IRTCManager::ActionPickCallFailed:
                break;
            case instac::IRTCManager::ActionCallPickedupByOther:
                break;
            case instac::IRTCManager::ActionCallPickedupByMe:
                break;
            case instac::IRTCManager::ActionCallReConnected:
                break;
            case instac::IRTCManager::ActionDidSetCallOnHold:
                break;
            case instac::IRTCManager::ActionDidSetCallResumed:
                break;
            case instac::IRTCManager::ActionDidUpdateVisitor:
                break;
            case instac::IRTCManager::ActionDidDeleteVisitor:
                break;
            case instac::IRTCManager::ActionVisitorDidBecomeInactive:
                break;
            case instac::IRTCManager::ActionDidUpdateAgent:
                break;
            case instac::IRTCManager::ActionIncomingChatRequest:
                break;
            case instac::IRTCManager::ActionOutgoingChatRequest:
                break;
            case instac::IRTCManager::ActionChatAccepted:
                break;
            case instac::IRTCManager::ActionChatAcceptedByOther:
                break;
            case instac::IRTCManager::ActionChatEnded:
                break;
            case instac::IRTCManager::ActionDidEnqueueChatMessage:
                break;
            case instac::IRTCManager::ActionDidSendChatMessage:
                break;
            case instac::IRTCManager::ActionDidReceiveChatMessage:
                break;
            case instac::IRTCManager::ActionFloorFeaturesUpdated:
                break;
            case instac::IRTCManager::ActionParticipantAvailabilityChanged:
                break;
            case instac::IRTCManager::ActionStartPeerConnectionCall:
                break;
            case instac::IRTCManager::ActionQoSValueDidChange:
                break;
            case instac::IRTCManager::ActionDidReportCallAvailability:
                break;
            case instac::IRTCManager::ActionDidRequestPersonalInfo:
                break;
                
            default:
                break;
        }
    }

    return s;
}

- (void)startTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:_timeout
                                              target:self
                                            selector:@selector(timeoutReached:)
                                            userInfo:nil
                                             repeats:NO];
}

- (void)killTimer
{
    if ([_timer isValid])
        [_timer invalidate];
    
    _timer = nil;
}

- (BOOL)hasMatchingEventAction:(instac::IRTCManager::Action)eventActionToMatch
{
    NSUInteger eventActionToMatchInteger = (NSUInteger)eventActionToMatch;
    
    for (NSNumber* eventActionNumber in _eventActions)
    {
        NSUInteger eventActionInteger = [eventActionNumber unsignedIntegerValue];
        
        if (eventActionInteger == eventActionToMatchInteger)
        {
            return YES;
        }
    }
    
    return NO;
}

- (RtcEventCompletionHandler)completionHandler
{
    return _completionHandler;
}

- (void)timeoutReached:(NSTimer*)timer
{
    [_timer invalidate];
    _timer = nil;
    
    [self.delegate eventListenerItemDidTimeout:self];
}

@end
