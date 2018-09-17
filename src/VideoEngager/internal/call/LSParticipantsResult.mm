//
//  LSParticipantsResult.mm
//  leadsecure
//
//  Created by ivan shulev on 3/25/16.
//  Copyright © 2016 SoftAvail. All rights reserved.
//

#import "LSParticipantsResult.h"

#import "CallsContainer.h"
#import "IParticipantsResult.h"
#import "RefCountPtr.h"

@implementation LSParticipantsResult
{
    instac::RefCountPtr<instac::IParticipantsResult> _participantsResult;
}

- (instancetype)initWithModel:(const void*)modelPtr
{
    self = [super init];
    
    if (self == nil)
    {
        return nil;
    }
    
    ASSERT_AND_LOG(modelPtr != NULL, "ParticipantsResult Model pointer should not be NULL", 0);
    
    instac::RefCountPtr<instac::IParticipantsResult>* pParticipantsResult = (instac::RefCountPtr<instac::IParticipantsResult>*)modelPtr;
    _participantsResult = *pParticipantsResult;
    
    ASSERT_AND_LOG(_participantsResult != NULL, "ParticipantsResult Model should not be NULL", 0);
    
    return self;
}

- (void)fetch
{
    _participantsResult->fetch();
}

- (NSUInteger)itemsCount
{
    return _participantsResult->getItemsCount();
}

- (LSParticipant*)itemAtRow:(NSUInteger)rowIndex
{
    instac::RefCountPtr<instac::IParticipant> participant = _participantsResult->getItemAtRow(rowIndex);
    return [[LSParticipant alloc] initWithModel:&participant];
}

@end
