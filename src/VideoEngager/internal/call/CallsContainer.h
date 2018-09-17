//
//  CallsContainer.h
//  leadsecure
//
//  Created by ivan shulev on 8/14/15.
//  Copyright (c) 2015 SoftAvail. All rights reserved.
//

#import "RefCountPtr.h"
#import "IParticipant.h"

@interface CallsContainer : NSObject

- (instancetype)initWithParticipant:(instac::RefCountPtr<instac::IParticipant>)participant;

- (BOOL)hasVideoCallInProgress;
- (BOOL)hasVideoCall;
- (BOOL)hasChatCall;

- (instac::RefCountPtr<instac::ICall>)videoCall;
- (instac::RefCountPtr<instac::ICall>)chatCall;

@end
