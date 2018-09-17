//
//  CallsContainer.m
//  leadsecure
//
//  Created by ivan shulev on 8/14/15.
//  Copyright (c) 2015 SoftAvail. All rights reserved.
//

#import "CallsContainer.h"

@implementation CallsContainer
{
    std::vector<instac::RefCountPtr<instac::ICall>> _videoCalls;
    std::vector<instac::RefCountPtr<instac::ICall>> _chatCalls;
}

- (instancetype)initWithParticipant:(instac::RefCountPtr<instac::IParticipant>)participant
{
    self = [super init];
    
    if (self == nil)
    {
        return nil;
    }
    
    _videoCalls = removeEndedCallsIfNotNeeded(participant->videoCalls());
    _chatCalls = removeEndedCallsIfNotNeeded(participant->chatCalls());
    
    return self;
}

- (BOOL)hasVideoCallInProgress
{
    if (![self hasVideoCall])
    {
        return NO;
    }
    
    return _videoCalls[0]->callState() == instac::CallStateAccepted;
}

- (BOOL)hasVideoCall
{
    return !_videoCalls.empty();
}

- (BOOL)hasChatCall
{
    return !_chatCalls.empty();
}

- (instac::RefCountPtr<instac::ICall>)videoCall
{
    if (![self hasVideoCall])
    {
        return NULL;
    }
    
    return _videoCalls[0];
}

- (instac::RefCountPtr<instac::ICall>)chatCall
{
    if (![self hasChatCall])
    {
        return NULL;
    }
    
    return _chatCalls[0];
}

static std::vector<instac::RefCountPtr<instac::ICall>> removeEndedCallsIfNotNeeded(std::vector<instac::RefCountPtr<instac::ICall>> calls)
{
    std::vector<instac::RefCountPtr<instac::ICall>> notEndedCalls;
    
    for (std::vector<instac::RefCountPtr<instac::ICall>>::iterator it = calls.begin(); it != calls.end(); it++)
    {
        if ((*it)->callState() != instac::CallStateEnded)
        {
            notEndedCalls.push_back(*it);
        }
    }
    
    if (notEndedCalls.empty())
    {
        return calls;
    }
    else
    {
        return notEndedCalls;
    }
}

@end
