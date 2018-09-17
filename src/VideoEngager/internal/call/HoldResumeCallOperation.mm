//
//  HoldResumeCallOperation.m
//  leadsecure
//
//  Created by ivan shulev on 3/28/16.
//  Copyright © 2016 SoftAvail. All rights reserved.
//

#import "HoldResumeCallOperation.h"

//#import "VideoCallManager.h"

@implementation HoldResumeCallOperation
{
    LSParticipant* _participant;
}

//- (instancetype)initWithParticipant:(LSParticipant*)participant
//{
//    self = [super init];
//
//    if (self == nil)
//    {
//        return nil;
//    }
//
//    _participant = participant;
//
//    return self;
//}
//
//- (void)perform
//{
//    VideoCallManager* videoCallManager = [VideoCallManager instance];
//
//    LSCall* callWithActivePeerConnection = [videoCallManager callWithActivePeerConnection];
//
//    if (callWithActivePeerConnection != nil)
//    {
//        [videoCallManager holdCall:[callWithActivePeerConnection callId]];
//    }
//
//    _callToBeResumed = nil;
//
//    NSArray* videoCalls = [_participant videoCalls];
//
//    if (videoCalls.count > 0)
//    {
//        _callToBeResumed = videoCalls[0];
//    }
//
//    if (_callToBeResumed)
//    {
//        [videoCallManager resumeCall:[_callToBeResumed callId]];
//    }
//}

@end
