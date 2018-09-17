//
//  ListParticipantsOnHoldOperation.m
//  leadsecure
//
//  Created by ivan shulev on 3/25/16.
//  Copyright © 2016 SoftAvail. All rights reserved.
//

#import "ListParticipantsOnHoldOperation.h"

#import "LSOnHoldParticipantsResult.h"
//#import "VideoCallManager.h"
#import "RtcEventsListener.h"


@implementation ListParticipantsOnHoldOperation
{
    NSString* _eventsListenerIdentifier;
}

- (void)dealloc
{
    IMLogDbg("Deallocating ... %s", self.description.UTF8String);
    
    [[RtcEventsListener sharedInstance] removeListenerWithIdentifier:_eventsListenerIdentifier];
}

- (void)perform
{
//    _participantsResult = [[LSOnHoldParticipantsResult alloc] initWithParticipantsResult:[[VideoCallManager instance] participantsResult]];
//    [_participantsResult fetch];
}

- (void)notifyOnChangesCompletionHandler:(void (^)(BOOL isSuccessful, BOOL* stopNotifyingOperationUsers))completionHandler
{
    _eventsListenerIdentifier =
        [[RtcEventsListener sharedInstance] notifyOnEventActions:@[@(instac::IRTCManager::ActionDidUpdateVisitor),
                                                                   @(instac::IRTCManager::ActionParticipantAvailabilityChanged),
                                                                   @(instac::IRTCManager::ActionDidDeleteVisitor),
                                                                   @(instac::IRTCManager::ActionDidSetCallOnHold),
                                                                   @(instac::IRTCManager::ActionDidSetCallResumed),
                                                                   @(instac::IRTCManager::ActionCallEnded)]
                                                         timeout:0
                                               completionHandler:^(instac::RTCEvent* event, BOOL isTimedOut, BOOL* stop)
     {
         IMLogDbg("event action %d", event->getAction());
         
         if (event->getAction() == instac::IRTCManager::ActionCallEnded)
         {
         }
         
         BOOL stopNotifyingOperationUsers = NO;
         completionHandler(YES, &stopNotifyingOperationUsers);
         
         if (stopNotifyingOperationUsers)
         {
             *stop = YES;
         }
     }];
}

@end
