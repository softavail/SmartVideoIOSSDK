//
//  LSOnHoldParticipantsResult.m
//  leadsecure
//
//  Created by ivan shulev on 3/28/16.
//  Copyright © 2016 SoftAvail. All rights reserved.
//

#import "LSOnHoldParticipantsResult.h"

#import "LSCall.h"

@implementation LSOnHoldParticipantsResult
{
    LSParticipantsResult* _participantsResult;
    NSMutableArray* _participantsWithCallOnHold;
}

- (instancetype)initWithParticipantsResult:(LSParticipantsResult*)participantsResult
{
    self = [super init];
    
    if (self == nil)
    {
        return nil;
    }
    
    _participantsResult = participantsResult;
    _participantsWithCallOnHold = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)fetch
{
    [_participantsResult fetch];
    NSUInteger itemsCount = [_participantsResult itemsCount];
    
    NSMutableArray* participantsWithCallOnHold = [[NSMutableArray alloc] init];
    
    for (NSUInteger j = 0; j < itemsCount; j++)
    {
        LSParticipant* participant = [_participantsResult itemAtRow:j];
        
        NSArray* videoCalls = [participant videoCalls];
        
        if (videoCalls.count > 0)
        {
            LSCall* videoCall = videoCalls[0];
            
            if (([videoCall callState] == LSCallStateAccepted) && ([videoCall isOnHold]))
            {
                [participantsWithCallOnHold addObject:participant];
            }
        }
    }
    
    _participantsWithCallOnHold = participantsWithCallOnHold;
}

- (NSUInteger)itemsCount
{
    return _participantsWithCallOnHold.count;
}

- (LSParticipant*)itemAtRow:(NSUInteger)rowIndex
{
    if (rowIndex >= _participantsWithCallOnHold.count)
    {
        return nil;
    }
    
    return _participantsWithCallOnHold[rowIndex];
}

@end
