//
//  LSParticipant.m
//  leadsecure
//
//  Created by ivan shulev on 9/12/15.
//  Copyright (c) 2015 SoftAvail. All rights reserved.
//

#import "LSParticipant.h"

#import "LSCall.h"
#import "IParticipant.h"

@implementation LSParticipant
{
    instac::RefCountPtr<instac::IParticipant> _participant;
}

- (id) initWithModel: (const void *) modelPtr
{
    if (nil != (self = [super init]))
    {
        ASSERT_AND_LOG(modelPtr != NULL, "Participant Model pointer should not be NULL", 0);
        
        if (modelPtr == NULL)
        {
            IMLogErr("Cannot instantiate LSParticipant, modelPtr is NULL.", 0);
            return nil;
        }
        
        instac::RefCountPtr<instac::IParticipant>* pParticipant = (instac::RefCountPtr<instac::IParticipant> *) modelPtr;
        _participant = *pParticipant;
        
        if (_participant == NULL)
        {
            IMLogErr("Cannot instantiate LSParticipant, _participant is NULL.", 0);
            return nil;
        }
        
        ASSERT_AND_LOG(_participant != NULL, "Participant Model should not be NULL", 0);
    }
    
    return self;
}

- (NSString*)identifier
{
    return OBJCStringA(_participant->getId());
}

- (NSString*)visitorId
{
    return self.identifier;
}

- (NSString*)callerType
{
    return OBJCStringA(_participant->callerType());
}

- (NSString*)email
{
    return OBJCStringA(_participant->email());
}

- (NSString*)image
{
    return OBJCStringA(_participant->image());
}

- (NSString*)name
{
    return OBJCStringA(_participant->name());
}

- (NSString*)referrer
{
    return OBJCStringA(_participant->referrer());
}

- (NSString*)telephone
{
    return OBJCStringA(_participant->telephone());
}

- (NSString*)title
{
    return OBJCStringA(_participant->title());
}

- (double)updatedAt
{
    return _participant->updatedAt();
}

- (double)createdAt
{
    return _participant->createdAt();
}

- (NSString*)location
{
    return OBJCStringA(_participant->location());
}

- (NSString*)url
{
    return OBJCStringA(_participant->url());
}

- (NSString*)user
{
    return OBJCStringA(_participant->user());
}

- (BOOL)isInactive
{
    return _participant->isInactive();
}

- (NSArray*)videoCalls
{
    return [self arrayFromCallsVector:_participant->videoCalls()];
}

- (NSArray*)chatCalls
{
    return [self arrayFromCallsVector:_participant->chatCalls()];
}

- (NSArray*)activeVideoCalls
{
    return [self arrayFromCallsVector:_participant->activeVideoCalls()];
}

- (NSArray*)activeChatCalls
{
    return [self arrayFromCallsVector:_participant->activeChatCalls()];
}

- (NSArray*)arrayFromCallsVector:(const std::vector<instac::RefCountPtr<instac::ICall>>)callsVector
{
    NSMutableArray* callsArray = [[NSMutableArray alloc] initWithCapacity:callsVector.size()];
    
    for (std::vector<instac::RefCountPtr<instac::ICall>>::const_iterator it = callsVector.begin();
         it != callsVector.end(); it++)
    {
        LSCall* call = [[LSCall alloc] initWithModel:&(*it)];
        [callsArray addObject:call];
    }
    
    return callsArray;
}

@end
