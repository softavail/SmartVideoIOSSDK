//
//  VanityCellState.h
//  leadsecure
//
//  Created by ivan shulev on 8/14/15.
//  Copyright (c) 2015 SoftAvail. All rights reserved.
//

//#import "VanityRootTableViewCell.h"

#ifndef WITH_CORE_PARTICPANT_STATE

#import "CallsContainer.h"

typedef NS_ENUM ( NSInteger, CellCallState )
{
    CellCallStateInitial,
    CellCallStateInitialAgentAway,
    
    CellCallStateRinging,
    CellCallStateOnHold,
    CellCallStateInProgress,
    CellCallStateInProgressByOther,
    CellCallStateInProgressByOtherAgent,
    CellCallStateTransferWaiting,
    
    CellCallStateChatRinging,
    CellCallStateChatInProgress,
    CellCallStateChatInProgressByOther,
    
    CellCallStateVisitorInactive,
    
    CellCallStateVideoCalling
};

typedef NS_ENUM ( NSInteger, AvailabilityChangeStatus )
{
    AutoChange = 0,
    UserForceToON = 1,
    UserForceToOFF = 2,
};

@interface VanityCellState : NSObject
{
    instac::RefCountPtr<instac::IParticipant> _participant;
    CallsContainer* _callsContainer;
}

+ (CellCallState)determineStateForParticipant:(instac::RefCountPtr<instac::IParticipant>)participant
                               callsContainer:(CallsContainer*)callsContainer;

- (CellCallState)cellCallState;

- (void)setParticipant:(instac::RefCountPtr<instac::IParticipant>)participant
        callsContainer:(CallsContainer*)callsContainer;

- (BOOL)isInThisState;

@end

#endif
